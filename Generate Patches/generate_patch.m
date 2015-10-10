function [idx] = generate_patch(data_idx)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here

    % retreive image file path
    % connect to limsdb
    conn = database('limsdb','lims','mou53Brains!');
    curs = exec(conn,[]);
    sql = ['SELECT primary_file_system_location_lossy FROM data_file WHERE id = "' num2str(data_idx) '"'];
    curs = exec(conn,sql);
    curs = fetch(curs);
    imagefilename = curs.Data;

    % create image file path
    path = strcat('Z:\Converted Image Data\', imagefilename);


    im0 = imread(char(path));

    % recast from uint16 to uint8
    im1 = uint8(im0);

    % query limsdb for actual coordinates
    sql = ['SELECT click_location_x_coordinate, click_location_y_coordinate FROM limsdb.data_file_click where (user_id = 4) and (counter_id = 1) and data_file_id = "' num2str(data_idx) '"'];
    curs = exec(conn,sql);
    curs = fetch(curs);
    tmr_actuals = cell2mat(curs.Data);

    for idx = 1:length(tmr_actuals)

        a = tmr_actuals(idx,1);
        b = tmr_actuals(idx,2);
        patch_size = 50;

        tmr_patch = im1( b-patch_size: b +patch_size, a - patch_size: a + patch_size,:);
        filename = strcat(int2str(data_idx), '_', int2str(a), '_', int2str(b),'.tif');
        imwrite(tmr_patch, filename, 'tif');
        
    end

end

