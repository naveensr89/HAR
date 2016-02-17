function l_pred = perceptron_pred(l_test,f_test,w)

num_features = size(f_test,1);
num_dim = size(f_test,2);
num_classes = length(unique(l_test));

r = f_test * w';

[M,l_pred] = max(r,[],2);
