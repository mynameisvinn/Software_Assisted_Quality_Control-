clc
tic
i1 = imread('37_96_2015-03-30_2_1579_()_2_1_50_1_schema_assigned_464807_lossy.jp2');

% convert to 8bit image
% for better performance, create new variable when changing class type
i2 = uint8(i1);

% imwrite(i2, 'rgb.jpg', 'jpg', 'Quality', 100);

% option: create tiff files
imwrite(i2, 'rgb.tif', 'tiff');
toc