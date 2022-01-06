clc; clear all; close all;
% this is the main script for our workflow

% set some usefull flags
flag_load_data = 1;         % 1 - data will be loaded from mat files, 0 - data will be extracted from xlsx files
flag_load_feat = 0;         % 1 - features will be loaded from mat files, 0 - features will be extracted from data


% define our data matrix that contains sturctures
files_filepath = 'BHQ files';
mat_filepath = 'mat files';

% define our features names
features_names = split('load_var working_day sport stayed_home late_hangout studying_day family_time day_hangout wifi_sum no_wifi bluetooth_sum on_off_switches battery_start battery_mid battery_end first_charge_time calls_num calls_sum calls_max calls_max_time in_vehicle on_foot tilting location_sum location_max location_max_time sleep_time wake_time sleep_duration light_sum load_var_norm');

% extract data from xlsx files
all_data = extract_data(files_filepath, mat_filepath, flag_load_data);

% splot the data into train & test sets containing different people data
train_data = all_data(1:round(0.8*length(all_data)));
test_data = all_data(round(0.8*length(all_data)) + 1:end);

% extract features for train & test sets
train_feat = feat_set(train_data);
test_feat = feat_set(test_data);

% feature selection process
% correlations tests
[feat_feat_corr, weights, best_feat_label, features_removed_names,...
    feature_removed_indices, new_feat_matrix, new_feat_names, highest_corr_under_thresh,...
    feat_names_too_many_nan, feat_removed_nan_indices]...
    = corr_analysis(train_feat, features_names);

% SFS - ussing filter method with CFS criterion
best_features = [];
CFS = 0;
while true
    for i = 1:length(weights)
        if ismember(i,best_features)
            continue
        end
        curr_cfs = calculate_CFS(weights, feat_feat_corr, [best_features i]);
        if curr_cfs > CFS
            CFS = curr_cfs;
            feat_to_add = i;
        end
    end
    if ~exist('feat_to_add', 'var')
        break
    end
    best_features = [best_features, feat_to_add];
    clear feat_to_add
end

best_feat_names = new_feat_names(best_features);

% remove features from train & test sets - and take only the selected
% best features
train_feat(:,feat_removed_nan_indices) = [];
train_feat(:,feature_removed_indices) = [];

test_feat(:,feat_removed_nan_indices) = [];
test_feat(:,feature_removed_indices) = [];

train_feat = [train_feat(:,best_features), train_feat(:,end)];
test_feat = [test_feat(:,best_features), test_feat(:,end)];

% classifier - linear discriminant
MDL = fitcdiscr(train_feat(:,1:end-1), train_feat(:,end), 'DiscrimType', 'linear', ...
    'Gamma', 0, 'FillCoeffs', 'off', 'ClassNames', [0; 1]);

prediction_train = predict(MDL, train_feat(:,1:end-1));
prediction_test = predict(MDL, test_feat(:,1:end-1));

figure;
heatmap(abs(corr(train_feat(:,1:end-1), 'type', 'Spearman', 'rows', 'complete')));
title('Feature Correlation after CFS- BHQ')

figure;
gplotmatrix(train_feat(:,1:end-1),[],train_feat(:,end));
title('Gplot- BHQ');


