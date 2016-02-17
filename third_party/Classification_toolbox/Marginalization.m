function [test_targets, P] = Marginalization(train_patterns, train_targets, test_patterns, params)

% Classify data with missing features using the marginal distribution
%
% Inputs:
% 	train_patterns  - Training patterns
%	train_targets   - Training targets
%   test_patterns   - Test patterns
%	params          - [The number of the missing feature, Number of bins for the data]
%
% Outputs
%   targets         - Output targets
%	P               - P(w|x) (Probability of a class given the good features)
%
%Example:
% load clouds
% t = Marginalization(patterns, targets, patterns, [2 10]);
% disp(mean(t == targets))

[missing, N] = process_params(params);

[d, L] = size(train_patterns);

if (missing > d),
    error(['The number of the missing pattern must be between 1 and ' num2str(d)])
end

not_missing = find(~ismember(1:d, missing));

%Calculate the marginal distribution using histograms
Nbins           = max(3,floor(size(train_patterns,2).^(1/3)));
[p, b, region]  = high_histogram(train_patterns,Nbins);
classes         = unique(train_targets);

Ptrain = zeros(length(classes), Nbins^(d-1));
for i = 1:length(classes),
    indices	    = find(train_targets == classes(i));
    g_i         = high_histogram(train_patterns(:,indices),Nbins,region);
    Pc          = squeeze(sum(g_i.*p,missing)./sum(p,missing));
    bad         = find(~isfinite(Pc));
    Pc(bad)     = 0;
    Ptrain(i,:) = Pc(:)';
end
if (d > 2)
    Ptrain = reshape(Ptrain, [length(classes) ones(1,d-1)*d]);
end

% Classify the marginal probabilities for all the patterns
[temp, binned_patterns] = high_histogram(test_patterns, Nbins, region);

P   = zeros(length(classes), size(test_patterns,2));
for i = 1:size(P,2),
    s = ':,';
    for j = 1:d-1,
        s = [s, num2str(binned_patterns(not_missing(j),i))];
        if (j ~= d-1)
            s = [s, ','];
        end
    end
    s = [s, ''];
    P(:,i) = eval(['Ptrain(', s, ')']); 
end

[m, I]          = max(P);
test_targets    = classes(I);

