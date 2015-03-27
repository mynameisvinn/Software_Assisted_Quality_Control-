
%% image processing
% function: given image, create binary image for object counting
% input: file name
% output: image (2d array)

clc

i1 = imread('red_25.jpg');
i2 = wiener2(i1, [5 5]);

se = strel('rectangle',[40 40]);
i3 = imtophat(i2, se);

i4 = imdilate(i3, se);

i5 = imextendedmax(i4,80);

i6 = imclose(i5, se);

i7 = imerode(i6, se);

i8 = imerode(i7, se);

%% generate mask
% function: given image, generate mask to exclude background
% input: image object
% output: image object

% http://matlabtricks.com/post-35/a-simple-image-segmentation-example-in-matlab

SE40 = strel('rectangle',[40 40]);
BW1_1 = imerode(i1,SE40);
BW1_2 = imdilate(BW1_1,SE40);
BW1_3 = imdilate(BW1_2,SE40);
BW1_4 = imdilate(BW1_2,SE40);
BW_mask = im2bw(BW1_4);
labels = bwlabel(BW_mask);
id = labels(6000, 6000);
man = (labels == id);
imshow(man)


% https://www.mathworks.com/matlabcentral/answers/38547-masking-out-image-area-using-binary-mask

j1 = imread('rgb_25.jpg');
man = uint8(man);
j2 = j1.*man;

%% detect objects
% function: given processed image, generate contours
% input: processed image
% output: array of contours

s = regionprops(i8, 'Centroid', 'BoundingBox', 'Area');


%% inspect image
% function: modify original image to show detected objects
% input: original image
% output: modified image

% show ROI on original image
image = imread('rgb_25.jpg');
imshow(image)

% define isinbox lambda function
isInBox = @(M,B) (M(:,1)>B(1)).*(M(:,1)<B(1)+B(3)).*(M(:,2)>B(2)).*(M(:,2)<B(2)+B(4));

for i = 1:length(s)
    centers = s(i).Centroid;
    if (isInBox(centers, rect)) && (s(i).Area < 200)
        viscircles(centers,100);
    end
end

%% generate tiles

% cropping and saving ROI tiles

x = []
y = []
id = []

for i = 1:length(s)
    centers = s(i).Centroid;
    if isInBox(centers, rect)
        tile = imcrop(image, [centers-100, 512, 512]);
        filename = strcat(int2str(i),'.jpg')
        imwrite(tile, filename, 'jpg');
        id = vertcat(id, i);
        x = vertcat(x, s(i).Centroid(1));
        y = vertcat(y, s(i).Centroid(2));
    end
end

% save coordinates as csv to disk

T = table(id, x, y)
write(T, 'output.txt')