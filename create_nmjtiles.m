
%% generate mask for segmentation
% function: generate mask to segment tissue
% input: 8bit red channel
% output: binary mask

% step 1 of 2: create mask

clc

i1 = imread('red_25.jpg');
se = strel('rectangle',[40 40]);
i1 = imerode(i1,se);
i1 = imdilate(i1,se);
i1 = imdilate(i1,se);
i1 = imdilate(i1,se);
i1 = imdilate(i1,se);
i1 = imdilate(i1,se);

BW_mask = im2bw(i1);
BW_mask = imfill(BW_mask, 'holes');
BW_mask = imfill(BW_mask, 'holes');

% labels gives the labeled image
% num gives the number of objects
[labels, num] = bwlabel(BW_mask);
% id = labels(6000, 6000);

% find largest mask
% https://it.mathworks.com/matlabcentral/newsreader/view_thread/91291
tissue_properties = regionprops(labels, 'Area');
[~,ind] = max([tissue_properties.Area]);
    
% tissue is a mask of logical type
tissue_mask = (labels == ind);

%% apply mask to segment
% step 2 of 2: apply mask

j1 = imread('rgb_25.jpg');
tissue_mask = uint8(tissue_mask);
j2 = j1.*repmat(tissue_mask,[1,1,3]);
imwrite(j2, 'rgb_25_cropped.jpg');

j1_red = imread('red_25.jpg');
tissue_mask = uint8(tissue_mask);
j2_red = j1_red.*tissue_mask;
imwrite(j2_red, 'red_25_cropped.jpg');

%% process masked image
% function: prepares masked image for counting
% inputs: threshold value (set at 40) for imextendedmax
% outputs: image array for regionprops

clc
clear

processed_image = imread('rgb_25_cropped.jpg');

processed_image = processed_image(:,:,1);

processed_image = imadjust(processed_image, [0 1], [0 1], 5);
processed_image = wiener2(processed_image, [5 5]);

se = strel('disk',40);
processed_image = imtophat(processed_image, se);

processed_image = imdilate(processed_image, se);

% keep regional maximum only if it is at least 50 units greater
processed_image = imextendedmax(processed_image,80);

% erode smaller objects and regenerate survivors
processed_image = imopen(processed_image, se);

% processed_image is logical type - do not convert to uint8 yet
processed_image = imerode(processed_image, se);


%% count objects

s = regionprops(processed_image, 'Centroid', 'Area');


%% inspect ROIs on original image

% function:

% inputs: (1) 3-channel jpeg; (2) struct containing centroid coordinates,
% as calculated by COUNT_OBJECTS function

% output: (1) modified jpeg, displayed

% show ROI on original image
image = imread('rgb_25.jpg');
figure, imshow(image)

for i = 1:length(s)
    if (s(i).Area < 20)
        centers = s(i).Centroid;
        viscircles(centers,100);
    end
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
tileid = []

image = imread('rgb_25.jpg');

% extract dimensions for coordinatetotileid function
dimensions = size(image)


for i = 1:length(s)
    if (s(i).Area < 20)
        centers = s(i).Centroid;
        delta = 256
        tile = image(round(centers(2))-delta:round(centers(2))+(delta -1), round(centers(1))- delta: round(centers(1)) +(delta -1),:);
        filename = strcat(int2str(i),'.jpg')
        imwrite(tile, filename, 'jpg');
        id = vertcat(id, i);
        x = vertcat(x, s(i).Centroid(1));
        y = vertcat(y, s(i).Centroid(2));
        
        
        % calculate tileID
        clickX = centers(1)
        clickY = centers(2)
        imageH = dimensions(1)
        imageW = dimensions(2)
        tile_hash_id = CoordinatesToTileNumber(clickX, clickY, imageH, imageW)
        tileid = vertcat(tileid, tile_hash_id);
    end
end

T = table(id, x, y, tileid)
write(T, 'output.txt')