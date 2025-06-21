%==============================
%    分散式平台公共属性初始化
%==============================
Sensor_decen = struct; % 分散式平台
for i=1:N_sensor
    
    % 传感器属性设置
    Sensor_decen(i).Pd = PD; % 检测范围
    Sensor_decen(i).R  = R;  % 观测误差协方差
    Sensor_decen(i).Zr = ZR; % 杂波期望
    Sensor_decen(i).R_detect = R_DETECT;        % 检测范围
%     Sensor_decen(i).R_communicate=R_INTERVAL; % 通信距离(默认为平台的距离)
    Sensor_decen(i).location = location(1:3,i); % 平台坐标(全局笛卡尔坐标)
    Sensor_decen(i).serial = location(4,i);     % 平台编号 
    Sensor_decen(i).mat_topo = mat_topo_decen;  % 平台拓扑矩阵
    Sensor_decen(i).Num_communicate = Num_communicate_decen; % 单个融合周期通信次数
    Sensor_decen(i).Com_BandWidth = ComWD;
    
    % 观测相关变量
    Sensor_decen(i).Z_polar_part = cell(N,1);    % 极坐标系下的局部观测(以平台为中心)
    Sensor_decen(i).Z_dicaer_global = cell(N,1); % 笛卡尔坐标系下的全局观测
    
end

%================================
%       分布式平台属性初始化
%================================
Sensor_distr=struct; % 分散式平台
for i=1:N_sensor
    
    % 传感器属性设置
    Sensor_distr(i).Pd = PD; % 检测范围
    Sensor_distr(i).R = R;   % 观测误差协方差
    Sensor_distr(i).Zr = ZR; % 杂波期望
    Sensor_distr(i).R_detect = R_DETECT;         % 检测范围
%     Sensor_distr(i).R_communicate=R_INTERVAL;  % 通信距离(默认为平台的距离)
    Sensor_distr(i).location = location(1:3,i);  % 平台坐标(全局笛卡尔坐标)
    Sensor_distr(i).serial = location(4,i);      % 平台编号
    Sensor_distr(i).mat_topo = mat_topo_distr; % 平台拓扑矩阵
   
    % 观测相关变量
    Sensor_distr(i).Z_polar_part = cell(N,1);    % 极坐标系下的局部观测(以平台为中心)
    Sensor_distr(i).Z_dicaer_global = cell(N,1); % 笛卡尔坐标系下的全局观测
    
end