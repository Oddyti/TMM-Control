%% PreSettings
    close all;
    clear;
    clear -global;
    clc;

    addpath('functions');
    % rows and columns of unit cells.
    n = 5; m = 5;

    % Angle of the homogeneous lattice (1<=i_alpha<=176), (0.3344<=alpha<=3.8344).
    i_alpha = 16;

    % Lattice configuration.
    % Blue Triangle
    a_b = 0.5; b_b = 0.7; c_b = 1;
    psi_ab = acos((a_b ^ 2 - b_b ^ 2 - c_b ^ 2) / (-2 * b_b * c_b));
    psi_bb = acos((b_b ^ 2 - a_b ^ 2 - c_b ^ 2) / (-2 * a_b * c_b));
    psi_cb = acos((c_b ^ 2 - b_b ^ 2 - a_b ^ 2) / (-2 * b_b * a_b));

    % Red Triangle
    a_r = 0.4; b_r = 0.8; c_r = 1;
    psi_ar = acos((a_r ^ 2 - b_r ^ 2 - c_r ^ 2) / (-2 * b_r * c_r));
    psi_br = acos((b_r ^ 2 - a_r ^ 2 - c_r ^ 2) / (-2 * a_r * c_r));
    psi_cr = acos((c_r ^ 2 - b_r ^ 2 - a_r ^ 2) / (-2 * b_r * a_r));

    l_s = (a_b + b_r) / 2 * 0.95;
    k_bond = 1e4; k_spring = 100;
    eta_bond = 20; eta_spring = 10;
    m_b = 0.1; m_r = 0.1;

    Lattice_config.a_b = a_b;
    Lattice_config.b_b = b_b;
    Lattice_config.c_b = c_b;
    Lattice_config.psi_ab = psi_ab;
    Lattice_config.psi_bb = psi_bb;
    Lattice_config.psi_cb = psi_cb;
    Lattice_config.a_r = a_r;
    Lattice_config.b_r = b_r;
    Lattice_config.c_r = c_r;
    Lattice_config.psi_ar = psi_ar;
    Lattice_config.psi_br = psi_br;
    Lattice_config.psi_cr = psi_cr;
    Lattice_config.l_s = l_s;
    Lattice_config.k_bond = k_bond;
    Lattice_config.k_spring = k_spring;
    Lattice_config.eta_bond = eta_bond;
    Lattice_config.eta_spring = eta_spring;
    Lattice_config.m_b = m_b;
    Lattice_config.m_r = m_r;

    % Solve angles bistable lattice
    [Alpha, Gamma, Theta] = solve_angles_bistable_lattice(Lattice_config);

    % Present homogeneous hexagon
    [Coor_unit_cell_x, Coor_unit_cell_y, rotation_kappa] = present_homogeneous_hexagon(Lattice_config, Alpha, Gamma, Theta, n, m, i_alpha);

    % Store u name unit cell
    [U_entire_name, U_bottom_name, U_left_name, U_top_name, U_right_name] = store_u_name_unit_cell(n, m);

    % Generate the basic index_map
    index_map = generate_index_map(Coor_unit_cell_x, Coor_unit_cell_y, rotation_kappa, m, n);
    % Process the matadata for analyzing
    % the process_data() function takes about 30 seconds to finish
    file1 = 'data_colormap.mat';
    file2 = 'coordinates.mat';
    if exist(file1, 'file') == 2 && exist(file2, 'file') == 2
        disp('data_colormap.mat found!');
        load data_colormap.mat;
        load coordinates.mat;
    else
        disp('data_colormap.mat not found! Start to process the data');
        [data, coordinates] = process_data_colormap(index_map);
    end

%% Draw static figure
    BASE_COLOR_1 = [20, 102, 127]/255;
    BASE_COLOR_2 = [226, 121, 35]/255;
    % BASE_COLOR_1 = [189, 207, 214]/255;
    % BASE_COLOR_2 = [224, 198, 179]/255;
    F_index = [1,1,1,3];
    
    F_value_loop = [1:6, 8:2:20, 25:5:100];
    F_index_loop = struct('F_index', {});
    for i = 1:170
        F_index_loop(i).F_index = data(i).F_index;
    end
    
    w = waitbar(0, 'GIF图像生成中');
    pause(1);
    elapsed_time = 60;

    index_num = 170;
    for index = 1:index_num
        tic;
        time_remaining = (index_num-index)*elapsed_time/60;
        message = {sprintf('当前进度：%3d / %3d，预计剩余：%2.2f分钟',index,index_num, time_remaining)};
        waitbar(index/index_num,w,message);

        for direction = 1:3

            close all;

            % filename
            F_index_str = strjoin(string(F_index_loop(index).F_index), '-');
            filename = strcat('output/colormap_images/', F_index_str,'-',num2str(direction), '.gif');

            % Loop through the data of same F_index and draw the gif
            h1 = figure('Position',[826,108,1018,777]);
            set(gca, 'FontSize', 12);
            frameRate = 5;
            % v = VideoWriter('test.mp4', 'MPEG-4');
            % v.FrameRate = 5;  % 设置视频的帧速率
            % v.Quality  = 100;
            % open(v);  % 打开 VideoWriter 对象准备写入视频

            for each_value = 1:29
                index_to_be_draw = [];
                for i = 1:numel(data)
                    if isequal(F_index_loop(index).F_index, data(i).F_index) && isequal(F_value_loop(each_value), data(i).F)
                        index_to_be_draw = i;
                        break;
                    end
                end

                % draw base cells
                for i = 1:n + 1
                    for j = 1:m
                        for k = 1:9
                            XY_unit(1, k) = Coor_unit_cell_x(i, j, k); XY_unit(2, k) = Coor_unit_cell_y(i, j, k);
                        end
                        XY_unit = rotation_kappa * XY_unit;
                        if i == 1
                            plot(XY_unit(1, 4:7), XY_unit(2, 4:7),  'color', BASE_COLOR_1, 'linewidth', 1.4); hold on;
                            % fill(XY_unit(1, 4:7), XY_unit(2, 4:7),  BASE_COLOR_1, 'linestyle', 'none', FaceAlpha=0.5); hold on;
                        elseif i == n + 1
                            plot(XY_unit(1, 1:4), XY_unit(2, 1:4),  'color', BASE_COLOR_2, 'linewidth', 1.4); hold on;
                            % fill(XY_unit(1, 1:4), XY_unit(2, 1:4), BASE_COLOR_2, 'linestyle', 'none', FaceAlpha=0.5); hold on;
                        else
                            plot(XY_unit(1, 1:4), XY_unit(2, 1:4), 'color', BASE_COLOR_2, 'linewidth', 1.4); hold on;
                            % fill(XY_unit(1, 1:4), XY_unit(2, 1:4),  BASE_COLOR_2, 'linestyle', 'none', FaceAlpha=0.5); hold on;
                            plot(XY_unit(1, 4:7), XY_unit(2, 4:7),  'color', BASE_COLOR_1, 'linewidth', 1.4); hold on;
                            % fill(XY_unit(1, 4:7), XY_unit(2, 4:7),  BASE_COLOR_1, 'linestyle', 'none', FaceAlpha=0.5); hold on;
                        end
                    end
                end

                draw_fram(data, coordinates, index_to_be_draw, direction, F_index_str);

                drawnow;

                % Capture the plot as an image
                frame = getframe(h1);
                im = frame2im(frame);
                [imind, cm] = rgb2ind(im, 256);

                % Write to the GIF File
                if each_value == 1
                    imwrite(imind, cm, filename, 'gif', 'Loopcount', 1, 'DelayTime', 1/frameRate);
                else
                    imwrite(imind, cm, filename, 'gif', 'WriteMode', 'append', 'DelayTime', 1/frameRate);
                end
                    
                % % 将当前帧写入视频
                % frame = getframe(h);  % 获取当前图像帧
                % writeVideo(v, frame);  % 写入视频

                % 清除之前的文本
                delete(findobj('Type', 'text'));
            end

            % close(v);
        end

        elapsed_time = toc;
    end
    
    close(w);
    
    msgbox('输出完毕~');

    function draw_fram(data, coordinates, index_to_be_draw, displacement_type, F_index_str)

        if displacement_type == 1
            z = data(index_to_be_draw).disp_norm;
            title_text = strcat('Displacement', " - Force at [", F_index_str, ']');
        elseif displacement_type == 2
            z = data(index_to_be_draw).disp_x;
            title_text = strcat('Displacement of X Direction', " - Force at [", F_index_str, ']');
        elseif displacement_type == 3
            z = data(index_to_be_draw).disp_y;
            title_text = strcat('Displacement of X Direction', " - Force at [", F_index_str, ']');
        else
            error('ERROR: Input the correct displacment-type: 1, 2, 3');
        end

    
        % 定义颜色映射范围
        cmin = min(z);
        cmax = max(z);
        normalized_z = (z - cmin) / (cmax - cmin);
        
        colormap('turbo');
        % 绘制散点图，并使用连续伪彩色
        scatter(coordinates(:, 1), coordinates(:, 2), 150, normalized_z, 'filled');
        colorbar; % 显示颜色的色标
    
        scatter(data(index_to_be_draw).F_coor(1),data(index_to_be_draw).F_coor(2), 200, "red", "LineWidth",2);
        if data(index_to_be_draw).F_index(3) == 1
            quiver(data(index_to_be_draw).F_coor(1),data(index_to_be_draw).F_coor(2),0.5,0,1,'Color','red', 'LineWidth', 2);
        else
            quiver(data(index_to_be_draw).F_coor(1),data(index_to_be_draw).F_coor(2),0,0.5,1,'Color','red', 'LineWidth', 2);
        end
    
        text(4.5, 5.5, strcat('External Force: ', sprintf('%3d',data(index_to_be_draw).F)), 'FontSize', 14, 'FontWeight', 'bold', 'HorizontalAlignment', 'left');
        xlim([-3, 7]); ylim([-1, 6]);
        grid on;
        title(title_text, FontSize=14);
    
    end


    % figure('Position',[826,108,1018,777]);
    % set(gca, 'FontSize', 12);
    % % draw base cells
    % for i = 1:n + 1
    %     for j = 1:m
    %         for k = 1:9
    %             XY_unit(1, k) = Coor_unit_cell_x(i, j, k); XY_unit(2, k) = Coor_unit_cell_y(i, j, k);
    %         end
    %         XY_unit = rotation_kappa * XY_unit;
    %         if i == 1
    %             plot(XY_unit(1, 4:7), XY_unit(2, 4:7),  'color', BASE_COLOR_1, 'linewidth', 1.4); hold on;
    %             % fill(XY_unit(1, 4:7), XY_unit(2, 4:7),  BASE_COLOR_1, 'linestyle', 'none', FaceAlpha=0.5); hold on;
    %         elseif i == n + 1
    %             plot(XY_unit(1, 1:4), XY_unit(2, 1:4),  'color', BASE_COLOR_2, 'linewidth', 1.4); hold on;
    %             % fill(XY_unit(1, 1:4), XY_unit(2, 1:4), BASE_COLOR_2, 'linestyle', 'none', FaceAlpha=0.5); hold on;
    %         else
    %             plot(XY_unit(1, 1:4), XY_unit(2, 1:4), 'color', BASE_COLOR_2, 'linewidth', 1.4); hold on;
    %             % fill(XY_unit(1, 1:4), XY_unit(2, 1:4),  BASE_COLOR_2, 'linestyle', 'none', FaceAlpha=0.5); hold on;
    %             plot(XY_unit(1, 4:7), XY_unit(2, 4:7),  'color', BASE_COLOR_1, 'linewidth', 1.4); hold on;
    %             % fill(XY_unit(1, 4:7), XY_unit(2, 4:7),  BASE_COLOR_1, 'linestyle', 'none', FaceAlpha=0.5); hold on;
    %         end
    %     end
    % end

    % z = data(2).disp_x;
    % % 定义颜色映射范围
    % cmin = min(z);
    % cmax = max(z);
    % normalized_z = (z - cmin) / (cmax - cmin);
    
    % colormap('turbo');
    % % 绘制散点图，并使用连续伪彩色
    % scatter(coordinates(:, 1), coordinates(:, 2), 150, normalized_z, 'filled');
    % colorbar; % 显示颜色的色标

    % scatter(data(2).F_coor(1),data(2).F_coor(2), 200, "red", "LineWidth",2);
    % if data(2).F_index(3) == 1
    %     quiver(data(2).F_coor(1),data(2).F_coor(2),0.5,0,1,'Color','red', 'LineWidth', 2);
    % else
    %     quiver(data(2).F_coor(1),data(2).F_coor(2),0,0.5,1,'Color','red', 'LineWidth', 2);
    % end

    % text(4.5, 5.5, strcat('External Force: ', sprintf('%3d',data(2).F)), 'FontSize', 14, 'FontWeight', 'bold', 'HorizontalAlignment', 'left');
    % xlim([-3, 7]); ylim([-1, 6]);
    % grid on;
    % title('Max Displacement', FontSize=14);