function features = feat_set(data)

features = [];
for i = 1:length(data)
    feat_norm = feat_extract_norm(data{i}, 1); % includes the label in the last idx
    feat = feat_extract_unnorm(data{i});
    temp_feat = [feat, feat_norm];
    features = [features; temp_feat];
end
end


