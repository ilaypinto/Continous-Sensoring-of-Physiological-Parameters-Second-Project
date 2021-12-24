function feat_mat = feat_extract(all_data,day_vec)
% This function does the same old fucking thing- extracting features
% Nothing new, just another fuckery. % now after we had our laugh, description in the next line
% This function extracts features using data from 'extract_data' function and using the day names as described in the field of the structures gotten from said function.

struct = all_data{1};
feat_mat=[];
for j = 1:length(day_vec)

    % get the label of the day - weekend or not
    label = weekday(struct.(day_vec(j)).date);
        if label <= 5
            label = 0;
        else
            label = 1;
        end

        % Features extraction
        wireless_sum = size(struct.(day_vec(j)).wifi,1); % num of wifi found that day
        
        bluetooth_sum = size(struct.(day_vec(j)).bluetooth,1);  % num of BT devices found that day
        
%         accelerator_xyz = accelerator_mat(:,2:4); % accelerator max value
%         accelerator_e=sqrt((accelerator_xyz(:,1)).^2 + (accelerator_xyz(:,2)).^2 + (accelerator_xyz(:,3)).^2);
%         accelerator_max = max(accelerator_e);
        
        on_off_switches = 0;                   % number of changes of Screenstate on/off
        for i = 1:size(struct.(day_vec(j)).screen,1)-1
            if strcmp(struct.(day_vec(j)).screen(i,2),'on')
                if strcmp(struct.(day_vec(j)).screen(i+1,2),'off')
                    on_off_switches = on_off_switches+1;
                end
            else
                if strcmp(struct.(day_vec(j)).screen(i+1,2),'on')
                    on_off_switches = on_off_switches+1;        % ######## should remain the same ########
                end                                             % ^^^line 28 - if it says 'on' and the next one 'off' then add one^^^
                                                                % ^^^line 33 - if it says 'off' and the next one 'on' then add one^^^
            end
        end
        
        % ######## i think we need to find better features to extract from the battery data #########
        % ^^^ Idk Dude^^^
        battery_start = str2double(...
            struct.(day_vec(j)).battery(1,2));                    % battery % at start of the day
        battery_end = str2double(...
            struct.(day_vec(j)).battery(end,2));                  % battery % at end of the day
        battery_mid = str2double(...
            struct.(day_vec(j)).battery(...
            (round(size(struct.(day_vec(j)).battery,1)-1)/2),2)); % battery % at mid of day

        first_charge_time = 0;                                    % first time connected to
        for i=1:size(struct.(day_vec(j)).battery,1)                               % a charger
            if strcmp(struct.(day_vec(j)).battery(i,4),'usbCharge')...
                    || strcmp(struct.(day_vec(j)).battery(i,4),'acCharge')
                first_charge_time = struct.(day_vec(j)).battery(i,1);
                break
            end
        end

        calls_num = size(struct.(day_vec(j)).calls,1);   % number of calls in a day  
        calls_sum = sum(str2double(struct.(day_vec(j)...
            ).calls(:,2)));                              % sum of sec on the phone per day  
        [M,I] = max(str2double(struct.(day_vec(j)).calls(:,2)));     
        calls_max = M;                                     % longest call(in sec)
        calls_max_time = struct.(day_vec(j)).calls(I-1); % time of longest call 
        
        in_vehicle= sum(strcmp(struct.(...
                day_vec(j)).activity(:,3),'IN_VEHICLE')); % times a day in vehicle
   
        on_foot= sum(strcmp(struct.(...
                day_vec(j)).activity(:,3),'ON_FOOT'));    % times a day on foot
        
        tilting= sum(strcmp(struct.(...
                day_vec(j)).activity(:,3),'TILTING'));    % times a day tilting
        
        location_sum = sum(str2double(...
            struct.(day_vec(j)).location(:,2))); % sum of movement in a day
        [M,I] = max(str2double(struct.(day_vec(j)).location(:,3)));    
        location_max = M;                      % max movement
        location_max_time = struct.(day_vec(j)).location(I-1); % max movement time   

    feat_vec = [wireless_sum, bluetooth_sum, on_off_switches, battery_start,...
        battery_mid, battery_end, first_charge_time, calls_num, calls_sum,...
        calls_max, calls_max_time, in_vehicle, on_foot, tilting, location_sum,...
        location_max, location_max_time, label];

    feat_mat = cat(feat_mat,feat_vec);
end
end
