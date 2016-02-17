
function [W, ERR,STD] = dist_free_classifier(str,Tr,degree,S,crossVal,N_folds,N_times)

% Initialization
ERR = -1;
STD = -1;

N_folds = str2double(N_folds);
N_times = str2double(N_times);

if ~(isnan(str2double(degree)))
    degree = str2double(degree);
end

if ~(isnan(str2double(S)))
    S = str2double(S);
end

switch str
    case 'fisherc'
       if strcmpi(crossVal,'TRUE')
          [ERR, STD] = crossval(Tr,fisherc,N_folds,N_times);
       end
       W = fisherc(Tr);
    case 'perlc'
       if strcmpi(crossVal,'TRUE')
          [ERR, STD] = crossval(Tr,perlc,N_folds,N_times);
       end
       W = perlc(Tr,no_of_iteartions);
    case 'nmc'
       if strcmpi(crossVal,'TRUE')
          [ERR, STD] = crossval(Tr,nmc,N_folds,N_times);
       end
       W = nmc(Tr);
    case 'mmsc'
       if strcmpi(crossVal,'TRUE')
          [ERR, STD] = crossval(Tr,mmsc,N_folds,N_times);
       end
       W = mmsc(Tr);
    case 'polyc'
       if strcmpi(crossVal,'TRUE')
          [ERR, STD] = crossval(Tr,polyc,N_folds,N_times);
       end 
       W = polyc(Tr,fisherc,degree,S);
    otherwise
        disp('ERROR: Select proper routine for Ditribution Free classifiers..!!');
        error('Use any of [fisherc, perlc, nmc, mmsc, polyc] ONLY..!!');
end

print = strcat(str,' Classifier Used');
disp(print);