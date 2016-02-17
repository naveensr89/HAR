function [test_targets, weak_targets] = Bagging (train_patterns, train_targets, test_patterns, params)

% Classify using the bagging algorithm
% Inputs:
% 	train_patterns  - Train patterns
%	train_targets	- Train targets
%   test_patterns   - Test patterns
%   params          - [N, frac, weak learner, weak learner params]
%                       N    - The number of weak learners
%                       frac - The fraction of patterns that will be used
%                              for each learner
%
% Outputs
%	test_targets	- Predicted targets
%
%See also Ada_Boost
%
%Example:
% load clouds
% [test_targets, weak_targets] = Bagging (patterns, targets, patterns,'[100, 0.2, ''LS'', []]');
% disp(mean(test_targets == targets))

[Nweak, frac, learner_type, learner_params] = process_params(params);

if (frac >= 1)
    error('Fraction of training patterns should be smaller than 1')
end

Ut          = unique(train_targets);
Ntrain      = size(train_patterns, 2);
weak_targets= zeros(Nweak, size(test_patterns, 2));

%Train weak classifiers
for i = 1:Nweak,
    in                  = randperm(Ntrain);
    in                  = in(1:max(1, floor(frac*Ntrain)));
    weak_targets(i, :)  = feval(learner_type, train_patterns(:, in), train_targets(in), test_patterns, learner_params);
end

%Do majority voting
target_count    = zeros(length(Ut), size(test_patterns, 2));
for i = 1:length(Ut)
    target_count(i, :) = sum(weak_targets == Ut(i));
end
[m, I]          = max(target_count);
test_targets    = Ut(I);
    
    
