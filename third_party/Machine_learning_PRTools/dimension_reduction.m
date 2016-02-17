
function [Tr, Test, Testf] = dimension_reduction(str,Tr, Test, Testf,k)

% This checks whether k is a string or a number,
% If given from the config file then its a string else
% it will be number.
% If k is a number then str2double(k) is not a number
if ~(isnan(str2double(k)))
    k = str2double(k);
end
    
switch str
    case 'pca'
        w = pca(Tr,k);
    case 'klm'
        w = klm(Tr,k);
    case 'fisherm'
        w = fisherm(Tr,k);
    otherwise
        disp('ERROR: Select proper routine for Dimension Reduction..!!');
        error('Use any of [pca, klm, fisherm] ONLY..!!');
end

Tr = Tr*w;
Test = Test*w;
Testf = Testf*w;

