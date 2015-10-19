% @date: 10/19/15
% @author: vin tang
% @function: for each datafile ID, generate patches according to raw
% specimen

for idx = 1:length(list_of_data_id)
    
    tic
    raw_specimen = list_of_data_id(idx, 1);
    data_id = list_of_data_id(idx, 2);
    
    disp(idx);
    disp(data_id);

    generate_patch(data_id, raw_specimen);
    toc
end
