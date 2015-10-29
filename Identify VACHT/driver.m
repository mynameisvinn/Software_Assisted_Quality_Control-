list_paths = dir;
%%
for i = 3:length(list_paths)
    tic
    path = list_paths(i).name;
   
       disp(i);
       disp(path);

       if identify_vacht_2(path, 50, 90) == 1
            new_path = strcat('true/', path);

       else
            new_path = strcat('false/', path);
       end

       im_raw = imread(path);
       patch = im_raw * 2^6;
       patch(:,:,1) = 0;
       patch(:,:,2) = patch(:,:,2) * 2.5;
       patch(:,:,3) = 0;

       imwrite(patch, new_path)
       toc
end