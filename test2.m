draw_fram();



function draw_fram(data, coordinates, index_to_be_draw)
    
    z = data(index_to_be_draw).disp_x;
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
    title('Max Displacement', FontSize=14);

end