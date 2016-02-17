function [patterns, targets, pattern_numbers, weights] = RELIEF(patterns, targets, params)

% Perform sequential feature selection
%
% Inputs:
%	train_patterns	- Input patterns
%	train_targets	- Input targets
%	params  		- Algorithm parameters: [Output dimension , Maximum iterations with no change]
%
% Outputs:
%	patterns		- New patterns
%	targets			- New targets
%	pattern_numbers	- The numbers of the selected features
%   weights         - The weights of all the features
%
%See also Exhaustive_Feature_Selection, Sequential_Feature_Selection, Information_based_selection, Genetic_Culling
%
%Example:
% load DHSchapter2
% [new_patterns, new_targets, pattern_numbers, weights] = RELIEF(patterns, targets, [2 100]);

[final_Ndims, MaxIterNoChange] = process_params(params);

IterNoChange    = 0;
[Dims, Nf]      = size(patterns);
weights         = zeros(Dims,1);
MaxIter         = 10*Nf;

if (final_Ndims > Dims)
    error('The output dimension is larger than the input dimension.');
end
if (length(unique(targets)) < 2)
    error('At least two classes are needed')
end

for i = 1:MaxIter,
    %Choose a random test sample
    test_sample = max(1, min(Nf, round(rand(1)*Nf)));
    
    %Find the distance to all samples
    dist        = sum((patterns(:, test_sample)*ones(1,Nf) - patterns).^2);
    dist(test_sample)   = 1e200;
    
    %Find the nearest sample from the same class
    [m, Inh]    = min(dist + (targets ~= targets(test_sample)).*1e200);

    %Find the nearest sample from the other classes
    [m, Inm]    = min(dist + (targets == targets(test_sample)).*1e200);
    
    %Update the weights
    d_weights   = abs(patterns(:, test_sample) - patterns(:, Inm)) - abs(patterns(:, test_sample) - patterns(:, Inh));
    weights     = weights + d_weights;
    
    if (sum(d_weights) < 1e-3)
        IterNoChange    = IterNoChange + 1;
    else
        IterNoChange    = 0;
    end
    
    if (IterNoChange >= MaxIterNoChange)
        break
    end
end

%Find largest weights
[m, I]          = sort(weights, 'descend');
pattern_numbers = I(1:final_Ndims);
patterns        = patterns(pattern_numbers, :);
