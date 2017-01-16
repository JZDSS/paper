% detect landmark points using face++ sdk
clc; clear ; close all;
set_path
% input your API_KEY & API_SECRET
addpath(fullfile(lib_path,'Facepp-Matlab-SDK'));
API_KEY = 'ed9fe1b425ddede0e71feec1d49e9434';
API_SECRET = 'Ds4SleI6YbYFDsYfBPs6uITXXLW-wetG';

% API_KEY = 'd45344602f6ffd77baeab05b99fb7730';
% API_SECRET = 'jKb9XJ_GQ5cKs0QOk6Cj1HordHFBWrgL';
api = facepp(API_KEY, API_SECRET);

% parameter
% sets = {'train','test'};

for i=1% training and test set
    i_locs = dir(db_path);
    i_locs(1:2) = [];
    for q = 23+4:numel(i_locs)
        i_loc = fullfile(db_path, i_locs(q).name);
        seqs = dir(i_loc);
        seqs(1:2) = [];
        s_len = length(seqs);
        for j=1:s_len   % for each sequence
            if q==23+4 && j<7
                continue;
            end
            % find img of this sequence
            imgs = dir(fullfile(i_loc,seqs(j).name,'*.jpg'));

            % make output folder
            if ~exist(fullfile(i_loc,seqs(j).name,'landmark'),'dir')
                mkdir(fullfile(i_loc,seqs(j).name,'landmark'))
            end

            for k=1:numel(imgs) % for each image
            if q==23+4 && j==7 &&k<438
                continue;
            end
                img = fullfile(i_loc,seqs(j).name,imgs(k).name);

                % Detect faces in the image, save result file
                rst = detect_file(api, img, 'all');
                face = rst{1}.face;
                if length(face) == 1
                    face_i = face{1};
                    rst2 = api.landmark(face_i.face_id, '83p');

                    save(fullfile(i_loc,seqs(j).name,'landmark',imgs(k).name(1:end-4)),'rst2');
                    fprintf('%s,%02d,%03d/%03d\n',i_locs(q).name,j,k,numel(imgs))
                else
                    fprintf('%s,%02d,%03d: %d face detected\n',i_locs(q).name,j,k,length(face))
                end
                pause(1)
            end
        end
    end
end

