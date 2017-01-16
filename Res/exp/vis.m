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
img_sz = 160;
sl = 20;
qy = [12 14 1 2 4 6 7 10  15 17 23 24];

% i_locs = dir(db_path);
% i_locs(1:2) = [];
% dele = cell(41,8);
% for q = 1:numel(i_locs)
% 	i_loc = fullfile(db_path, i_locs(q).name);
% 	seqs = dir(i_loc);
% 	seqs(1:2) = [];
% 	N = numel(seqs);
% 	for i=1:N
% 		nn = 1;
% 		meta_name = [i_locs(q).name sprintf('_T%d.csv',i)];
% 		t = readtable(fullfile(meta_path, meta_name));
% 		check = t.x0;
% 		for j = 1:numel(check)
% 			if ~exist(fullfile(db_path,i_locs(q).name,sprintf(...
% 					'T%d/shape_norm_partial/%04d.jpg',i,check(j))),'file')...
% 					&&~exist(fullfile(db_path,i_locs(q).name,sprintf(...
% 					'T%d/shape_norm_partial/%03d.jpg',i,check(j))),'file')
% 				dele{q,i}(end+1) = j;
% 			end
% 		end
% 		for u= 1:12;
% 			k = qy(u);
% 			meta{u,q,i} = t.(field{k});
% 			meta{u,q,i}(dele{q,i}) = [];
% 		end
% 	end
% end
load meta

i_locs = dir(db_path);
i_locs(1:2) = [];
for q = 6:numel(i_locs)
	i_loc = fullfile(db_path, i_locs(q).name);
	seqs = dir(i_loc);
	seqs(1:2) = [];
	N = numel(seqs);
	for i=1:N
		nn = 0;
		A0 = [];
		E0 = [];
		for u = 1:12
			for m = 1:sl/2:numel(meta{u,q,i})-sl
				overlap(u,(m-1)*2/sl+1) = sum(meta{u,q,i}(m:m+sl-1) == 1);
				if overlap(u,(m-1)*2/sl+1)>sl/2
					label(u,(m-1)*2/sl+1) = 1;
				else
					label(u,(m-1)*2/sl+1) = 0;
				end
			end
		end
		for m = 1:sl/2:numel(meta{u,q,i})-sl
			nn = nn+1;
			if rand()>0.05
				fprintf('pass\n');
				continue;
			end
			fprintf([seqs(i,1).name '\n']);
			if isempty(A0)
				[A0,E0] = parload(fullfile(i_loc,seqs(i,1).name,'RASL',choice,'final.mat'));
			end
			fns = m:m+ sl - 1;
			A = reshape(sum(A0(:,fns),2),[img_sz, img_sz]);
			E = reshape(sum(abs(E0(:,fns)),2),[img_sz, img_sz]);
			% 				if k<=7
			% 					A = A(1:img_sz/2, 1:img_sz);
			% 					E = E(1:img_sz/2, 1:img_sz);
			% 				else
			% 					A = A(img_sz/2 + 1:img_sz, 1:img_sz);
			% 					E = E(img_sz/2 + 1:img_sz, 1:img_sz);
			% 				end
			A = mat2gray(A);
			E = mat2gray(E);
			A = uint8(A*255);
			E = uint8(E*255);
			
			subplot(2,1,1)
			imshow(A);
			tit = sprintf('   au   :12 14 01 02 04 06 07 10 15 17 23 24\n label  :%02d %02d %02d %02d %02d %02d %02d %02d %02d %02d %02d %02d\noverlap:%02d %02d %02d %02d %02d %02d %02d %02d %02d %02d %02d %02d',...
				label(1,(m-1)*2/sl+1),...
				label(2,(m-1)*2/sl+1),...
				label(3,(m-1)*2/sl+1),...
				label(4,(m-1)*2/sl+1),...
				label(5,(m-1)*2/sl+1),...
				label(6,(m-1)*2/sl+1),...
				label(7,(m-1)*2/sl+1),...
				label(8,(m-1)*2/sl+1),...
				label(9,(m-1)*2/sl+1),...
				label(10,(m-1)*2/sl+1),...
				label(11,(m-1)*2/sl+1),...
				label(12,(m-1)*2/sl+1),...
				overlap(1,(m-1)*2/sl+1),...
				overlap(2,(m-1)*2/sl+1),...
				overlap(3,(m-1)*2/sl+1),...
				overlap(4,(m-1)*2/sl+1),...
				overlap(5,(m-1)*2/sl+1),...
				overlap(6,(m-1)*2/sl+1),...
				overlap(7,(m-1)*2/sl+1),...
				overlap(8,(m-1)*2/sl+1),...
				overlap(9,(m-1)*2/sl+1),...
				overlap(10,(m-1)*2/sl+1),...
				overlap(11,(m-1)*2/sl+1),...
				overlap(12,(m-1)*2/sl+1));
			title(tit);
			subplot(2,1,2)
			imshow(E);
			mkdir('./vis');
			print(1,sprintf('./vis/%s T%03d seq%d',i_locs(q).name,i,nn),'-dpng');
			
		end
	end
end



			