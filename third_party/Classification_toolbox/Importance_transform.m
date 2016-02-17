function [new_patterns, train_targets] = Importance_transform(train_patterns, train_targets, param, plot_on)

%Reshape the data points using the importance transform
%Inputs:
%	train_patterns	- Input patterns
%	train_targets	- Input targets
%	param			- Unused
%   plot_on         - Unused
%
%Outputs
%	new_patterns    - New patterns
%	targets			- New targets
%   var_mat			- Variance matrix
%   means           - Means vector
%
%See also PCA, Scaling_transform, Whitening_transform
%
%Example:
% load clouds
% [new_patterns, new_targets] = Importance_transform(patterns-min(patterns,[],2)*ones(1,size(patterns,2)), targets);
% plot_scatter(new_patterns, new_targets)

if any(train_patterns(:) < 0)
    error('This function requires that all patterns be greater than or equal to zero');
end

[r,c]		 = size(train_patterns);
means        = mean(train_patterns')';
means        = means + (means == 0);

new_patterns = train_patterns./(means*ones(1,c));
