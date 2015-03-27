%% image format conversion

% function: converts 12 bit JP2 RGB into 8-bit, lossy red and green JPEGS
% input: JP2
% output: (1) 8 bit red JPEG at 25% compression; (2) 8 bit green JPEG at 25% compression; 

i1 = imread('test.jp2');
i2 = uint8(i1);

% create red channel
i2_red = i2(:,:,1);

% create green channel
i2_green = i2(:,:,2);

% save files to disk
imwrite(i2, 'rgb_25.jpg', 'jpg', 'mode', 'lossy', 'Quality', 25);
imwrite(i2_red, 'red_25.jpg', 'jpg', 'mode', 'lossy', 'Quality', 25);
imwrite(i2_green, 'green_25.jpg', 'jpg', 'mode', 'lossy', 'Quality', 25);