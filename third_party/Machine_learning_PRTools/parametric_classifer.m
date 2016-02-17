
function [W,ERR,STD] = parametric_classifer(str,Tr,crossVal,N_folds,N_times, no_of_iteartions)

% Initialization
ERR = -1;
STD = -1;
N_folds = str2double(N_folds);
N_times = str2double(N_times);

switch str
    case 'qdc'
       if strcmpi(crossVal,'TRUE')
          [ERR, STD] = crossval(Tr,qdc,N_folds,N_times);
       end
       W = qdc(Tr);
    case 'ldc'
       if strcmpi(crossVal,'TRUE')
          [ERR, STD] = crossval(Tr,ldc,N_folds,N_times);
       end
       W = ldc(Tr);
        case 'udc'
       if strcmpi(crossVal,'TRUE')
          [ERR, STD] = crossval(Tr,udc,N_folds,N_times);
       end
       W = udc(Tr);
    otherwise
        disp('ERROR: Select proper routine for Parametric classifiers..!!');
        error('Use any of [qdc,ldc,udc] ONLY..!!');
end

print = strcat(str,' Classifier Used');
disp(print);