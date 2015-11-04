function [ hsv_mask] = generate_hsv_mask(im_raw)

% created on 10/29/15

% function:
% ---------
% given an image (unmodified uint16), generate an "hsv" mask.
% combining saturation and value mask to hue mask localizes the ROI to
% the actual stain location.

% parameters:
% -----------
% @im_raw: unmodified uint16 image with dimensions 201x201x3

% returns:
% --------
% @hsv_mask: 201x201x1 logical mask

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

end

