function [class] = is_vacht(patch, min_area, threshold)

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
% @patch: 201x201x3 uint16 patch
% @min_area: integer, representing the minimum number of pixels required
% for a positive identification. the lower the threshold, the more false
% positives. a value of 50 works well.
% @threshold: integer between 0 and 100. threshold value determines the
% percentile value. default value = 90.

% returns:
% --------
% @class: 1 for positive identification, 0 for negative identification

%%

    % by segmenting in hsv space, the following code eliminates high
    % intensity green regions that do not correspond to acht receptors
    hsv_mask = generate_hsv_mask(patch); 

    % now identify regions with high green intensities. high green
    % intensities are defined by the Kth percentile determined by user.
    intensity_mask = generate_intensity_mask(patch, threshold);

    % combine hue and intensity masks
    hsv_intensity_mask = hsv_mask .* intensity_mask;
    
    % basic preprocessing
    se = strel('disk', 5);
    hsv_intensity_mask = imclose(hsv_intensity_mask, se);
    hsv_intensity_mask = bwareaopen(hsv_intensity_mask, 2);
    
    % finally, generate a mask based on edges
    edge_mask = generate_edge_mask(patch);
    
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