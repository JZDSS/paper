% extract feature lbp, from training and test set
warning off
clc; clear; close all;
set_path
addpath(fullfile(lib_path,'lbp'));
% var
choice = 'snp_with_eyebrow'; % shape_norm_partial or shape_norm
field = {'x1', 'x2', '', 'x4', '', 'x6', 'x7', ...
    '', '', 'x10', '', 'x12', '', 'x14', 'x15', ...
    '', 'x17', '', '', '', '', '', 'x23', 'x24'};

% lbp para
low = 5;
high = 15;
img_sz = 160;
blk_sz = 20;
lbp_feat_sz = 59*(img_sz/blk_sz)^2/2;
load mapping
sl = 20;
qy = [1 2 4 6 7 10 12 14 15 17 23 24];
load meta

i_locs = dir(db_path);
i_locs(1:2) = [];
for u = 1:12
	label = [];
	for q = 1:numel(i_locs)
		for i=1:8
			for m = 1:sl/2:numel(meta{u,q,i})-sl
				overlap(u,(m-1)*2/sl+1) = sum(meta{u,q,i}(m:m+sl-1) == 1);
				if overlap(u,(m-1)*2/sl+1)>= high
					label(end+1,1) = 1;
				elseif overlap(u,(m-1)*2/sl+1)<=low
					label(end+1,1) = 0;
				else
					label(end+1,1) = -1;
				end
			end
			
		end
	end
	mkdir(sprintf('./seg_eyebrow_eq_part_%d_threshold_%d_%d',sl,low,high));
	save(sprintf('./seg_eyebrow_eq_part_%d_threshold_%d_%d/au%02dlabel',sl,low,high,qy(u)), 'label');
end








for k = {'d_quarter'}%{'up','down'}
	feat_A = [];
	feat_E = [];
	label = [];
	subject_id = [];
	data_folder_name = sprintf('./seg_eyebrow_eq_part_%d_threshold_%d%d/%sdata',sl,low,high,k{1});
	if ~exist(data_folder_name,'dir')
		mkdir(data_folder_name);
	end

	for q = 1:numel(i_locs)
		i_loc = fullfile(db_path, i_locs(q).name);
		seqs = dir(i_loc);
		seqs(1:2) = [];
		
		N = numel(seqs);
		
		for i=1:N
			[A0,E0] = parload(fullfile(i_loc,seqs(i,1).name,'RASL',choice,'final.mat'));
			% 			A0 = A;
			% 			E0 = E;
			for m = 1:sl/2:numel(meta{1,q,i})-sl
				fns = m:m+ sl - 1;
				A = reshape(sum(A0(:,fns),2),[img_sz, img_sz]);
				E = reshape(sum(abs(E0(:,fns)),2),[img_sz, img_sz]);
				if strcmp(k{1},'up')
					A = A(1:img_sz/2, 1:img_sz);
					E = E(1:img_sz/2, 1:img_sz);
				elseif strcmp(k{1},'u_quarter')
					A = A(1:img_sz/4, 1:img_sz);
					E = E(1:img_sz/4, 1:img_sz);
				elseif strcmp(k{1},'down')
					A = A(img_sz/2 + 1:img_sz, 1:img_sz);
					E = E(img_sz/2 + 1:img_sz, 1:img_sz);
				elseif strcmp(k{1},'d_quarter')
					A = A(img_sz/4*3 + 1:img_sz, 1:img_sz);
					E = E(img_sz/4*3 + 1:img_sz, 1:img_sz);
				end
				A = mat2gray(A);
				E = mat2gray(E);
				A = uint8(A*255);
				E = uint8(E*255);
				feat_A_tmp = sf_calc_lbp(A,blk_sz,mapping);
				feat_E_tmp = sf_calc_lbp(E,blk_sz,mapping);
				feat_A = [feat_A; feat_A_tmp];
				feat_E = [feat_E; feat_E_tmp];
				subject_id(end+1,1) = q;
			end
			% 			for m = 1:2:length(po)
			% 				fns = po(m):po(m + 1);%frame numbers
			% 				A = reshape(sum(A0(:,fns),2),[img_sz, img_sz]);
			% 				E = reshape(sum(abs(E0(:,fns)),2),[img_sz, img_sz]);
			% 				A = mat2gray(A);
			% 				E = mat2gray(E);
			% 				A = uint8(A*255);
			% 				E = uint8(E*255);
			% 				feat_A_tmp = sf_calc_lbp(A,blk_sz,mapping);
			% 				feat_E_tmp = sf_calc_lbp(E,blk_sz,mapping);
			% 				feat_A = [feat_A; feat_A_tmp];
			% 				feat_E = [feat_E; feat_E_tmp];
			% 				label(end+1,1) = 1;
			% 				subject_id(end+1,1) = q;
			% 			end
			% 			feat_A_tmp = zeros(length(ne)/2,lbp_feat_sz);
			% 			feat_E_tmp = zeros(length(ne)/2,lbp_feat_sz);
			% 			for m = 1:2:length(ne)
			% 				fns = ne(m):ne(m + 1);%frame numbers
			% 				A = reshape(sum(A0(:,fns),2),[img_sz, img_sz]);
			% 				E = reshape(sum(abs(E0(:,fns)),2),[img_sz, img_sz]);
			% 				A = mat2gray(A);
			% 				E = mat2gray(E);
			% 				A = uint8(A*255);
			% 				E = uint8(E*255);
			%
			% 				feat_A_tmp = sf_calc_lbp(A,blk_sz,mapping);
			% 				feat_E_tmp = sf_calc_lbp(E,blk_sz,mapping);
			% 				feat_A = [feat_A; feat_A_tmp];
			% 				feat_E = [feat_E; feat_E_tmp];
			% 				label(end+1,1) = 0;
			% 				subject_id(end+1,1) = q;
			% 			end
			fprintf('%s %s T%03d\n',k{1},i_locs(q).name,i)
		end
	end
	parsave(data_folder_name,choice,feat_A,feat_E,subject_id);
	% 	save([data_folder_name sprintf('/feat_lbp_A_%s.mat',choice)],'feat_A');
	% 	save([data_folder_name sprintf('/feat_lbp_E_%s.mat',choice)],'feat_E');
	% 	save([data_folder_name '/train_label.mat'], 'label');
	% 	save([data_folder_name '/train_subject_id.mat'], 'subject_id');
end
figure