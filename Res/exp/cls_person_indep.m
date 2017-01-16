% person independent test

clear all; close all;
addpath('./svm');
addpath('./functions');
load('./data/train_label.mat'); % label of FERA training set
load('./data/train_subject_id.mat');
true_label = label;

%% feature choice
A_feature = 'lpq';  % lbp or lpq
A_is_face = '';%'';%     % '' or '_face'
E_feature = 'lpq';
E_is_face = '';

hist_eq = '';    % '_histeq' or ''

load(['./data/feat_',A_feature,'_A',A_is_face,hist_eq,'.mat']);
load(['./data/feat_',E_feature,'_E',E_is_face,hist_eq,'.mat']);

%% choice
feature_choice = 3;
cls_choice = 'liblinear';

%% feature
if feature_choice == 1
    % EAI
    feat = feat_A;
elseif feature_choice == 2
    % residule
    feat = feat_E;
elseif feature_choice == 3
    % EAI + residule
    feat = [feat_A feat_E];
end

%% column-wise and row-wise norm
feat = norm_col(feat);
%feat = norm_col(feat')';

%% PCA
feat = sf_pca(feat,.9999);


%% svm parameter
svm_para = '-t 0 -q';
liblinear_para = '-s 4 -q';

%% classification
pred = zeros(size(true_label));
ids = unique(subject);

for i=1:numel(ids)
    k = ids(i);
    train_idx = find(subject~=k);
    train_data = feat(train_idx,:);
    train_label = true_label(train_idx,:);
    
    test_idx = find(subject==k);
    test_data = feat(test_idx,:);
    test_label = true_label(test_idx,:);
    
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
cp = classperf(true_label);
classperf(cp,pred);
disp(cp.CorrectRate)
disp(['A_feature: ',A_feature])
disp(['E_feature: ',E_feature])
disp(['A_is_face: ',A_is_face])
disp(['E_is_face: ',E_is_face])