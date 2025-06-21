%{
                        *****************************************
                        ***    不同信息处理结构下的算法仿真   ***
                        *****************************************
功能：
     将多个算法进行对比

参数设置简介：


%}
% function main

clear;close all;
% 【添加路径】
addpath('Alg_1_2019_LTC_AA_Decen')      % 
addpath('Alg_2_2020_YW_AA_Distr')       % 
addpath('Alg_3_2020_LGC_GA_Distr')      % 
addpath('Alg_4_2013_Giorgio_KLD_Decen') %
addpath('Alg_5_2022_AA_Decen')          % 
addpath('Alg_6_2022_GA_Decen')          %
addpath('Alg_7_2022_AGM_Decen')         %
addpath('Alg_8_2023_AA_Flood_Decen')       %
addpath('Alg_9_2023_AGM_Flood_Decen')      %
addpath('Alg_10_2022_BIRD_Decen')          %
addpath('Alg_11_2025_AGM3.0_Flood_Decen')  %
addpath('Alg_12_2017_DSIF_Flood_Decen')    %
addpath('Tool')

% 系统模型设置
model;

% 整体参数配置
Configuration;


% **********************************
%          目标运动仿真
% **********************************
% 生成两种格式的真实值，一种为目标数*时间数，一种为时间数*目标数
[Xreal_target_time,Xreal_time_target] = targetset(N,Set_TargetState);
Xreal_time_target_copy = Xreal_time_target;
% 删除每个时刻真实目标中的nan数据
for t=1:N
    Xreal_time_target_copy{t,1}(:,isnan(Xreal_time_target_copy{t,1}(1,:))) = [];
end
% =======计算每个时刻真实目标数目=======
num_real = zeros(1,N); % 全局真实目标数目
for t=1:N
    num_real(1,t) = size(Xreal_time_target_copy{t,1},2);
end

% ###这是一个观测脚本，用来看真实目标的轨迹和传感器的观测范围###
test_script;

% ===采集结果变量初始化===
% 需要采集的内容变量 1.OSPA均值(所有算法) 2.视域重叠度 3.分散式通信次数 4.拓扑稀疏度
DataSave = struct;
DataSave.ALG = struct;
for Serial_Monte = 1 : Num_monte  %Num_monte在<Configuration>中设置
    % =====根据配置情况对跟踪模型进行调整=====
    % 4.视域重叠程度和OSPA均值的二维图  -> a.根据视域重叠程度 Config.OverlapFoV 调整变量 R_DETECT
    % 5.通信次数和OSPA收敛的二维图  -> b.根据分散式一个融合周期通信次数 Config.Num_communicate 调整变量 Num_communicate_decen
    % 6.拓扑连接稀疏度，通信次数和OSPA收敛的二维图(分别对应x,y,z轴) -> c.基于b根据拓扑连接稀疏度 Config.Rank_TopoConnect 调整分散式的拓扑矩阵变量 mat_topo_decen
    % 7.检测概率和OSPA收敛的二维图
    if Config.AlgPerformance(4) == 1
        R_DETECT = ModelAdjust_FoV( Config.OverlapFoV( Serial_Monte ) , R_INTERVAL);
        DataSave(Serial_Monte).OverlapFoV = Config.OverlapFoV( Serial_Monte );
        
    elseif Config.AlgPerformance(5) == 1
        Num_communicate_decen = Config.Num_communicate( Serial_Monte );
        DataSave(Serial_Monte).Num_communicate = Num_communicate_decen;
        
    elseif Config.AlgPerformance(6) == 1
        % 此处是将拓扑连接程度和通信次数进行遍历的组合形成点集来画3维曲面
        % 10个拓扑连接程度和10个通信次数 的组合就是100种
        % 注释：顺序是先固定拓扑连接程度，变通信次数
        % # 拓扑连接程度
        mat_topo_decen = ModelAdjust_topo( mat_topo_decen , ...
            Config.Rank_TopoConnect( 1 + fix( Serial_Monte / size(Config.Num_communicate,2) - 0.01)) );
        % 大都市权重分配
        [mat_weight_decen] = Metropolis_Weights(mat_topo_decen);
        
        % # 通信次数
        if mod( Serial_Monte , size(Config.Num_communicate,2) ) ~= 0
            Num_communicate_decen = Config.Num_communicate( ...
                mod( Serial_Monte , size(Config.Num_communicate,2) ) );
        else
            Num_communicate_decen = Config.Num_communicate( size(Config.Num_communicate,2) );
        end
        
        % # 数据记录
        DataSave(Serial_Monte).Rank_TopoConnect = ...
            Config.Rank_TopoConnect( 1 + fix( Serial_Monte / size(Config.Num_communicate,2) - 0.01 ));
        DataSave(Serial_Monte).Num_communicate = Num_communicate_decen;
        
    elseif Config.AlgPerformance(7) == 1
        PD = Config.PD( Serial_Monte );
        DataSave(Serial_Monte).PD = PD;
    elseif Config.AlgPerformance(8) == 1
        R = Config.R( Serial_Monte ) * R_init;
        DataSave(Serial_Monte).R = Config.R(Serial_Monte);
    elseif Config.AlgPerformance(9) == 1
        ZR = Config.ZR( Serial_Monte );
        DataSave(Serial_Monte).ZR = ZR;
    elseif Config.AlgPerformance(10) == 1
        ComWD = Config.ComWD( Serial_Monte );
        DataSave(Serial_Monte).ComWD = ComWD;
    end
    
    %================
    %  蒙特卡洛过程
    %================
    MonteCarlo_Process; 
        
    % === 采集蒙特卡洛仿真结果 ===
    % 算法的平均ospa和平均运行时间
    for i=1:size(Config.AlgCompare,2)
        DataSave( Serial_Monte ).ALG(i).OSPA = sum(MM_ALG(i).OSPA,2) / size(MM_ALG(i).OSPA,2);
        DataSave( Serial_Monte ).ALG(i).Time = MM_ALG(i).TIME_TOTAL;
        DataSave( Serial_Monte ).ALG(i).Err_num = sum(abs(MM_ALG(i).Num_estimate - num_real),2) / size(MM_ALG(i).OSPA,2);
    end
    
    % === 单次蒙特卡洛数值分析评估 -- 针对评价指标 1，2，3 ===
    if Serial_Monte == 1
        Numerical_analysis_compare123;
    end
  
end

% 多次蒙特卡洛数值分析评估 -- 针对评价指标4，5，6,7,8
if sum( Config.AlgPerformance(4:10),2 ) >= 1 
    Numerical_analysis_compare_ospa_EX;
%     Numerical_analysis_compare_num_EX;
%     Numerical_analysis_compare_time_EX;
end

disp('******************** done ***********************')


% end