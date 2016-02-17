addpath('libsvm-3.20/matlab');
addpath('prtools');

f_train = dlmread('../Project/UCI HAR Dataset/train/X_train.txt');
l_train = dlmread('../Project/UCI HAR Dataset/train/y_train.txt');
f_test = dlmread('../Project/UCI HAR Dataset/test/X_test.txt');
l_test = dlmread('../Project/UCI HAR Dataset/test/y_test.txt');

num_features = size(f_train,1);
num_dim = size(f_train,2);
num_classes = size(unique(l_train),1);

% Random class assignment with no priors
l_pred = unidrnd(ones(num_features,1)*num_classes);
100 - 100 * sum(l_pred ~= l_train)/num_features

% Random class assignment with priors
h = histogram(l_train,'Normalization','probability');
xlabel('Class label');
ylabel('PDF');
title('PDF of class labels');
print('prior_pdf.png','-dpng');

pdf = h.Values;
v = unidrnd(ones(num_features*2,1)*num_classes);
u = rand(1,num_features*2);
m = max(pdf);
r = m.*u < pdf(v);
l_pred = v(r==1);
l_pred = l_pred(1:num_features);
histogram(l_pred,'Normalization','probability');
100 - 100 * sum(l_pred ~= l_train)/num_features
