%% Defining labels using date
function feat_mat = feat_extract(all_data,day_vec)
struct = all_data{1};
feat_mat=[];
for j = 1:length(day_vec)
        label=weekday(struct.(day_vec(j)).date);
        if label <= 5
            label = 0;
        else
            label = 1;
        end

        %% Features extraction
        
        wireless_sum = size(...
            struct.(day_vec(j)).wifi,1);       % number of wireless devices connected per day
        
        bluetooth_sum = size(...
            struct.(day_vec(j)).bluetooth,1);  % number of bluetooth devices connected per day
        
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
                    on_off_switches = on_off_switches+1;
                end
            end
        end
        
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

        calls_num = size(struct.(day_vec(j)).battery,1);   % number of calls in a day
        calls_sum = sum(str2double(struct.(day_vec(j)...
            ).battery(:,2)));                              % sum of sec on the phone per day
        [M,I] = max(str2double(struct.(day_vec(j)).battery(:,2)));
        calls_max = M;                                     % longest call(in sec)
        calls_max_time = struct.(day_vec(j)).battery(I-1); % time of longest call
        
        if sum(strcmp(struct.(...
                day_vec(j)).activity(:,3),'IN_VEHICLE'))~=0 % were you in a vehicle or not
            in_vehicle = 1;
        else
            in_vehicle = 0;
        end
        
        if sum(strcmp(struct.(...
                day_vec(j)).activity(:,3),'ON_FOOT'))~=0    % were you on foot or not
            on_foot = 1;
        else
            on_foot = 0;
        end
        
        if sum(strcmp(struct.(...
                day_vec(j)).activity(:,3),'TILTING'))~=0    % were you tilting or not
            tilting = 1;
        else
            tilting = 0;
        end
        
        location_sum = sum(str2double(...
            struct.(day_vec(j)).location(:,2))); % sum of movement in a day
        [M,I] = max(str2double(struct.(day_vec(j)).activity(:,3)));
        location_max = M;                      % max movement
        location_max_time = struct.(day_vec(j)).activity(I-1); % max movement time

    feat_vec = [wireless_sum bluetooth_sum on_off_switches battery_start...
        battery_mid battery_end first_charge_time calls_num calls_sum...
        calls_max calls_max_time in_vehicle on_foot tilting location_sum...
        location_max location_max_time label];

    feat_mat = cat(feat_mat,feat_vec);


end
end