
%% generate mask for segmentation
% function: generate mask to segment tissue
% input: 8bit red channel
% output: binary mask

% step 1 of 2: create mask
% http://matlabtricks.com/post-35/a-simple-image-segmentation-example-in-matlab



clc

i1 = imread('red_25.jpg');
se = strel('rectangle',[40 40]);
BW1_1 = imerode(i1,se);
BW1_2 = imdilate(BW1_1,se);
BW1_3 = imdilate(BW1_2,se);
BW1_4 = imdilate(BW1_3,se);
BW1_5 = imdilate(BW1_4,se);
BW1_6 = imdilate(BW1_5,se);

BW_mask = im2bw(BW1_6);
labels = bwlabel(BW_mask);
id = labels(6000, 6000);

man = (labels == id);
man2 = imfill(man, 'holes');
figure, imshow(man2)

%% apply mask to segment
% step 2 of 2: apply mask
% https://www.mathworks.com/matlabcentral/answers/38547-masking-out-image-area-using-binary-mask

j1 = imread('rgb_25.jpg');
man2 = uint8(man2);
j2 = j1.*repmat(man2,[1,1,3]);
imwrite(j2, 'rgb_25_cropped.jpg');
figure, imshow(j2);

%% process masked image
% function: prepares masked image for counting
% inputs: threshold value (set at 40) for imextendedmax
% outputs: image array for regionprops

clc
clear

i0 = imread('rgb_25_cropped.jpg');

i1 = i0(:,:,1);

i2 = imadjust(i1, [0 1], [0 1], 5);
i3 = wiener2(i2, [5 5]);

se = strel('disk',40);
i4 = imtophat(i3, se);

i5 = imdilate(i4, se);

% keep regional maximum only if it is at least 50 units greater
i6 = imextendedmax(i5,50);

% erode smaller objects and regenerate survivors
i7 = imopen(i6, se);

i8 = imerode(i7, se);

figure, imshow(i8)

%% count objects

s = regionprops(i8, 'Centroid', 'Area');


%% inspect ROIs on original image

% function:

% inputs: (1) 3-channel jpeg; (2) struct containing centroid coordinates,
% as calculated by COUNT_OBJECTS function

% output: (1) modified jpeg, displayed

% show ROI on original image
image = imread('rgb_25.jpg');
figure, imshow(image)

for i = 1:length(s)
    centers = s(i).Centroid;
    viscircles(centers,100);
end

%% create tiles
% function:
% input: (1) 3-channel lossless jpeg; (2) centroid coordinates, as calculated by
% COUNT_OBJECTS
% output: (1) 3-channel jpeg tiles; (2) csv of coordinates

% cropping and saving ROI tiles

x = []
y = []
id = []

image = imread('rgb_25.jpg');

for i = 1:length(s)
    centers = s(i).Centroid;
    delta = 256
    tile = image(round(centers(2))-delta:round(centers(2))+(delta -1), round(centers(1))- delta: round(centers(1)) +(delta -1),:);
    filename = strcat(int2str(i),'.jpg')
    imwrite(tile, filename, 'jpg');
    id = vertcat(id, i);
    x = vertcat(x, s(i).Centroid(1));
    y = vertcat(y, s(i).Centroid(2));
end

T = table(id, x, y)
write(T, 'output.txt')