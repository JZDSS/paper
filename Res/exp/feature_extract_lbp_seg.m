% extract feature lbp, from training and test set
warning off
clc; clear; close all;
set_path
addpath(fullfile(lib_path,'lbp'));

% var
choice = 'shape_norm_partial'; % shape_norm_partial or shape_norm
field = {'x1', 'x2', '', 'x4', '', 'x6', 'x7', ...
    '', '', 'x10', '', 'x12', '', 'x14', 'x15', ...
    '', 'x17', '', '', '', '', '', 'x23', 'x24'};

sets = {'train','test'};

% lbp para

img_sz = 160;
blk_sz = 20;
lbp_feat_sz = 59*(img_sz/blk_sz)^2;
load mapping

for k= 12%[1 2 4 6 7 10 12 14 15 17 23 24]
	feat_A = [];
	feat_E = [];
	label = [];
	subject_id = [];
	data_folder_name = sprintf('./segment_level/au%02ddata',k);
	if ~exist(data_folder_name,'dir')
		mkdir(data_folder_name);
	end
    i_locs = dir(db_path);
    i_locs(1:2) = [];
	for q = 1:numel(i_locs)
        i_loc = fullfile(db_path, i_locs(q).name);
        seqs = dir(i_loc);
        seqs(1:2) = [];

        N = numel(seqs);

		for i=1:N
            meta_name = [i_locs(q).name sprintf('_T%d.csv',i)];
            t = readtable(fullfile(meta_path, meta_name));
            check = t.x0;
            meta = t.(field{k});
            dele = [];
            for j = 1:numel(check)
                if ~exist(fullfile(db_path,i_locs(q).name,sprintf(...
                        'T%d/shape_norm_partial/%04d.jpg',i,check(j))),'file')...
					&&~exist(fullfile(db_path,i_locs(q).name,sprintf(...
                        'T%d/shape_norm_partial/%03d.jpg',i,check(j))),'file')
                    dele(end+1) = j;
                end
            end
            meta(dele) = [];
			if isempty(meta)
				continue;
			end
            dif = diff(meta(:))';
            po = find(dif ~= 0);
            if meta(1)==1
                po = [0, po];
            end
            po(1:2:end) = po(1:2:end) + 1;
            if mod(numel(po),2)
				po(end+1) = numel(meta);
			end
			ne = po;
            ne(1:2:end) = ne(1:2:end) - 1;
            ne(2:2:end) = ne(2:2:end) + 1;
			if isempty(ne)
				ne = [1 numel(meta)];
			else
				if ne(1)==0
					ne = ne(2:end);
				else
					ne = [1 ne];
				end
				if ne(end)>numel(meta)
					ne = ne(1:end - 1);
				else
					ne = [ne numel(meta)];
				end
			end

			load(fullfile(i_loc,seqs(i,1).name,'RASL',choice,'final.mat'));
			A0 = A;
			E0 = E;
			for m = 1:2:length(po)
				fns = po(m):po(m + 1);%frame numbers
				A = reshape(sum(A0(:,fns),2),[img_sz, img_sz]);
				E = reshape(sum(abs(E0(:,fns)),2),[img_sz, img_sz]);
				A = mat2gray(A);
				E = mat2gray(E);
				A = uint8(A*255);
				E = uint8(E*255);
				feat_A_tmp = sf_calc_lbp(A,blk_sz,mapping);
				feat_E_tmp = sf_calc_lbp(E,blk_sz,mapping);
				feat_A = [feat_A; feat_A_tmp];
				feat_E = [feat_E; feat_E_tmp];
				label(end+1,1) = 1;
				subject_id(end+1,1) = q;
			end
			feat_A_tmp = zeros(length(ne)/2,lbp_feat_sz);
			feat_E_tmp = zeros(length(ne)/2,lbp_feat_sz);
			for m = 1:2:length(ne)
				fns = ne(m):ne(m + 1);%frame numbers
				A = reshape(sum(A0(:,fns),2),[img_sz, img_sz]);
				E = reshape(sum(abs(E0(:,fns)),2),[img_sz, img_sz]);
				A = mat2gray(A);
				E = mat2gray(E);
				A = uint8(A*255);
				E = uint8(E*255);

				feat_A_tmp = sf_calc_lbp(A,blk_sz,mapping);
				feat_E_tmp = sf_calc_lbp(E,blk_sz,mapping);
				feat_A = [feat_A; feat_A_tmp];
				feat_E = [feat_E; feat_E_tmp];
				label(end+1,1) = 0;
				subject_id(end+1,1) = q;
			end
            fprintf('au%02d_%s %03d\n',k,i_locs(q).name,i)
		end
	end
	save([data_folder_name sprintf('/feat_lbp_A_%s.mat',choice)],'feat_A');
	save([data_folder_name sprintf('/feat_lbp_E_%s.mat',choice)],'feat_E');
	save([data_folder_name '/train_label.mat'], 'label');
	save([data_folder_name '/train_subject_id.mat'], 'subject_id');
end
