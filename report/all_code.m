%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%% PROJECT.M %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
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

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%% MIN DIST TO MEANS.M %%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function min_dist_means(f_train,l_train,f_test,l_test)

mean = min_dist_means_train(l_train,f_train);

l_pred = min_dist_means_pred(l_train,f_train,mean);

fprintf('\n Percentage Correct classification Training = %f\n',100*sum(l_pred == l_train)/length(l_train));

l_pred = min_dist_means_pred(l_test,f_test,mean);

fprintf('\n Percentage Correct classification Test = %f\n',100*sum(l_pred == l_test)/length(l_test));

[train_error, validation_error, test_error] = validation('Min Dist Means PCA', f_train, l_train, f_test, l_test, @min_dist_means_train, @min_dist_means_pred, 1);

[train_error, validation_error, test_error] = validation('Min Dist Means FLD', f_train, l_train, f_test, l_test, @min_dist_means_train, @min_dist_means_pred, 0);

function mean = min_dist_means_train(l_train,f_train,varargin)
num_classes = length(unique(l_train));
num_dim = size(f_train,2);
mean = zeros(num_classes,num_dim);

for i=1:num_classes
    train_cur = l_train ==  i;
    mean(i,:) = sum(f_train(train_cur,:),1)/sum(train_cur);
end

function l_pred = min_dist_means_pred(l_test,f_test,mean)

num_features = size(f_test,1);
num_dim = size(f_test,2);
num_classes = length(unique(l_test));

d = pdist2(f_test,mean);

[M,l_pred] = min(d,[],2);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%% PERCEPTRON.M %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function perceptron(f_train,l_train,f_test,l_test)

perceptron_train_1 = @(l_train, f_train, varargin) perlc(prdataset(f_train,l_train),100);
perceptron_pred_1 = @(l_test, f_test, w) labeld(prdataset(f_test,l_test),w);

w = perceptron_train_1(l_train,f_train);

l_pred = perceptron_pred_1(l_train,f_train,w);

fprintf('\n Percentage Correct classification Training = %f\n',100*sum(l_pred == l_train)/length(l_train));

l_pred = perceptron_pred_1(l_test,f_test,w);

fprintf('\n Percentage Correct classification Test = %f\n',100*sum(l_pred == l_test)/length(l_test));

[train_error, validation_error, test_error] = validation('Perceptron PCA', f_train, l_train, f_test, l_test, perceptron_train_1, perceptron_pred_1, 1 );

[train_error, validation_error, test_error] = validation('Perceptron FLD', f_train, l_train, f_test, l_test, perceptron_train_1, perceptron_pred_1, 0 );


% Parameter estimation
P = cvpartition(size(f_train,1),'Holdout',0.20);
f_tr_pr = prdataset(f_train(P.training,:),l_train(P.training));
f_va_pr = prdataset(f_train(P.test,:),l_train(P.test));
f_te_pr = prdataset(f_test,l_test);
f = {f_tr_pr,f_va_pr,f_te_pr};    

eta = 0.1:0.18:1;
e = zeros(size(eta,2),3);

for k = 1:size(eta,2)
    w = perlc(f_tr_pr,100,eta(k));
    e(k,:) = f*w*testc*100;
end

plot(eta,e);hold on
[M idx] = min(e);
plot(eta(idx),M,'b*');
legend('Training','Validation','Test','Minimum');
hold off;
xlabel('eta'); ylabel('Classification error %');
title('Perceptron Parameter selection');
print('Perceptron Parameter Selection.png','-dpng');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%% LS.M %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function LS(f_train,l_train,f_test,l_test)

%LS_train = @(l, f, varargin) pinv(f'*f)*f'*l;
%LS_pred = @(l, f, a) round(f*a);

LS_train = @(l_train, f_train, varargin) fisherc(prdataset(f_train,l_train));
LS_pred = @(l_test, f_test, w) labeld(prdataset(f_test,l_test),w);

f_tr_pr = prdataset(f_train,l_train);
f_te_pr = prdataset(f_test,l_test);
f = {f_tr_pr, f_te_pr};

a = LS_train(l_train,f_train,'-q');
c = 100 - f*a*testc*100

[train_error, validation_error, test_error] = validation('LS PCA', f_train, l_train, f_test, l_test, LS_train, LS_pred, 1 );
[train_error, validation_error, test_error] = validation('LS FLD', f_train, l_train, f_test, l_test, LS_train, LS_pred, 0 );

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%% SVM.M %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function svm(f_train,l_train,f_test,l_test)

model = svmtrain(l_train,f_train,'-q');
[l_pred, accuracy, decision_values] = svmpredict(l_train,f_train,model);

[l_pred, accuracy, decision_values] = svmpredict(l_test,f_test,model);

[train_error, validation_error, test_error] = validation('SVM PCA', f_train, l_train, f_test, l_test, @svmtrain, @svmpredict, 1 );
[train_error, validation_error, test_error] = validation('SVM FLD', f_train, l_train, f_test, l_test, @svmtrain, @svmpredict, 0 );


kernel_t = [0 1 2 3];
kernel_t_name = {'Linear','polynomial', 'rbf', 'sigmoid'};
validation_error_kernel = zeros(size(kernel_t,2),1);
test_error_kernel = validation_error_kernel;

P = cvpartition(size(f_train,1),'Holdout',0.20);
% For kernel testing
for k = 1:size(kernel_t,2)
    params = ['-q -c 1000 -g 0.01 -t ',num2str(kernel_t(k))];
    model = svmtrain(l_train(P.training),f_train(P.training,:),params);
    [l_pred, accuracy, decision_values] = svmpredict(l_train(P.test),f_train(P.test,:),model);
    validation_error_kernel(k) = 100*sum((l_pred ~= l_train(P.test)))/size(P.test,1);
    [l_pred, accuracy, decision_values] = svmpredict(l_test,f_test,model);
    test_error_kernel(k) = 100*sum((l_pred ~= l_test))/size(l_test,1);
end

figure;
plot(kernel_t, validation_error_kernel);
hold on
plot(kernel_t, test_error_kernel);
hold on;
[M1, idx1] = min(validation_error_kernel);
[M2, idx2] = min(test_error_kernel);
plot(kernel_t([idx1 idx2]),[M1 M2],'b*');

set(gca, 'XTick',kernel_t, 'XTickLabel',kernel_t_name);
xlabel('Kernel Type');
ylabel('Classification error %');
title('SVM Kernel selection');
legend('Validation','Test','Minimum');
print('SVM Kernel Selection.png','-dpng');

c_power = -5:2:15;
C = 2.^c_power;
gamma_power = -15: 2: 3; 
gamma = 2.^gamma_power;
test_error_kernel = zeros(size(C,2),size(gamma,2));
validation_error_kernel = test_error_kernel;

P = cvpartition(size(f_train,1),'Holdout',0.20);

% For C ang gamma testing
for i = 1:size(C,2)
    for j = 1:size(gamma,2)
        params = ['-q -t 2  -c ',num2str(C(i)),' -g ',num2str(gamma(j))];        
        model = svmtrain(l_train(P.training,:),f_train(P.training,:),params);
        [l_pred, accuracy, decision_values] = svmpredict(l_train(P.test,:),f_train(P.test,:),model);
        validation_error_kernel(i,j) = 100*sum((l_pred ~= l_train(P.test,:)))/size(P.test,1);
        [l_pred, accuracy, decision_values] = svmpredict(l_test,f_test,model);
        test_error_kernel(i,j) = 100*sum((l_pred ~= l_test))/size(l_test,1);
    end
end

[Y,X] = meshgrid(gamma,C);

[M idx1] = min(validation_error_kernel);
[M idx2] = min(M);
min_c = X(idx1(idx2),idx2)
min_g = Y(idx1(idx2),idx2)
M

surf(X,Y,validation_error_kernel, gradient(validation_error_kernel)); hold on;
scatter3(min_c,min_g,M,500,'r.');
view(65, 45);
ax = gca;
ax.XScale = 'log';
ax.YScale = 'log';
xlabel('C');
ylabel('gamma');
zlabel('Error Classification %');
title('SVM C and gamma selection on validation');
print('SVM C and gamma selection on validation.png','-dpng');

figure;
[M idx1] = min(test_error_kernel);
[M idx2] = min(M);
min_c = X(idx1(idx2),idx2)
min_g = Y(idx1(idx2),idx2)
M

surf(X,Y,test_error_kernel,gradient(test_error_kernel)); hold on;
scatter3(min_c,min_g,M,500,'r.');
view(65, 45);
ax = gca;
ax.XScale = 'log';
ax.YScale = 'log';
xlabel('C');
ylabel('gamma');
zlabel('Error Classification %');
title('SVM C and gamma selection on test');
print('SVM C and gamma selection on test.png','-dpng');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%% KNN.M %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

knnc_train = @(l_train, f_train, varargin) knnc(prdataset(f_train,l_train),8);
knnc_pred = @(l_test, f_test, w) labeld(prdataset(f_test,l_test),w);

W = knnc(f_tr_pr);
100 - f_te_pr*W*testc*100

[train_error, validation_error, test_error] = validation('Knnc PCA', f_train, l_train, f_test, l_test, knnc_train, knnc_pred, 1 );
[train_error, validation_error, test_error] = validation('Knnc FLD', f_train, l_train, f_test, l_test, knnc_train, knnc_pred, 0 );


% KNN parameter selection
K = 2:2:12;
n = size(K,2);
f_tr_pr = prdataset(f_train,l_train);
f_te_pr = prdataset(f_test,l_test);
f = {f_tr_pr(1:6500,:),f_te_pr};    

e = zeros(n,2);
for i=1:n
    w = knnc(f_tr_pr,K(i));
    e(i,:) = f*w*testc*100;
end

plot(K,e);hold on
[M idx] = min(e);
plot(K(idx),M,'b*');
legend('Training','Test','Minimum');
hold off;
xlabel('K'); ylabel('Classification error %');
title('KNN Parameter selection');
print('KNN Parameter Selection.png','-dpng');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%% NAIVE BAYES.M %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

naivebc_train = @(l_train, f_train, varargin) naivebc(prdataset(f_train,l_train),4);
naivebc_pred = @(l_test, f_test, w) labeld(prdataset(f_test,l_test),w);

W = naivebc(f_tr_pr);
100 - f_tr_pr*W*testc*100
100 - f_te_pr*W*testc*100

[train_error, validation_error, test_error] = validation('Naive Bayes PCA', f_train, l_train, f_test, l_test, naivebc_train, naivebc_pred, 1 );
[train_error, validation_error, test_error] = validation('Naive Bayes FLD', f_train, l_train, f_test, l_test, naivebc_train, naivebc_pred, 0 );


% Naive bayes parameter selection
K = 2:1:12;
n = size(K,2);
f_tr_pr = prdataset(f_train,l_train);
f_te_pr = prdataset(f_test,l_test);
f = {f_tr_pr,f_te_pr};    

e = zeros(n,2);
for i=1:n
    w = naivebc(f_tr_pr,K(i));
    e(i,:) = f*w*testc*100;
end

plot(K,e);hold on
[M idx] = min(e)
plot(K(idx),M,'b*');
legend('Training','Test','Minimum');
hold off;
xlabel('N bins'); ylabel('Classification error %');
title('Naive Bayes Parameter selection');
print('Naive Bayes Parameter Selection.png','-dpng');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%% LDC STATISTICAL.M %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
ldc_train = @(l_train, f_train, varargin) ldc(prdataset(f_train,l_train),0,0.2);
ldc_pred = @(l_test, f_test, w) labeld(prdataset(f_test,l_test),w);

W = ldc(f_tr_pr);
f_tr_pr*W*testc*100
f_te_pr*W*testc*100

[train_error, validation_error, test_error] = validation('LDC PCA', f_train, l_train, f_test, l_test, ldc_train, ldc_pred, 1 );
[train_error, validation_error, test_error] = validation('LDC FLD', f_train, l_train, f_test, l_test, ldc_train, ldc_pred, 0 );


% Naive bayes parameter selection
R = 0:.2:1;
S = 0:.2:1;
n = size(R,2);
f_tr_pr = prdataset(f_train,l_train);
f_te_pr = prdataset(f_test,l_test);

e_test = zeros(n,n);
for i=1:n
    for j=1:n
        w = ldc(f_tr_pr,R(i),S(j));
         e_test(i,j) = f_te_pr*w*testc*100;
    end
end
[Y,X] = meshgrid(S,R);

[M idx1] = min(e_test);
[M idx2] = min(M);
min_R = X(idx1(idx2),idx2)
min_S = Y(idx1(idx2),idx2)
M

surf(X,Y,e_test); hold on;
scatter3(min_R,min_S,M,800,'r.');
view(230, 45);
xlabel('R');
ylabel('S');
zlabel('Error Classification %');
title('LDC R and S selection on test');
print('LDC R and S selection on test.png','-dpng');
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%% VALIDATION.M %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [train_error, validation_error, test_error] = validation(classifier,
 f_train, l_train, f_test, l_test, func_train, func_pred, pca_or_fld)
  t_start = tic;
  addpath('libsvm-3.20/matlab');
  num_features = size(f_train,1);
  num_classes = size(unique(l_train),1);
  num_dim = size(f_train,2);

  if pca_or_fld ==1
      num_steps = 11;
  else
      num_steps = num_classes - 1;
  end
  
  step = floor(num_dim/num_steps);
  train_error = zeros(num_steps,1);
  validation_error = zeros(num_steps,1);
  test_error = zeros(num_steps,1);
  
  idx = 1:num_features;
  
  f_validation = f_train(mod(idx,4)==0,:);
  l_validation = l_train(mod(idx,4)==0);
  f_train_s = f_train(mod(idx,4)~=0,:);
  l_train_s = l_train(mod(idx,4)~=0);
  
  for i = 1:num_steps
    n_f =  step * i;
    if pca_or_fld ==1
        options.ReducedDim = n_f;        
        [e,~] = PCA(f_train,options);
        f_train_new = f_train_s * e;
        f_validation_new = f_validation * e;
        f_test_new = f_test * e;
    else
        f_tr_pr = prdataset(f_train_s,l_train_s);
        f_va_pr = prdataset(f_validation,l_validation);
        f_te_pr = prdataset(f_test,l_test);        
        W = fisherm(f_tr_pr,i);
        f_train_new = f_tr_pr*W;
        f_validation_new = f_va_pr*W;
        f_test_new = f_te_pr*W;
        f_train_new = f_train_new.data;
        f_validation_new = f_validation_new.data;
        f_test_new = f_test_new.data;
    end
%{    
    f_train_new = f_train_new(:,1:n_f);
    f_validation_new = f_validation_new(:,1:n_f);
    f_test_new = f_test_new(:,1:n_f);
%}    
    model = func_train(l_train_s, f_train_new,'-q -c 32768 -g 1.22e-04') ;
    
    l_pred = func_pred( l_train_s,f_train_new,model);
    train_error(i) = 100*sum((l_pred ~= l_train_s))/size(l_train_s,1);

    l_pred = func_pred(l_validation,f_validation_new,model);
    validation_error(i) = 100*sum((l_pred ~= l_validation))/size(l_validation,1);
    
    l_pred = func_pred( l_test,f_test_new,model);
    test_error(i) = 100*sum((l_pred ~= l_test))/size(l_test,1);
    
  end
  
  if pca_or_fld ==1
      x = step:step:num_dim;
  else
      x = 1:num_steps;
  end
  
  figure;
  [M, idx] = min(train_error);
  h1 = plot(x,train_error);
  hold on
  plot(x(idx),M,'b*');
  hold on
  M
  [M, idx] = min(validation_error);
  h2 = plot(x,validation_error);
  hold on
  plot(x(idx),M,'b*');
  hold on
  M
  [M, idx] = min(test_error);
  h3 = plot(x,test_error);
  hold on
  h4 = plot(x(idx),M,'b*');
  hold off
  legend([h1,h2,h3,h4],'Training set','Validation set','Test set','Minimum Error');
  M
  title(strcat(classifier,' Validation'));
  xlabel('Number of dimensions');
  ylabel('Classification error %');
  print(strcat(classifier,'_validation.png'),'-dpng');
  
  toc(t_start)
