function [train_error, validation_error, test_error] = validation(classifier, f_train, l_train, f_test, l_test, func_train, func_pred, pca_or_fld)
  t_start = tic;
  addpath('libsvm-3.20/matlab');
  num_features = size(f_train,1);
  num_classes = size(unique(l_train),1);
  num_dim = size(f_train,2);

  if pca_or_fld ==1
      num_steps = 11;
  else
      num_steps = num_classes - 1;
  end
  
  step = floor(num_dim/num_steps);
  train_error = zeros(num_steps,1);
  validation_error = zeros(num_steps,1);
  test_error = zeros(num_steps,1);
  
  idx = 1:num_features;
  
  f_validation = f_train(mod(idx,4)==0,:);
  l_validation = l_train(mod(idx,4)==0);
  f_train_s = f_train(mod(idx,4)~=0,:);
  l_train_s = l_train(mod(idx,4)~=0);
  
  for i = 1:num_steps
    n_f =  step * i;
    if pca_or_fld ==1
        options.ReducedDim = n_f;        
        [e,~] = PCA(f_train,options);
        f_train_new = f_train_s * e;
        f_validation_new = f_validation * e;
        f_test_new = f_test * e;
    else
        f_tr_pr = prdataset(f_train_s,l_train_s);
        f_va_pr = prdataset(f_validation,l_validation);
        f_te_pr = prdataset(f_test,l_test);        
        W = fisherm(f_tr_pr,i);
        f_train_new = f_tr_pr*W;
        f_validation_new = f_va_pr*W;
        f_test_new = f_te_pr*W;
        f_train_new = f_train_new.data;
        f_validation_new = f_validation_new.data;
        f_test_new = f_test_new.data;
    end
%{    
    f_train_new = f_train_new(:,1:n_f);
    f_validation_new = f_validation_new(:,1:n_f);
    f_test_new = f_test_new(:,1:n_f);
%}    
    model = func_train(l_train_s, f_train_new,'-q -c 32768 -g 1.22e-04') ;
    
    l_pred = func_pred( l_train_s,f_train_new,model);
    train_error(i) = 100*sum((l_pred ~= l_train_s))/size(l_train_s,1);

    l_pred = func_pred(l_validation,f_validation_new,model);
    validation_error(i) = 100*sum((l_pred ~= l_validation))/size(l_validation,1);
    
    l_pred = func_pred( l_test,f_test_new,model);
    test_error(i) = 100*sum((l_pred ~= l_test))/size(l_test,1);
    
  end
  
  if pca_or_fld ==1
      x = step:step:num_dim;
  else
      x = 1:num_steps;
  end
  
  figure;
  [M, idx] = min(train_error);
  h1 = plot(x,train_error);
  hold on
  plot(x(idx),M,'b*');
  hold on
  M
  [M, idx] = min(validation_error);
  h2 = plot(x,validation_error);
  hold on
  plot(x(idx),M,'b*');
  hold on
  M
  [M, idx] = min(test_error);
  h3 = plot(x,test_error);
  hold on
  h4 = plot(x(idx),M,'b*');
  hold off
  legend([h1,h2,h3,h4],'Training set','Validation set','Test set','Minimum Error');
  M
  title(strcat(classifier,' Validation'));
  xlabel('Number of dimensions');
  ylabel('Classification error %');
  print(strcat(classifier,'_validation.png'),'-dpng');
  
  
  
  toc(t_start)