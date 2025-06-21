%{
                           分布式的PHD相关参数进行初始化
%}
for i=1:N_sensor
    
    %***********************
    %   滤波相关参数初始化
    %***********************
    % 全局粒子初始化
    Sensor(i).state{1,1}=0;           % 权重
    Sensor(i).state{2,1}=zeros(6,1);  % 均值
    Sensor(i).state{3,1}=zeros(6,6);  % 协方差
    Sensor(i).state{4,1}=0;           % 粒子数量
    
    %***********************
    %   估计相关参数初始化
    %***********************
    % 第一个时刻的初始值赋值
    Sensor(i).X_est{1,1}=zeros(6,0); % 全局目标估计结果
    Sensor(i).X_est{2,1}=zeros(6,0); % 全局目标估计结果
    
end

% 融合中心变量初始化
Fusion_center = struct;
Fusion_center.sensor_inf = struct;
Fusion_center.Inf_recieve = struct;

%===每个传感器的融合中心已知的一些先验信息===
for i=1:N_sensor
    for j = 1: N_sensor
        Fusion_center(i).sensor_inf(j).location = Sensor(j).location;  % 传感器的位置信息
        Fusion_center(i).sensor_inf(j).R_detect = Sensor(j).R_detect;  % 传感器的观测半径
        Fusion_center(i).sensor_inf(j).serial   = Sensor(j).serial;    % 传感器的编号
    end
end