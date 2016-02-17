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
