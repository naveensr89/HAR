function [patterns, targets, W] = PPT(patterns, targets, dimension)

%Reshape the data points using the projection pursuit transform (Ifarraguerri and Chang, 2000)
%Inputs:
%	train_patterns	- Input patterns
%	train_targets	- Input targets
%	dimension		- Number of dimensions for the output data points
%
%Outputs
%	patterns		- New patterns
%	targets			- New targets
%   base            - The basis vectors
%
%See also FishersLinearDiscriminant, PCA, NMF
%
%Example:
% load clouds
% [new_patterns, new_targets] = PPT(patterns, targets, 2);
% plot_scatter(new_patterns, new_targets)

[r,c] = size(patterns);

if (r < dimension),
   disp('Required dimension is larger than the data dimension.')
   disp(['Will use dimension ' num2str(r)])
   dimension = r;
end

% Preprocessing
m           = mean(patterns')';
S			= ((patterns - m*ones(1,c)) * (patterns - m*ones(1,c))');
[V, D]	    = eig(S);
invD        = diag((diag(D).^(-0.5)));
Z           = invD*V'*(patterns - m*ones(1,c));
Zall        = Z;

% Project
W           = [];
Nbins       = max(5, round(c.^(1/3)));
q           = exp(-(linspace(-5, 5, Nbins).^2)); q = q / sum(q);

while ((rank(Z)>0) & (size(W, 2) < dimension))
    proj_score  = zeros(1, c);
    for i = 1:c,
        cur_data        = Z'*Z(:, i);
        cur_data        = (cur_data - mean(cur_data)) / std(cur_data);
        p               = hist(cur_data, linspace(-5, 5, Nbins));
        p               = p / sum(p);
        in              = find(p.*q > 0);
        proj_score(i)   = sum(p(in).*log(p(in)./q(in))) + sum(q(in).*log(q(in)./p(in)));
        if (i/1000 == floor(i/1000))
            fprintf('.');
        end
    end
    fprintf('\n');
    
    [m, I]  = max(proj_score);
    I       = I(1);
    w       = Z(:, I) ./ norm(Z(:, I));
    
    W       = [W, w];
    Pw      = eye(r) - W*inv(W'*W)*W';
    Z       = Pw*Z;
    
    disp(['Found ' num2str(size(W,2)) ' components. Remaining rank is ' num2str(rank(Z))])
end

patterns    = W'*Zall;