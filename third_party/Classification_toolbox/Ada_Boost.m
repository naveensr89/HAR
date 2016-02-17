function [test_targets, E, train_margin, test_margin, train_error] = ada_boost(train_patterns, train_targets, test_patterns, params)

% Classify using the AdaBoost algorithm
% Inputs:
% 	train_patterns	- Train patterns
%	train_targets	- Train targets
%   test_patterns   - Test  patterns
%	Params          - [NumberOfIterations, Weak Learner Type, Learner's parameters]
%
% Outputs
%	test_targets	- Predicted targets
%   E               - Errors through the iterations
%   train_margin    - The margin to the training patterns as a function of
%                     the iteration number
%   test_margin     - The (estimated) margin to the test patterns as a function of
%                     the iteration number
%
% NOTE: Suitable for only two classes
%
%See also SVM, Perceptron_Voted
%
%Example:
% load clouds
% t = Ada_Boost(patterns, targets, patterns, '[100,''Stumps'',[]]');
% disp(mean(t == targets))

[k_max, weak_learner, alg_param] = process_params(params);

[Ni,M]			= size(train_patterns);
W			 	= ones(1,M)/M;
IterDisp		= 10;

full_patterns   = [train_patterns, test_patterns];
test_targets    = zeros(1, size(test_patterns,2));
predicted_train_targets = zeros(1, M);

train_margin    = zeros(1, k_max);
test_margin     = zeros(1, k_max);
train_error     = zeros(1, k_max);
E               = zeros(1, k_max);

%Do the AdaBoosting
for k = 1:k_max,
    if (k > 1),
        %Train weak learner Ck using the data sampled according to W:
        %...so sample the data according to W
        randnum = rand(1,M);
        cW	    = cumsum(W);
        
        %The following line is a quick way to do the commented code
        indices = max(1, min(M, round(interp1q(cW', [1:M]', randnum'))));
        
%         indices = zeros(1,M);
%         for i = 1:M,
%             %Find which bin the random number falls into
%             loc = max(find(randnum(i) > cW))+1;
%             if isempty(loc)
%                 indices(i) = 1;
%             else
%                 indices(i) = loc;
%             end
%         end
    else
        indices = 1:M;
    end
    
    %...and now train the classifier
    Ck 	= feval(weak_learner, train_patterns(:, indices), train_targets(indices), full_patterns, alg_param);

    %Ek <- Training error of Ck
    E(k) = mean(Ck(indices) ~= train_targets(indices));
    
    if (E(k) == 0),
        break
    end

    %alpha_k <- 1/2*ln(1-Ek)/Ek)
    alpha_k = 0.5*log((1-E(k))/E(k));

    %W_k+1 = W_k/Z*exp(+/-alpha)
    W  = W.*exp(alpha_k*(xor(Ck(1:M),train_targets)*2-1));
    %You could also use the equivalent statement: W  = W.*exp(-alpha_k.*(2*Ck(1:M)-1).*(2*train_targets-1));
    
    W  = W./sum(W);

    %Update the test targets
    test_targets    = test_targets + alpha_k*(2*Ck(M+1:end)-1);

    %Compute margin
    predicted_train_targets = predicted_train_targets + alpha_k*(2*Ck(1:M)-1);    
    test_margin(k)          = mean(abs(test_targets));
    train_margin(k)         = mean(abs(predicted_train_targets));
    train_error(k)          = mean((predicted_train_targets>0) ~= train_targets);
    
    if (k/IterDisp == floor(k/IterDisp)),
        disp(['Completed ' num2str(k) ' boosting iterations'])
    end

end

if (k < k_max)
    %Finished before maximum iteration reached
    E               = E(1:k);
    train_error     = train_error(1:k);
    train_margin    = train_margin(1:k);
    test_margin     = test_margin(1:k);
end

%Collapse labels
test_targets = test_targets > 0;