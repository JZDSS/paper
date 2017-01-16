% person independent test, use test set as auxilary training

clc; clear; close all;
addpath('./util');
% load label
load('./data/train_label.mat'); true_label = label;
load('./data/test_label.mat');  aux_label = label;
label = [true_label; aux_label];

% load subject id
load('./data/train_subject_id.mat');    true_subject_id = subject;
load('./data/test_subject_id.mat');     aux_subject_id = subject;
subject_id = [true_subject_id; aux_subject_id];

%% feature choice
op_norm = 'shape_norm_partial';
A_feature = 'lpq';  % lbp, lpq, toplbp, toplpq
E_feature = 'toplpq';
load(sprintf('./data/feat_%s_A_%s.mat',A_feature,op_norm))
load(sprintf('./data/feat_%s_E_%s.mat',A_feature,op_norm))

%% choice
feat_comb_choice = 1;
cls_choice = 'liblinear';
% cls_choice = 'libsvm';

%% svm parameter
svm_para = '-t 1 -q';
liblinear_para = '-s 4 -q';

%% feature
if feat_comb_choice == 1
    % EAI
    feat = feat_A;
    f_name = 'A';
elseif feat_comb_choice == 2
    % residule
    feat = feat_E;
    f_name = 'E';
elseif feat_comb_choice == 3
    % EAI + residule
    feat = [feat_A feat_E];
    f_name = 'A+E';
end

%% column-wise and row-wise norm
feat = norm_col(feat);
% feat = norm_col(feat')';

%% PCA
feat = sf_pca(feat,.9999);

%% classification
pred = zeros(size(label));
ids = unique(subject_id);

for k=1:numel(ids)
    train_idx = find(subject_id~=k);
    train_data = feat(train_idx,:);
    train_label = label(train_idx,:);
    
    test_idx = find(subject_id==k);
    test_data = feat(test_idx,:);
    test_label = label(test_idx,:);
    
    if strcmp(cls_choice,'libsvm')
        % libsvm
        model = svmtrain(train_label, train_data, svm_para); 
        [predict_label_L, ~, ~] = svmpredict(test_label, test_data, model);
        pred(test_idx) = predict_label_L;
    elseif strcmp(cls_choice,'liblinear')
        model = train(train_label, sparse(train_data), liblinear_para); 
        [predict_label_L, ~, ~] = predict(test_label, sparse(test_data), model);
        pred(test_idx) = predict_label_L;
    end
end
cp = classperf(label);
classperf(cp,pred);
cr = cp.CorrectRate;
fprintf('overall accuracy: %.4f\n',cr)
save(sprintf('./result/cls_acc/cls_%s_%s_%s_[%.1f].mat',f_name,A_feature,op_norm,cr*100),'cr')
