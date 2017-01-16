% person independent test, use test set as auxilary training

clc; clear; close all;
addpath('./util');
low = 1;
high = 20;
framenum = 20;
rg = 'u_quarter';
ref =  containers.Map();
ref('up') = [1 2 4 6 7];
ref('u_quarter') = [1 2 4 6 7];
ref('down') = [10 12 14 15 17 23 24];
ref('d_quarter') = [10 12 14 15 17 23 24];
% load subject id
load(sprintf('./seg_eyebrow_eq_part_%d_threshold_%d_%d/%sdata/train_subject_id.mat',framenum,low,high,rg));%    true_subject_id = subject;
% load('./data/test_subject_id.mat');     aux_subject_id = subject;
%subject_id = subject';%[true_subject_id; aux_subject_id];

%% feature choice
op_norm = 'snp_with_eyebrow';
A_feature = 'hog';  % lbp, lpq, toplbp, toplpq, hog
E_feature = 'hog';
load(sprintf('./seg_eyebrow_eq_part_%d_threshold_%d_%d/%sdata/feat_%s_A_%s.mat',framenum,low,high,rg,A_feature,op_norm))
load(sprintf('./seg_eyebrow_eq_part_%d_threshold_%d_%d/%sdata/feat_%s_E_%s.mat',framenum,low,high,rg,A_feature,op_norm))

%% choice
feat_comb_choice = 3;
cls_choice = 'liblinear';
% cls_choice = 'libsvm';

%% svm parameter
svm_para = '-t 1 -q';
liblinear_para = '-s 4 -q';

%% feature
if feat_comb_choice == 1
	% EAI
	feat0 = feat_A;
	f_name = 'A';
elseif feat_comb_choice == 2
	% residule
	feat0 = feat_E;
	f_name = 'E';
elseif feat_comb_choice == 3
	% EAI + residule
	feat0 = [feat_A feat_E];
	f_name = 'A+E';
end

%% column-wise and row-wise norm
%feat = norm_col(feat);
feat0 = norm_col(feat0')';

%% PCA
feat0 = sf_pca(feat0,.9999);

%% classification
subject_id0 = subject_id;
ids = unique(subject_id);
for k = ref(rg)%[1 2 4 6 7 10 12 14 15 17 23 24]
	subject_id = subject_id0;
	% load label
	%load(sprintf('./seg_eyebrow_eq_%d/au%02ddata/train_label.mat',framenum,k));% true_label = label;
	load(sprintf('./seg_eyebrow_eq_part_%d_threshold_%d_%d/au%02dlabel.mat',framenum,low,high,k));
	del = find(label==-1);
	subject_id(del) = [];
	label(del) = [];
	feat = feat0;
	feat(del,:) = [];
	pred = zeros(size(label));
	for w=1:4:numel(ids)-2
		if w~=37
			train_idx = intersect(intersect(find(subject_id~=w),find(subject_id~=w+1)),intersect(find(subject_id~=w+2),find(subject_id~=w+3)));
			train_data = feat(train_idx,:);
			train_label = label(train_idx,:);
			
			test_idx = [find(subject_id==w);find(subject_id==w+1);find(subject_id==w+2);find(subject_id==w+3)];
			test_data = feat(test_idx,:);
			test_label = label(test_idx,:);
		else
			train_idx = intersect(intersect(...
				intersect(find(subject_id~=w),find(subject_id~=w+1)),...
				intersect(find(subject_id~=w+2),find(subject_id~=w+3))),...
				find(subject_id~=w+4));
			train_data = feat(train_idx,:);
			train_label = label(train_idx,:);
			
			test_idx = [find(subject_id==w);find(subject_id==w+1);find(subject_id==w+2);find(subject_id==w+3);find(subject_id==w+4)];
			test_data = feat(test_idx,:);
			test_label = label(test_idx,:);
		end
		
		if strcmp(cls_choice,'libsvm')
			% libsvm
			model = svmtrain(train_label, train_data, svm_para);
			[predict_label_L, ~, ~] = svmpredict(test_label, test_data, model);
			pred(test_idx) = predict_label_L;
		elseif strcmp(cls_choice,'liblinear')
			model = train(train_label, sparse(double(train_data)), liblinear_para);
			[predict_label_L, ~, ~] = predict(test_label, sparse(double(test_data)), model);
% 			predict_label_L =  - predict_label_L + 1;
			pred(test_idx) = predict_label_L;
		end
	end
	cp = classperf(label);
	classperf(cp,pred);
	cr = cp.CorrectRate;
% 	if cr<0.5
% 		pred =  1 - pred;
% 		cp = classperf(label);
% 		classperf(cp,pred);
% 		cr = cp.CorrectRate;
% 	end
	tp = numel(intersect(find(pred==1), find(label==1)));
	tn = numel(intersect(find(pred==0), find(label==0)));
	fn = numel(intersect(find(pred==0), find(label==1)));
	fp = numel(intersect(find(pred==1), find(label==0)));
	recall = tp/(tp+fn);
	precission =tp/(tp+fp);
	f1 = precission*recall*2/(precission+recall);
	fprintf('overall accuracy: %.4f\nf1: %.4f\n',cr,f1);
	mkdir(sprintf('./seg_eyebrow_eq_part_%d_threshold_%d_%d/result',framenum,low,high));
	save(sprintf('./seg_eyebrow_eq_part_%d_threshold_%d_%d/result/au%02d_cls_%s_%s_%s_[%.2f]_f1_[%.2f].mat',framenum,low,high,k,f_name,A_feature,rg,cr*100,f1*100),'cr')
end