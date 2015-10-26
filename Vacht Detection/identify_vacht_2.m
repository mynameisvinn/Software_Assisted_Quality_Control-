function [class] = identify_vacht_2(path, min_area)

    im_raw = imread(path);
    im_uint8 = uint8(im_raw);
    im_hsv = rgb2hsv(im_uint8);
    im_hue = im_hsv(:,:,1);
    im_val = im_hsv(:,:,2);
    im_sat = im_hsv(:,:,3);
    im_hue = im_hue .* 360;

    hue_mask = imcomplement((im_hue < 130) & (im_hue > 60));
    val_mask = (im_val > .8);
    sat_mask = imcomplement(im_sat < .9);

    combined_masked_1 = hue_mask .* sat_mask .* val_mask;
    combined_masked_1 = imclearborder(combined_masked_1); 

    im_green = im_uint8(:,:,2); 
    level = graythresh(im_green); %%%
    im_enhanced = imadjust(im_green, [level 1], []); 

    % im_peaks = im_enhanced > prctile(median(im_green), threshold);
    % im_peaks = imextendedmax(im_enhanced, prctile(median(im_green), level * 100));
    im_peaks = im_enhanced > 250;

    combined_masked_2 = combined_masked_1 .* im_peaks;
    
    combined_masked_2 = combined_masked_2(50:150, 50:150, :);

    se = strel('disk', 5);
    combined_masked_2 = imclose(combined_masked_2, se);
    combined_masked_2 = bwareaopen(combined_masked_2, 2);
    % combined_masked_2 = imclearborder(combined_masked_2);
    
    
    patch = im_raw * 2^6;
    G_kernel = fspecial('gaussian', [3 3], 15); % ([kernel dimensions], sigma); larger sigma values will reduce count
    patch = patch(50:150,50:150,2);
    I = imfilter(patch, G_kernel ,'same', 'conv');
    hy = fspecial('sobel');
    hx = hy';
    Iy = imfilter(double(I), hy, 'replicate');
    Ix = imfilter(double(I), hx, 'replicate');
    gradmag = sqrt(Ix.^2 + Iy.^2);
    g = gradmag - min(gradmag(:));
    g = g / max(g(:));
    th = graythresh(g); %# Otsu's method.
    a = imhmax(g,th/2); %# Conservatively remove local maxima.
    combined_3 = a .* combined_masked_2;
    combined_4 = combined_3 > .2;
    
    
    area = sum(sum(combined_4));    

    % inspect largest object
    if (area > min_area)
        class = 1;
    else
        class = 0;
    end

end