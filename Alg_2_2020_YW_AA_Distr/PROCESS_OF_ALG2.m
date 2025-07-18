%{
                                算法2子函数
           输入: 1.真实数据
                 2.观测数据
                 3.传感器属性
                 4.总跟踪时长

           输出: 1.跟踪结果的OSPA (包含每个时刻的OSPA数值)
                 2.跟踪结果的数量 (包含每个时刻的数量)
                 3.算法跟踪总耗时 

          
%}
function [OSPA,Num_estimate,Time] = PROCESS_OF_ALG2(~,Xreal_time_target,Sensor,N)

%===一些默认的参数===
Ps = 1; % 存活概率
Vx_thre = 200;
Vy_thre = 200;
Vz_thre = 200;
merge_threshold = 200;
N_sensor = size(Sensor,2);

%===预处理===
% 如果检测概率很高，内部当成1来进行滤波
for i = 1:N_sensor
    if Sensor(i).Pd >= 0.99
        Sensor(i).Pd = 1;
    end
end

%======PHD最初估计值初始化======
ALG2_PHD_initial;

% 时间消耗
Time=0;
for t = 3:N
    
    timing = tic;
    %==================
    % 单传感器滤波过程
    %==================
    for i=1:N_sensor 
        [Sensor(i).state]=ALG2_PHD1time_3d_ukf_distr(Sensor(i).Z_dicaer_global{t-2,1},...
            Sensor(i).Z_dicaer_global{t-1,1},Sensor(i).Z_polar_part{t,1},...
            Sensor(i).state,Sensor(i).Zr,Sensor(i).R,Ps,Sensor(i).Pd,...
            Vx_thre,Vy_thre,Vz_thre,...
            Sensor(i).location(1,1),Sensor(i).location(2,1),Sensor(i).location(3,1));    
    end
    t_sus = toc(timing);
    Time = Time + t_sus/N_sensor;
    timing = tic;
    
    %===融合中心接收信息===
    for i=1:N_sensor 
        Fusion_center.sensor_inf(i).gm_particles = Sensor(i).state; % 传感器估计的状态信息
        Fusion_center.sensor_inf(i).location = Sensor(i).location;  % 传感器的位置信息
        Fusion_center.sensor_inf(i).R_detect = Sensor(i).R_detect;  % 传感器的观测半径
        Fusion_center.sensor_inf(i).serial = Sensor(i).serial;      % 传感器的编号
    end
    
    %===AA融合方法===
    [Fusion_center.results] = ALG2_fusion_AA_distr(Fusion_center.sensor_inf,merge_threshold);
    
    %===状态提取===
    for i=1:N_sensor  
        [Sensor(i).X_est{t,1},~] = statedraw_3d( Fusion_center.results );       
    end
    
    %=== 结果反馈 ===
    %=== 剔除观测范围之外的状态分量，防止漏检分量对后续跟踪的影响 ===
    for i=1:N_sensor
        [Sensor(i).state,~]=FoV_divide( Fusion_center.results,Sensor(i).location,Sensor(i).R_detect);
    end
    
    t_sus = toc(timing);
    Time = Time + t_sus;
  
end
Time = Time / ( N - 2 ); % 单个融合周期时间计算

%===分布式 OSPA 计算===
OSPA = zeros(1,N);
OSPA(1:2) = 0;

for t=1:N
    % 要对 Xreal_time_target 进行一个数据处理，将内部的nan值删除
    Xreal_time_target{t,1}( :,isnan(Xreal_time_target{t,1}(1,:)) ) = [];
end

for t=3:N
    OSPA(t) = ospa_dist(Xreal_time_target{t,1},Sensor(2).X_est{t,1},120,2);
end

%===分布式数量计算===
Num_estimate = zeros(1,N);
Num_estimate(1:2) = 0;
for t=3:N
    Num_estimate(t) = size(Sensor(6).X_est{t,1},2);
end

%{
% =======计算每个时刻真实目标数目=======
num_real = zeros(1,N); % 全局真实目标数目
for t=1:N
    num_real(1,t) = size(Xreal_time_target{t,1},2);
end

figure
hold on;
plot(OSPA,'-ko','Markerface','b');
legend('分布式AA','FontSize',14);
t=title('OSPA');
t.FontSize = 14;
xlabel('时刻 t/s','FontSize',14)
ylabel('OSPA距离','FontSize',14)
disp(num2str(sum(OSPA(3:end))/98));

figure
hold on;
plot(num_real,'-k');
plot(Num_estimate,'-ko','Markerface','b');
legend('真实值','分布式AA','FontSize',14);
t=title('数量跟踪对比');
t.FontSize = 14;
xlabel('时刻 t/s','FontSize',14)
ylabel('估计数量','FontSize',14)
%}

end
