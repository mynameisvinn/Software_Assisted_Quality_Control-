function [idx] = generate_patch(rs_id, datafile_id, user_id, counter_id, multiplier, dimension)

% =======================================================================
% @date: 10/19/15; 11/10/15
% @author: vincent tang

% function: 
% ---------
% generate "pretty" uint16 patches, given datafileID, userID, counterID and
% multiplier. generally, these patches are used for inspection.

% parameters: 
% -----------
% @rs_id: int, refers to raw specimen ID. used only to create directory
% folder.
% @datafile_id: datafile ID
% @user_id: int, referring to userID
% @counter_id: int, 1 & 3 refer to red channel and 2 & 4 refer to green
% channel. channels 3 and 4 have been deprecated.
% @multiplier: should be 2.5x... used to increase channel intensity
% @dimension: int, refers to size of patches created.
% =======================================================================

    % retrieve image
    conn = database('limsdb','lims','mou53Brains!');
    sql = ['SELECT primary_file_system_location_lossy FROM data_file WHERE id = "' num2str(datafile_id) '"'];
    curs = exec(conn,sql);
    curs = fetch(curs);
    imagefilename = curs.Data;
    path = strcat('Z:\Converted Image Data\', imagefilename);
    im_raw = imread(char(path));
    im_modified = im_raw * 2^6; % not unit8!

    % grab coordinates
    sql = ['SELECT click_location_x_coordinate, click_location_y_coordinate FROM limsdb.data_file_click where (user_id = "' num2str(user_id) '") and (counter_id = "' num2str(counter_id) '") and data_file_id = "' num2str(datafile_id) '"'];
    curs = exec(conn,sql);
    curs = fetch(curs);
    predictions = cell2mat(curs.Data);
    
    % create datafileID folder, which will store patches
    directory_name = strcat(num2str(rs_id), '-', num2str(datafile_id));
    mkdir(directory_name);
    
    % generate patches according to coordinates
    for idx = 1:length(predictions(:,1))

        x_coordinate = predictions(idx,1);
        y_coordinate = predictions(idx,2);
        patch_size = dimension / 2;

        try
            % create red patches
            patch = im_modified(y_coordinate - patch_size: y_coordinate + patch_size, x_coordinate - patch_size: x_coordinate + patch_size,:);
            patch(:,:,2:3) = 0;
            patch(:,:,1) = patch(:,:,1) * multiplier;
            filename = strcat(directory_name, '/red_', int2str(datafile_id), '_', int2str(x_coordinate), '_', int2str(y_coordinate),'.tif');
            imwrite(patch, filename, 'tif');
            
            % create corresponding green patches
            patch = im_modified(y_coordinate - patch_size: y_coordinate + patch_size, x_coordinate - patch_size: x_coordinate + patch_size,:);
            patch(:,:,1) = 0;
            patch(:,:,3) = 0;
            patch(:,:,2) = patch(:,:,2) * multiplier;
            filename = strcat(directory_name, '/green_', int2str(datafile_id), '_', int2str(x_coordinate), '_', int2str(y_coordinate),'.tif');
            imwrite(patch, filename, 'tif');
            
        catch % pass in the event of array out of bound exceptions
            continue
        end
    end

end

