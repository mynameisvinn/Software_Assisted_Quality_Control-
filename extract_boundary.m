%% function: script calculates minimum box around largest object. the
% coordinates of the bounding box should be used to exclude detected
% objects outside of the tissue.
% input: jpeg
% output: array
% notes: should explore active contours in next iteration

clc

i1 = imread('red_25.jpg');
bw = im2bw(i1, graythresh(i1));
s = regionprops(bw, 'Area', 'BoundingBox');

% find largest object
[~,ind] = max([s.Area]);
rect = s(ind).BoundingBox % rect is array containing bounding box vertices

% draw rectangle over object
imshow(bw)
rectangle('Position',rect,'EdgeColor','r')


