
% This file controls the different routines of the PrTools.
% Enter the required parameters in the configuration file
% and run this file.
% This files allows the user to call the *testconfig* function 
% in the way they like.
% One can make changes in the user defined area to customize the usage of
% this file.
% Refer to the video for more details:

% Author - Jigar Gada
% Email Id - jigargada90@gmail.com
% Last Updated - 05/13/2014
% Refer the Video for more details.

clc;
clear all;
close all;

INI = ini2struct('test.ini');

% Add the path in here, or directly add it from Home --> Set Path
addpath('E:\Courses\EE559\EE_559_Project\prtools');
% ---- Read the train, test data -----%

[Tr, Test, Testf] = getAllData(INI.data.traindatafile,INI.data.trainlabelfile,...
    INI.data.testdatafile,INI.data.testlabelfile,...
    INI.data.testfdatafile,INI.data.testflabelfile);


% -------- USER Defined Area ---------%

%--- For One run ------%

% Tr1, Test1, Testf1- this is the data after normalization/feature
% reduction/ feature selection.
% In cases where the preprocessing on data is not performed, Tr1, Test1,
% Tesf1 will be same as Tr, Test, Testf.
% W - mapping of the classifier.
% ERR - Cross validation Error
% STD - In cases where the number of times the cross validation is
% performed is more than 1, STD stores the standard deviation of the Cross
% validation Error.

[Tr1, Test1, Testf1,W,ERR,STD] = testConfig(INI,Tr, Test, Testf);

% This is the cross validation error, In cases where the cross-validation
% is turned OFF, this value will be -1.
disp ('Cross Validation Error = ');
disp(ERR);

% Test the classifier for the test set
D = Test1*W;

% Compute the error rate for the test set.
Err_testSet = testc(D,'crisp');


% --------------------- Multiple Runs --------------%

% Once the classifer is selected, use the final test set to 
% evaluate the final perfromance.
% I have commented this section. Uncomment it when you have finalized
% the classifer.
% Dfinal = Testf1*W
% Err = testc(Dfinal,'crisp');


% Example of changing the values of the dimesion of PCA and running the
% routine. 
% In a similar way, you can also change the parameters you like and run
% the testconfig fucntion.
% 
% -- Run the classifier for the required configuration ---%
% Error = zeros(1,10);
% i = 0;
% for k = 5:5:50
%     INI.dim_red.k = k;
%     disp(INI.dim_red.k);
%     [Tr1, Test1, Testf1,W,ERR,STD] = testConfig(INI,Tr, Test, Testf);
%     Error(i) = ERR;
%     i = i + 1
% end


%---- Plotting for The 2-d Case ------%
% To plot the data
% scatterd(Tr1);
% % To plor the decesion boundaries
% plotc(W);


