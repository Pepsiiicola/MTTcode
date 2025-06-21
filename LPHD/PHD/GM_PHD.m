%% SFMGM_PHD仿真实验
close all;%关闭图片窗口
clear;%清除变量
clc;%清屏
Mnte=1;%蒙特卡洛次数
Target_Movement;%目标真实运动轨迹
s1_ospa_err=zeros(1,numT);
Label_mapping = @(x)(x(1,:) * 10 + x(2,:) + x(3,:) * 2000);
%% SFMGM_PHD滤波程序
for mnte=1:Mnte
    GM_PHD_Initialise;%参数初始化
    mnte
for k=1:numT
      %% Sensor1 GM_PHD
    Measurement;%传感器1测量
        [s1_x_k_history,s1_L_k_history,s1_w_birth,s1_m_birth,s1_P_birth,s1_L_birth,s1_numTargetbirth,s1_w_bar_k,s1_m_bar_k,s1_P_bar_k,s1_L_bar_k,s1_x_k,s1_x_k_w,s1_x_k_P] = GM_PHD_Filter(s1_numTargetbirth,s1_m_birth,s1_P_birth,s1_w_birth,s1_L_birth,F,Q,H,R,...
        s1_w_bar_k,s1_m_bar_k,s1_P_bar_k,s1_L_bar_k,s1_Z,s1_Z_clutter,s1_nClutter,w_k,s1_detect_prob,s1_x_k_history,s1_L_k_history,k);%传感器1PHD滤波
    [s1_metric_history] = ospa_metric(s1_x_k,k,Target1,Target1_birth_time,Target1_end_time,Target2,Target3,cutoff_c,order_p,s1_metric_history);%传感器1ospa距离测量
    s1_numT(mnte,k)=size(s1_x_k,2);%目标估计数目
end
%蒙特卡洛次数下的ospa指标
    s1_ospa_err=s1_ospa_err+s1_metric_history;%ospa指标
end
%蒙特卡洛次数下的目标数估计指标
for k=1:numT
   s1_Target_estimate(k)=sum(s1_numT(:,k))/Mnte;
end
%% 画图
GM_PHD_Plot;
save test_2D_Liner T numT R Q F H xrange yrange s1_nClutter  s1_detect_prob s1_Z_clutter;