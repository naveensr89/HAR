function [test_targets, coding_matrix] = multiclass(train_patterns, train_targets, test_patterns, params)

% Multiclass classification using two-class classification
%
% 	train_patterns	- Train patterns
%	train_targets	- Train targets
%   test_patterns   - Test  patterns
%	params  		- [Type of matrix, balance classes?, classification algorithm, algorithm parameters]
%                     The type of matrix can be:
%                       OAA - One against all
%                       all-pairs
%                       Hamming
%                     If the balance classes flag is set, the examples in the two-class
%                     problems will be replicated so as to form
%                     approximately balanced classes
%
%Outputs
%	test_targets	- Predicted targets
%   coding_matrix   - The coding matrix used
%
%See also multiclass_sbc
%
%Example:
% load multiclass_xor
% t = multiclass(patterns, targets, patterns, '[''OAA'', 0, ''LS'', []]');
% disp(mean(t == targets))

[matrix_type, balance, class_alg, class_alg_params] = process_params(params);

Uc  = unique(train_targets);
Nc  = length(Uc);

switch lower(matrix_type)
    case {'oaa', 'one against all'}
        coding_matrix = 2*eye(Nc)-1;
    case 'all-pairs'
        coding_matrix = zeros(Nc, Nc*(Nc-1)/2);
        count         = 0;
        for i = 1:Nc-1,
            for j = i+1:Nc,
                count   = count + 1;
                coding_matrix(i, count) = 1;
                coding_matrix(j, count) = -1;
            end
        end        
    case 'hamming'
        coding_matrix                   = ones(Nc, 2*Nc-1);
        coding_matrix(1:Nc, 1:Nc)       = eye(Nc);
        coding_matrix(2:end, Nc+1:end)  = ~eye(Nc-1);
        coding_matrix                   = 2*coding_matrix-1;
    otherwise
        error('Unknown coding matrix');
end

output = zeros(size(coding_matrix, 2), size(test_patterns,2));
for i = 1:size(coding_matrix, 2)
    %Build a two-class classifier
    labels0     = find(ismember(train_targets, Uc(find(coding_matrix(:,i)==-1))));
    labels1     = find(ismember(train_targets, Uc(find(coding_matrix(:,i)==1))));
    N0          = length(labels0);
    N1          = length(labels1);
    
    if ~isempty(labels0) & ~isempty(labels1)
        if balance
            if (N0 < N1)
                %Replicate class 0
                if N1-N0 < N0,
                    new_in  = randperm(N0);
                    new_in  = new_in(1:N1-N0);
                else
                    if N0 > 1
                        new_in  = rem(randperm(N1-N0), N0-1)+1;
                    else
                        new_in  = ones(1, N0);
                    end
                end
                labels0 = [labels0, labels0(new_in)];
            else
                %Replicate class 1
                if N0-N1 < N1,
                    new_in  = randperm(N1);
                    new_in  = new_in(1:N0-N1);
                else
                    if N1 > 1
                        new_in  = rem(randperm(N0-N1), N1-1)+1;
                    else
                        new_in  = ones(1, N0-N1);
                    end
                end
                labels1 = [labels1, labels1(new_in)];
            end
        end
        
        new_targets     = [zeros(1, length(labels0)), ones(1, length(labels1))];
        new_patterns    = train_patterns(:, [labels0, labels1]);
        
        %Mix the new data
        in              = randperm(size(new_patterns, 2));
        new_targets     = new_targets(in);
        new_patterns    = new_patterns(:, in);

        if strcmp(class_alg,'Perceptron')
            fprintf('perceptron class %d ',i);
        end
        output(i,:)     = feval(class_alg, new_patterns, new_targets, test_patterns, class_alg_params);
        if length(unique(output(i,:))) == 2,
            output(i, :) = output(i, :)*2-1;
        end
        
    elseif isempty(labels0)
        output(i, :)    = 1;
    else
        output(i, :)    = -1;
    end
end

%For each pattern in the test patterns, find the closest coding matrix vector
test_targets    = zeros(1,size(test_patterns, 2));
apriory_dist    = hist(train_targets, Uc);
for i = 1:length(test_targets)
    if ~strcmp(lower(matrix_type), 'all-pairs')
        dist            = sum((coding_matrix - ones(size(coding_matrix,1),1)*output(:,i)')'.^2);
        [m, closest]    = min(dist);
        test_targets(i) = Uc(closest);
    else
        [x, y]           = find(coding_matrix==ones(size(coding_matrix,1),1)*sign(output(:,i))');
        %dist            = (ones(size(coding_matrix,1),1)*output(:,i)').*coding_matrix;
        %[x,y]           = ind2sub(size(dist), find(dist~=0));
        %sums            = zeros(1, Nc);
        %for j = 1:Nc,
        %    sums(j) = sum(x==j);
        %end
        sums            = hist(x, Uc);
        in              = find(sums  == max(sums));
        if length(in) > 1,
            in  = in(find(apriory_dist(in) == max(apriory_dist(in))));
            if (length(in) > 1)
                in  = in(randperm(length(in)));
                in  = in(1);
            end
        end
        test_targets(i) = Uc(in);
    end
end