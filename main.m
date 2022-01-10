function main(folder_path)

% set some usefull flags 
flag_load_data = 0;         % 1 - data will be loaded from mat files, 0 - data will be extracted from xlsx files
flag_save_data = 0;         % 1 - data will be saved, 0 - data wont be saved

% define our data matrix that contains sturctures
files_filepath = folder_path;
mat_filepath = 'mat files';

% extract data from xlsx files
all_data = extract_data(files_filepath, mat_filepath, flag_load_data, flag_save_data);

% extract features from the data
test_feat = feat_set(all_data);

% feature selection process - load the mat file and remove unnecessary
% features
load('mat files\first features to remove ind.mat', 'feat_removed_nan_indices');
load('mat files\second features to remove ind.mat', 'feature_removed_indices');
load('mat files\best features.mat', 'best_features');

test_feat(:,find(feat_removed_nan_indices)) = [];
test_feat(:,feature_removed_indices) = [];
test_feat = [test_feat(:,best_features), test_feat(:,end)];

% classifier - load the Random forest model
load('mat files\BestMDL.mat', 'ensemble_MDL');

% predict on the data
prediction_test = predict(ensemble_MDL, test_feat(:,1:end-1)); % predictions on test set

C = confusionmat(test_feat(:,end),prediction_test);
figure;
confusionchart(C, {'weekdays', 'weekends'});
end