%{
                        *****************************************
                        ***    ��ͬ��Ϣ����ṹ�µ��㷨����   ***
                        *****************************************
���ܣ�
     ������㷨���жԱ�

�������ü�飺


%}
% function main

clear;close all;
% �����·����
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

% ϵͳģ������
model;

% �����������
Configuration;


% **********************************
%          Ŀ���˶�����
% **********************************
% �������ָ�ʽ����ʵֵ��һ��ΪĿ����*ʱ������һ��Ϊʱ����*Ŀ����
[Xreal_target_time,Xreal_time_target] = targetset(N,Set_TargetState);
Xreal_time_target_copy = Xreal_time_target;
% ɾ��ÿ��ʱ����ʵĿ���е�nan����
for t=1:N
    Xreal_time_target_copy{t,1}(:,isnan(Xreal_time_target_copy{t,1}(1,:))) = [];
end
% =======����ÿ��ʱ����ʵĿ����Ŀ=======
num_real = zeros(1,N); % ȫ����ʵĿ����Ŀ
for t=1:N
    num_real(1,t) = size(Xreal_time_target_copy{t,1},2);
end

% ###����һ���۲�ű�����������ʵĿ��Ĺ켣�ʹ������Ĺ۲ⷶΧ###
test_script;

% ===�ɼ����������ʼ��===
% ��Ҫ�ɼ������ݱ��� 1.OSPA��ֵ(�����㷨) 2.�����ص��� 3.��ɢʽͨ�Ŵ��� 4.����ϡ���
DataSave = struct;
DataSave.ALG = struct;
for Serial_Monte = 1 : Num_monte  %Num_monte��<Configuration>������
    % =====������������Ը���ģ�ͽ��е���=====
    % 4.�����ص��̶Ⱥ�OSPA��ֵ�Ķ�άͼ  -> a.���������ص��̶� Config.OverlapFoV �������� R_DETECT
    % 5.ͨ�Ŵ�����OSPA�����Ķ�άͼ  -> b.���ݷ�ɢʽһ���ں�����ͨ�Ŵ��� Config.Num_communicate �������� Num_communicate_decen
    % 6.��������ϡ��ȣ�ͨ�Ŵ�����OSPA�����Ķ�άͼ(�ֱ��Ӧx,y,z��) -> c.����b������������ϡ��� Config.Rank_TopoConnect ������ɢʽ�����˾������ mat_topo_decen
    % 7.�����ʺ�OSPA�����Ķ�άͼ
    if Config.AlgPerformance(4) == 1
        R_DETECT = ModelAdjust_FoV( Config.OverlapFoV( Serial_Monte ) , R_INTERVAL);
        DataSave(Serial_Monte).OverlapFoV = Config.OverlapFoV( Serial_Monte );
        
    elseif Config.AlgPerformance(5) == 1
        Num_communicate_decen = Config.Num_communicate( Serial_Monte );
        DataSave(Serial_Monte).Num_communicate = Num_communicate_decen;
        
    elseif Config.AlgPerformance(6) == 1
        % �˴��ǽ��������ӳ̶Ⱥ�ͨ�Ŵ������б���������γɵ㼯����3ά����
        % 10���������ӳ̶Ⱥ�10��ͨ�Ŵ��� ����Ͼ���100��
        % ע�ͣ�˳�����ȹ̶��������ӳ̶ȣ���ͨ�Ŵ���
        % # �������ӳ̶�
        mat_topo_decen = ModelAdjust_topo( mat_topo_decen , ...
            Config.Rank_TopoConnect( 1 + fix( Serial_Monte / size(Config.Num_communicate,2) - 0.01)) );
        % ����Ȩ�ط���
        [mat_weight_decen] = Metropolis_Weights(mat_topo_decen);
        
        % # ͨ�Ŵ���
        if mod( Serial_Monte , size(Config.Num_communicate,2) ) ~= 0
            Num_communicate_decen = Config.Num_communicate( ...
                mod( Serial_Monte , size(Config.Num_communicate,2) ) );
        else
            Num_communicate_decen = Config.Num_communicate( size(Config.Num_communicate,2) );
        end
        
        % # ���ݼ�¼
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
    %  ���ؿ������
    %================
    MonteCarlo_Process; 
        
    % === �ɼ����ؿ�������� ===
    % �㷨��ƽ��ospa��ƽ������ʱ��
    for i=1:size(Config.AlgCompare,2)
        DataSave( Serial_Monte ).ALG(i).OSPA = sum(MM_ALG(i).OSPA,2) / size(MM_ALG(i).OSPA,2);
        DataSave( Serial_Monte ).ALG(i).Time = MM_ALG(i).TIME_TOTAL;
        DataSave( Serial_Monte ).ALG(i).Err_num = sum(abs(MM_ALG(i).Num_estimate - num_real),2) / size(MM_ALG(i).OSPA,2);
    end
    
    % === �������ؿ�����ֵ�������� -- �������ָ�� 1��2��3 ===
    if Serial_Monte == 1
        Numerical_analysis_compare123;
    end
  
end

% ������ؿ�����ֵ�������� -- �������ָ��4��5��6,7,8
if sum( Config.AlgPerformance(4:10),2 ) >= 1 
    Numerical_analysis_compare_ospa_EX;
%     Numerical_analysis_compare_num_EX;
%     Numerical_analysis_compare_time_EX;
end

disp('******************** done ***********************')


% end