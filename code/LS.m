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
