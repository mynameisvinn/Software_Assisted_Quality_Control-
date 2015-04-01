%% version 1.0 on 4/1/2015 9:30AM

% function: when executed from folder containing images, script will
% convert each image into 3 images: (1) rgb jpeg; (2) red jpeg; (3) cropped
% RGB jpeg. 

list_of_files = dir

for i = 3:length(list_of_files)-1
    
    % create subfolders
    
    file_name = list_of_files(i).name
    new_folder_name = strsplit(file_name,'.')
    directoryname = char(new_folder_name(1))
    mkdir(directoryname)
    
    % convert each image into rgb and red jpeg
    
    i1 = imread(file_name);
    i1 = uint8(i1);
    path = strcat(char(directoryname), char('/'), 'rgb_25.jpg')
    imwrite(i1, path, 'jpg', 'mode', 'lossy', 'Quality', 25);

    i1_red = i1(:,:,1);
    path = strcat(char(directoryname), char('/'), 'red_25.jpg')
    imwrite(i1_red, path, 'jpg', 'mode', 'lossy', 'Quality', 25);
    
    % convert each image into cropped rgb jpeg

    se = strel('rectangle',[40 40]);
    i1_red = imerode(i1_red,se);
    i1_red = imdilate(i1_red,se);

    BW_mask = im2bw(i1_red);
    se = strel('disk',[100]);
    BW_mask = imdilate(BW_mask,se);
    BW_mask = imdilate(BW_mask,se);
    
    BW_mask = imfill(BW_mask, 'holes');

    % labels gives the labeled image; % num gives the number of objects
    [labels, num] = bwlabel(BW_mask);
    
    % find largest object in image
    % https://it.mathworks.com/matlabcentral/newsreader/view_thread/91291
    tissue_properties = regionprops(labels, 'Area');
    [~,ind] = max([tissue_properties.Area]);

    tissue_mask = (labels == ind);
    se = strel('rectangle',[200 200]);
    tissue_mask = imdilate(tissue_mask,se);
    tissue_mask = imfill(tissue_mask, 'holes');

    % create cropped rgb jpeg
    tissue_mask = uint8(tissue_mask);
    j2 = i1.*repmat(tissue_mask,[1,1,3]);
    
    % save cropped rgb jpeg into subfolder
    path = strcat(char(directoryname), char('/'), 'rgb_25_cropped.jpg')
    imwrite(j2, path);

end