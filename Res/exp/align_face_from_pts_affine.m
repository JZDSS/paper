% detect landmark points using face++ sdk
clc; clear ; close all;
set_path

% parameter
sets = {'train','test'};

for i=1% training and test set
    i_locs = dir(db_path);
    i_locs(1:2) = [];
    for q = 1:numel(i_locs)
        i_loc = fullfile(db_path, i_locs(q).name);
        seqs = dir(i_loc);
        seqs(1:2) = [];
        s_len = length(seqs);
        for j=1:s_len   % for each sequence

            % find pts detection results of this sequence
            pts = dir(fullfile(i_loc,seqs(j).name,'landmark','*.mat'));

            % make output folder
            if ~exist(fullfile(i_loc,seqs(j).name,'pts_affine'),'dir')
                mkdir(fullfile(i_loc,seqs(j).name,'pts_affine'))
            end

            for k=1:numel(pts) % for each image
                im = imread(fullfile(i_loc,seqs(j).name,[pts(k).name(1:end-3),'jpg']));
                [img_height,img_width,~] = size(im);

                load(fullfile(i_loc,seqs(j).name,'landmark',pts(k).name));
                landmark_points = rst2{1}.result{1}.landmark;
                landmark_names = fieldnames(landmark_points);

                % Draw facial key points
                figure(1), imshow(im), hold on
                for j = 1 : length(landmark_names)
                    pt = getfield(landmark_points, landmark_names{j});
                    scatter(pt.x * img_width / 100, pt.y * img_height / 100, 'g.');
                end
                hold off
                % Detect faces in the image, save result file
    %             rst = detect_file(api, img, 'all');
    %             face = rst{1}.face;
    %             if length(face) == 1
    %                 face_i = face{1};
    %                 rst2 = api.landmark(face_i.face_id, '83p');
    % 
    %                 save(fullfile(i_loc,seqs(j).name,'landmark',imgs(k).name(1:end-4)),'rst2');
    %                 fprintf('%s,%02d,%03d/%03d\n',sets{i},j,k,numel(imgs))
    %             else
    %                 fprintf('%s,%02d,%03d: %d face detected\n',sets{i},j,k,length(face))
    %             end
            end
        end
    end
end

