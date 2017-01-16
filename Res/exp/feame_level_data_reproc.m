clear all
r = './frame_level';
au = dir(r);
au(1:2) = [];
for i = 7%1:numel(au)
	p = dir(fullfile(r,au(i).name));
	p(1:2) = [];
	feat_A0 = [];
	feat_E0 = [];
	subject0 = [];
	label0 = [];
	for j = 1:numel(p)
		curr_p = fullfile(r,au(i).name,p(j).name);
		load(fullfile(curr_p,'feat_lbp_A_shape_norm_partial.mat'));
		load(fullfile(curr_p,'feat_lbp_E_shape_norm_partial.mat'));
		load(fullfile(curr_p,'train_label'));
		load(fullfile(curr_p,'train_subject_id'));
		feat_A0 = [feat_A0;feat_A(1:20:end,:)];
		feat_E0 = [feat_E0;feat_E(1:20:end,:)];
		subject0 = [subject0;subject(1:20:end)'];
		label0 = [label0;label(1:20:end)'];
	end
	feat_A = feat_A0;
	clear A0
	feat_E = feat_E0;
	clear E0
	subject = subject0;
	label = label0;
	save(fullfile(r,au(i).name,'feat_lbp_A_shape_norm_partial.mat'),'feat_A','-v7.3');
	save(fullfile(r,au(i).name,'feat_lbp_E_shape_norm_partial.mat'),'feat_E','-v7.3');
	save(fullfile(r,au(i).name,'subject.mat'),'subject','-v7.3');
	save(fullfile(r,au(i).name,'label.mat'),'label','-v7.3');
end
