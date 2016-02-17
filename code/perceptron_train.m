function w = perceptron_train(l_train,f_train,varargin)

num_classes = length(unique(l_train));
num_dim = size(f_train,2);
w = zeros(num_classes,num_dim);
max_iter = 500;
n = 10;

for i=1:max_iter
    r = f_train * w';
    [M l_pred] = max(r,[],2);
    l_wrong = l_pred ~= l_train;
    
    for j=1:num_classes
      l_wrong_cur = l_wrong & (l_train == j);
      cur_class = l_train(l_wrong_cur,:);
      wrong_class = l_pred(l_wrong_cur);
      w(cur_class,:) = w(cur_class,:) + n * f_train(l_wrong_cur,:);
      w(wrong_class,:) = w(wrong_class,:) - n * f_train(l_wrong_cur,:);
    end
end
