function l_pred = min_dist_means_pred(l_test,f_test,mean)

num_features = size(f_test,1);
num_dim = size(f_test,2);
num_classes = length(unique(l_test));

d = pdist2(f_test,mean);

[M,l_pred] = min(d,[],2);
