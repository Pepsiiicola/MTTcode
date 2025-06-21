%% SFMGM_PHD����ʵ��
close all;%�ر�ͼƬ����
clear;%�������
clc;%����
Mnte=1;%���ؿ������
Target_Movement;%Ŀ����ʵ�˶��켣
s1_ospa_err=zeros(1,numT);
Label_mapping = @(x)(x(1,:) * 10 + x(2,:) + x(3,:) * 2000);
%% SFMGM_PHD�˲�����
for mnte=1:Mnte
    GM_PHD_Initialise;%������ʼ��
    mnte
for k=1:numT
      %% Sensor1 GM_PHD
    Measurement;%������1����
        [s1_x_k_history,s1_L_k_history,s1_w_birth,s1_m_birth,s1_P_birth,s1_L_birth,s1_numTargetbirth,s1_w_bar_k,s1_m_bar_k,s1_P_bar_k,s1_L_bar_k,s1_x_k,s1_x_k_w,s1_x_k_P] = GM_PHD_Filter(s1_numTargetbirth,s1_m_birth,s1_P_birth,s1_w_birth,s1_L_birth,F,Q,H,R,...
        s1_w_bar_k,s1_m_bar_k,s1_P_bar_k,s1_L_bar_k,s1_Z,s1_Z_clutter,s1_nClutter,w_k,s1_detect_prob,s1_x_k_history,s1_L_k_history,k);%������1PHD�˲�
    [s1_metric_history] = ospa_metric(s1_x_k,k,Target1,Target1_birth_time,Target1_end_time,Target2,Target3,cutoff_c,order_p,s1_metric_history);%������1ospa�������
    s1_numT(mnte,k)=size(s1_x_k,2);%Ŀ�������Ŀ
end
%���ؿ�������µ�ospaָ��
    s1_ospa_err=s1_ospa_err+s1_metric_history;%ospaָ��
end
%���ؿ�������µ�Ŀ��������ָ��
for k=1:numT
   s1_Target_estimate(k)=sum(s1_numT(:,k))/Mnte;
end
%% ��ͼ
GM_PHD_Plot;
save test_2D_Liner T numT R Q F H xrange yrange s1_nClutter  s1_detect_prob s1_Z_clutter;