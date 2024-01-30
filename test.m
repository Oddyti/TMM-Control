h = waitbar(0, '数据输出中……');
m = 10;
pause(1);
elapsed_time = 0;

for i = 1:1:m %m为循环次数，可以自己定义，也可以是前面某个矩阵的行数或列数
    tic;

    p = fix(i / m * 10000) / 100; %这样做是可以让进度条的 %位数为2位
    time_remaining = (m-i)*elapsed_time/60;
    str = {sprintf('当前进度：%3d / %3d，预计剩余：%2.2f分钟',i,m, time_remaining)}; %进度条上显示的内容

    waitbar(i / m, h, str);

    pause(0.8); % 正式编写是删去这一行暂停代码

    %------------------------

    %   写正常循环的语句   %

    %------------------------

    elapsed_time = toc;
end

close(h);

msgbox('输出完毕~');
