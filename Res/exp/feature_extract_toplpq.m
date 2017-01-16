% extract feature lbp, from training and test set
clc; clear; close all;
set_path
addpath(fullfile(lib_path,'TOP_LBP'));
para = set_TOPLPQ_para;

% var
choice = 'shape_norm_partial'; % shape_norm_partial or shape_norm, could be SIFTflow, but in for this project
sets = {'train','test'};

feat_A = [];
feat_E = [];
img_sz = 160;
blk_sz = 20;
lbp_feat_sz = 3*256*(img_sz/blk_sz)^2;


for k=1% training and test set
    i_locs = dir(db_path);
    i_locs(1:2) = [];
    for q = 1:numel(i_locs)
        i_loc = fullfile(db_path, i_locs(q).name);
        seqs = dir(i_loc);
        seqs(1:2) = [];

        N = numel(seqs);
        feat_A_tmp = zeros(N,lbp_feat_sz);
        feat_E_tmp = zeros(N,lbp_feat_sz);
        for i=1:N
            [A,E] = load_parfor(i_loc,seqs(i,1).name,'RASL',choice,'final.mat');

            A = mat2gray(A);
            E = mat2gray(E);

            A = uint8(A*255);
            E = uint8(E*255);

            A = reshape(A,[img_sz, img_sz, size(A,2)]);
            E = reshape(E,[img_sz, img_sz, size(E,2)]);

            feat_A_tmp(i,:) = calcTOPLPQ(A,blk_sz,para);
            feat_E_tmp(i,:) = calcTOPLPQ(E,blk_sz,para);
            fprintf('%s %03d\n',i_locs(q).name,i)
        end
        feat_A = [feat_A; feat_A_tmp];
        feat_E = [feat_E; feat_E_tmp];
    end
end

save(sprintf('./data/feat_toplpq_A_%s.mat',choice),'feat_A');
save(sprintf('./data/feat_toplpq_E_%s.mat',choice),'feat_E');

