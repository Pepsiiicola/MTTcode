% 【具体场景配置(包含算法选择和指标选择)】
Config = struct; % 配置变量
Config.M = 100;    % 蒙特卡洛次数

%  == 对比算法选择 ==
% 目录
% 1.李天成     2019 分散式 AA融合 粒子PHD
% 2.Yiwei      2020 分布式 AA融合 GMPHD
% 3.LiGC       2020 分布式 GA融合 GMPHD
% 4.Giorgio    2013 分散式 KLD融合 CPHD
% 5.课题组工作 2022 分散式 AA融合 GMPHD
% 6.课题组工作 2022 分散式 GA融合 GMPHD
% 7.课题组工作 2022 分散式 AGM融合 GMPHD
% 8.创新点1    2023 分散式 AA融合  GMPHD-------add by swc
% 9.创新点2    2023 分散式 AGM2.0融合 GMPHD  -----add by swc
% 10.王佰录    2022 分散式 BIRD融合  GMPHD -------add by swc
% 11.创新点3   2025 分散式 AGM3.0融合 GMPHD ------add by swc
% 12.李天成泛洪  2017 分散式 AGM融合  GMPHD ------add by swc
Config.AlgCompare = [0,0,0,0,0,0,1,1,1,1,0,1];
% Config.AlgCompare = [0,0,0,0,0,0,0,1,0,0,0];

% == 指标选择 == 
% 目录
% 1.OSPA
% 2.数量
% 3.计算量
% 4.视域重叠程度和OSPA均值的二维图
% 5.通信次数和OSPA收敛的二维图
% 6.拓扑连接程度，通信次数和OSPA收敛的二维图(分别对应x,y,z轴)--(已废弃)
% 7.检测概率和OSPA收敛的二维图
% 8.观测误差和OSPA收敛的二维图
% 9.杂波数目和OSPA收敛的二维图
% 10.通信带宽和OSPA收敛的二维图
% 4、5、6、7、8的存在互斥，每次只能出其中的一个图
Config.AlgPerformance = [1,1,1,0,0,0,0,0,0,0];

%{
  【说明】
   1.下面三个变量可以设置多组,以,分隔
   2.若没有选择相应的性能指标，则算法默认参数为数组的第一个参数
%}
Config.OverlapFoV = [1.5, 1.5, 2, 2.5, 3, 3.5]; % 视域重叠度
Config.Num_communicate = [5,2,3,4,5,6];      % 分散式一个融合周期通信次数
Config.Rank_TopoConnect= [0];    % 拓扑连接稀疏度 -> 这个数值代表节点有几个连接的邻居节点 -- 已废弃
Config.PD= [ 0.95, 0.6, 0.7,0.8,0.9, 1];     % 检测概率 
Config.R = [1,3,5,7,9,11];%观测误差，1-6表示此观测误差与初始观测误差的倍数
Config.ZR = [10,20,30,40,50,60]; %传感器杂波数目
Config.ComWD = [10000,50,90,130,170]*3; % 通信带宽

% 若配置选项 Config.AlgPerformance 中涉及到了4，5，6 ,7、8 、9的评估指标，那么需要进行多组蒙特卡洛过程
% 根据选择，计算出需要进行的蒙特卡洛组的次数
% 此处若4，5，6, 7、8、9都选，那么只会考虑4
% 提前赋值
Num_communicate_decen = Config.Num_communicate(1); 
R_DETECT  = Config.OverlapFoV(1) * R_INTERVAL;  % 检测半径 = 视域重叠度 * 传感器与邻居节点的距离
PD = Config.PD(1);
R = Config.R(1) * R_init;
ZR = Config.ZR(1);
ComWD = 10000;


%系列蒙特卡洛次数，也就是"大循环"，根据不同的性能指标要求设置
if Config.AlgPerformance(4) == 1
    Num_monte = size( Config.OverlapFoV,2 );
elseif Config.AlgPerformance(5) == 1
    Num_monte = size( Config.Num_communicate,2 );
elseif Config.AlgPerformance(6) == 1
    Num_monte = size( Config.Num_communicate,2 ) * size( Config.Rank_TopoConnect,2 );
elseif Config.AlgPerformance(7) == 1
    Num_monte = size( Config.PD,2 );
elseif Config.AlgPerformance(8) == 1
    Num_monte = size(Config.R,2);
elseif Config.AlgPerformance(9) == 1
    Num_monte = size(Config.ZR,2);
elseif Config.AlgPerformance(10) == 1
    Num_monte = size(Config.ComWD,2);
else
    Num_monte = 1;
end

