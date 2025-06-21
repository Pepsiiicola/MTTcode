%******************************
%       全局系统参数设置
%******************************
N  = 100;     % 跟踪时长
T  = 1;       % 采样时间间隔1s
Ps = 1;       % 目标存活概率
ZR_init = 60;       % 杂波期望
% PD = 1;     % 检测概率 --> 在 Configuration.m文件中设置
N_sensor = 16; % 传感器个数
% R_DETECT = 1000;  % 观测范围设置 --> 在 Configuration.m文件中设置
R_INTERVAL = 1000; % 平台之间的间距
R_COMMUNICATE = R_INTERVAL;  % 通信半径
R_init = diag([100,1,1]); % 观测误差协方差

%=======是否存在遮挡======
Occlusion_flag = 0;

%===========================
%     分散式拓扑矩阵生成
%===========================
location_center = [0;0;0;1]; % 平台原点坐标(前3维)，平台编号(第4维)
[mat_topo_decen,location] = topo_born_3d(N_sensor,location_center,R_INTERVAL,R_COMMUNICATE);
% 大都市权重分配
[mat_weight_decen] = Metropolis_Weights(mat_topo_decen);


%=============2024.11.5 增加拓扑变化=============
% N_sensor_extra = 11;
% Num_communicate_decen_extra = 11;
% [mat_topo_decen_extra,location_extra] = topo_born_3d(N_sensor_extra,location_center,R_INTERVAL,R_COMMUNICATE);


%==========================
%    分布式拓扑矩阵生成
%==========================
% 分布式需要将所有节点与中心节点(视为融合中心)进行拓扑关联，并且取消与其余节点拓扑的关联
% 默认1号节点为融合中心节点
mat_topo_distr = mat_topo_decen * 0;
mat_topo_distr(1,:) = 1;
mat_topo_distr(:,1) = 1;

% == 运动目标的状态属性设置 == 
% 1.初始X坐标  2.X速度  3.Y坐标  4.Y速度  5.Z坐标  6.Z速度  7.出现时间   8.消亡时间  9.运动模式
% 注: 最后一维的运动模式，有三种运动模式：CV,CA,CT  具体实现见函数 targetset.mat
motion_pattern_default = 1; % 默认运动模式
Set_TargetState=[
%          400   -10   100    -10   0    0    20   N   motion_pattern_default; % 1
%         -1500   0   -500     10   0    0    1    80   motion_pattern_default; % 2
%         -1000   15  1700    0    0    0     1    N   motion_pattern_default;%3
        -1000   25  -2000    8    0    0    50   N   motion_pattern_default; % 4
%         -800   -10   400     10   0    0    20   60  motion_pattern_default; % 5
        -800    0    300    -10   0    0    1    N   motion_pattern_default; % 6
         600   -15   1000   -10   0    0    20   N   motion_pattern_default; % 7       
        -300    10  -500    -10   0    0    20   80  motion_pattern_default; % 8
%          1500    5    1000   -15  0    0    1    80   motion_pattern_default; % 9
        -1400  -10   1500   -20   0    0    20   80  motion_pattern_default; % 10
        -500    15   250      0   0    0    1    N   motion_pattern_default; % 11
%         -2000   13   2000     7   0    0    1    N  motion_pattern_default; % 12
%         -3000   5    -300     8   0    0    1    N  motion_pattern_default; % 13
%          1100   6    -2300   16   0    0    20   80 motion_pattern_default; % 14
%         -2000   0    -800    -6   0    0    1    N  motion_pattern_default; % 15
         500     3     3000   -8   0    0   1   N  motion_pattern_default; % 16
         1800     7     2200   -8   0    0   1   N  motion_pattern_default; % 16
         2000     9     -1750   10   0    0   1   N  motion_pattern_default; % 16
         
        ]';
% Set_TargetState=[
%          400   -10   100    -10   100    10    20   N   motion_pattern_default; % 1
%         -1500   0   -500     10   -500   5    1    80   motion_pattern_default; % 2
%         -1000   15   1700    0    800    -5    1    N   motion_pattern_default; % 3
%         -1500   25   2300    10    1000    20    50   N   motion_pattern_default; % 4
%         -800   -10   400     10   -800    0    20   60  motion_pattern_default; % 5
%         -800    0    300    -10   -1000    15    1    N   motion_pattern_default; % 6
%          600   -15   1000   -10   1000    -10    20   N   motion_pattern_default; % 7       
%         -300    10  -500    -10   -1000    10    20   80  motion_pattern_default; % 8
%          1000    5    2000   -15   250    10    1    80   motion_pattern_default; % 9
%         -1400  -10   1500   -20   -250    -10    20    80  motion_pattern_default; % 10
%         -500    15   250     0    0    -10    1    N   motion_pattern_default; % 11
%         ]';