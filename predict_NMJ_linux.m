function tmr_predictions_4 = predict_NMJ_linux(data_id)
try
    import java.io.File;
    import java.io.FileInputStream;
    import java.io.IOException;
    import java.io.InputStream;

    disp('***connecting with db***')

    conn = database('limsdb', 'lims', 'mou53Brains!', 'Vendor', 'MySQL', 'Server', '10.10.10.11'); % JDBC driver
    db_handle = conn.Handle;
    action_url = '';
    set(conn, 'AutoCommit', 'off'); % turn autocommit off; better to commit manually
    sql = ['SELECT primary_file_system_location_lossy FROM data_file WHERE id = "' num2str(data_id) '"'];
    curs = exec(conn,sql);
    curs = fetch(curs);
    imagefilename = curs.Data;
    path = strcat('/storage/Clarapath Local Share/Converted Image Data/', imagefilename);
    feature_count = 0;
    
    sql = ['DELETE FROM saqc_data_file_status WHERE data_file_id = "' num2str(data_id) '"'...
            'AND status_id IN (5,6,7)'];
    exec(conn,sql);
    commit(conn);
    
    data = {data_id, 6, datestr(now,'yyyy-mm-dd HH:MM:SS')};
    tablename = 'saqc_data_file_status';
    colnames = {'data_file_id', 'status_id', 'start_time'};
    fastinsert(conn,tablename,colnames,data);
    
    commit(conn);
    
    

    disp('***generating TMR predictions***')

    im0 = imread(char(path));
    im1 = uint8(im0);
    im2 = rgb2hsv(im1);
    im3 = im2(:,:,1);
    im4 = im3 .* 360;
    im5 = uint8(im4);
    im6 = (im5 < 65 & im5 > 5);
    im7 = uint8(im6);
    j1 = im1(:,:,1);
    j2 = j1 .* im7;
    h1 = im2(:,:,2);
    h2 = h1 > .75;
    h3 = uint8(h2);
    j3 = j2 .* h3;
    j4 = j3 > 150;
    tmr_predictions_1 = regionprops(j4, j3, 'WeightedCentroid', 'Area');
   
    disp('***cleaning up TMR predictions***')
    
    tmr_predictions_3 = tmr_predictions_1([tmr_predictions_1.Area] >150);

    disp('***formatting TMR predictions***')
    
    user_id = zeros(length(tmr_predictions_3), 1);
    data_file_id = zeros(length(tmr_predictions_3), 1);
    counter_id = zeros(length(tmr_predictions_3), 1);
    tile_id = zeros(length(tmr_predictions_3), 1);
    tmr_predictions_x = zeros(length(tmr_predictions_3), 1);
    tmr_predictions_y = zeros(length(tmr_predictions_3), 1);
    annotation_circle_radius_in_pixels  = zeros(length(tmr_predictions_3), 1);
    analytical_protocol_counter_set_id = zeros(length(tmr_predictions_3), 1); 
    yes_count =  zeros(length(tmr_predictions_3), 1);
    maybe_count =  zeros(length(tmr_predictions_3), 1);

    for idx_i_2 = 1:length(tmr_predictions_3)

        tmr_predictions_x(idx_i_2) = round(tmr_predictions_3(idx_i_2).WeightedCentroid(1));
        tmr_predictions_y(idx_i_2) = round(tmr_predictions_3(idx_i_2).WeightedCentroid(2));
        
        imageInfo = imfinfo(char(path));
        imageLevels = imageInfo.QualityLayers;
        magnificationLevel = imageLevels;
        imageW = imageInfo.Width;
        imageH = imageInfo.Height;
        
        clickX = tmr_predictions_x(idx_i_2);
        clickY = tmr_predictions_y(idx_i_2);
        
        tileW = 1570; 
        tileH = 748;

        if (magnificationLevel <= 0 || magnificationLevel > imageLevels)
            magnificationLevel = imageLevels;
        end; 

        tileW = uint64(tileW * power(2, imageLevels - magnificationLevel));
        tileH = uint64(tileH * power(2, imageLevels - magnificationLevel));

        cntTileX = uint64(ceil(double(imageW / tileW)));

        xNum = uint64(floor(double(clickX) / double(tileW))); % must recast numerator and denominator to double prior to division
        yNum = uint64(floor(double(clickY) / double(tileH)));

        tileID = xNum + yNum * cntTileX + 1;
        tile_id(idx_i_2) = tileID;

    end
    
    disp('***updating db with TMR predictions***')
    
    data_file_id(data_file_id ==0 ) = data_id; 
    user_id(user_id == 0 ) = 8;
    counter_id(counter_id == 0 ) = 1; % 1 indicates red channel
        %When we eventually make counter_id dynamic, we will use these
        %queries to get the appropriate counter_id to use:
        %SELECT id FROM counter WHERE counter_name = 'TMR-a-Bungarotoxin';
        %SELECT id FROM counter WHERE counter_name = 'VACHT';
    
    annotation_circle_radius_in_pixels(annotation_circle_radius_in_pixels == 0) = 10; 
        %When we eventually make annotation_circle_radius_in_pixels dynamic, we
        %will use this query:
        %SELECT annotation_circle_radius_in_pixels from data_file_annotation_circle_defaults LIMIT 1;
        
    analytical_protocol_counter_set_id(analytical_protocol_counter_set_id == 0) = 1;
        %TODO: Need to provide replacement query for when we eventually make this
        %dynamic.
    
    yes_count(yes_count == 0) = 1;
        %In the future, we may start tracking "maybe this is an NMJ" in addition to "yes,
        %this is definitely an NMJ."  For now, we are only tracking "yes."
    maybe_count(maybe_count == 0) = 0;
    
    tmr_predictions_4 = cat(2, data_file_id, user_id, counter_id, tile_id, tmr_predictions_x, tmr_predictions_y, annotation_circle_radius_in_pixels, analytical_protocol_counter_set_id, yes_count, maybe_count);
    
    colnames = {'data_file_id', 'user_id', 'counter_id', 'tile_id', 'click_location_x_coordinate', 'click_location_y_coordinate', 'annotation_circle_radius_in_pixels', 'analytical_protocol_counter_set_id', 'yes_count', 'maybe_count'};
    
    data_table = array2table(tmr_predictions_4, 'VariableNames', colnames);

    sql = ['DELETE FROM data_file_click WHERE data_file_id = "' num2str(data_id) '"' ...
            'AND user_id = 8'];
    exec(conn,sql);
    commit(conn);

    insert(conn,'data_file_click',colnames,data_table)

    disp('***generating vacht predictions***')
    
    commit(conn);
    
    VACHT_patch_size = 50;
    im_16bit = im0 * 2^6;
    
    vacht_predictions_x = zeros(1, 1);
    vacht_predictions_y = zeros(1, 1);
    counter = 1;
    
    for idx_i_3 = 1:length(tmr_predictions_3)
        
        tmr_x_midpoint = round(tmr_predictions_3(idx_i_3).WeightedCentroid(1));
        tmr_y_midpoint = round(tmr_predictions_3(idx_i_3).WeightedCentroid(2));
        
        
        vacht_patch = im_16bit(tmr_y_midpoint - VACHT_patch_size: tmr_y_midpoint + VACHT_patch_size, tmr_x_midpoint - VACHT_patch_size: tmr_x_midpoint + VACHT_patch_size,2) * 2.5;
        
        high_vacht_patch = vacht_patch > 25000;
        
        if sum(high_vacht_patch(:)) > 0
            vacht_predictions_x(counter, 1) = tmr_x_midpoint;
            vacht_predictions_y(counter, 1) = tmr_y_midpoint;
            counter = counter + 1;
        end
    end
    
    disp('***formatting vacht predictions***')

    user_id = zeros(length(vacht_predictions_x), 1);
    data_file_id = zeros(length(vacht_predictions_x), 1);
    counter_id = zeros(length(vacht_predictions_x), 1);
    tile_id = zeros(length(vacht_predictions_x), 1);
    annotation_circle_radius_in_pixels  = zeros(length(vacht_predictions_x), 1);
    analytical_protocol_counter_set_id = zeros(length(vacht_predictions_x), 1); 
    yes_count =  zeros(length(vacht_predictions_x), 1);
    maybe_count =  zeros(length(vacht_predictions_x), 1);

    for idx_i_8 = 1:length(vacht_predictions_x)

        imageInfo = imfinfo(char(path));
        imageLevels = imageInfo.QualityLayers;
        magnificationLevel = imageLevels;
        imageW = imageInfo.Width;
        imageH = imageInfo.Height;
        
        clickX = vacht_predictions_x(idx_i_8);
        clickY = vacht_predictions_y(idx_i_8);
        
        tileW = 1570; 
        tileH = 748;

        if (magnificationLevel <= 0 || magnificationLevel > imageLevels)
            magnificationLevel = imageLevels;
        end; 

        tileW = uint64(tileW * power(2, imageLevels - magnificationLevel));
        tileH = uint64(tileH * power(2, imageLevels - magnificationLevel));

        cntTileX = uint64(ceil(double(imageW / tileW)));

        xNum = uint64(floor(double(clickX) / double(tileW))); % must recast to double prior to division!!!!
        yNum = uint64(floor(double(clickY) / double(tileH)));

        tileID = xNum + yNum * cntTileX + 1;        
        tile_id(idx_i_8) = tileID;

    end
    
    disp('***udpating db with vacht predictions***')

    data_file_id(data_file_id ==0 ) = data_id; 
    user_id(user_id == 0 ) = 8;
    counter_id(counter_id == 0 ) = 2; % 2 indicates green channel
    annotation_circle_radius_in_pixels(annotation_circle_radius_in_pixels == 0) = 10; 
    analytical_protocol_counter_set_id(analytical_protocol_counter_set_id == 0) = 1;
    yes_count(yes_count == 0) = 1;
    maybe_count(maybe_count == 0) = 0;
    vacht_predictions_combined = cat(2, data_file_id, user_id, counter_id, tile_id, vacht_predictions_x, vacht_predictions_y, annotation_circle_radius_in_pixels, analytical_protocol_counter_set_id, yes_count, maybe_count);

    colnames = {'data_file_id', 'user_id', 'counter_id', 'tile_id', 'click_location_x_coordinate', 'click_location_y_coordinate', 'annotation_circle_radius_in_pixels', 'analytical_protocol_counter_set_id', 'yes_count', 'maybe_count'};
    
    data_table = array2table(vacht_predictions_combined, 'VariableNames', colnames);

    insert(conn,'data_file_click',colnames,data_table)
    
    commit(conn);
    
    disp('***generating patches for visual inspection***')

    sql = ['DELETE FROM saqc_candidate_feature WHERE data_file_id = "' num2str(data_id) '"'];
    exec(conn,sql);
    commit(conn);

    TMR_patch_size = 50;
    
    % grab image dimensions prior to cropping (subscript comparison)
    dimensions = size(im0);
    image_height = dimensions(1);
    image_width = dimensions(2);
    

    for idx_i_6 = 1:length(tmr_predictions_4(:,1))
        feature_count = feature_count + 1;
        tmr_a = round(tmr_predictions_4(idx_i_6,5)); % 5 represents x coordinate
        tmr_b = round(tmr_predictions_4(idx_i_6,6)); % 6 represents x coordinate
        
        % if patch is out of bounds, return control to loop
        if (tmr_b-TMR_patch_size < 0) || (tmr_a - TMR_patch_size < 0) || (tmr_b +TMR_patch_size > height) || (tmr_a + TMR_patch_size > width)
            continue
        end
        
        % otherwise, generate tmr patches
        tmr_patch = im_16bit(tmr_b-TMR_patch_size: tmr_b +TMR_patch_size, tmr_a - TMR_patch_size: tmr_a + TMR_patch_size,:);
        
        tmr_patch(:,:,2:3) = 0;
        tmr_patch(:,:,1) = tmr_patch(:,:,1) * 2.5;
        [m,n,q] = size(tmr_patch);
        tmr_filename = strcat('TMR_', num2str(data_id), '_', int2str(idx_i_6),'.png');
        imwrite(tmr_patch, tmr_filename, 'png');
        
        tmr_png_stream = FileInputStream(File(tmr_filename));
        delete(tmr_filename);
        
        sql = ['SELECT id FROM data_file_click WHERE click_location_x_coordinate = "' num2str(tmr_a) '" ' ... 
               'AND click_location_y_coordinate = "' num2str(tmr_b) '" AND counter_id = 1 AND user_id = 8 ' ...
               'ORDER BY last_changed_time DESC ' ...
               'LIMIT 1'];
        curs = exec(conn,sql);
        curs = fetch(curs);
        row = curs.Data;
        data_file_click_id = row{1};
        
        insertcommand = ['INSERT INTO saqc_candidate_feature (image, data_file_click_id, name, height, width, data_file_id)' ...
                         'values (?, ?, ?, ?, ?, ?)'];
        StatementObject = db_handle.prepareStatement(insertcommand);
        StatementObject.setBlob(1,tmr_png_stream);
        StatementObject.setInt(2, data_file_click_id);
        StatementObject.setString(3, tmr_filename);
        StatementObject.setInt(4, m);
        StatementObject.setInt(5, n);
        StatementObject.setInt(6, data_id);
        StatementObject.execute
        close(StatementObject)
        

        
    end
    
    
    for idx_i_7 = 1:length(vacht_predictions_x)
        feature_count = feature_count + 1;
        vacht_a = round(vacht_predictions_x(idx_i_7)); % 5 represents x coordinate
        vacht_b = round(vacht_predictions_y(idx_i_7)); % 6 represents x coordinate

        % if patch is out of bounds, return control to loop
        if (vacht_b-VACHT_patch_size < 0) || (vacht_a - VACHT_patch_size < 0) || (vacht_b +VACHT_patch_size> height) || (vacht_a + VACHT_patch_size > width)
            continue
        end
        
        % otherwise, generate vatch patches
        
        VACHT_patch = im_16bit(vacht_b-VACHT_patch_size: vacht_b +VACHT_patch_size, vacht_a - VACHT_patch_size: vacht_a + VACHT_patch_size,:);  
        VACHT_patch(:,:,1) = 0;
        VACHT_patch(:,:,3) = 0;
        VACHT_patch(:,:,2) = VACHT_patch(:,:,2) * 2.5; % if you change 2.5 boost factor, youll need to change vacht threshold
        [m,n,q] = size(VACHT_patch);
        VACHT_filename = strcat('VACHT_', num2str(data_id), '_', int2str(idx_i_7),'.png');
        imwrite(VACHT_patch, VACHT_filename, 'png');
        
        VACHT_png_stream = FileInputStream(File(VACHT_filename));
        delete(VACHT_filename);
        
        sql = ['SELECT id FROM data_file_click WHERE click_location_x_coordinate = "' num2str(vacht_a) '" ' ...
               'AND click_location_y_coordinate = "' num2str(vacht_b) '" AND counter_id = 2 AND user_id = 8 ' ...
               'ORDER BY last_changed_time DESC ' ...
               'LIMIT 1'];
        curs = exec(conn,sql);
        curs = fetch(curs);
        row = curs.Data;
        data_file_click_id = row{1};
        
        insertcommand = ['INSERT INTO saqc_candidate_feature (image, data_file_click_id, name, height, width, data_file_id) ' ... 
                         'values (?, ?, ?, ?, ?, ?)'];
        StatementObject = db_handle.prepareStatement(insertcommand);
        StatementObject.setBlob(1,VACHT_png_stream);
        StatementObject.setInt(2, data_file_click_id);
        StatementObject.setString(3, VACHT_filename);
        StatementObject.setInt(4, m);
        StatementObject.setInt(5, n);
        StatementObject.setInt(6, data_id);
        StatementObject.execute
        close(StatementObject)

    end
    
    sql = ['DELETE FROM saqc_automated_detection_queue WHERE data_file_id = "' num2str(data_id) '"'];
    exec(conn,sql);
    commit(conn);
    
    if(feature_count <= 150)
        action_url = strcat('<a href="http://10.10.10.12/staticfile/feature_qc_collage.html?data_file_id=', num2str(data_id), '"> FEATURE QC </a>');
    else
        action_url = strcat('<a href="http://10.10.10.12/staticfile/djatoka_viewer_v3.html?data_file_id=', num2str(data_id), '&analysis=y"> MANUAL QC </a>');
    end
    
    data = {data_id, 7, datestr(now,'yyyy-mm-dd HH:MM:SS'), datestr(now,'yyyy-mm-dd HH:MM:SS'), action_url};
    tablename = 'saqc_data_file_status';
    colnames = {'data_file_id', 'status_id', 'start_time', 'end_time', 'action_url'};
    fastinsert(conn,tablename,colnames,data);
    
    data = {datestr(now,'yyyy-mm-dd HH:MM:SS')};
    colnames = {'end_time'};
    whereclause = strcat('where data_file_id = "', num2str(data_id), '"', ' AND status_id = 6');
        
    update(conn,tablename,colnames,data,whereclause);
    
    commit(conn);
    close(conn);
    
    disp('***end of job***')
    exit;
    
catch ME
    data = {data_id, 15, datestr(now,'yyyy-mm-dd HH:MM:SS'), datestr(now,'yyyy-mm-dd HH:MM:SS')};
    tablename = 'saqc_data_file_status';
    colnames = {'data_file_id', 'status_id', 'start_time', 'end_time'};
    fastinsert(conn, tablename, colnames, data);
    commit(conn);
    close(conn);
    exit;
end
end


