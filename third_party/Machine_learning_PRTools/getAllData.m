
% This function reads the train and test data
% and creates a dataset array for traning and test data.
% All the input parameters (train and test file have to be
% entered in the input parameter section.

function [Tr,Test,Testf] = getAllData(traindataFile,trainLabelFile,testdataFile,testLabelFile,testFDataFile,testFLabelFile)

% Read the training and test data
[trainPts, trainLabels] = readData(traindataFile,trainLabelFile);
[testPts, testLabels] = readData(testdataFile,testLabelFile);
[testFPts, testFLabels] = readData(testFDataFile,testFLabelFile);

% Create the dataset array
Tr = dataset(trainPts,trainLabels);
Test = dataset(testPts,testLabels);
Testf = dataset(testFPts,testFLabels);

% No_of_classes = length(getlablist(Tr));

disp ('Data Read');

