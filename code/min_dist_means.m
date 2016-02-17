function min_dist_means(f_train,l_train,f_test,l_test)

mean = min_dist_means_train(l_train,f_train);

l_pred = min_dist_means_pred(l_train,f_train,mean);

fprintf('\n Percentage Correct classification Training = %f\n',100*sum(l_pred == l_train)/length(l_train));

l_pred = min_dist_means_pred(l_test,f_test,mean);

fprintf('\n Percentage Correct classification Test = %f\n',100*sum(l_pred == l_test)/length(l_test));

[train_error, validation_error, test_error] = validation('Min Dist Means PCA', f_train, l_train, f_test, l_test, @min_dist_means_train, @min_dist_means_pred, 1);

[train_error, validation_error, test_error] = validation('Min Dist Means FLD', f_train, l_train, f_test, l_test, @min_dist_means_train, @min_dist_means_pred, 0);