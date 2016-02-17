function [new_patterns, train_targets, Aw, means] = Whitening_transform(train_patterns, train_targets, param, plot_on)

%Reshape the data points using the whitening transform
%Inputs:
%	train_patterns	- Input patterns
%	train_targets	- Input targets
%	param			- Unused
%   plot_on         - Unused
%
%Outputs
%	new_patterns    - New patterns
%	targets			- New targets
%   Aw				- Whitening matrix
%   means           - Means vector
%
%See also PCA, Importance_transform, Scaling_transform
%
%Example:
% load clouds
% [new_patterns, new_targets] = Whitening_transform(patterns, targets);
% plot_scatter(new_patterns, new_targets)

[r,c]		 = size(train_patterns);
means        = mean(train_patterns')';

new_patterns = train_patterns - means*ones(1,c);
cov_mat      = cov(new_patterns',1);
Aw			 = inv(sqrtm(cov_mat));
new_patterns = Aw*new_patterns;

