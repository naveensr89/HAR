function [false_alarm, hit, area] = ROCC(patterns, targets, Nbins)

%Generate a receiver operating characteristic curve (ROCC) for 1-D data
%Inputs:
%	patterns	- The data from which to estimate
%	targets     - The class for each of the patterns
%Outputs:
%	false_alarm, hit - The x and y axes for the ROCC. 
%   area        - The area under the ROCC.
%	If the function is called without output, the ROCC is plotted

if (nargin == 2)
    Nbins       = max(3,floor(length(patterns).^(1/3)));
end

indice0		= find(targets ~= 1);
indice1		= find(targets == 1);
range		= [min(patterns), max(patterns)];

if size(patterns, 1) > 1
    p0          = high_histogram(patterns(:,indice0),Nbins,range);
    p1          = high_histogram(patterns(:,indice1),Nbins,range);
else
    p0          = hist(patterns(:,indice0),linspace(min(patterns), max(patterns), Nbins))';
    p1          = hist(patterns(:,indice1),linspace(min(patterns), max(patterns), Nbins))';
end

p0			= p0 ./ sum(p0);
p1			= p1 ./ sum(p1);

false_alarm = 1-cumsum(p0);
hit			= 1-cumsum(p1);

x           = [1; false_alarm; 0];
y           = [1; hit; 0];
area        = sum(-diff(x).*(y(1:end-1)+y(2:end))/2);

if (nargout == 0),
   figure
   plot(x, y)
   xlabel('False alarm')
   ylabel('Hit rate')
   line([0 1], [0 1], 'Color', [0 0 0], 'LineStyle', ':')
   text(0.25, 0.75, ['Area under ROC: ' num2str(area)])  
end
