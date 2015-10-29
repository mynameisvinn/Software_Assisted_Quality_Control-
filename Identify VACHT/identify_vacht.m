function [class] = identify_vacht(path, min_area, threshold)

%%
% created on 10/28/15

% function:
% ---------
% given a clicks coordinate path, determine if there is a vacht stain. it
% looks for regions that satisfy three constraints: (1) hsv; (2) high G
% intensity; and (3) many edges.
% 

% parameters:
% -----------
% @path: string, representing image file location
% @min_area: integer, representing the minimum number of pixels required
% for a positive identification. the lower the threshold, the more false
% positives. a value of 50 seems to work well.
% @threshold: integer between 0 and 100. threshold value determines the
% percentile value.

% returns:
% --------
% @class: 1 for positive identification, 0 for negative identification

%%

    im_raw = imread(path);
    
    % by segmenting in hsv space, the following code eliminates high
    % intensity green regions that do not correspond to acht receptors
    
    im_uint8 = uint8(im_raw);
    im_hsv = rgb2hsv(im_uint8);
    im_hue = im_hsv(:,:,1);
    im_val = im_hsv(:,:,2);
    im_sat = im_hsv(:,:,3);
    im_hue = im_hue .* 360;

    hue_mask = imcomplement((im_hue < 130) & (im_hue > 60)); % segment green regions
    val_mask = (im_val > .8);
    sat_mask = imcomplement(im_sat < .9);

    hsv_mask = hue_mask .* sat_mask .* val_mask;
    hsv_mask = imclearborder(hsv_mask); 

    % now identify regions with high green intensities. high green
    % intensities are defined by the Kth percentile determined by user.
    
    im_green_channel = im_uint8(:,:,2); 
    level = graythresh(im_green_channel); 
    im_gamma_adjusted = imadjust(im_green_channel, [level 1], []); 
    im_high_intensity_regions = im_gamma_adjusted > prctile(median(im_green_channel), threshold);

    % combine masks
    combined_mask_1 = hsv_mask .* im_high_intensity_regions;
    
    % no longer need neighborhood information, so lets crop
    combined_mask_1 = combined_mask_1(50:150, 50:150, :);

    % basic preprocessing
    se = strel('disk', 5);
    combined_mask_1 = imclose(combined_mask_1, se);
    combined_mask_1 = bwareaopen(combined_mask_1, 2);
    
    % finally, generate a mask based on edges
    im_uint16 = im_raw * 2^6;
    G_kernel = fspecial('gaussian', [3 3], 15); % ([kernel dimensions], sigma); larger sigma values will reduce count
    im_uint16 = im_uint16(50:150,50:150,2);
    I = imfilter(im_uint16, G_kernel ,'same', 'conv');
    
    % https://dsp.stackexchange.com/questions/1766/how-to-apply-watershed-to-segment-images-using-matlab
    hy = fspecial('sobel');
    hx = hy';
    Iy = imfilter(double(I), hy, 'replicate');
    Ix = imfilter(double(I), hx, 'replicate');
    gradmag = sqrt(Ix.^2 + Iy.^2);
    g = gradmag - min(gradmag(:));
    g = g / max(g(:));
    th = graythresh(g); %# Otsu's method.
    edge_mask = imhmax(g,th/2); %# Conservatively remove local maxima.
    
    % combine all three masks
    combined_2 = edge_mask .* combined_mask_1;
    combined_3 = combined_2 > .2;
    
    % calculate area for classification
    area = sum(sum(combined_3));    
    if (area > min_area)
        class = 1;
    else
        class = 0;
    end

end