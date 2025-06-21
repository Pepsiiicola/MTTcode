%{
                                算法1子函数
           输入: 1.真实数据
                 2.观测数据
                 3.传感器属性
                 4.总跟踪时长

           输出: 1.跟踪结果的OSPA (包含每个时刻的OSPA数值)
                 2.跟踪结果的数量 (包含每个时刻的数量)
                 3.算法跟踪总耗时 

           注： 以1号传感器的结果作为结果输出
%}
function [OSPA,Num_estimate,Time] = PROCESS_OF_ALG1(Xreal_target_time,Xreal_time_target,Sensor,N)
    ALG1_SensorData;
    Time = 0;
    tic;
    for k = 1:N
        X = sprintf('第%d个算法运行中',k);
        fprintf(X);
        for j = 1:sensor_Num
            %出传感器滤波
%             [Input(j).x_k_history,Input(j).w_birth,Input(j).m_birth,Input(j).numTargetbirth,Input(j).w_bar_k,Input(j).m_bar_k,Output(j).x_k,Output(j).x_k_GM,Output(j).w_k_GM,Output(j).P_k_GM] = ALG1_SMC_PHD_Filter(Input(j).numTargetbirth,Input(j).m_birth,Input(j).w_birth,F,H,R,...
%             Input(j).w_bar_k,Input(j).m_bar_k,Input(j).Z{k,1},Input(j).Z_clutter,Input(j).nClutter,Input(j).detect_prob,Input(j).x_k_history,k,Input(j).location,Input(j).R_detect);
            [Input(j).x_k_history,Input(j).w_birth,Input(j).m_birth,Input(j).P_birth,Input(j).numTargetbirth,Input(j).w_bar_k, Input(j).m_bar_k,Input(j).P_bar_k,Output(j).x_k,Output(j).x_k_w,Output(j).x_k_P] = GM_PHD_Filter(Input(j).numTargetbirth,Input(j).m_birth,Input(j).P_birth,Input(j).w_birth,F,Q,R,...
            Input(j).w_bar_k,Input(j).m_bar_k,Input(j).P_bar_k,Input(j).Z{k,1},Input(j).Z_clutter,Input(j).nClutter,Input(j).detect_prob,Input(j).x_k_history,k,Input(j).location,Input(j).R_detect);
        end
        ALG1_FUSION;
    end     
    Time = toc;
    Time = Time / (sensor_Num * N);
%     ALG1_PLOT;

    % 额外处理
    OSPA(1,1:2)=0;
end

