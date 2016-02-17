function [output1, output2, output3] = classification_system (train_patterns, train_targets, test_patterns, varargin)

% Create a classifier system
%
% Inputs:
% 	train_patterns      - Train patterns
%	train_targets       - Train targets
%   test_patterns       - Test  patterns
%   system components   - A list of pairs of algorithm and its parameter vector
%
% Outputs:
%   test_patterns       - Test patterns (if exist)
%   test_targets        - Test targets  (if exist)
%   system_parameters   - An array of the same size as the number of
%                         algorithms with the returned data from these algorithms
%
% Example:
%   load clouds
%   t = classification_system(patterns, targets, patterns, 'k_means', 40, 'SVM', '[''RBF'', 1, ''Quadprog'', 5]');
%   mean(t == targets)

if (rem(length(varargin), 2) ~= 0),
    error('Each algorithm should have a vector of parameters');
end

last_is_classification      = 0;

% Read the types of available algorithms
temp                        = read_algorithms('Classification.txt');
classification_algorithms   = lower({temp.Name});
temp                        = read_algorithms('Preprocessing.txt');
preprocessing_algorithms    = lower({temp.Name});
temp                        = read_algorithms('Feature_selection.txt');
feature_selection_algorithms= lower({temp.Name});

cur_train_patterns          = train_patterns;
cur_test_patterns           = test_patterns;
cur_train_targets           = train_targets;

% Loop over the algorithms and execute them
for i = 1:length(varargin)/2,
    cur_alg     = lower(varargin{2*i-1});
    cur_params  = varargin{2*i};
    disp(['Executing ' cur_alg])
    
    %Find if this is a supervised or an unsupervised algorithm
    if ~isempty(strmatch(cur_alg, classification_algorithms, 'exact')),
        %Supervised

        %Prepare function call
        output_arguments    = get_function_outputs(cur_alg);
        st                  = '[cur_test_targets, ';
        for j = 2:length(output_arguments)
            st  = [st, 'system_parameters(i).' output_arguments{j}, ', '];
        end
        st  = [st(1:end-2) '] = ' cur_alg '(cur_train_patterns, cur_train_targets, cur_test_patterns, cur_params);'];

        %Run the function
        eval(st); 
        
        last_is_classification = (i == length(varargin)/2);            
    else
        %Unsupervised
        switch cur_alg
            case 'none'
       
            case {'pca', 'whitening_transform'}
                [cur_train_patterns, cur_train_targets, W, m]   = feval(cur_alg, train_patterns, train_targets, cur_params); 
                cur_test_patterns                               = W*(test_patterns-m*ones(1,size(test_patterns,2)));      
                system_parameters(i).W = W;
                system_parameters(i).m = m;
       
            case {'ica'}
                [cur_train_patterns, cur_train_targets, W, aW, m]   = feval(cur_alg, train_patterns, train_targets, cur_params); 
                cur_test_patterns                                   = W*(test_patterns-m*ones(1,size(test_patterns,2)));      
                system_parameters(i).W = W;
                system_parameters(i).aW= aW;
                system_parameters(i).m = m;
       
            case 'scaling_transform'
                [cur_train_patterns, cur_train_targets, w, m]   = feval(cur_alg, train_patterns, train_targets, cur_params); 
                cur_test_patterns                               =(cur_test_patterns-m*ones(1,size(cur_test_patterns,2)))./(w * ones(1,size(cur_test_patterns,2)));
                system_parameters(i).W = w;
                system_parameters(i).m = m;
       
            case 'fisherslineardiscriminant'
                [cur_train_patterns, cur_train_targets, w]      = feval(cur_alg, train_patterns, train_targets, cur_params); 
                cur_test_patterns                               = w'*cur_test_patterns;
                system_parameters(i).W = w;

            otherwise
                %Prepare function call
                output_arguments    = get_function_outputs(cur_alg);
                st                  = '[cur_train_patterns, cur_train_targets, ';
                for j = 3:length(output_arguments)
                    st  = [st, 'system_parameters(i).' output_arguments{j}, ', '];
                end
                st  = [st(1:end-2) '] = ' cur_alg '(cur_train_patterns, cur_train_targets, cur_params);'];
                                
                %Run the function
                eval(st);
                
                %If this is a feature selection algorithm, try to apply it
                %to the test patterns as well
                if ~isempty(strmatch(cur_alg, feature_selection_algorithms, 'exact')) & (length(output_arguments) > 2),
                    cur_test_patterns   = eval(['cur_test_patterns(system_parameters(i).', output_arguments{3}, ', :)']);                    
                end                
        end        
    end
end

if last_is_classification
    output1 = cur_test_targets;
    output2 = system_parameters;
else
    output1 = cur_test_patterns;
    output2 = cur_test_targets;
    output3 = system_parameters;
end
