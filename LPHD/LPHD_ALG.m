function [a,b] = LPHD_ALG(Xreal_target_time,Xreal_time_target,Sensor,N)
    ALG1_SensorData;
    for k = 1:N
        for j = 1:sensor_Num
          [Input(j).x_k_history,Input(j).L_k_history,Input(j).w_birth,Input(j).m_birth,Input(j).P_birth,Input(j).L_birth,Input(j).numTargetbirth,Input(j).w_bar_k,Input(j).m_bar_k,Input(j).P_bar_k,Input(j).L_bar_k,Output(j).x_k,Output(j).x_k_w,Output(j).x_k_P] = GM_PHD_Filter(Input(j).numTargetbirth,Input(j).m_birth,Input(j).P_birth,Input(j).w_birth,Input(j).L_birth,F,Q,H,R,...
    Input(j).w_bar_k,Input(j).m_bar_k,Input(j).P_bar_k,Input(j).L_bar_k,Input(j).Z{k,1},Input(j).Z_clutter,Input(j).nClutter,Input(j).detect_prob,Input(j).x_k_history,Input(j).L_k_history,k,j);%´«¸ÐÆ÷1PHDÂË²¨
        end
        ALG4_Fusion;
    end     
    test_plot;
    a = 0;
    b = 0;
end

