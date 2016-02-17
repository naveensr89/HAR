function [patterns, targets, label] = kernel_k_means(train_patterns, train_targets, params, plot_on)

%Reduce the number of data points using the kernel k-means algorithm
%Inputs:
%	train_patterns	- Input patterns
%	train_targets	- Input targets
%	params			- [Number of output data points, Kernel type, kernel parameter]
%                     Kernel can be one of: Gauss, RBF (Same as Gauss), Poly, Sigmoid, or Linear
%                     The kernel parameters are:
%                       RBF kernel  - Gaussian width (One parameter)
%                       Poly kernel - Polynomial degree
%                       Sigmoid     - The slope and constant of the sigmoid (in the format [1 2], with no separating commas)
%					    Linear		- None needed
%   plot_on         - Plot stages of the algorithm
%
%Outputs
%	patterns		- New patterns
%	targets			- New targets
%	label			- The labels given for each of the original patterns
%
%See also k_means, fuzzy_k_means, spectral_k_means
%
%Example:
% load clouds
% [new_patterns, new_targets, labels] = kernel_k_means(patterns, targets, '[10, ''RBF'', 0.5]');
% disp(new_patterns)

if (nargin < 4),
    plot_on = 0;
end

%Get parameters
[Nmu, kernel, kernel_params] = process_params(params);

max_iter= 1000;
[D,L]	= size(train_patterns);
dist	= zeros(Nmu,L);
label   = zeros(1,L);

%Kernelize the training patterns
y       = compute_kernel_matrix(train_patterns, train_patterns, kernel, kernel_params);

%Use Nmu random points as the start points for the algorithm
in      = randperm(L);
mu      = train_patterns(:, in(1:Nmu));

%Start iterating
iter               = 0;
assignment_changed = 1;
while assignment_changed & (iter < max_iter)
    old_label = label;
    iter      = iter + 1;

    %Find the distance of each cluster center from each data point
    y_mu    = compute_kernel_matrix(mu, mu, kernel, kernel_params);
    y_cross = compute_kernel_matrix(mu, train_patterns, kernel, kernel_params);
    dist    = ones(Nmu, 1)*diag(y)' - 2*y_cross + diag(y_mu)*ones(1,L);

    %Label the points
    [m, label] = min(dist);

    %Recompute the mu's
    for i = 1:Nmu,
        in_pat    = find(label == i);
        switch length(in_pat)
            case 0,
                mu(:, i)  = zeros(D, 1);
            case 1,
                mu(:, i)  = train_patterns(:, in_pat);
            otherwise
                mu(:,i) = mean(train_patterns(:,in_pat)')';
        end
    end

    %Plot the centers during the process
    plot_process(mu, plot_on)

    assignment_changed = any(old_label ~= label);
end

%Classify the patterns
targets   = zeros(1,Nmu);
Uc        = unique(train_targets);
for i = 1:Nmu,
    if (length(unique(train_targets(:,find(label == i)))) == 1)
        targets(i) = unique(train_targets(:,find(label == i)));
    else
        N = hist(train_targets(:,find(label == i)), Uc);
        if (~isempty(N))
            [m, max_l] = max(N);
            targets(i) = Uc(max_l);
        end
    end
end

patterns = mu;
