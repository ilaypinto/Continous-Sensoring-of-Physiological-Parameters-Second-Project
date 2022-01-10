function main(folder_path)

% set some usefull flags 
flag = 0;         % replacing for all the falgs we used in main workflow

% define our data matrix that contains sturctures
files_filepath = folder_path;
mat_filepath = 'mat files';

% extract data from xlsx files
all_data = extract_data(files_filepath, mat_filepath, flag, flag);

% extract features from the data
test_feat = feat_set(all_data,flag,flag,'no name');

% feature selection process - load the mat file and remove unnecessary
% features
load('mat files\logical features to remove.mat', 'features_not_removed_idx');
load('mat files/SFS data','Indx_sfs', 'history_sfs');

test_feat(:,~features_not_removed_idx) = [];
test_feat = [test_feat(:,Indx_sfs), test_feat(:,end)];

% classifier - load the Random forest model
load('mat files\BestMDL.mat', 'ensemble_MDL');

% predict on the data
prediction_test = predict(ensemble_MDL, test_feat(:,1:end-1)); % predictions on test set

C = confusionmat(test_feat(:,end),prediction_test);
figure;
confusionchart(C, {'weekdays', 'weekends'});
end