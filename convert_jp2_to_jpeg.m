% function: converts 3-channel, 12 bit JP2 into 8-bit, lossy red and green JPEGS
% input: JP2 image
% output: (1) compressed 8 bit red JPEG; (2) compressed 8 bit RGB JPEG; (2)
% uncompressed 8 bit TIFF

i1 = imread('25_10_2015-02-18_3_1020_()_4_2_18_schema_assigned_134824_lossy.jp2');
i2 = uint8(i1);
i2_red = i2(:,:,1);

imwrite(i2, 'rgb_25.jpg', 'jpg', 'mode', 'lossy', 'Quality', 25);
imwrite(i2, 'rgb_25.tif', 'tiff');
imwrite(i2_red, 'red_25.jpg', 'jpg', 'mode', 'lossy', 'Quality', 25);

clear
