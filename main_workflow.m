clc; clear all; close all;
% this is the main script for our workflow

% set some usefull flags
flag_load_data = 1;         % 1 - data will be loaded from mat files, 0 - data will be extracted from xlsx files
flag_save_data = 1;         % 1 - data will be saved, 0 - data wont be saved
flag_load_feat = 1;         % 1 - features will be loaded from mat files, 0 - features will be extracted from data
flag_save_fest = 1;
flag_load_SFS  = 1;

% define our data paths
files_filepath = 'BHQ files';
mat_filepath = 'mat files';

% define our features names
features_names = split('load_var working_day sport stayed_home late_hangout studying_day family_time day_hangout wifi_sum no_wifi bluetooth_sum on_off_switches battery_start battery_mid battery_end first_charge_time calls_num calls_sum calls_max calls_max_time in_vehicle on_foot tilting location_sum location_max location_max_time sleep_time wake_time sleep_duration light_sum load_var_norm wifi_samp bluetooth_samp battery_samp activity_samp location_samp light_samp');

% define the categorical and numerical features indices
catg_feat = (2:8);
num_feat = [1, 9:37];

% extract data from xlsx files
all_data = extract_data(files_filepath, mat_filepath, flag_load_data, flag_save_data);

% splot the data into train & test sets containing different people data
train_data = all_data(1:round(0.8*length(all_data)));
test_data = all_data(round(0.8*length(all_data)) + 1:end);

% extract features for train & test sets
train_feat = feat_set(train_data, flag_load_feat, flag_save_fest, 'train feat');
test_feat = feat_set(test_data, flag_load_feat, flag_save_fest, 'test feat');

% feature selection process
% correlations tests
[feat_feat_corr, weights, best_feat_label, features_removed_names, features_not_removed_idx,...
    highest_corr_under_thresh, feat_names_nans] = corr_analysis(train_feat, features_names, catg_feat);

save('mat files/logical features to remove', 'features_not_removed_idx');

% remove features from train & test sets 
features_names(~features_not_removed_idx) = [];
train_feat(:,~features_not_removed_idx) = [];
test_feat(:,~features_not_removed_idx) = [];

%% SFS - ussing filter method with CFS criterion
if ~flag_load_SFS
    N = 100; % num of trees
    learners = templateTree("MaxNumSplits", 50, "MinLeafSize", 10, 'Reproducible', true); % basic trees
    options_mdl = statset('UseParallel', true); % options for fitcensemble
    
    options_sfs = statset('Display', 'iter', 'UseParallel', true);  % UseParallel to speed up the computations and Display so we can see the progress
    
    % SFS- using loss function as criteria
    fun = @(Xtrain,Ytrain,Xtest,Ytest)loss(fitcensemble(Xtrain, Ytrain, 'Method', 'Bag',...
        'NumLearningCycles', N, 'Learners', learners, 'options', options_mdl), Xtest, Ytest);
    
    [Indx_sfs, history_sfs] = sequentialfs(fun, train_feat(:,1:end-1), train_feat(:,end), 'options', options_sfs);
    save('mat files/SFS data','Indx_sfs', 'history_sfs')
else
    load('mat files/SFS data','Indx_sfs', 'history_sfs');
end

best_feat_names = features_names(Indx_sfs);
train_feat = [train_feat(:,Indx_sfs) train_feat(:,end)];
test_feat = [test_feat(:,Indx_sfs), test_feat(:,end)];

figure; % correlation matrix
heatmap(abs(feat_feat_corr));
title('Feature Correlation after correlation filtering  - BHQ')

figure; % correlation matrix
beat_feat_feat_corr = feat_feat_corr(:,Indx_sfs);
beat_feat_feat_corr = beat_feat_feat_corr(Indx_sfs,:);
heatmap(abs(beat_feat_feat_corr));
title('Feature Correlation after SFS - BHQ')

figure; % gplot
gplotmatrix(train_feat(:,1:end-1),[],train_feat(:,end));
title('Gplot- BHQ');

% %% SFS - filter method with CFS criterion #### we got better results with
% wraper method ####
% best_features = [];
% CFS = 0;
% while true
%     for i = 1:length(weights)
%         if ismember(i,best_features)
%             continue
%         end
%         curr_cfs = calculate_CFS(weights, abs(feat_feat_corr), [best_features i]);
%         if curr_cfs > CFS
%             CFS = curr_cfs;
%             feat_to_add = i;
%         end
%     end
%     if ~exist('feat_to_add', 'var')
%         break
%     end
%     best_features = [best_features, feat_to_add];
%     clear feat_to_add
% end
% best_feat_names = features_names(best_features);
% save('mat files/best features','best_features');
% 
% 
% train_feat = [train_feat(:,best_features), train_feat(:,end)];
% test_feat = [test_feat(:,best_features), test_feat(:,end)];



%% classifier - linear discriminant
disc_MDL = fitcdiscr(train_feat(:,1:end-1), train_feat(:,end), 'DiscrimType', 'linear', ...
    'Gamma', 0, 'FillCoeffs', 'off', 'ClassNames', [0; 1]);

prediction_train = predict(disc_MDL, train_feat(:,1:end-1));
prediction_test = predict(disc_MDL, test_feat(:,1:end-1));

CM_train_ld = confusionmat(train_feat(:,end), prediction_train);
figure;
confusionchart(CM_train_ld, {'weekdays', 'weekends'});
title('confusion matrix - linear discriminant: train set');

CM_test_ld = confusionmat(test_feat(:,end), prediction_test);
figure;
confusionchart(CM_test_ld, {'weekdays', 'weekends'});
title('confusion matrix - linear discriminant: test set');


%% classifier - Random forest
N = 100; % num of trees
learners = templateTree("MaxNumSplits", 30, "MinLeafSize", 3, 'Reproducible', true); % basic trees
options = statset('UseParallel', true, 'UseSubstreams', true, 'Streams', RandStream('mlfg6331_64')); % options for fitcensemble
optimizer.MaxObjectiveEvaluations = 300; 
optimizer.MaxTime = 60;
optimizer.UseParallel = 1;
ensemble_MDL = fitcensemble(train_feat(:,1:end-1), train_feat(:,end), 'Method', 'Bag',...
    'NumLearningCycles', N, 'Learners', learners, 'options', options, 'ClassNames', [0 1],...
    'OptimizeHyperparameters',{'MinLeafSize', 'NumLearningCycles', 'MaxNumSplits','NumVariablesToSample','SplitCriterion'},...
    'HyperparameterOptimizationOptions', optimizer); % RF model and its optimization

[prediction_train, scores] = predict(ensemble_MDL, train_feat(:,1:end-1)); % predictions
prediction_test = predict(ensemble_MDL, test_feat(:,1:end-1)); % predictions

CM_train_RF = confusionmat(train_feat(:,end), prediction_train);
figure;
confusionchart(CM_train_RF, {'weekdays', 'weekends'});
title('confusion matrix - Random Forest: train set');

CM_test_RF = confusionmat(test_feat(:,end), prediction_test);
figure;
confusionchart(CM_test_RF, {'weekdays', 'weekends'});
title('confusion matrix - Random Forest: test set');

%% set working points for the optimized better model - RF in our case
% deafult
C = confusionmat(train_feat(:,end),prediction_train);
figure;
confusionchart(C, {'weekdays', 'weekends'});
title('confusion matrix for a deafult working point')

% sensitivity
[~,Y,T,~] = perfcurve(train_feat(:,end),scores(:,2), 1);
[~,ind] = min(abs(Y-0.9));
threshold_sensitivity_90 = T(ind);

sens_prediction_train(scores(:,2) > threshold_sensitivity_90) = 1;
sens_prediction_train(scores(:,2) <= threshold_sensitivity_90) = 0;

C = confusionmat(train_feat(:,end),sens_prediction_train);
figure;
confusionchart(C, {'weekdays', 'weekends'});
title('confusion matrix for a working point of sensitiviy = 90%')

% PPV
[~,Y,T,~] = perfcurve(train_feat(:,end),scores(:,2), 1, 'YCrit', 'ppv');
[~,ind] = min(abs(Y-0.9));
threshold_ppv_90 = T(ind);

ppv_prediction_train(scores(:,2) > threshold_ppv_90) = 1;
ppv_prediction_train(scores(:,2) <= threshold_ppv_90) = 0;

C = confusionmat(train_feat(:,end),ppv_prediction_train);
figure;
confusionchart(C, {'weekdays', 'weekends'});
title('confusion matrix for a working point of ppv = 90%');

%% submitted files
save('mat files/BestMDL', 'ensemble_MDL');
save('mat files/CM RF test', 'CM_test_RF' );

