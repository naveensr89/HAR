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

