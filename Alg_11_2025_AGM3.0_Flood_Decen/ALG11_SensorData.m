%================传感器数据集合===============%
%         使用结构体存储所有传感器数据
%         数据初始化
%============================================%
sensor_Num = size(Sensor,2);%传感器个数
for j = 1:sensor_Num
   Input(j).numTargetbirth = [];
   Input(j).m_birth = [];
   Input(j).P_birth = [];
   Input(j).w_birth = [];
   
   Input(j).w_bar_k = [];
   Input(j).m_bar_k = [];
   Input(j).P_bar_k = [];
   
   Input(j).Z = Sensor(j).Z_polar_part;
   Input(j).Z_clutter = Sensor(j).Z_dicaer_global;
   Input(j).nClutter = Sensor(j).Zr;
   Input(j).detect_prob = Sensor(j).Pd;
   Input(j).x_k_history = [];
   Input(j).location = Sensor(j).location;
   Input(j).R_detect = Sensor(j).R_detect;
   
   Output(j).x_k = [];
   Output(j).x_k_w = [];
   Output(j).x_k_P = [];

end

%========对传感器观测数据进行处理=======%
%       只取二维数据：距离+方位角       %
%======================================%
for k = 1:N
    for j = 1:sensor_Num
        Input(j).Z_clutter{k,1} = Sensor(j).Z_dicaer_global{k,1}([1,2],:);  
        Input(j).Z{k,1} = Sensor(j).Z_polar_part{k,1}([1,2],:);
    end
end
%ospa参数c与p
cutoff_c=120;
order_p=2;
metric_history=[];%用于保存ospa指标
%运动模型
F=[1 1 0 0;
   0 1 0 0;
   0 0 1 1;
   0 0 0 1;];
H=[1 0 0 0;
    0 0 1 0;];
R = Sensor(1).R(1:2,1:2);
Q = diag([1,0.01,1,0.01]);
 history = [];
 metric_history = [];
 communicate_Num = Sensor(1).Num_communicate;%一个融合周期内通信次数
 numTarget = zeros(1,100);
 match_threshold = 200;
