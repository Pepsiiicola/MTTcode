%=================传感器融合程序==============%
%输入参数：各传感器后验高斯分量：Output 
%输入参数：一个周期内通信次数:communicate_Num
%输入参数：分散式网络拓扑矩阵:mat_topo
%输出参数：融合结果fusion
%=============================================%
mat_topo = Sensor(1).mat_topo;%分散式网络拓扑矩阵
%用于融合循环迭代
for j = 1:sensor_Num
    Fusion(j).X =  Input(j).m_bar_k;
    Fusion(j).W =  Input(j).w_bar_k;
    Fusion(j).P =  Input(j).P_bar_k;  
    Fusion(j).cdn  = Input(j).cdn_update;
    Temp(j).X =  Input(j).m_bar_k;
    Temp(j).W =  Input(j).w_bar_k;
    Temp(j).P =  Input(j).P_bar_k;  
    Temp(j).cdn =  Input(j).cdn_update;
end
%=================一个融合周期内传感器进行通信通信==============%
for coun = 1:communicate_Num
   for j = 1:sensor_Num
    index = find(mat_topo(j,:)>0);
    delet_index = find(index == j);
    index(delet_index) = [];
    %=============状态融合===========%
     fusion_Times = 1;
        for ell = 1:length(index)
            fusion_Times = fusion_Times + 1;
            [Fusion(j).X,Fusion(j).W,Fusion(j).P] = ALG4_Matching(Fusion(j).W,Fusion(j).X,Fusion(j).P,Temp(index(ell)).W,Temp(index(ell)).X,Temp(index(ell)).P,fusion_Times);
            [Fusion(j).cdn] = ALG4_Cdn_Fusion(Fusion(j).cdn,Temp(index(ell)).cdn);
        end
   
   end 
        for j = 1:sensor_Num
            Temp(j).X =  Fusion(j).X;
            Temp(j).W =  Fusion(j).W;
            Temp(j).P =  Fusion(j).P;  
            Temp(j).cdn = Fusion(j).cdn;
        end
end
   
 %===========Sensor1-状态提取=============% 
x_k=[];
[~,idx_max_cdn] = max(Fusion(1).cdn);
map_cdn = idx_max_cdn-1;
N_k=min(length(Fusion(1).W),map_cdn);%估计目标数
[~,idx_m_srt]= sort(-Fusion(1).W);%返回从大到小的数据的索引
x_k=Fusion(1).X(:,idx_m_srt(1:N_k));
history = [history,x_k];
Target_Num(k) = N_k; 
Num_estimate(k) = N_k;
 %================OSPA计算================%
    %=========处理Xreal_time_target数据=======%
    %               去掉NaN数据               %
    %=========================================%
  nan_index = find(all(isnan(Xreal_time_target{k,1}),1) == 1);
  Xreal_time_target{k,1}(:,nan_index) = [];
  Y = Xreal_time_target{k,1}(1:4,:);
metric = ALG4_ospa_dist(x_k, Y , cutoff_c, order_p);
metric_history = [metric_history, metric];
OSPA(k) = metric;

%===========Sensor-GM2P=============% 
for j = 1:sensor_Num
    [Input(j).w_bar_k,Input(j).m_bar_k,Input(j).P_bar_k] = ALG4_GM2P(Fusion(j).W,Fusion(j).X,Fusion(j).P,Input(j).location,Input(j).R_detect);
end

 


