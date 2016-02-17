function [test_targets, w] = logistic_regression (train_patterns, train_targets, test_patterns, lambda)

% Classify using the regularized logistic regression algorithm (Nigam et al., 1999). The optimization
% algorithm is Newton
% 	train_patterns  - Train patterns
%	train_targets	- Train targets
%   test_patterns   - Test patterns
%	lambda          - Regularization constant
%
% Outputs
%	test_targets	- Predicted targets
%	w			    - Weights of the predictor
%
%See also Perceptron, LMS, LS
%
%Example:
% load clouds
% t = logistic_regression(patterns, targets, patterns, .5);
% disp(mean(t == targets))

convergence_th = 1e-4;
iter_disp      = 10;

train_patterns(end+1, :) = ones(1, size(train_patterns, 2));

if all(ismember(train_targets, [0 1]))
    train_targets = 2*train_targets-1;
end

[D, N]  = size(train_patterns);
w       = randn(1, D);
old_w   = ones(1, D);;
iter    = 0;

X       = -train_patterns.*(ones(D,1)*train_targets);

while norm(w - old_w)/sqrt(norm(w)*norm(old_w)) > convergence_th
    old_w   = w;
    iter    = iter + 1;
    
    for i = 1:D,
        t       = logit(w, X);
        g       = X(i, :)*t' - lambda*w(i);
        h       = (X(i, :).^2)*(t.*(1-t))' + lambda;
        delta   = g/h;
        w(i)    = w(i) + delta;
    end
    
    if (rem(iter, iter_disp) == 0)
        disp(norm(w - old_w)/sqrt(norm(w)*norm(old_w)))
    end
end

test_targets = logit(w, [test_patterns; ones(1, size(test_patterns, 2))]);
if all(ismember(train_targets, [-1 1]))
    test_targets = test_targets > 0.5;
end

%END
function p = logit (w, x)

p = 1 ./ (1 + exp(w*x));
