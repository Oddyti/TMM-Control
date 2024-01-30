function [data, coordinates] = process_data_colormap(index_map)

    data_folder = 'data/metadata';
    files = dir(data_folder);
    data_names = {files.name};
    data_names(1:2) = [];
    data_names = erase(data_names, '.mat');
    data_names = data_names';
    L = numel(data_names);

    % data_names_mat stores all the data names like '10 2 4 2 1', means: 10N, (2,4) Y Point 1
    data_names_mat = zeros(numel(data_names), 5);
    for i = 1:L
        temp = data_names{i};
        temp = split(temp, '_');

        for j = 1:5
            data_names_mat(i, j) = str2double(temp{j});
        end

    end

    % change all the lattice name into individual numbers
    [U_entire_name, ~, ~, ~, ~] = store_u_name_unit_cell(5, 5);
    U_entire_name_str = num2str(U_entire_name);
    row = double(U_entire_name_str(:, 1)) - 48; % double(a): get the ASCII of a, then minus 48 to get the num of string a
    col = double(U_entire_name_str(:, 3)) - 48;
    direction = double(U_entire_name_str(:, 4)) - 48;
    point = double(U_entire_name_str(:, 5)) - 48;
    
    U_entire_name_single = U_entire_name(1:2:end, :);
    % 按照U_entire_name的顺序存储了每个点实际的x,y坐标
    % 这和displacement中的顺序对应
    coordinates = zeros(85, 2);
    for i = 1:85
        temp_index = [row(i*2), col(i*2), point(i*2)];
        for j = 1:numel(index_map)
            if isequal(index_map(j).index, temp_index)
                coordinates(i, 1) = index_map(j).x;
                coordinates(i, 2) = index_map(j).y;
                break;
            end
        end
    end

    % final data struct
    data = struct('F', {},'F_index', {},'F_coor', {}, 'disp_x', {},'disp_y', {},'disp_norm', {});
    tic
    % Data Processing: traverse the data according the data_names and extract the required data
    for i = 1:L
        data_name = strcat('data/metadata/', data_names{i});
        load(data_name);
        data(i).F = data_names_mat(i,1);
        F_index = data_names_mat(i,2:end);
        data(i).F_index = F_index;
        Temp = F_index;
        Temp(3) = [];
        F_coor = zeros(2,1);
        for j = 1:numel(index_map)
            if isequal(index_map(j).index, Temp)
                F_coor(1) = index_map(j).x;
                F_coor(2) = index_map(j).y;
                break;
            end
        end
        data(i).F_coor = F_coor;

        U_displacement = U(1:2:end, 123); % HERE: extract the 123 row of the data(0.122s)

        U_displacement_x = U_displacement(1:2:end, :);
        data(i).disp_x = U_displacement_x;
        
        U_displacement_y = U_displacement(2:2:end, :);
        data(i).disp_y = U_displacement_y;
        
        U_displacement_norm = sqrt(U_displacement_x .^ 2 + U_displacement_y .^ 2);
        data(i).disp_norm = U_displacement_norm;
        
    end
    toc
    disp('The data was processed successfully!');
    save('data_colormap.mat', 'data');
    save('coordinates.mat', 'coordinates');
end