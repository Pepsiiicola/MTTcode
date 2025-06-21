%=================传感器融合程序==============%
%输入参数：各传感器后验高斯分量：Output 
%输入参数：一个周期内通信次数:communicate_Num
%输入参数：分散式网络拓扑矩阵:mat_topo
%输出参数：融合结果fusion
%=============================================%
mat_topo = Sensor(1).mat_topo;%分散式网络拓扑矩阵
%用于融合循环迭代
for j = 1:sensor_Num
    Fusion(j).X =  Output(j).x_k_GM;
    Fusion(j).W =  Output(j).w_k_GM;
    Fusion(j).P =  Output(j).P_k_GM;  
    Temp(j).X =  Output(j).x_k_GM;
    Temp(j).W =  Output(j).w_k_GM;
    Temp(j).P =  Output(j).P_k_GM;  
end
%=================一个融合周期内传感器进行通信通信==============%
for coun = 1:communicate_Num
   for j = 1:sensor_Num
    index = find(mat_topo(j,:)>0);
    delet_index = find(index == j);
    index(delet_index) = [];
        for ell = 1:length(index)
            [Fusion(j).X,Fusion(j).W,Fusion(j).P] = ALG1_Matching(Fusion(j).W,Fusion(j).X,Fusion(j).P,Temp(index(ell)).W,Temp(index(ell)).X,Temp(index(ell)).P);
        end
   end 
   
   for j = 1:sensor_Num
        Temp(j).X =  Fusion(j).X;
        Temp(j).W =  Fusion(j).W;
        Temp(j).P =  Fusion(j).P;  
   end
end
 %===========Sensor1-状态提取=============% 
 state_Index = find(Fusion(1).W > 0.5);
 history = [history,Fusion(1).X(:,state_Index)];
 numTarget(k) = size(state_Index,2);
 Num_estimate(k) = size(state_Index,2); 
 %================OSPA计算================%
    %=========处理Xreal_time_target数据=======%
    %               去掉NaN数据               %
    %=========================================%
  nan_index = find(all(isnan(Xreal_time_target{k,1}),1) == 1);
  Xreal_time_target{k,1}(:,nan_index) = [];
  Y = Xreal_time_target{k,1}(1:4,:);
metric = ALG1_ospa_dist(Fusion(1).X(:,state_Index), Y , cutoff_c, order_p);
metric_history = [metric_history, metric];
OSPA(k) = metric;
%===========Sensor-GM2P=============% 
for j = 1:sensor_Num
    [Input(j).w_bar_k,Input(j).m_bar_k] = ALG1_GM2P(Fusion(j).W,Fusion(j).X,Input(j).location,Input(j).R_detect);
end

 


