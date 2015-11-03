function [intensity_mask] = generate_intensity_mask(im_raw, threshold)

% function:
% ---------
% given an image (unmodified uint16), generate an intensity mask. the goal
% is to segment out peaks, based on pixel intensities in the green channel

% parameters:
% -----------
% @im_raw: unmodified uint16 image with dimensions 201x201x3

% returns:
% --------
% @hsv_mask: 201x201x1 logical mask

    im_uint8 = uint8(im_raw); % thresholding in uint8 generalizes better than in uint16
    green_channel = im_uint8(:,:,2); 
    
    level = graythresh(green_channel); 
    gamma_adjusted_image = imadjust(green_channel, [level 1], []); 
    intensity_mask = gamma_adjusted_image > prctile(median(green_channel), threshold);

end

