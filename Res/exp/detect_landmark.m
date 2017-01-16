% detect landmark points using face++ sdk
clc; clear ; close all;
set_path
% input your API_KEY & API_SECRET
addpath(fullfile(lib_path,'Facepp-Matlab-SDK'));
API_KEY = 'de8b2372fdc97c0e19f2f5429fcde0ad';
API_SECRET = 'zznvmwzQdT1avTr9BnkEikSLrE1C13-L';

% API_KEY = 'd45344602f6ffd77baeab05b99fb7730';
% API_SECRET = 'jKb9XJ_GQ5cKs0QOk6Cj1HordHFBWrgL';
api = facepp(API_KEY, API_SECRET);

% parameter
sets = {'train','test'};

for i=1   % training and test set
    i_loc = fullfile(db_path,sets{i});
    seqs = dir(fullfile(i_loc,[sets{i},'*']));
    s_len = length(seqs);
    for j=64:s_len   % for each sequence
            
        % find img of this sequence
        imgs = dir(fullfile(i_loc,seqs(j).name,'*.jpg'));
        
        % make output folder
        if ~exist(fullfile(i_loc,seqs(j).name,'landmark'),'dir')
            mkdir(fullfile(i_loc,seqs(j).name,'landmark'))
        end
        
        for k=1:numel(imgs) % for each image
            img = fullfile(i_loc,seqs(j).name,imgs(k).name);
            
            % Detect faces in the image, save result file
            rst = detect_file(api, img, 'all');
            face = rst{1}.face;
            if length(face) == 1
                face_i = face{1};
                rst2 = api.landmark(face_i.face_id, '83p');

                save(fullfile(i_loc,seqs(j).name,'landmark',imgs(k).name(1:end-4)),'rst2');
                fprintf('%s,%02d,%03d/%03d\n',sets{i},j,k,numel(imgs))
            else
                fprintf('%s,%02d,%03d: %d face detected\n',sets{i},j,k,length(face))
            end
            pause(.5)
        end
    end
end

