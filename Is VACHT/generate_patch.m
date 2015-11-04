function [idx] = generate_patch(data_idx)
% @date: 10/19/15
% @author: vincent tang

% function: generate patches for user id 9 and counter 1

% parameters: 
% @data_idx: datafile ID

    % retreive image
    conn = database('limsdb','lims','mou53Brains!');
    curs = exec(conn,[]);
    sql = ['SELECT primary_file_system_location_lossy FROM data_file WHERE id = "' num2str(data_idx) '"'];
    curs = exec(conn,sql);
    curs = fetch(curs);
    imagefilename = curs.Data;
    path = strcat('Z:\Converted Image Data\', imagefilename);
    im_raw = imread(char(path));

    % grab coordinates
    sql = ['SELECT click_location_x_coordinate, click_location_y_coordinate FROM limsdb.data_file_click where (user_id = 9) and (counter_id = 1) and data_file_id = "' num2str(data_idx) '"'];
    curs = exec(conn,sql);
    curs = fetch(curs);
    predictions = cell2mat(curs.Data);
    
    % generate vacht patches from coordinates
    for idx = 1:length(predictions(:,1))

        a = predictions(idx,1);
        b = predictions(idx,2);
        patch_size = 100;

        try
            patch = im_raw( b-patch_size: b +patch_size, a - patch_size: a + patch_size,:);
            filename = strcat(int2str(data_idx), '_', int2str(a), '_', int2str(b),'.tif');
            imwrite(patch, filename, 'tif');
            
        catch
            continue
        
    end

end

