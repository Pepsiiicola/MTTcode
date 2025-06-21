%{
                        数据分析画图函数
      分别为：
      1、三种融合结构OSPA对比
      2、三种融合结构数量跟踪对比
      3、分散式跟踪轨迹 
      4、分布式跟踪轨迹
      5、集中式跟踪轨迹
      6、数值文字分析

%}

clc;
clear;
load('data_compare.mat')

figure
hold on;
plot(MM_OSPA_decen,'-ko','Markerface','b');
plot(MM_OSPA_distr,'-ks','Markerface','r');
plot(MM_OSPA_centra,'-k^','Markerface','y');
legend('分散式','分布式','集中式','FontSize',14);
t=title('三种融合结构OSPA对比');
t.FontSize = 14;
xlabel('时刻 t/s','FontSize',14)
ylabel('OSPA距离','FontSize',14)

figure
hold on;
plot(num_real,'-k');
plot(MM_count_estimate_decen,'-ko','Markerface','b');
plot(MM_count_estimate_distr,'-ks','Markerface','r');
plot(MM_count_estimate_centra,'-k^','Markerface','y');
legend('真实值','分散式','分布式','集中式','FontSize',14);
t=title('三种融合结构数量跟踪对比');
t.FontSize = 14;
xlabel('时刻 t/s','FontSize',14)
ylabel('估计数量','FontSize',14)

%===============================================================================
%                               分散式跟踪轨迹  
figure
flag_realtarget=0;
flag_ob=0;
flag_estimate=0;

% 画出传感器节点的位置
for i=1:N_sensor
    text(Sensor_decen(i).location(1,1),Sensor_decen(i).location(2,1),Sensor_decen(i).location(3,1),num2str(i),'Fontsize',14);
    h_point=plot3(Sensor_decen(i).location(1,1),Sensor_decen(i).location(2,1),Sensor_decen(i).location(3,1),...
        'k^','Markerface','y');
    hold on;
end

for i=1:N
    
    % 真实值
    h_real=plot3(Xreal_time_target{i,1}(1,:),Xreal_time_target{i,1}(3,:),...
                 Xreal_time_target{i,1}(5,:),'ro');
    hold on;
    % 观测值
    if ~isempty(Sensor_decen(1).Z_dicaer_global{i,1})
        h_Z=plot3(Sensor_decen(1).Z_dicaer_global{i,1}(1,:),...
            Sensor_decen(1).Z_dicaer_global{i,1}(2,:),...
            Sensor_decen(1).Z_dicaer_global{i,1}(3,:),'g+');
        hold on
%         drawnow;
        if ~isempty(h_Z) && flag_ob==0
            leg_ob=h_Z;
            flag_ob=1;
        end  
    end
    
    % 估计值
    if i>2
        h_est=plot3(Sensor_decen(1).X_est{i,1}(1,:),Sensor_decen(1).X_est{i,1}(3,:),...
            Sensor_decen(1).X_est{i,1}(5,:),'b*');
        hold on
        if ~isempty(h_est) && flag_estimate==0
            leg_estimate=h_est;
            flag_estimate=1;
        end
    end
    
    % 获取legend素材
    if ~isempty(h_real) && flag_realtarget==0
        leg_realtarget=h_real;
        flag_realtarget=1;
    end
end

for i=1:size(Track_decen(1).track,2)
    for j=1:Track_decen(1).track(i).tr_count
        text(Track_decen(1).track(i).tr_state(1,j),...
             Track_decen(1).track(i).tr_state(3,j),...
             Track_decen(1).track(i).tr_state(5,j),...
             num2str(Track_decen(1).track(i).serial_number),...
             'HorizontalAlignment','center','VerticalAlignment','bottom');
%         drawnow;
    end
end
grid on
axis equal 
t=title('分散式跟踪轨迹');
t.FontSize = 14;
legend([h_point,leg_realtarget,leg_ob,leg_estimate],{'节点坐标','真实值','节点观测值','节点估计值'},'FontSize',14);
xlabel('X轴坐标/m','FontSize',14);
ylabel('Y轴坐标/m','FontSize',14);
zlabel('Z轴坐标/m','FontSize',14);


%================================================================================

%===============================================================================
%                               分布式跟踪轨迹  
figure
flag_realtarget=0;
flag_ob=0;
flag_estimate=0;

% 画出传感器节点的位置
for i=1:N_sensor
    text(Sensor_distr(i).location(1,1),Sensor_distr(i).location(2,1),Sensor_distr(i).location(3,1),num2str(i),'Fontsize',14);
    h_point=plot3(Sensor_distr(i).location(1,1),Sensor_distr(i).location(2,1),Sensor_distr(i).location(3,1),...
        'k^','Markerface','y');
    hold on;
end

for i=1:N
    
   h_real=plot3(Xreal_time_target{i,1}(1,:),Xreal_time_target{i,1}(3,:),...
        Xreal_time_target{i,1}(5,:),'ro');
    hold on
    
    % 观测值
    if ~isempty(Sensor_distr(1).Z_dicaer_global{i,1})
        h_Z=plot3(Sensor_distr(1).Z_dicaer_global{i,1}(1,:),...
            Sensor_distr(1).Z_dicaer_global{i,1}(2,:),...
            Sensor_distr(1).Z_dicaer_global{i,1}(3,:),'g+');
        hold on
        if ~isempty(h_Z) && flag_ob==0
            leg_ob=h_Z;
            flag_ob=1;
        end  
    end
    
    % 估计值
    if i>2
        h_est=plot3(Sensor_distr(1).X_est{i,1}(1,:),Sensor_distr(1).X_est{i,1}(3,:),...
            Sensor_distr(1).X_est{i,1}(5,:),'b*');
        hold on
        if ~isempty(h_est) && flag_estimate==0
            leg_estimate=h_est;
            flag_estimate=1;
        end
    end
    
    % 获取legend素材
    if ~isempty(h_real) && flag_realtarget==0
        leg_realtarget=h_real;
        flag_realtarget=1;
    end
end

for i=1:size(Track_distr(1).track,2)
    for j=1:Track_distr(1).track(i).tr_count
        text(Track_distr(1).track(i).tr_state(1,j),...
             Track_distr(1).track(i).tr_state(3,j),...
             Track_distr(1).track(i).tr_state(5,j),...
             num2str(Track_distr(1).track(i).serial_number),...
             'HorizontalAlignment','center','VerticalAlignment','bottom');
    end
end
grid on
axis equal 
t=title('分布式跟踪轨迹');
t.FontSize = 14;
legend([h_point,leg_realtarget,leg_ob,leg_estimate],{'节点坐标','真实值','节点观测值','节点估计值'},'FontSize',14);
xlabel('X轴坐标/m','FontSize',14);
ylabel('Y轴坐标/m','FontSize',14);
zlabel('Z轴坐标/m','FontSize',14);
%================================================================================

%===============================================================================
%                               集中式跟踪轨迹  
figure
flag_realtarget=0;
flag_ob=0;
flag_estimate=0;

% 画出传感器节点的位置
for i=1:N_sensor
    text(Sensor_centra(i).location(1,1),Sensor_centra(i).location(2,1),Sensor_centra(i).location(3,1),num2str(i),'Fontsize',14);
    h_point=plot3(Sensor_centra(i).location(1,1),Sensor_centra(i).location(2,1),Sensor_centra(i).location(3,1),...
        'k^','Markerface','y');
    hold on;
end

for i=1:N
    
    h_real=plot3(Xreal_time_target{i,1}(1,:),Xreal_time_target{i,1}(3,:),...
        Xreal_time_target{i,1}(5,:),'ro');
    hold on

    % 观测值
    if ~isempty(Sensor_centra(1).Z_dicaer_global{i,1})
        h_Z=plot3(Sensor_centra(1).Z_dicaer_global{i,1}(1,:),...
            Sensor_centra(1).Z_dicaer_global{i,1}(2,:),...
            Sensor_centra(1).Z_dicaer_global{i,1}(3,:),'g+');
        hold on
        if ~isempty(h_Z) && flag_ob==0
            leg_ob=h_Z;
            flag_ob=1;
        end  
    end
    
    % 估计值
    if i>2
        h_est=plot3(Sensor_centra(1).X_est{i,1}(1,:),Sensor_centra(1).X_est{i,1}(3,:),...
            Sensor_centra(1).X_est{i,1}(5,:),'b*');
        hold on
        if ~isempty(h_est) && flag_estimate==0
            leg_estimate=h_est;
            flag_estimate=1;
        end
    end
    
    % 获取legend素材
    if ~isempty(h_real) && flag_realtarget==0
        leg_realtarget=h_real;
        flag_realtarget=1;
    end
end


for i=1:size(Track_centra(1).track,2)
    for j=1:Track_centra(1).track(i).tr_count
        text(Track_centra(1).track(i).tr_state(1,j),...
             Track_centra(1).track(i).tr_state(3,j),...
             Track_centra(1).track(i).tr_state(5,j),...
             num2str(Track_centra(1).track(i).serial_number),...
             'HorizontalAlignment','center','VerticalAlignment','bottom');
    end
end
grid on
axis equal 
t=title('集中式跟踪轨迹');
t.FontSize = 14;
legend([h_point,leg_realtarget,leg_ob,leg_estimate],{'节点坐标','真实值','节点观测值','节点估计值'},'FontSize',14);
xlabel('X轴坐标/m','FontSize',14);
ylabel('Y轴坐标/m','FontSize',14);
zlabel('Z轴坐标/m','FontSize',14);
%================================================================================

%====================== 数值分析 ========================
% 文字输出模块
Inf_show_1=['分散式单个融合周期耗费时间为:',num2str( MM_TIME_CONSU_DECEN ),'秒/s'];
Inf_show_2=['分布式单个融合周期耗费时间为:',num2str( MM_TIME_CONSU_DISTR ),'秒/s'];
Inf_show_3=['集中式单个融合周期耗费时间为:',num2str( MM_TIME_CONSU_CENTRA ),'秒/s'];

Inf_show_4=['分散式跟踪航迹文件大小:',num2str( MM_BYTES_DECEN_TRACK ),'kb'];
Inf_show_5=['分布式跟踪航迹文件大小:',num2str( MM_BYTES_DISTR_TRACK ),'kb'];
Inf_show_6=['集中式跟踪航迹文件大小:',num2str( MM_BYTES_CENTRA_TRACK ),'kb'];

Inf_show_7=['分散式关联正确率:',num2str( MM_ASSOCI_DECEN ),'%'];
Inf_show_8=['分布式关联正确率:',num2str( MM_ASSOCI_DISTR ),'%'];
Inf_show_9=['集中式关联正确率:',num2str( MM_ASSOCI_CENTRA ),'%'];

% 文字形式
% 单个节点以及融合中心存储量
Inf_show_10=['分散式单个节点平均存储量:',num2str( sum(MM_BYTES_DECEN_SENSOR_STORAGE,2)/(N-1)),'kb'];
Inf_show_11=['分布式单个节点平均存储量:',num2str( sum(MM_BYTES_DISTR_SENSOR_STORAGE,2)/(N-1)),'kb'];
Inf_show_12=['集中式单个节点平均存储量:',num2str( sum(MM_BYTES_CENTRA_SENSOR_STORAGE,2)/(N-1)),'kb'];
Inf_show_13=['分布式融合中心平均存储量:',num2str( sum(MM_BYTES_DISTR_FUSION_STORAGE,2)/(N-2)),'kb'];
Inf_show_14=['集中式融合中心平均存储量:',num2str( sum(MM_BYTES_CENTRA_FUSION_STORAGE,2)/(N-2)),'kb'];

% 单个节点以及融合中心数据发送量
Inf_show_15=['分散式节点平均数据发送量:',num2str( sum(MM_BYTES_DECEN_SEND,2)/(N-1)),'kb'];
Inf_show_16=['分布式节点平均数据发送量:',num2str( sum(MM_BYTES_DISTR_SENSOR_SEND,2)/(N-2)),'kb'];
Inf_show_17=['分布式融合中心平均数据发送量:',num2str( sum(MM_BYTES_DISTR_FUSION_SEND,2)/(N-2)),'kb'];
Inf_show_18=['集中式节点平均数据发送量:',num2str( sum(MM_BYTES_CENTRA_SENSOR_SEND,2)/(N-2)),'kb'];
Inf_show_19=['集中式融合中心平均数据发送量:',num2str( sum(MM_BYTES_CENTRA_FUSION_SEND,2)/(N-2)),'kb'];

% 数据接收量
Inf_show_20=['分散式节点平均数据接收量:',num2str( sum(MM_BYTES_DECEN_GET/(N-1)),2),'kb'];
Inf_show_21=['分布式节点平均数据接收量:',num2str( sum(MM_BYTES_DISTR_SENSOR_GET,2)/(N-2)),'kb'];
Inf_show_22=['分布式融合中心平均数据接收量:',num2str( sum(MM_BYTES_DISTR_FUSION_GET,2)/(N-2)),'kb'];
Inf_show_23=['集中式节点平均数据接收量:',num2str( sum(MM_BYTES_CENTRA_SENSOR_GET,2)/(N-2)),'kb'];
Inf_show_24=['集中式融合中心平均数据接收量:',num2str( sum(MM_BYTES_CENTRA_FUSION_GET,2)/(N-2)),'kb'];

% OSPA值
Inf_show_25=['分散式跟踪平均OSPA:',num2str( sum(MM_OSPA_decen(3:end)/(N-2)),2)];
Inf_show_26=['分布式跟踪平均OSPA:',num2str( sum(MM_OSPA_distr(3:end),2)/(N-2))];
Inf_show_27=['集中式跟踪OSPA:',num2str( sum(MM_OSPA_centra(3:end),2)/(N-2))];

disp(Inf_show_1);
disp(Inf_show_2);
disp(Inf_show_3);
disp(Inf_show_4);
disp(Inf_show_5);
disp(Inf_show_6);
disp(Inf_show_7);
disp(Inf_show_8);
disp(Inf_show_9);

disp(" ");
disp("存储量:")
disp(Inf_show_10);
disp(Inf_show_11);
disp(Inf_show_12);
disp(Inf_show_13);
disp(Inf_show_14);

disp(" ");
disp("数据发送量:");
disp(Inf_show_15);
disp(Inf_show_16);
disp(Inf_show_17);
disp(Inf_show_18);
disp(Inf_show_19);

disp(" ");
disp("数据接收量:");
disp(Inf_show_20);
disp(Inf_show_21);
disp(Inf_show_22);
disp(Inf_show_23);
disp(Inf_show_24);

disp(" ");
disp("OSPA");
disp(Inf_show_25);
disp(Inf_show_26);
disp(Inf_show_27);