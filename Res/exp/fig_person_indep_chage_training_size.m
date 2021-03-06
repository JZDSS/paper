% classification with various training size

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
A_feature = 'lpq';  % lbp or lpq
E_feature = 'lpq';
load(sprintf('./data/feat_%s_A_%s.mat',A_feature,op_norm))
load(sprintf('./data/feat_%s_E_%s.mat',A_feature,op_norm))
%% choice
feat_comb_choice = 3;
cls_choice = 'liblinear';

%% feature
if feat_comb_choice == 1
    % EAI
    feat = feat_A;
elseif feat_comb_choice == 2
    % residule
    feat = feat_E;
elseif feat_comb_choice == 3
    % EAI + residule
    feat = [feat_A feat_E];
end

%% column-wise and row-wise norm
feat = norm_col(feat);
% feat = norm_col(feat')';

%% PCA
feat = sf_pca(feat,.9999);

%% svm parameter
svm_para = '-t 0 -q';
liblinear_para = '-s 4 -q';

%% classification
% number of people in training: from 10 to max, step size 10
pred = zeros(size(label));
ids = unique(subject_id);
id_num = numel(ids);
training_fold = 30;
train_size = 10:10:numel(label);
result = cell(numel(train_size),1);
for k=1:numel(ids)  % test on one subject every iteration
    test_idx = find(subject_id==k);
    test_data = feat(test_idx,:);
    test_label = label(test_idx,:);
    
    rest_idx = find(subject_id~=k);
    for id_size=10:10:numel(rest_idx) % change training size
        for j=1:training_fold
            id_idx = randperm(numel(rest_idx));
            train_idx = rest_idx(id_idx(1:id_size));

            train_data = feat(train_idx,:);
            train_label = label(train_idx,:);

            % cls
            model = train(train_label, sparse(train_data), liblinear_para); 
            [pred, ~, ~] = predict(test_label, sparse(test_data), model);

            % store cls result
            cls_rate = sum(pred==test_label)/numel(test_label);
            result{id_size/10,1} = [result{id_size/10,1} cls_rate];
        end
    end
end

result_final = [];
me = [];
va = [];
for i=1:24
    result_final = [result_final; result{i,1}];
    me = [me; median(result{i,1})];
    va = [va; var(result{i,1})];
end
figure,boxplot(result_final'),ylim([0.2 1])
x = 1:24;
figure,plot(x,me,'-b',x,me+va,'o',x,me-va,'o'),ylim([.2 1])

% export me and va to excel for result anotation