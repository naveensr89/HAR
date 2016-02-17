
function [Tr,Test,Testf,W,ERR,STD] = testConfig(INI,Tr, Test, Testf)

W = 0;
% ---- Data Normalization ---- %

if(strcmpi(INI.data_norm.usethis,'TRUE'))
   [Tr, Test, Testf] = data_normalization(INI.data_norm.routine,Tr,Test,Testf);
end

% ---- Dimension Reduction/Feature Selection ---- %

if strcmpi(INI.feat_sel.usethis,'TRUE')
    [Tr, Test, Testf] = feat_selection(INI.feat_sel.routine,Tr,Test,Testf,INI.feat_sel.crit,INI.feat_sel.k,INI.feat_sel.n);
end

if strcmpi(INI.dim_red.usethis,'TRUE')
    [Tr, Test, Testf] = dimension_reduction(INI.dim_red.routine,Tr,Test,Testf,INI.dim_red.k);
end

% ---- Classification ---- %
% -- Distribution Free classifiers --- %
if strcmpi(INI.dist_free.usethis,'TRUE')
    [W,ERR,STD] = dist_free_classifier(INI.dist_free.routine,Tr,INI.dist_free.d,...
        INI.dist_free.s,INI.dist_free.docrossvalidation,...
        INI.dist_free.n_folds,INI.param.n_times);
    
elseif strcmpi(INI.svm.usethis,'TRUE')
    [W,ERR,STD] = SVM_local(INI.svm.routine,Tr,INI.svm.deg,...
        INI.svm.c,INI.svm.docrossvalidation,INI.svm.n_folds,...
        INI.param.n_times);

% -- Parametric classifiers ---%
elseif strcmpi(INI.param.usethis,'TRUE')
    [W,ERR,STD] = parametric_classifer(INI.param.routine,Tr,INI.param.docrossvalidation,...
        INI.param.n_folds,INI.param.n_times);
        
elseif strcmpi(INI.non_param.usethis,'TRUE')
    [W,ERR,STD] = non_parametric_classifer(INI.non_param.routine,Tr,INI.non_param.k,...
        INI.non_param.docrossvalidation,INI.non_param.n_folds,INI.non_param.n_times);
end     



