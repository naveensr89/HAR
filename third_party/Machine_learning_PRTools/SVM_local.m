
function [W ERR STD] = SVM_local(str,Tr,Deg,C,crossVal,N_folds,N_times)

ERR = -1;
STD = -1;
N_folds = str2double(N_folds);
N_times = str2double(N_times);

% Increase the memory capacity
prmemory(200000000);

if ~(isnan(str2double(Deg)))
    Deg = str2double(Deg);
end

if ~(isnan(str2double(C)))
    C = str2double(C);
end

if strcmpi(crossVal,'TRUE')
    [ERR, STD] = crossval(Tr,libsvc([],proxm([],str,Deg),C),N_folds,N_times);
end

W = libsvc(Tr,proxm([],str,Deg),C);

print = strcat('SVM Classifer with ',str,' mode Used');
disp(print);
        