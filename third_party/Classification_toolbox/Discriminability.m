function d_tag = Discriminability(mu1, sigma1, mu2, sigma2, p1)

% Find the discriminability given means and covariances of single gaussian distributions
% Inputs:
%   mu1         - Mean for class 1
%   sigma1      - Covariance matrix for class 1
%   mu2         - Mean for class 2
%   sigma2      - Covariance matrix for class 2
%   p1          - Probability of class 1
%
% Outputs
%	d_tag     	- Discriminability
%
%See also Chernoff, Bhattacharyya
%
%Example:
% load clouds
% p = Discriminability(distribution_parameters(1).mu(1,:), squeeze(distribution_parameters(1).sigma(1,:,:)), ...
%                   distribution_parameters(2).mu, squeeze(distribution_parameters(2).sigma), ...
%                   distribution_parameters(1).p)

sigma   = (sigma1+sigma2)/2;

d_tag   = abs(mu2-mu1)/sigma;
