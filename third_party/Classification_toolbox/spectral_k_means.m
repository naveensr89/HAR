function [patterns, targets, label] = spectral_k_means(train_patterns, train_targets, params, plot_on)

%Reduce the number of data points using the spectral k-means algorithm
%The k largest eigenvectors of the kernel matrix of examples are clustered
%using k-means
%
%Inputs:
%	train_patterns	- Input patterns
%	train_targets	- Input targets
%	params			- [Number of output data points, Kernel type, kernel parameter, cluster_type]
%                     Kernel can be one of: Gauss, RBF (Same as Gauss), Poly, Sigmoid, or Linear
%                     The kernel parameters are:
%                       RBF kernel  - Gaussian width (One parameter)
%                       Poly kernel - Polynomial degree
%                       Sigmoid     - The slope and constant of the sigmoid (in the format [1 2], with no separating commas)
%					    Linear		- None needed                   
%                     Clustering type can be Multicut (Meila-Shi) or NJW (Ng, Jordan, Weiss)
%   plot_on         - Unused
%
%Outputs
%	patterns		- New patterns
%	targets			- New targets
%	label			- The labels given for each of the original patterns
%
%See also k_means, fuzzy_k_means, kernel_k_means
%
%Example:
% load clouds
% [new_patterns, new_targets, labels] = spectral_k_means(patterns, targets, '[4, ''RBF'', 0.5, ''Multicut'']');
% disp(new_patterns)

if (nargin < 4),
    plot_on = 0;
end

%Get parameters
[Nmu, kernel, kernel_params, clustering_type] = process_params(params);

max_iter   = 1000;
[Ndim, Nf] = size(train_patterns);
label      = zeros(1,Nf);

%Kernelize the training patterns
y       = compute_kernel_matrix(train_patterns, train_patterns, kernel, kernel_params);
D       = diag(sum(y));

switch lower(clustering_type)
    case 'multicut'
        y       = inv(D)*y;
        [v, d]  = eig(y);
        kernel_patterns = v(end-Nmu+1:end, :);
    case 'njw'
        sqD             = sqrtm(D);
        L               = sqD*y*sqD;
        [v, d]          = eig(L);
        kernel_patterns = v(end-Nmu+1:end, :);
        kernel_patterns = kernel_patterns ./ (sum(kernel_patterns'.^2)'*ones(1, Nf));
    otherwise
        error('Unknown clustering type');
end

[p, t, label] = k_means(kernel_patterns, train_targets, Nmu, []);

Ul      = unique(label);
Uc      = unique(train_targets);
patterns= zeros(Ndim, length(Ul));
targets = zeros(1,    length(Ul));
for i = 1:length(Ul)
    in              = find(label == Ul(i));
    patterns(:, i)  = mean(train_patterns(:, in)')';
    if length(unique(train_targets(in))) == 1,
        targets(i)  = train_targets(in(1));
    else
        N           = hist(train_targets(in), Uc);
        [m, max_l]  = max(N);
        targets(:, i)= Uc(max_l(1));
    end
end    
