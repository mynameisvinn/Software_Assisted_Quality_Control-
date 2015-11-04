function [idx] = generate_patch(data_id, user_id, counter_id)
% @date: 10/19/15
% @author: vincent tang

% function: 
% ---------
% generate 100x100x3 uint16 patches for user id 9 and counter 1

% parameters: 
% -----------
% @data_id: int, datafile ID
% @user_id: int, user 9 is ideal; user 8 is vin.compute (automated)
% @counter_id: int, counter 1 is TMR and counter 3 is VACHT

    % retreive image
    conn = database('limsdb','lims','mou53Brains!');
    sql = ['SELECT primary_file_system_location_lossy FROM data_file WHERE id = "' num2str(data_id) '"'];
    curs = exec(conn,sql);
    curs = fetch(curs);
    imagefilename = curs.Data;
    path = strcat('Z:\Converted Image Data\', imagefilename);
    image = imread(char(path));

    % grab click coordinates in the specified counter
    sql = ['SELECT click_location_x_coordinate, click_location_y_coordinate FROM limsdb.data_file_click where (user_id = "' num2str(user_id) '") and (counter_id = "' num2str(counter_id) '") and data_file_id = "' num2str(data_id) '"'];
    curs = exec(conn,sql);
    curs = fetch(curs);
    coordinates = cell2mat(curs.Data);
    
    % generate patches
    for idx = 1:length(coordinates(:,1))

        x_coordinate = coordinates(idx,1);
        y_coordinate = coordinates(idx,2);
        patch_size = 100;

        % exception: nmj falls on border and cannot be cropped
        try
            patch = image( y_coordinate-patch_size: y_coordinate +patch_size, x_coordinate - patch_size: x_coordinate + patch_size,:);
            filename = strcat(int2str(data_id), '_', int2str(x_coordinate), '_', int2str(y_coordinate),'.jp2');
            imwrite(patch, filename);
        
        catch
            continue
        end
    end

end

