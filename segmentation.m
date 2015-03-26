i1 = imread('red_channel_25.jpg');
i2 = wiener2(i1, [5 5]);
i3 = adapthisteq(i2);

se = strel('disk',6);
i4 = imtophat(i3, se);

i5 = imextendedmax(i4,80);

i6 = imerode(i5,se);
i7 = imerode(i6,se);

s = regionprops(i7, 'centroid');


% show all ROI circles on original image
image = imread('vin_test_image-25.jpg');
imshow(image)


for i = 1:173
    centers = s(i).Centroid;
    viscircles(centers,100);
end

% cropping and saving ROI tiles

for i = 1:173
    centers = s(i).Centroid;
    tile = imcrop(image, [centers-100, 512, 512]);
    filename = strcat(int2str(i),'.jpg')
    imwrite(tile, filename, 'jpg');
end


