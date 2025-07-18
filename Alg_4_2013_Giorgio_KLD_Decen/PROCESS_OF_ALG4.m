%{
                                算法4子函数
           输入: 1.真实数据
                 2.观测数据
                 3.传感器属性
                 4.总跟踪时长

           输出: 1.跟踪结果的OSPA (包含每个时刻的OSPA数值)
                 2.跟踪结果的数量 (包含每个时刻的数量)
                 3.算法跟踪总耗时 

           注： 以1号传感器的结果作为结果输出
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
        % 额外处理
    OSPA(1,1:2)=0;
end

