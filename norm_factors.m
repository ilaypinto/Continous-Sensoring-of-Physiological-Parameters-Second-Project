function [means, stds] = norm_factors(data)

fields = string(fieldnames(data));
fields = fields(2:end);
L = length(fieldnames(data)) - 1;
n = zeros(1,L);
for i = 1:L
    n(i) = datenum(datestr(data.(fields(i,:)).date),'dd-mmm-yyyy');
end

% find whole weeks 
following = n(2:end) - n(1:end - 1);
following = following == 1;
whole_weeks = [];
for i = 1:length(following) - 6
    if length(find(following(i + 1:i + 6))) == 6
        whole_weeks = [whole_weeks ;(i:(i+6))];
    end
end
num_whole = size(whole_weeks,1);
days = {};
% find weeks without common days
for i = 1:num_whole
    for j = 1:num_whole
        if ismember(whole_weeks(i,:),whole_weeks(j,:)) == 0
            first_week = fields(whole_weeks(i,:),:);
            second_week = fields(whole_weeks(j,:),:);
            days{end + 1} = [first_week ;second_week];
        end
    end
end

% if theres not 2 weeks availavble then we will average over one week only

for i = 1:size(whole_weeks,1)
    days{end + 1} = fields(whole_weeks(i,:),:);
end


for j = 1:size(days, 2)
    flag = false;
    for v = 2:size(days{j},1)
        if isnan(data.(days{j}(v,:)).sleep_time)
            flag = true;
            break
        end
    end
    if ~flag
        for i = 1:length(days{j})
            temp_struct.(days{j}(i,:)) = data.(days{j}(i,:));
        end
        features = feat_extract_norm(temp_struct, 0);
        means = mean(features(:,1:end-1));
        stds = std(features(:,1:end-1));
        if size(days{j},1) == 7
            disp(strcat('uid-' ,num2str(data.uid{1,1}), ' was normalized with only 1 week data!'));
        end
        return
    end
end