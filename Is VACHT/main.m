% generate patches - dimensions should be 200x200

list_paths = dir;
%%
for i = 3:163
    tic
    path = list_paths(i).name;

    disp(i);
    disp(path);

    patch = imread(path);

    if is_vacht(patch, 50, 90) == 1
        new_path = strcat('true/', path);

    else
        new_path = strcat('false/', path);
    end

    % display
    patch = patch * 2^6;
    patch(:,:,1) = 0;
    patch(:,:,2) = patch(:,:,2) * 2.5;
    patch(:,:,3) = 0;

    imwrite(patch, new_path)
    toc
end