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



