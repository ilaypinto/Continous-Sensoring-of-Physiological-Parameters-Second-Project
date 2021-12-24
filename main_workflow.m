clc; clear all; close all;
% this is the main script for our workflow

% set some usefull flags
flag_load_data = 0;         % 1 - data will be loaded from mat files, 0 - data will be extracted from xlsx files
flag_load_feat = 0;         % 1 - features will be loaded from mat files, 0 - features will be extracted from data




% define our data matrix that contains sturctures
files_filepath = 'BHQ files';
mat_filepath = 'mat files';



all_data = extract_data(files_filepath, mat_filepath, flag_load_data);
%%
train_set_data = all_data(1,1:round(0.8*length(all_data)));
test_set_data = all_data(1,round(0.8*length(all_data)):end);

train_set_feat = feat_extract(train_set_data);
test_set_feat = feat_extract(test_set_data);




