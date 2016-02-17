
% This function reads the data from 2 files -
%
% 1. Data File (features for each prototype)
% 2. labelFile (which stores labels of the data)
%
% and stores the data in the array *pts* and the
% labels in the array *labels*
%
% Assuming data is stored as
% 2,4,5,6,7,8 .. where all the features are separated by comma(,)

function [pts,labels] = readData(datafile,labelFile)

% This function reads the comma separated data file. 
pts = csvread(datafile);

% This function reads the label file.
fileID = fopen(labelFile);
labels = fscanf(fileID,'%d');
fclose(fileID);

