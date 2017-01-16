% extract feature
clc; clear; close all;
set_path
addpath(fullfile(lib_path,'lpq'));

% var
choice = 'shape_norm'; % shape_norm_partial or shape_norm

sets = {'train','test'};

% lpq para
feat_A = [];
feat_E = [];
img_sz = 160;
blk_sz = 20;
lpq_feat_sz = 256*(img_sz/blk_sz)^2;

for k=1:2
    in_loc = fullfile(db_path,sets{k});
    seqs = dir(fullfile(in_loc,[sets{k},'*']));
    
    N = numel(seqs);
    feat_A_tmp = zeros(N,lpq_feat_sz);
    feat_E_tmp = zeros(N,lpq_feat_sz);
    for i=1:N
        load(fullfile(in_loc,seqs(i,1).name,'RASL',choice,'final.mat'));
        
        A = reshape(sum(A,2),[img_sz, img_sz]);
        E = reshape(sum(abs(E),2),[img_sz, img_sz]);
        
        A = mat2gray(A);
        E = mat2gray(E);
        
        feat_A_tmp(i,:) = calcLPQ(A,blk_sz);
        feat_E_tmp(i,:) = calcLPQ(E,blk_sz);
        fprintf('%s %03d\n',sets{k},i)
    end
    feat_A = [feat_A; feat_A_tmp];
    feat_E = [feat_E; feat_E_tmp];
end

save(sprintf('./data/feat_lpq_A_%s.mat',choice),'feat_A');
save(sprintf('./data/feat_lpq_E_%s.mat',choice),'feat_E');
