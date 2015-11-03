function [edge_mask] = generate_edge_mask(im_raw)

% created on 10/29/15

% function:
% ---------
% given an image (unmodified uint16), generate an "edges" mask. an edges
% mask effectively retains only high-frequency, high contrast regions.

% parameters:
% -----------
% @im_raw: unmodified uint16 image with dimensions 201x201x3

% returns:
% --------
% @edge_mask: edge mask, which reveals areas with dense horizontal and
% vertical edges
    
    im_raw = im_raw * 2^6;
    im_raw = im_raw(:,:,2);
    
    % basic blurring to remove salt pepper noise
    kernel = fspecial('gaussian', [3 3], 15); % ([kernel dimensions], sigma); larger sigma values will reduce count
    im_raw = imfilter(im_raw, kernel ,'same', 'conv');
    
    % find horizontal and vertical edges to generate edges mask
    se = strel('disk', 5);
    
    im_raw = imadjust(im_raw, [], [], 2);
    
    im_horizontal = edge(im_raw,'Prewitt','horizontal');
    im_horizontal = imclose(im_horizontal, se);
   
    im_vertical = edge(im_raw,'Prewitt','vertical');
    im_vertical = imclose(im_vertical, se);
    
    edge_mask = im_horizontal .* im_vertical;

end

