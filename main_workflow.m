clc; clear all; close all;
% this is the main script for our workflow

% set some usefull flags
flag_load_data = 0;         % 1 - data will be loaded from mat files, 0 - data will be extracted from xlsx files




% define our data matrix that contains sturctures
files_filepath = 'BHQ files';
mat_filepath = 'mat files';



all_data = extract_data(files_filepath, mat_filepath, flag_load_data);


