% extract feature lbp, from training and test set
clc; clear; close all;
set_path
addpath(fullfile(lib_path,'TOP_LBP'));
para = set_TOPLBP_para;

% var
choice = 'shape_norm'; % shape_norm_partial or shape_norm, could be SIFTflow, but in for this project
sets = {'train','test'};

feat_A = [];
feat_E = [];
img_sz = 160;
blk_sz = 20;
lbp_feat_sz = 3*59*(img_sz/blk_sz)^2;

for k=1:2
    in_loc = fullfile(db_path,sets{k});
    folders = dir(fullfile(in_loc,[sets{k},'*']));
    N = numel(folders);
    
    feat_A_tmp = zeros(N,lbp_feat_sz);
    feat_E_tmp = zeros(N,lbp_feat_sz);
    parfor i=1:N
        [A,E] = load_parfor(in_loc,folders(i,1).name,'RASL',choice,'final.mat');
        
        A = mat2gray(A);
        E = mat2gray(E);
        
        A = uint8(A*255);
        E = uint8(E*255);
        
        A = reshape(A,[img_sz, img_sz, size(A,2)]);
        E = reshape(E,[img_sz, img_sz, size(E,2)]);
        
        feat_A_tmp(i,:) = calcTOPLBP(A,blk_sz,para);
        feat_E_tmp(i,:) = calcTOPLBP(E,blk_sz,para);
        fprintf('%s seq %02d finished\n',choice, i)
    end
    feat_A = [feat_A; feat_A_tmp];
    feat_E = [feat_E; feat_E_tmp];
end

save(sprintf('./data/feat_toplbp_A_%s.mat',choice),'feat_A');
save(sprintf('./data/feat_toplbp_E_%s.mat',choice),'feat_E');

