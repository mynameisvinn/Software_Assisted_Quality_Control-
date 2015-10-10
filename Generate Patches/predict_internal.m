tic

% 5/14/15
% use this script to generate patches for classifiers. this is internal do
% not share it for outside use.

for q = 1:length(list_of_data_id)

    %% Step 1: connect to limsdb
    conn = database('limsdb','lims','mou53Brains!');
    curs = exec(conn,[]);
    data_id = list_of_data_id(q);

    % retreive path
    sql = ['SELECT primary_file_system_location_lossy FROM data_file WHERE id = "' num2str(data_id) '"'];
    curs = exec(conn,sql);
    curs = fetch(curs);
    imagefilename = curs.Data;
    path = strcat('Z:\Converted Image Data\', imagefilename);

    %% Step 2: generate predictions

    im0 = imread(char(path));

    % recast from uint16 to uint8
    im1 = uint8(im0);

    % convert rgb to hsv colorspace
    im2 = rgb2hsv(im1);

    % extract hue
    % 1st plane is hue; 2nd is saturation; 3rd is value
    % https://www.mathworks.com/help/matlab/ref/rgb2hsv.html
    im3 = im2(:,:,1);

    % convert to a hue angle, which is required for color subsetting
    % https://www.mathworks.com/matlabcentral/answers/8058-hue-value-of-image-image-processing-in-matlab-rgb-to-hsv
    im4 = im3 .* 360;

    % cast im4 (double) to im5 (int8)
    im5 = uint8(im4);

    % create orange hue mask (values of [5,65]
    % keep this larger band for reddish NMJs
    % http://www.color-blindness.com/color-name-hue/
    im6 = (im5 < 65 & im5 > 5);

    % recast im6 to int8 create a mask
    im7 = uint8(im6);

    % j1 is the red channel, as subsetted from original rgb image
    j1 = im1(:,:,1);

    % extract regions that satisfy hue mask
    % j2 represents regions of red channel that satisfies hue mask
    j2 = j1 .* im7;

    % now, lets create saturation mask
    % keep pixels where saturation > 75%
    % lowering saturation threshold will increase FPs dramatically
    h1 = im2(:,:,2);
    h2 = h1 > .75;  
    h3 = uint8(h2);

    % j3 represents regions of red channel that satisfies both hue mask AND saturation mask
    j3 = j2 .* h3;

    % j4 represents regions of j3 with high red intensities
    j4 = j3 > 150;

    % for weightedcentroids calculation, => mask (logic) first, followed by grayscale channel
    tmr_predictions_1 = regionprops(j4, j3, 'WeightedCentroid', 'Area');

    %% Step 3: minimize TMR FPs

    % size filter to remove smaller image artifacts
    % tightening the size condition substantially reduces FPs
    tmr_predictions_2 = tmr_predictions_1([tmr_predictions_1.Area] >150);

    %% Step 4: extract TMR predictions from structure

    % preallocate arrays
    tmr_predictions_x = zeros(length(tmr_predictions_2), 1);
    tmr_predictions_y = zeros(length(tmr_predictions_2), 1);

    % populate arrays with coordinates of TMR predictions
    for idx_i_2 = 1:length(tmr_predictions_2)

        tmr_predictions_x(idx_i_2) = round(tmr_predictions_2(idx_i_2).WeightedCentroid(1));
        tmr_predictions_y(idx_i_2) = round(tmr_predictions_2(idx_i_2).WeightedCentroid(2));

    end

    % zip arrays
    tmr_predictions_4 = cat(2, tmr_predictions_x, tmr_predictions_y);
    % csv_filename = strcat(int2str(data_id), 'predictions.csv');
    % csvwrite(csv_filename, tmr_predictions_4)

    %% Step 5: generate patches

    TMR_patch_size = 50;
    VACHT_patch_size = 50;
    
    %%%%%%%%%%%
    % first grab dimensions
    dimensions = size(im0);
    height = dimensions(1);
    width = dimensions(2);
    %%%%%%%%%%%

    for idx_i_6 = 1:length(tmr_predictions_4)

        a = round(tmr_predictions_4(idx_i_6,1)); % x values
        b = round(tmr_predictions_4(idx_i_6,2)); % y values

        % create TMR patches only if it is within bounds
        if (b-TMR_patch_size <= 0) || (a - TMR_patch_size <= 0) || (b+TMR_patch_size >= height) || (a + TMR_patch_size >= width)
            continue
        end
        tmr_patch = im1(b-TMR_patch_size: b +TMR_patch_size, a - TMR_patch_size: a + TMR_patch_size,:);
        tmr_filename = strcat('prediction_', int2str(data_id), '_', int2str(a),'_', int2str(b),'_.tif');
        imwrite(tmr_patch, tmr_filename, 'tif');

        % create VACHT patches

%         VACHT_patch = im1(b-VACHT_patch_size: b +VACHT_patch_size, a - VACHT_patch_size: a + VACHT_patch_size,:);  
%         VACHT_patch(:,:,1) = 0;
%         VACHT_patch(:,:,3) = 0;
%         VACHT_filename = strcat('VACHT_', int2str(data_id), '_', int2str(idx_i_6),'.tif');
%         imwrite(VACHT_patch, VACHT_filename, 'tif');

    end
     
end

toc