function [patterns, targets, pattern_numbers] = Sequential_Feature_Selection(patterns, targets, params)

% Perform sequential feature selection
%
% Inputs:
%	train_patterns	- Input patterns
%	train_targets	- Input targets
%	params  		- Algorithm parameters: [Forward/Backward, Output dimension , classifier type, classifier params]
%
% Outputs:
%	patterns		- New patterns
%	targets			- New targets
%	pattern_numbers	- The numbers of the selected features
%
%See also Exhaustive_Feature_Selection, Information_based_selection, RELIEF, Genetic_Culling
%
%Example:
% load DHSchapter2
% [new_patterns, new_targets, pattern_numbers] = Sequential_Feature_Selection(patterns, targets, '[''Forward'', 2, ''LS'', []]');

[type, final_Ndims, Type, Params] = process_params(params);

Nfold        = 5;
[Dims, Nf]   = size(patterns);

if (final_Ndims < 2),
    error('The minimum feature number is two.')
end

if (final_Ndims > Dims)
    error('The output dimension is larger than the input dimension.');
end

Lf           = floor(Nf/Nfold)*Nfold;
Fin          = reshape([1:Lf], Lf/Nfold, Nfold)';
train_indices= zeros(Nfold,Lf/Nfold*(Nfold-1));
test_indices = zeros(Nfold,Lf/Nfold);
for i=1:Nfold,
    train_indices(i,:)  = reshape(Fin([1:i-1,i+1:Nfold],:),1,Lf*(Nfold-1)/Nfold);
    test_indices(i,:)   = Fin(i,:);
end

%Generate initial partitions
switch type
    case 'Forward'
        chosen_features = [];
        step            = 1;
        st              = 1;
    case 'Backward'
        chosen_features = 1:Dims;
        st              = Dims-1;
        step            = -1;
    otherwise
        error('Unknown type.')
end

%Start iterating
for i = st:step:final_Ndims,

    %Generate the groups to test
    if (strcmp(type, 'Forward'))
        %Generate groups with the old features plus any one of the
        %remaining features
        unchosen_features   = find(~ismember(1:Dims, chosen_features));
        groups              = [repmat(chosen_features, length(unchosen_features), 1), unchosen_features'];
    else
        %Generate groups of the old features removing any one of the
        %remaining features
        groups              = zeros(length(chosen_features), length(chosen_features)-1);
        for j = 1:length(chosen_features),
            groups(j, :)    = chosen_features([1:j-1, j+1:end]);
        end
    end
    
    %Get Nfold cross validation of error
    Ng    = size(groups, 1);
    score = zeros(Nfold, Ng);
    for j = 1:Ng,
        for k = 1:Nfold,
            cur_train_patterns  = patterns(groups(j,:),train_indices(k,:));
            cur_test_patterns   = patterns(groups(j,:),test_indices(k,:));
            
            %If data dimension is one, add a dummy dimension 
            if size(cur_train_patterns, 1) == 1, 
                cur_train_patterns  = [cur_train_patterns; zeros(1, size(cur_train_patterns, 2))];
                cur_test_patterns   = [cur_test_patterns; zeros(1, size(cur_test_patterns, 2))];
            end
            
            Ptargets            = feval(Type, cur_train_patterns, targets(train_indices(k,:)), cur_test_patterns, Params);
            score(k,j)          = 1 - mean(Ptargets ~= targets(test_indices(k,:)));
        end
    end

    %Find which feature group gave the best results
    ave_score               = mean(score);
    [max_score, best_group] = max(ave_score);
    chosen_features         = groups(best_group, :);

    if (i == final_Ndims)
        break
    end
end

%Assign the best pattern group to the output
patterns        = patterns(chosen_features,:);
pattern_numbers = chosen_features;

disp(['The best patterns are: ' num2str(chosen_features)])