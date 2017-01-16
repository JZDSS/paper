% robust batch image alignment example
clc; clear; close all ;

% addpath
lib_path = 'Y:\paper\toolbox\matlab';
db_path = 'Y:\database\BP4D\BP4D-training';%
addpath(fullfile(lib_path,'RASL_Code\RASL_toolbox'));
addpath(fullfile(lib_path,'RASL_Code'));

%% var
i_name = 'snp_with_eyebrow';
o_name = [i_name,'_rasl'];
choices = {'train','test'};

%% define parameters
% display flag
raslpara.DISPLAY = 0 ;

% save flag
raslpara.saveStart = 0 ;
raslpara.saveEnd = 1 ;
raslpara.saveIntermedia = 0 ;


% for face images
raslpara.canonicalImageSize = [ 160 160  ];
raslpara.canonicalCoords = [ 1 160 ; ...
                             1 160  ];

% parametric tranformation model
raslpara.transformType = 'TRANSLATION'; 
% one of 'TRANSLATION', 'EUCLIDEAN', 'SIMILARITY', 'AFFINE','HOMOGRAPHY'

raslpara.numScales = 1 ; % if numScales > 1, we use multiscales

% main loop
raslpara.stoppingDelta = .01; % stopping condition of main loop
raslpara.maxIter = 2; % maximum iteration number of main loops

% inner loop
raslpara.inner_tol = 1e-6 ;
raslpara.inner_maxIter = 1000 ;
raslpara.continuationFlag = 1 ;
raslpara.mu = 1e-3 ;
raslpara.lambdac = 1.1 ; % lambda = lambdac/sqrt(m)

for k=1
    %choice = choices{k};
    i_locs = dir(db_path);
    i_locs(1:2) = [];
    for q = [23+2 23+8]%23+2:numel(i_locs)
       %% define images' path
        in_path = fullfile(db_path, i_locs(q).name);
        folders = dir(in_path);
        folders(1:2) = [];
        for i=4%1:numel(folders)
%             if q == 23+2 &&i<4
% 				continue;
% 			end
			% input path
            in_loc = fullfile(in_path,folders(i).name);
            out_loc = fullfile(in_path,folders(i).name,'RASL');
            imagePath = fullfile(in_loc) ;
            pointPath = fullfile(in_loc) ; % path to files containing initial feature coordinates

            % output path
            destRoot = fullfile(out_loc) ;
            destDir = fullfile(destRoot,i_name) ;
            if ~exist(destDir,'dir')
                mkdir(destRoot,i_name) ;
            end


            %% Get training images

            % get initial transformation
            transformationInit = 'IDENTITY';

            [fileNames, transformations, numImages] = get_training_images( imagePath, pointPath, i_name, raslpara.canonicalCoords, transformationInit) ;


            %% RASL main loop: do robust batch image alignment

            [D, Do, A, E, xi, numIterOuter, numIterInner ] = rasl_main(fileNames, transformations, numImages, raslpara, destDir);

            fprintf('==========%03d==========\n',i)
        end
    end
end