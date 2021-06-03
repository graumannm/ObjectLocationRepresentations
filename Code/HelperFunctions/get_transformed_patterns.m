function [pattern] = get_transformed_patterns(model,train_data)
% Compute patterns according to Haufe et al. (2014; NeuroImage). Code is
% adapted from libsvm
% http://www.csie.ntu.edu.tw/~cjlin/libsvm/faq.html#f804; and from TDT
% functions transres_SVM_weights_plusbias.m and
% transres_SVM_pattern_alldata.m
% 06-2021

% Input:
%   model: model struct output from libsvm function libsvmtrain
%   train_data: training data in format as used for libsvmtrain
%   (trialsxfeatures).

% Output:
%   pattern: scaled pattern

weights = model.SVs'*model.sv_coef;
b       = -model.rho;

if model.Label(1)== -1
   weights = -weights;
   b       = -b;
end

% covariance matrix
data_cov         = cov(train_data);

% covariance matrix x weight vector
pattern_unscaled = data_cov*weights;

% get scaling parameter and then get pattern
inv_scale_param    = 1./var(train_data*weights); % since the cov gives us a scalar, we can use var, and this does the scaling for each pattern
[n_samples, n_dim] = size(train_data);
pattern            = pattern_unscaled .* repmat(inv_scale_param,n_dim,1);

