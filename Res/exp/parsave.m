function parsave(data_folder_name,choice, feat_A,feat_E,subject_id,type)
save([data_folder_name sprintf('/feat_%s_A_%s.mat', type, choice)], 'feat_A');
save([data_folder_name sprintf('/feat_%s_E_%s.mat', type, choice)], 'feat_E');
save([data_folder_name '/train_subject_id.mat'], 'subject_id');
end