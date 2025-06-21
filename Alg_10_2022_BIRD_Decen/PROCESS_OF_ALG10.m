%{
                                算法10子函数
           输入: 1.真实数据
                 2.观测数据
                 3.传感器属性
                 4.总跟踪时长
                 5.一致性步骤次数
                 6.融合权重

           输出: 1.跟踪结果的OSPA (包含每个时刻的OSPA数值)
                 2.跟踪结果的数量 (包含每个时刻的数量)
                 3.算法跟踪总耗时 

          
%}
function [OSPA,Num_estimate,Time] = PROCESS_OF_ALG10(~,Xreal_time_target,Sensor,N,L,mat_weight)
    X = sprintf('第10个算法运行中...\n');
    fprintf(X);

%===一些默认的参数===
Ps = 1; % 存活概率
Vx_thre = 200;
Vy_thre = 200;
Vz_thre = 200;
match_threshold = 200;
N_sensor = size(Sensor,2);

%===预处理===
% 如果检测概率很高，内部当成1来进行滤波
for i = 1:N_sensor
    if Sensor(i).Pd >= 0.99
        Sensor(i).Pd = 1;
    end
end

%======PHD最初估计值初始化======
ALG10_PHD_initial;

%=====虚拟存储中心设置(用于通信)=====
com_storage = struct;

% 时间消耗
timing = tic;
for t=3:N

%============拓扑时变专用========= 2025.3.12增加

    if t > 25 && t <= 50
        N_sensor = 14;
    elseif t > 50 && t <= 75
        N_sensor = 12;
    elseif t > 75
        N_sensor = 10;
    end
%================================

    %==================
    % 单传感器滤波过程
    %==================
    for i=1:N_sensor 
        [Sensor(i).state_ex]=ALG10_PHD1time_3d_ukf_decen(Sensor(i).Z_dicaer_global{t-2,1},...
            Sensor(i).Z_dicaer_global{t-1,1},Sensor(i).Z_polar_part{t,1},...
            Sensor(i).state,Sensor(i).Zr,Sensor(i).R,Ps,Sensor(i).Pd,...
            Vx_thre,Vy_thre,Vz_thre,...
            Sensor(i).location(1,1),Sensor(i).location(2,1),Sensor(i).location(3,1),i);    
    end
    
    %*********************
    %     一致性步骤
    %*********************
    for l = 1:L
        
        % 发送
        for i=1:N_sensor
            com_storage(i).gm_particles = Sensor(i).state_ex;
        end
        % 接收 
        % 注：此处的 Fusion_center(i) 代表的是第 i 个传感器
        for i=1:N_sensor
            Fusion_center(i).Inf_recieve = module_com_recieve(com_storage,Sensor(i).mat_topo,i,N_sensor);
        end

        for i=1:N_sensor
            Sensor(i).FoV_range = ALG10_FoV_range(Sensor(i).mat_topo,i,l);
        end
        
        % 融合
        % 分散式GA融合方式
        for i=1:N_sensor
            [Sensor(i).state_ex] = ALG10_fusion_GA_decen(Fusion_center(i),match_threshold,i,Sensor);
        end
        
    end
    
    % 状态格式转化 将Sensor.state_ex 转化为 Sensor.state
    for i=1:N_sensor
        Sensor(i).state = Sensor(i).state_ex;
        Sensor(i).state{2,1}(7,:) = [];
    end
    
    % 状态提取
    for i=1:N_sensor
        [Sensor(i).X_est{t,1},Sensor(i).num_est(t)] = statedraw_3d(Sensor(i).state);
    end
    
    % 划分视域（用于自身反馈）
    for i=1:N_sensor
        [Sensor(i).state,~]=FoV_divide(Sensor(i).state,Sensor(i).location,Sensor(i).R_detect);
    end
    
end
% 时间计算
Time = toc(timing);
Time = Time/(N-2)/N_sensor; % 单个传感器单个周期所消耗的时间

%======================================评估部分=========================================
%=== OSPA 计算 ===
OSPA = zeros(1,N);
OSPA(1:2) = 0;
for t=3:N
    % 要对 Xreal_time_target 进行一个数据处理，将内部的nan值删除
    Xreal_time_target{t,1}( :,isnan(Xreal_time_target{t,1}(1,:)) ) = [];
end
for t=3:N
    OSPA(t) = ospa_dist(Xreal_time_target{t,1},Sensor(8).X_est{t,1},120,2);
end

%=== 数量计算 ===
Num_estimate = zeros(1,N);
for t=1:N
    Num_estimate(t) = size(Sensor(8).X_est{t,1},2);
end

%画图

% 画出平台节点以及其检测范围
% figure;
% hold on;
% for i=1:N_sensor
%     text(Sensor(i).location(1,1),Sensor(i).location(2,1),num2str(i),'Fontsize',20,'Position',...
%         [Sensor(i).location(1,1),Sensor(i).location(2,1)]);
%     h_sensor=plot(Sensor(i).location(1,1),Sensor(i).location(2,1),'k^','Markerface','y','MarkerSize',10);
%     draw_circle(Sensor(i).location(1,1),Sensor(i).location(2,1),Sensor(i).R_detect);
% end
% 
% for t=64:67
%     
%     
%        % ===估计值===
%        
%        plot(Sensor(6).X_est{t,1}(1,:),Sensor(6).X_est{t,1}(3,:),'b.');
%         
% 
%     
% end

%{
% =======计算每个时刻真实目标数目=======
num_real = zeros(1,N); % 全局真实目标数目
for t=1:N
    num_real(1,t) = size(Xreal_time_target{t,1},2);
end

figure
hold on;
plot(OSPA,'-ko','Markerface','b');
legend('分散式GA','FontSize',14);
t=title('OSPA');
t.FontSize = 14;
xlabel('时刻 t/s','FontSize',14)
ylabel('OSPA距离','FontSize',14)
disp(num2str(sum(OSPA(3:end))/98));

figure
hold on;
plot(num_real,'-k');
plot(Num_estimate,'-ko','Markerface','b');
legend('真实值','分散式GA','FontSize',14);
t=title('数量跟踪对比');
t.FontSize = 14;
xlabel('时刻 t/s','FontSize',14)
ylabel('估计数量','FontSize',14)

figure
hold on;
flag_realtarget=0;
flag_ob=0;
flag_estimate=0;

% 画出平台节点以及其检测范围
for i=1:N_sensor
    text(Sensor(i).location(1,1),Sensor(i).location(2,1),num2str(i),'Fontsize',20,'Position',...
        [Sensor(i).location(1,1),Sensor(i).location(2,1)]);
    h_sensor=plot(Sensor(i).location(1,1),Sensor(i).location(2,1),'k^','Markerface','y','MarkerSize',10);
    draw_circle(Sensor(i).location(1,1),Sensor(i).location(2,1),Sensor(i).R_detect);
end

for t=1:N
    
    if t>2
        ===估计值===
        h_estimate=plot(Sensor(1).X_est{t,1}(1,:),Sensor(1).X_est{t,1}(3,:),'bo');
        hold on;
        if ~isempty(h_estimate) && flag_estimate==0
            leg_estimate=h_estimate;
            flag_estimate=1;
        end
    end
    
end

for t=1:N
    %===真实值===
    h_realtarget=plot(Xreal_time_target{t,1}(1,:),Xreal_time_target{t,1}(3,:),'r.');
    hold on;
end

% 获取legend素材
if ~isempty(h_realtarget) && flag_realtarget==0
    leg_realtarget=h_realtarget;
    flag_realtarget=1;
end
if isempty(h_estimate)
    h_estimate=plot(0,0,'bo');
    leg_estimate=h_estimate;
    hold on;
end

xlabel('X轴坐标/m','FontSize',20);
ylabel('Y轴坐标/m','FontSize',20);
set(gca,'FontSize',20);
t=title('xxx','FontSize',20);
t.FontSize = 20;
grid on;
axis equal
legend([h_sensor,leg_realtarget,leg_estimate],...
    {'传感器坐标','真实目标点迹','传感器估计点迹'},'Fontsize',20);
%}

end