%{
                                �㷨4�Ӻ���
           ����: 1.��ʵ����
                 2.�۲�����
                 3.����������
                 4.�ܸ���ʱ��

           ���: 1.���ٽ����OSPA (����ÿ��ʱ�̵�OSPA��ֵ)
                 2.���ٽ�������� (����ÿ��ʱ�̵�����)
                 3.�㷨�����ܺ�ʱ 

           ע�� ��1�Ŵ������Ľ����Ϊ������
%}
function [OSPA,Num_estimate,Time] = PROCESS_OF_ALG4(Xreal_target_time,Xreal_time_target,Sensor,N)
    
    ALG4_SensorData;
    tic;
    for k = 1:N
        for j = 1:sensor_Num
            [Input(j).x_k_history,Birth(j),Input(j).w_bar_k,Input(j).m_bar_k, Input(j).P_bar_k,Output(j),Input(j).cdn_update] = ALG4_GM_CPHD_Filter(Birth(j),F,Q,R,...
            Input(j).w_bar_k,Input(j).m_bar_k,Input(j).P_bar_k,Input(j).Z{k,1},Input(j).Z_clutter,Input(j).nClutter,Input(j).detect_prob,Input(j).x_k_history,Input(j).cdn_update,k,Input(j).location);          
        end
        ALG4_Fusion;
    end
    Time = toc;
    Time = Time / (sensor_Num * N);
%     ALG4_PLOT;
        % ���⴦��
    OSPA(1,1:2)=0;
end

