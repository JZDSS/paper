% person independent test, use test set as auxilary training
clc; clear; close all;
addpath('./util');
for k = 12%[1 2 4 6 7 10 12 14 15 17 23 24]
	% load label
	load(sprintf('./frame_level/au%02ddata/train_label.mat',k));% true_label = label;
	% load('./data/test_label.mat');  aux_label = label;
	% label = [true_label; aux_label];
	%label = label';
	% load subject id
	load(sprintf('./frame_level/au%02ddata/train_subject_id.mat',k));%    true_subject_id = subject;
	% load('./data/test_subject_id.mat');     aux_subject_id = subject;
	%subject_id = subject;%[true_subject_id; aux_subject_id];
	
	%% feature choice
	op_norm = 'shape_norm_partial';
	A_feature = 'lbp';  % lbp, lpq, toplbp, toplpq
	E_feature = 'lbp';
	load(sprintf('./frame_level/au%02ddata/feat_%s_A_%s.mat',k,A_feature,op_norm))
	load(sprintf('./frame_level/au%02ddata/feat_%s_E_%s.mat',k,A_feature,op_norm))
	
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
		feat = feat_A;
		f_name = 'A';
	elseif feat_comb_choice == 2
		% residule
		feat = feat_E;
		f_name = 'E';
	elseif feat_comb_choice == 3
		% EAI + residule
		feat = [feat_A feat_E];
		clear feat_A feat_E
		f_name = 'A+E';
	end
	clear feat_A feat_E
	%% column-wise and row-wise norm
	feat = norm_row(feat);
	% feat = norm_col(feat')';
	
	%% PCA
	%feat = sf_pca(feat,.9999);
	
	%% classification
	pred = zeros(size(label));
	ids = unique(subject_id);
	
	for w=1:4:numel(ids)-2

		train_idx = intersect(intersect(find(subject_id~=w),find(subject_id~=w+1)),intersect(find(subject_id~=w+2),find(subject_id~=w+3)));
		train_data = feat(train_idx,:);
		train_label = label(train_idx,:);
		
		test_idx = [find(subject_id==w);find(subject_id==w+1);find(subject_id==w+2);find(subject_id==w+3)];
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
	tp = numel(intersect(find(pred==1), find(label==1)));
	tn = numel(intersect(find(pred==0), find(label==0)));
	fn = numel(intersect(find(pred==0), find(label==1)));
	fp = numel(intersect(find(pred==1), find(label==0)));
	recall = tp/(tp+fn);
	precission =tp/(tp+fp);
	f1 = precission*recall*2/(precission+recall);
	fprintf('overall accuracy: %.4f\nf1: %.4f\n',cr,f1);
	mkdir(sprintf('./frame_level/au%02ddata/result',k));
	save(sprintf('./frame_level/au%02ddata/result/cls_%s_%s_%s_[%.1f]_f1_[%f].mat',k,f_name,A_feature,op_norm,cr*100,f1),'cr')
end