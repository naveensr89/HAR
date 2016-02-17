function [patterns, targets, UW, m, W] = PCA(patterns, targets, dimension)

%Reshape the data points using the principal component analysis
%Inputs:
%	train_patterns	- Input patterns
%	train_targets	- Input targets
%	dimension		- Number of dimensions for the output data points
%
%Outputs
%	patterns		- New patterns
%	targets			- New targets
%	UW				- Reshape martix
%   m               - Original pattern averages
%   W               - Eigenvector matrix 
%
%See also FishersLinearDiscriminant, NMF, kernel_PCA
%
%Example:
% load clouds
% [new_patterns, new_targets] = PCA(patterns, targets, 2);
% plot_scatter(new_patterns, new_targets)

[r,c] = size(patterns);

if (r < dimension),
   disp('Required dimension is larger than the data dimension.')
   disp(['Will use dimension ' num2str(r)])
   dimension = r;
end

%Calculate cov matrix and the PCA matrixes
m           = mean(patterns')';
S			= ((patterns - m*ones(1,c)) * (patterns - m*ones(1,c))');
[V, D]	    = eig(S);
W			= V(:,[r:-1:r-dimension+1])';
U			= S*W'*inv(W*S*W');

%Calculate new patterns
UW			= U*W;
patterns    = W*patterns;