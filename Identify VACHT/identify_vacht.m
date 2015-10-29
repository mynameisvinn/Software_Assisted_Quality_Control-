function [class] = identify_vacht(path, min_area, threshold)

%%
% created on 10/28/15

% function:
% ---------
% given a clicks coordinate path, determine if there is a vacht stain. it
% looks for regions that satisfy three constraints: (1) hsv; m (2) high G
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
    hsv_mask = generate_hsv_mask(im_raw); 

    % now identify regions with high green intensities. high green
    % intensities are defined by the Kth percentile determined by user.
    intensity_mask = generate_intensity_mask(im_raw, threshold);

    % combine hue and intensity masks
    hsv_intensity_mask = hsv_mask .* intensity_mask;
    
    % no longer need neighborhood information, so lets crop
    % hsv_intensity_mask = hsv_intensity_mask(50:150, 50:150, :);

    % basic preprocessing
    se = strel('disk', 5);
    hsv_intensity_mask = imclose(hsv_intensity_mask, se);
    hsv_intensity_mask = bwareaopen(hsv_intensity_mask, 2);
    
    % finally, generate a mask based on edges
    edge_mask = generate_edge_mask(im_raw);
    
    % combine all three masks
    hsv_intensity_edge_mask = edge_mask .* hsv_intensity_mask;
    segmented_vacht = hsv_intensity_edge_mask > .2;
    segmented_vacht = segmented_vacht(50:150, 50:150,:); % center ROI so it's not impacted by neighbors
    
    % calculate area for classification
    area = sum(sum(segmented_vacht));    
    if (area > min_area)
        class = 1;
    else
        class = 0;
    end

end