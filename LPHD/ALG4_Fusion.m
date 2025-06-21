%=================�������ںϳ���==============%
%����������������������˹������Output 
%���������һ��������ͨ�Ŵ���:communicate_Num
%�����������ɢʽ�������˾���:mat_topo
%����������ںϽ��fusion
%=============================================%
mat_topo = Sensor(1).mat_topo;%��ɢʽ�������˾���
%�����ں�ѭ������
for j = 1:sensor_Num
    Fusion(j).X =  Input(j).m_bar_k;
    Fusion(j).W =  Input(j).w_bar_k;
    Fusion(j).P =  Input(j).P_bar_k;  
    Fusion(j).L  = Input(j).L_bar_k;
    
    Temp(j).X =  Input(j).m_bar_k;
    Temp(j).W =  Input(j).w_bar_k;
    Temp(j).P =  Input(j).P_bar_k;  
    Temp(j).L =  Input(j).L_bar_k;  
end
%=================һ���ں������ڴ���������ͨ��ͨ��==============%
for coun = 1:communicate_Num
   for j = 1:sensor_Num
    index = find(mat_topo(j,:)>0);
    delet_index = find(index == j);
    index(delet_index) = [];
    %=============״̬�ں�===========%
     fusion_Times = 1;
        for ell = 1:length(index)
            fusion_Times = fusion_Times + 1;
            [Fusion(j).X,Fusion(j).W,Fusion(j).P,Fusion(j).L] = ALG4_Matching(Fusion(j).W,Fusion(j).X,Fusion(j).P,Fusion(j).L,Temp(index(ell)).W,Temp(index(ell)).X,Temp(index(ell)).P,Temp(index(ell)).L,fusion_Times);
        end
   
   end 
        for j = 1:sensor_Num
            Temp(j).X =  Fusion(j).X;
            Temp(j).W =  Fusion(j).W;
            Temp(j).P =  Fusion(j).P;  
            Temp(j).L =  Fusion(j).L;
        end
end
 %===========Sensor1-״̬���ռ���ȡ=============% 

x_hat = Fusion(1).X(:,find(Fusion(1).W > 0.5));
L_hat = Fusion(1).L(:,find(Fusion(1).W > 0.5));
if ~isempty(L_hat) && ~isempty(L_hat_history)
    [L_hat,Fusion] = track_processing_1(L_hat,L_hat_history,Fusion,x_hat,x_hat_history,x_hat_time,k);
end
x_hat_history = [x_hat_history,x_hat];
L_hat_history = [L_hat_history,L_hat];
x_hat_time = [x_hat_time,ones(1,size(L_hat,2)) * k];

% Target_Num(k) = N_k; 
% Num_estimate(k) = N_k;
 %================OSPA����================%
    %=========����Xreal_time_target����=======%
    %               ȥ��NaN����               %
    %=========================================%
%   nan_index = find(all(isnan(Xreal_time_target{k,1}),1) == 1);
%   Xreal_time_target{k,1}(:,nan_index) = [];
%   Y = Xreal_time_target{k,1}(1:4,:);
% metric = ALG4_ospa_dist(x_k, Y , cutoff_c, order_p);
% metric_history = [metric_history, metric];
% OSPA(k) = metric;

% ===========Sensor-GM2P=============% 
for j = 1:sensor_Num
    [Input(j).w_bar_k,Input(j).m_bar_k,Input(j).P_bar_k,Input(j).L_bar_k] = ALG4_GM2P(Fusion(1).W,Fusion(1).X,Fusion(1).P,Fusion(1).L,Input(j).location,Input(j).R_detect);
end

 

 


