
function [W,ERR,STD] = non_parametric_classifer(str,Tr,k,crossVal,N_folds,N_times)

% Initialization
ERR = -1;
STD = -1;
N_folds = str2double(N_folds);
N_times = str2double(N_times);

% This increases the memory capacity
prmemory(100000000);

if ~(isnan(str2double(k)))
    k = str2double(k);
end

switch str
    case 'knnc'
       if strcmpi(crossVal,'TRUE')
          [ERR, STD] = crossval(Tr,knnc,N_folds,N_times);
       end
       [W H] = knnc(Tr,k);
    case 'parzenc'
       if strcmpi(crossVal,'TRUE')
          [ERR, STD] = crossval(Tr,parzenc,N_folds,N_times);
       end
       [W H] = parzenc(Tr,k);
    otherwise
        disp('ERROR: Select proper routine for Non-parametric classifiers..!!');
        error('Use any of [knnc, parzenc] ONLY..!!');
end


print = strcat(str,' Classifier Used');
disp(print);

