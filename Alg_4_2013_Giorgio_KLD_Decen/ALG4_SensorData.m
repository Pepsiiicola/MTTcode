%================传感器数据集合===============%
%         使用结构体存储所有传感器数据
%         数据初始化
%============================================%
sensor_Num = size(Sensor,2);%传感器个数
for j = 1:sensor_Num
    Input(j).Birth.w_birth = [];
    Input(j).Birth.m_birth = [];
    Input(j).Birth.P_birth = [];
    Input(j).Birth.numTargetbirth = [];
    Input(j).w_bar_k = [];
    Input(j).m_bar_k = [];
    Input(j).P_bar_k = [];
   Input(j).Z = Sensor(j).Z_polar_part;
   Input(j).Z_clutter = Sensor(j).Z_dicaer_global;
   Input(j).nClutter = Sensor(j).Zr;
   Input(j).detect_prob = Sensor(j).Pd;
   Input(j).x_k_history = [];
   Input(j).cdn_update = [1; zeros(20,1)];
   Input(j).location = Sensor(j).location([1,2],:);
   Input(j).R_detect = Sensor(j).R_detect;
   Birth(j).w_birth = [];
   Birth(j).m_birth = [];;
   Birth(j).P_birth = [] ;
   Birth(j).numTargetbirth = [];
end
%========对传感器观测数据进行处理=======%
%       只取二维数据：距离+方位角       %
%======================================%
for k = 1:100
    for j = 1:sensor_Num
        Input(j).Z_clutter{k,1} = Sensor(j).Z_dicaer_global{k,1}([1,2],:);  
        Input(j).Z{k,1} = Sensor(j).Z_polar_part{k,1}([1,2],:);
    end
end

%ospa参数c与p
cutoff_c=120;
order_p=2;
metric_history=[];%用于保存ospa指标
n_Max=20;
Q=diag([1,0.1,1,0.1]);%过程噪声协方差矩阵
R=Sensor(1).R(1:2,1:2);%观测噪声协方差矩阵
T = 1;
F=[1 T 0 0;
   0 1 0 0;
   0 0 1 T;
   0 0 0 1;];
communicate_Num = Sensor(1).Num_communicate;
history = [];
Target_Num = [];

