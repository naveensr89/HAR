
f_tr_pr = prdataset(f_train, l_train);
f_te_pr = prdataset(f_test, l_test);


W1 = ldc(f_tr_pr);
W2 = qdc(f_tr_pr);
W3 = udc(f_tr_pr);

W = {W1, W2, W3};

%labeld(f_te_pr,W);
100 - f_te_pr*W*testc*100

