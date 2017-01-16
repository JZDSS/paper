% detect landmark points using face++ sdk
clc; clear ; %close all;
set_path
addpath('./util');
addpath(genpath(fullfile(lib_path,'AAM_ICCV2013')));

% var
choice = 'snp_with_eyebrow'; % shape_norm_partial_flex or shape_norm_partial or shape_norm

% load reference AAM coordinates
% if strcmp(choice,'shape_norm_partial')
%     load('ref_coord_41.mat');
%     ctrl_pt_idx = [1:19,21:22,25:26,30,34:37,56,59,60,65,67,68,71,72,76,80:83];
% elseif strcmp(choice,'shape_norm_partial_flex')
%     load('ref_coord_35.mat');
%     ctrl_pt_idx = [1:19,22,26,56,30,35:37,59,65,60,68,72,80:83];
% elseif strcmp(choice,'shape_norm')
    load('ref_coord_83.mat');
    ctrl_pt_idx = 1:83;
% end
    
sz = 160;

% parameter
% sets = {'train','test'};

for i=1% training and test set
    i_locs = dir(db_path);
    i_locs(1:2) = [];
    for q = 1:numel(i_locs)
        i_loc = fullfile(db_path, i_locs(q).name);
        seqs = dir(i_loc);
        seqs(1:2) = [];
        s_len = length(seqs);
        for j=1:s_len   % for each sequence
%             if j<s_len
%                 while ~exist(fullfile(i_loc,seqs(j+1).name,'landmark'), 'dir')
%                     fprintf('waiting\n');
%                     pause(100);
%                 end
%             else
%                 while ~exist(fullfile(db_path, i_locs(q+1).name, 'T1\landmark'), 'dir')
%                     fprintf('waiting\n');
%                     pause(100);
%                 end
%             end
            % find pts detection results of this sequence
            pts = dir(fullfile(i_loc,seqs(j).name,'landmark','*.mat'));
            load(fullfile(i_loc,seqs(j).name,'landmark',pts(1).name));
% 			if strcmp(choice,'snp_with_eyebrow')
% 				rst2{1,1}.result{1,1}.landmark.left_eyebrow_left_corner.y = rst2{1,1}.result{1,1}.landmark.left_eyebrow_left_corner.y - 20;
% 				rst2{1,1}.result{1,1}.landmark.left_eyebrow_lower_left_quarter.y = rst2{1,1}.result{1,1}.landmark.left_eyebrow_lower_left_quarter.y - 20;
% 				rst2{1,1}.result{1,1}.landmark.left_eyebrow_lower_middle.y = rst2{1,1}.result{1,1}.landmark.left_eyebrow_lower_middle.y - 20;
% 				rst2{1,1}.result{1,1}.landmark.left_eyebrow_lower_right_quarter.y = rst2{1,1}.result{1,1}.landmark.left_eyebrow_lower_right_quarter.y - 20;
% 				rst2{1,1}.result{1,1}.landmark.left_eyebrow_right_corner.y = rst2{1,1}.result{1,1}.landmark.left_eyebrow_right_corner.y - 20;
% 				rst2{1,1}.result{1,1}.landmark.left_eyebrow_upper_left_quarter.y = rst2{1,1}.result{1,1}.landmark.left_eyebrow_upper_left_quarter.y - 20;
% 				rst2{1,1}.result{1,1}.landmark.left_eyebrow_upper_middle.y = rst2{1,1}.result{1,1}.landmark.left_eyebrow_upper_middle.y - 20;
% 				rst2{1,1}.result{1,1}.landmark.left_eyebrow_upper_right_quarter.y = rst2{1,1}.result{1,1}.landmark.left_eyebrow_upper_right_quarter.y - 20;
% 				
% 				rst2{1,1}.result{1,1}.landmark.left_eyebrow_left_corner.x = rst2{1,1}.result{1,1}.landmark.left_eyebrow_left_corner.x - 20;
% 				rst2{1,1}.result{1,1}.landmark.right_eyebrow_right_corner.x = rst2{1,1}.result{1,1}.landmark.right_eyebrow_right_corner.x + 20;
% 				
% 				rst2{1,1}.result{1,1}.landmark.right_eyebrow_left_corner.y = rst2{1,1}.result{1,1}.landmark.right_eyebrow_left_corner.y - 20;
% 				rst2{1,1}.result{1,1}.landmark.right_eyebrow_lower_left_quarter.y = rst2{1,1}.result{1,1}.landmark.right_eyebrow_lower_left_quarter.y - 20;
% 				rst2{1,1}.result{1,1}.landmark.right_eyebrow_lower_middle.y = rst2{1,1}.result{1,1}.landmark.right_eyebrow_lower_middle.y - 20;
% 				rst2{1,1}.result{1,1}.landmark.right_eyebrow_lower_right_quarter.y = rst2{1,1}.result{1,1}.landmark.right_eyebrow_lower_right_quarter.y - 20;
% 				rst2{1,1}.result{1,1}.landmark.right_eyebrow_right_corner.y = rst2{1,1}.result{1,1}.landmark.right_eyebrow_right_corner.y - 20;
% 				rst2{1,1}.result{1,1}.landmark.right_eyebrow_upper_left_quarter.y = rst2{1,1}.result{1,1}.landmark.right_eyebrow_upper_left_quarter.y - 20;
% 				rst2{1,1}.result{1,1}.landmark.right_eyebrow_upper_middle.y = rst2{1,1}.result{1,1}.landmark.right_eyebrow_upper_middle.y - 20;
% 				rst2{1,1}.result{1,1}.landmark.right_eyebrow_upper_right_quarter.y = rst2{1,1}.result{1,1}.landmark.right_eyebrow_upper_right_quarter.y - 20;
% 			end
			
            landmark_names = fieldnames(rst2{1}.result{1}.landmark);

            % make output folder
            if ~exist(fullfile(i_loc,seqs(j).name,choice),'dir')
                mkdir(fullfile(i_loc,seqs(j).name,choice))
            end

            for k=1:numel(pts) % for each image
                im = imread(fullfile(i_loc,seqs(j).name,[pts(k).name(1:end-3),'jpg']));
				im = circshift(im,[10,0]);
                [h,w,~] = size(im);

                load(fullfile(i_loc,seqs(j).name,'landmark',pts(k).name));
                landmark_pts = rst2{1}.result{1}.landmark;

                for kk = 1:length(landmark_names)
                    pt = landmark_pts.(landmark_names{kk});
                    pts_cur(kk,:) = [pt.x*w/100, pt.y*h/100];
                end


                Iw = warp_image(ref_coord, pts_cur(ctrl_pt_idx,:), im); % save coord_frame
                Iw = imresize(Iw, [sz sz]);

                % save results
                imwrite(uint8(255*sf_minmax_norm(Iw)),fullfile(i_loc,seqs(j).name,choice,[pts(k).name(1:end-3),'jpg']),'jpg');
                fprintf('%s,%02d,%03d/%03d\n',i_locs(q).name,j,k,numel(pts))

            end
        end
    end
end

