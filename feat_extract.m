function feat_mat = feat_extract(struct, call_norm_func)

% if call_norm_func
%     [means, stds] = norm_factors(struct);
% end

fields = string(fieldnames(struct));
feat_mat = [];
for j = 2:length(fields)
    % extract data from structure
    wifi = struct.(fields(j,:)).wifi;
    bluetooth = struct.(fields(j,:)).bluetooth;
    location = struct.(fields(j,:)).location;
    light = struct.(fields(j,:)).light;
    calls = struct.(fields(j,:)).calls;
    battery = struct.(fields(j,:)).battery;
    activity = struct.(fields(j,:)).activity;
    screen = struct.(fields(j,:)).screen;
    sleep_time = struct.(fields(j,:)).sleep_time;
    wake_time = struct.(fields(j,:)).wake_time;
    load = struct.(fields(j,:)).load;
    activities = struct.(fields(j,:)).activities;

    % get the label of the day - weekend or not
    label = weekday(struct.(fields(j,:)).date);
    if label <= 5
        label = 0;
    else
        label = 1;
    end

    % wifi
    wireless_sum = size(wifi,1); % num of wifi found that day

    % bluetooth
    bluetooth_sum = size(bluetooth,1);  % num of BT devices found that day

    % screen
    on_off_switches = 0;                   % number of changes of Screenstate on/off
    for i = 1:size(screen,1)-1
        if strcmp(screen{i,2},'on')
            if strcmp(screen{i+1,2},'off')
                on_off_switches = on_off_switches+1;
            end
        else
            if strcmp(screen{i+1,2},'on')
                on_off_switches = on_off_switches+1;        % ######## should remain the same ########
            end                                             % ^^^line 28 - if it says 'on' and the next one 'off' then add one^^^
                                                            % ^^^line 33 - if it says 'off' and the next one 'on' then add one^^^
        end
    end

    % battery
    battery_start = str2double(battery{1,2});                  % battery % at start of the day
    battery_end = str2double(battery{end,2});                  % battery % at end of the day
    battery_mid = str2double(battery{round((size(battery,1))/2),2}); % battery % at mid of day

    first_charge_time = 0;                                % first time connected to
    for i=1:size(battery,1)                               % a charger
        if strcmp(battery{i,4},'usbCharge') || strcmp(battery{i,4},'acCharge')
            first_charge_time = battery{i,1};
            break
        end
    end
    
    % calls
    calls_num = size(calls,1);   % number of calls in a day  
    calls_sum = sum(str2double(calls{:,2}));                              % sum of sec on the phone per day  
    [M,I] = max(str2double(calls{:,2}));     
    calls_max = M;                                     % longest call(in sec)
    calls_max_time = calls{I,1}; % time of longest call 

    % activity
    in_vehicle= sum(strcmp(activity{:,3},'IN_VEHICLE')); % times a day in vehicle

    on_foot= sum(strcmp(activity{:,3},'ON_FOOT'));    % times a day on foot
    
    tilting= sum(strcmp(activity{:,3},'TILTING'));    % times a day tilting

    % location
    location_sum = sum(str2double(location{:,2})); % sum of movement in a day
    [M,I] = max(str2double(location{:,3}));    
    location_max = M;                       % max movement
    location_max_time = location{I,1};      % max movement time  

    if isempty(wireless_sum)
        wireless_sum = 0;
    end
    if isempty(bluetooth_sum)
        bluetooth_sum = 0;
    end
    if isempty(on_off_switches)
        on_off_switches = 0;
    end             
    if isempty(first_charge_time)
        first_charge_time = 0;
    end
    if isempty(calls_num)
        calls_num = 0;
    end
    if isempty(calls_sum)
        calls_sum = 0;
    end
    if isempty(calls_max)
        calls_max = 0;
    end
    if isempty(calls_max_time)
        calls_max_time = nan;
    end
    if isempty(in_vehicle)
        in_vehicle = 0;
    end
    if isempty(on_foot)
        on_foot = 0;
    end
    if isempty(tilting)
        tilting = 0;
    end
    if isempty(location_sum)
        location_sum = nan;
    end
    if isempty(location_max)
        location_max = nan;
    end
    if isempty(location_max_time)
        location_max_time = nan;
    end

    feat_vec = [wireless_sum bluetooth_sum on_off_switches battery_start...
    battery_mid battery_end first_charge_time calls_num calls_sum...
    calls_max calls_max_time in_vehicle on_foot tilting location_sum...
    location_max location_max_time label];

    feat_mat = cat(1,feat_mat,feat_vec);
end
% feat_mat(:, 1:end-1) = (feat_mat(:, 1:end-1) - means)./stds;
end



