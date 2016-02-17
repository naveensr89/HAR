function test_targets = Perceptron_Voted(train_patterns, train_targets, test_patterns, params)

% Classify using the Voted Perceptron algorithm
% Inputs:
% 	train_patterns	- Train patterns
%	train_targets	- Train targets
%   test_patterns   - Test  patterns
%	Params          - [NumberOfPerceptrons, Kernel method (Linear, Polynomial, Gaussian), Kernel params]
%                     The kernel parameters are:
%			          Linear - none, Polinomial - power, Gaussian - sigma
%
% Outputs
%	test_targets	- Predicted targets
%
% NOTE: Works for only two classes
% Coded by: Igor Makienko and Victor Yosef
%
%See also LS, Perceptron, Perceptron_Batch, Perceptron_BVI, Perceptron_FM, Perceptron_VIM
%
%Example:
% load clouds
% t = Perceptron_Voted(patterns, targets, patterns, '[7,''Linear'',0.5]');
% disp(mean(t == targets))

[NumberOfPerceptrons, method, alg_param] = process_params(params);

[c, n]		   = size(train_patterns);
train_patterns = [train_patterns ; ones(1,n)];
train_one      = find(train_targets == 1);
train_zero     = find(train_targets == 0);

%Preprocessing
processed_patterns = train_patterns;
processed_patterns(:,train_zero) = -processed_patterns(:,train_zero);

%Initial weights for Linear case:
w_percept  = rand(c+1,NumberOfPerceptrons);

%Initial alphas for kernel method:
alpha = rand(n,NumberOfPerceptrons);

%Initial permutation matrix for kernel case;
kernel = compute_kernel_matrix(processed_patterns, processed_patterns, method, alg_param);

%Train targets for kernels' case [-1 1] :
t = 2 * train_targets - 1;
%Step for kernel case :
etta  = 1;
%Initial success vector:
w_sucesses = ones(NumberOfPerceptrons,1);

correct_classified = 0;
iter			   = 0;
max_iter		   = 500;

while (iter < max_iter)
    iter 		= iter + 1;
    indice 	= 1 + floor(rand(1)*n);

    InnerProduct = kernel(indice,:) * ((alpha'.*(ones(size(alpha,2),1)*t)))' ;     
    NegInnerProduct = (InnerProduct<=0)';
    PosInnerProduct = (InnerProduct>0)';
    w_sucesses = ones(size(w_sucesses)) + w_sucesses.*PosInnerProduct;
    alpha(indice,find(NegInnerProduct)) = alpha(indice,find(NegInnerProduct))...
        + etta * ones(1,sum(NegInnerProduct));
end

if (iter == max_iter),
    disp(['Maximum iteration (' num2str(max_iter) ') reached'])
end

%Classify test patterns
N               = size(test_patterns, 2);
test_targets    = zeros(1, N);
test_patterns(c+1, :) = ones(1, N);

kernel = compute_kernel_matrix(processed_patterns, test_patterns, method, alg_param);
for i = 1:NumberOfPerceptrons
    temp = (alpha(:,i)'.* t) * kernel;
    temp = 2*(temp>0)-1;
    test_targets = test_targets + w_sucesses(i) * temp;
end

test_targets = test_targets > 0;

disp(['Iterated ' num2str(iter) ' times.'])



