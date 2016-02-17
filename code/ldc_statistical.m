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
