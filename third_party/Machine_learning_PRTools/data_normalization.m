
function [Tr,Test,Testf] = data_normalization(str,Tr,Test, Testf) 

switch str
    case 'mean'
        str_norm = 'mean';
    case 'variance'
        str_norm = 'variance';
    case 'domain'
        str_norm = 'domain';
    otherwise
        disp('ERROR: Select proper routine for Data Normalization..!!');
        error('Use any of [mean, variance, domain] ONLY..!!');
end
    
% Scale the training data 
w = scalem(Tr,str_norm);
Tr = map(Tr,w);

% Scale the test intermediate data 
w = scalem(Test,str_norm);
Test = map(Test,w);
   
% Scale the test final data
w = scalem(Testf,str_norm);
Testf = map(Testf,w);

print = strcat(str_norm,' Normalization Technique Used');
disp(print);

