
function [Tr, Test, Testf] = feat_selection(str,Tr, Test, Testf,crit,k,N)

if ~(isnan(str2double(k)))
    k = str2double(k);
end
if ~(isnan(str2double(N)))
    N = str2double(N);
end


switch str
    case 'featself'
        [w R] = featself(Tr,crit,k,Test,N);   
    case 'featseli'
        [w R] = featseli(Tr,crit,k,Test,N); 
    case 'featselb'
        [w R] = featselb(Tr,crit,k,Test,N);
    case 'cmap'
        w = cmapm(54,[1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40]);
    otherwise 
        disp('ERROR: Select proper routine for Feature Selection..!!');
        error('Use any of [featself, featseli, featselb] ONLY..!!');
end

str = strcat(str, ' Feature selection technique used.');
disp(str);

Tr = Tr*w;
Test = Test*w;
Testf = Testf*w;

