function mean = min_dist_means_train(l_train,f_train,varargin)
num_classes = length(unique(l_train));
num_dim = size(f_train,2);
mean = zeros(num_classes,num_dim);

for i=1:num_classes
    train_cur = l_train ==  i;
    mean(i,:) = sum(f_train(train_cur,:),1)/sum(train_cur);
end