list_paths = dir;
%%
for i = 3:length(dir)
    tic
    path = list_paths(i).name;
   
       disp(i);
       disp(path);

       if identify_vacht(path, 50, 90) == 1
            new_path = strcat('temp_true/', path);

       else
            new_path = strcat('temp_false/', path);
       end

       im_raw = imread(path);
       patch = im_raw * 2^6;
       patch(:,:,1) = 0;
       patch(:,:,2) = patch(:,:,2) * 2.5;
       patch(:,:,3) = 0;

       imwrite(patch, new_path)
       toc
end