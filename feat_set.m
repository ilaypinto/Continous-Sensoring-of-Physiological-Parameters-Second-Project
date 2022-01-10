function features = feat_set(data, flag_load, flag_save, filename)
if flag_load
    load(strcat('mat files/',filename), 'features');
    return
end
features = [];
for i = 1:length(data)
    feat_norm = feat_extract_norm(data{i}); % includes the label in the last idx
    feat = feat_extract_unnorm(data{i});
    temp_feat = [feat, feat_norm];
    features = [features; temp_feat];
end
if flag_save
    save(strcat('mat files/',filename), 'features')
end
end


