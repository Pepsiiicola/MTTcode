%=================�������ںϳ���==============%
%����������������������˹������Output 
%���������һ��������ͨ�Ŵ���:communicate_Num
%�����������ɢʽ�������˾���:mat_topo
%����������ںϽ��fusion
%=============================================%
mat_topo = Sensor(1).mat_topo;%��ɢʽ�������˾���
%�����ں�ѭ������
for j = 1:sensor_Num
    Fusion(j).X =  Output(j).x_k;
    Fusion(j).W =  Output(j).x_k_w;
    Fusion(j).P =  Output(j).x_k_P;  
    Temp(j).X =  Output(j).x_k;
    Temp(j).W =  Output(j).x_k_w;
    Temp(j).P =  Output(j).x_k_P;  
end
%=================һ���ں������ڴ���������ͨ��==============%
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
 %===========Sensor1-״̬��ȡ=============% 
 state_Index = find(Fusion(6).W > 0.5);
 history = [history,Fusion(6).X(:,state_Index)];
 numTarget(k) = size(state_Index,2);
 Num_estimate(k) = size(state_Index,2); 
 %================OSPA����================%
    %=========����Xreal_time_target����=======%
    %               ȥ��NaN����               %
    %=========================================%
  nan_index = find(all(isnan(Xreal_time_target{k,1}),1) == 1);
  Xreal_time_target{k,1}(:,nan_index) = [];
  Y = Xreal_time_target{k,1}(1:4,:);
  metric = ALG1_ospa_dist(Fusion(6).X(:,state_Index), Y , cutoff_c, order_p);
  metric_history = [metric_history, metric];
  OSPA(k) = metric;
%===========Sensor-GM2P=============% 
for j = 1:sensor_Num
    [Input(j).w_bar_k,Input(j).m_bar_k,Input(j).P_bar_k] = ALG1_GM2P(Fusion(j).W,Fusion(j).X,Fusion(j).P,Input(j).location,Input(j).R_detect);
end

 


