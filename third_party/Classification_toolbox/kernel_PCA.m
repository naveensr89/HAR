function [new_patterns, targets] = kernel_PCA(patterns, targets, params)

% Reshape the data points using kernel principal component analysis
% 
% Inputs:
%	train_patterns	- Input patterns
%	train_targets	- Input targets
%	params	        - [output dimension, kernel, kernel parameter]
%                     Kernel can be one of: Gauss, RBF (Same as Gauss), Poly, Sigmoid, or Linear
%                     The kernel parameters are:
%                       RBF kernel  - Gaussian width (One parameter)
%                       Poly kernel - Polynomial degree
%                       Sigmoid     - The slope and constant of the sigmoid (in the format [1 2], with no separating commas)
%					    Linear		- None needed
%
% Outputs
%	patterns		- New patterns
%	targets			- New targets
%
%See also FishersLinearDiscriminant, NMF, PCA
%
%Example:
% load clouds
% [new_patterns, new_targets] = kernel_PCA(patterns(:,1:500), targets(1:500), '[2, ''RBF'', 10]');
% plot_scatter(new_patterns, new_targets)

[Dim, Nf]       = size(patterns);

%Get parameters
[dimension, kernel, ker_param] = process_params(params);

%Transform the input patterns
K   = compute_kernel_matrix(patterns, patterns, kernel, ker_param);

% Find eigenvalues of the kernel matrix
[v, e]          = eig(K);
new_patterns    = v(:, end-dimension+1:end)';

