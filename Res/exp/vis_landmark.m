% visualize facial landmark points
clc; clear ; close all;
set_path

% load reference AAM coordinates
load ref_coord_83
sz = 160;

% parameter
sets = {'train','test'};

for i=1%:2   % training and test set
    i_loc = fullfile(db_path,sets{i});
    seqs = dir(fullfile(i_loc,[sets{i},'*']));
    s_len = length(seqs);
    for j=14%:s_len   % for each sequence

        % find pts detection results of this sequence
        pts = dir(fullfile(i_loc,seqs(j).name,'landmark','*.mat'));
        load(fullfile(i_loc,seqs(j).name,'landmark',pts(1).name));

        % make output folder
        if ~exist(fullfile(i_loc,seqs(j).name,'shape_norm'),'dir')
            mkdir(fullfile(i_loc,seqs(j).name,'shape_norm'))
        end
        
        for k=1:numel(pts) % for each image
            im = imread(fullfile(i_loc,seqs(j).name,[pts(k).name(1:end-3),'jpg']));
            [h,w,~] = size(im);

            load(fullfile(i_loc,seqs(j).name,'landmark',pts(k).name));
            landmark_pts = rst2{1}.result{1}.landmark;

            [img_height,img_width,~] = size(im);
            landmark_points = rst2{1}.result{1}.landmark;
            landmark_names = fieldnames(landmark_points);

            % Draw facial key points
            figure(1), imshow(im), hold on
            for kk = 38:55 %1 : length(landmark_names)
                pt = getfield(landmark_points, landmark_names{kk});
                scatter(pt.x * img_width / 100, pt.y * img_height / 100, 'g.');
%                 text(pt.x * img_width / 100, pt.y * img_height / 100, num2str(kk), 'Color', 'r');
                
            end
            hold off
            pause()
        end
    end
end
