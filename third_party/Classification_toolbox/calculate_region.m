function [region, x, y] = calculate_region(patterns, region)

% This function calculates the plot region
% This is an internal toolbox function 

region = [min(patterns(1,:)) max(patterns(1,:)) ...
	      min(patterns(2,:)) max(patterns(2,:)) region(5)];   
   
if (sign(region(1)) == 1)
   region(1) = region(1) / 1.1;
else
   region(1) = region(1) * 1.1;
end   
if (sign(region(3)) == 1)
   region(3) = region(3) / 1.1;
else
   region(3) = region(3) * 1.1;
end   
if (sign(region(2)) == 1)
   region(2) = region(2) * 1.1;
else
   region(2) = region(2) / 1.1;
end   
if (sign(region(4)) == 1)
   region(4) = region(4) * 1.1;
else
   region(4) = region(4) / 1.1;
end   

if (region(1) == region(2))
    region(1) = region(1) - 0.05;
    region(2) = region(2) + 0.05;
end
if (region(3) == region(4))
    region(3) = region(3) - 0.05;
    region(4) = region(4) + 0.05;
end

x   = linspace (region(1),region(2),region(5));
y	= linspace (region(3),region(4),region(5));
