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
