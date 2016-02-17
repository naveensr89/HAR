function plot_scatter(plot_patterns, plot_targets, fig, color)

% Make a scatter plot of the data
% Inputs:
%	plot_patterns	- Data patterns
%	plot_targets	- Data targets
%	fig				- Optional figure handle
%	color			- Optional color tag (if 1, will color all points red)
%
% Example:
%   load clouds
%   plot_scatter(patterns, targets)

switch nargin,
    case 2
        color = 0;
    case 3
        color = 0;
        figure(fig);
    case 4
        if ~isempty(fig),
            figure(fig)
        end
end

one   = find(plot_targets == 1);
zero  = find(plot_targets == 0);

switch size(plot_patterns, 1)
    case 2,
        switch color
            case 0
                plot(plot_patterns(1,zero),plot_patterns(2,zero),'bo',plot_patterns(1,one),plot_patterns(2,one),'gx')
            case 1
                plot(plot_patterns(1,zero),plot_patterns(2,zero),'ro',plot_patterns(1,one),plot_patterns(2,one),'rx','LineWidth',2)
            case 2
                plot(plot_patterns(1,zero),plot_patterns(2,zero),'ko',plot_patterns(1,one),plot_patterns(2,one),'mx')
        end
    case 3,
        switch color
            case 0
                plot3(plot_patterns(1,zero),plot_patterns(2,zero),plot_patterns(3,zero),'bo',plot_patterns(1,one),plot_patterns(2,one),plot_patterns(3,one),'gx')
            case 1
                plot3(plot_patterns(1,zero),plot_patterns(2,zero),plot_patterns(3,zero),'ro',plot_patterns(1,one),plot_patterns(2,one),plot_patterns(3,one),'rx','LineWidth',2)
            case 2
                plot3(plot_patterns(1,zero),plot_patterns(2,zero),plot_patterns(3,zero),'ko',plot_patterns(1,one),plot_patterns(2,one),plot_patterns(3,one),'mx')
        end
    otherwise
        error(['Cannot plot data with ' num2str(size(plot_patterns, 1)) ' dimensions']);
end

grid on
