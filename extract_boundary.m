i1 = imread('red_channel_25.jpg');

bw = im2bw(i1, graythresh(i1));
bw2 = imfill(bw)

s = regionprops(bw, 'Area', 'PixelList', 'BoundingBox');

% find largest object
[~,ind] = max([s.Area]);

rect = s(ind).BoundingBox

% draw rectangle over object
imshow(bw)
rectangle('Position',rect,'EdgeColor','r')


% active contours