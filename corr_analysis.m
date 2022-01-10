function [feat_feat_corr, weights, best_feat_label, features_removed_names,...
    feature_removed_indices, new_feat_matrix, new_feat_names, highest_corr_under_thresh,...
    feat_names_too_many_nan, feat_removed_nan_indices, new_weights, new_feat_feat_corr]...
    = corr_analysis(feat_label_mat, feat_names)
% this function computes correlations between features and relieff between fetures and labels.

k = 7;     % num of neighbors for relieff

% Slice the data to features and labels
label_vec = feat_label_mat(:, end);         % Separate the Labels from matrix
feat_mat = feat_label_mat(:, 1:end - 1);    % Separate Features from labels

nan_feat_idx  = sum(isnan(feat_mat),1);
feat_names_too_many_nan = feat_names(nan_feat_idx > size(feat_mat,1)*0.15);
feat_removed_nan_indices = (nan_feat_idx > size(feat_mat,1)*0.15);
feat_names(nan_feat_idx > size(feat_mat,1)*0.15) = [];
new_feat_mat = feat_mat(:,nan_feat_idx < size(feat_mat,1)*0.15);

nan_exmpl_idx = sum(isnan(new_feat_mat),2);

% Compute feat label corr
[idx_relieff, weights] = relieff(new_feat_mat(nan_exmpl_idx == 0,:), label_vec(nan_exmpl_idx == 0,:), k, 'method', 'classification');   % Features-Labels correlation for all feat

% Compute feat feat corr
feat_feat_corr = corr(new_feat_mat, 'type', 'Spearman', 'rows', 'complete');                 % Features-Features correlation

% extract the feature with highest feature label correlation
best_feat_label{1} = [weights(idx_relieff(1)), weights(idx_relieff(2))];    % value of relieff
best_feat_label{2} = [idx_relieff(1), idx_relieff(2)];                              % index of feature in matrix
best_feat_label{3} = feat_names([idx_relieff(1), idx_relieff(2)]);                  % feature name

% find and remove features with over 0.7 feature-feature correlation
indices = find(and(abs(feat_feat_corr) >= 0.7, abs(feat_feat_corr) ~= 1) );
indices_cols = ceil(indices./size(feat_feat_corr, 1));
indices_rows = mod(indices, size(feat_feat_corr, 1));
indices_rows(indices_rows == 0) = size(feat_feat_corr, 1);
feature_removed_indices = zeros(1,length(indices));

for i = 1:length(indices)
    feat_1 = indices_cols(i);
    feat_2 = indices_rows(i);
    if weights(feat_1) > weights(feat_2)
        worst_feat = feat_2;
    else
        worst_feat = feat_1;
    end
    feature_removed_indices(i) = worst_feat;
end
feature_removed_indices = unique(feature_removed_indices);
features_removed_names = feat_names(feature_removed_indices);

vec = ones(1,size(new_feat_mat, 2));
vec(1,feature_removed_indices) = 0;
new_feat_matrix = new_feat_mat(:, vec == 1);
new_feat_names = feat_names(vec == 1);
new_feat_matrix = [new_feat_matrix, label_vec];

% find max feature-feature correlation under 0.7 and their names
M = max(feat_feat_corr(abs(feat_feat_corr) < 0.7));
I = find(abs(feat_feat_corr) == M, 1);
I_cols = ceil(I/size(feat_feat_corr, 1));
I_rows = mod(I, size(feat_feat_corr, 1));
highest_corr_under_thresh = cell(1,4);
highest_corr_under_thresh{1} = M;
highest_corr_under_thresh{2} = I;            % use this value to check for correct names afterwards
highest_corr_under_thresh{3} = feat_names{I_cols};
highest_corr_under_thresh{4} = feat_names{I_rows};

new_weights = weights;
new_weights(feature_removed_indices) = [];
new_feat_feat_corr = corr(new_feat_matrix(:,1:end-1), 'type', 'Spearman', 'rows', 'complete');
end
