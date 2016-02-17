function [cluster_patterns, cluster_labels, pattern_labels, U, V] = NMF (patterns, targets, Nclusters, plot_on)

% Perform non-negative matrix factorization
% See D. D. Lee and H. S. Seung. Algorithms for non-negative matrix factorization. In Advances in
% Neural Information Processing Systems, volume 13, pages 556–562, 2001.
%
%Inputs:
%	train_patterns	- Input patterns
%	train_targets	- Input targets
%	Nclusters		- Number of output data points
%   plot_on         - Plot stages of the algorithm
%
%Outputs
%	patterns		- New patterns
%	targets			- New targets
%	label			- The labels given for each of the original patterns
%   U, V            - Matrix factorization results
%
%See also FishersLinearDiscriminant, PCA
%
%Example:
% load clouds
% [new_patterns, new_targets] = NMF(patterns, targets, 4);
% plot_scatter(new_patterns, new_targets)

th      = 0.01;
max_iter= 100;
if (nargin < 4)
    plot_on = 0;
end

[m, n]  = size(patterns);
U       = rand(m, Nclusters);
V       = rand(n, Nclusters);
iter    = 0;

%Normalize the patterns
s       = sqrt(sum(patterns.^2));
patterns= patterns ./ (ones(m, 1) * (s + (s==0)));

%Start
obj_fun     = 0.5*sum(sum((patterns-U*V').^2));
old_obj_fun = 0;
while ((iter == 0) | (old_obj_fun - obj_fun > th)) & (iter < max_iter)
    old_U   = U;
    old_V   = V;
    iter    = iter + 1;

    XV      = patterns*V;
    UVV     = U*V'*V;
    XU      = patterns'*U;
    VUU     = V*U'*U;

    U       = U.*XV./UVV;
    V       = V.*XU./(VUU + (VUU==0));

    U       = U ./ (ones(m, 1) * sqrt(sum(U.^2)));
    V       = V ./ (ones(n, 1) * sqrt(sum(V.^2)));

    old_obj_fun = obj_fun;
    obj_fun = 0.5*sum(sum((patterns-U*V').^2));

    %Plot the centers so far
    if (plot_on > 0)
        [temp, pattern_labels]  = max(V');
        cluster_patterns        = zeros(size(patterns, 1), Nclusters);
        for i = 1:Nclusters,
            in  = find(pattern_labels == i);
            if ~isempty(in)
                cluster_patterns(:, i)  = mean(patterns(:, in)')';
            end
        end
        plot_process(cluster_patterns, plot_on)
    end

    disp(['Iter ' num2str(iter) ': Objective function update=' num2str(old_obj_fun-obj_fun)])
end

[temp, pattern_labels]  = max(V');

% Create the clusters
cluster_patterns    = zeros(size(patterns, 1), Nclusters);
cluster_labels      = zeros(1, Nclusters);
Ut                  = unique(targets);
for i = 1:Nclusters,
    in  = find(pattern_labels == i);
    if ~isempty(in)
        cluster_patterns(:, i)  = mean(patterns(:, in)')';
        if length(Ut) > 1
            x                       = hist(targets(in), Ut);
            [m, cluster_labels(i)]  = max(x);
        else
            cluster_labels(i)   = 1;
        end
    end
end
cluster_labels  = Ut(cluster_labels);
