% function: converts 3-channel, 12 bit JP2 into 8-bit, lossy red and green JPEGS
% input: JP2 image
% output: (1) 8 bit red JPEG at 25% compression; (2) 8 bit green JPEG at 25% compression; 

i1 = imread('vin_test_image.jp2');
i2 = uint8(i1);
i2_red = i2(:,:,1);
i2_green = i_4(:,:,2);
imwrite(i2_red, 'red_25.jpg', 'jpg', 'mode', 'lossy', 'Quality', 25);
imwrite(i2_green, 'green_25.jpg', 'jpg', 'mode', 'lossy', 'Quality', 25);