%% 目标真实轨迹图
%============目标真实轨迹图==========%
txt_bias = 60; % text标签偏移量
figure 
hold on;
box on;
%传感器数量
Sensor_Num = size(Sensor,2);
%目标数量
Target_Num = size(Xreal_target_time,1);
%观测范围
w = -pi:0.001:pi;
for k = 1:Sensor_Num
    Circle(k).X = Sensor(k).location(1) + Sensor(k).R_detect * cos(w);
    Circle(k).Y = Sensor(k).location(2) + Sensor(k).R_detect * sin(w);
    %传感器位置
    h1 = plot(Sensor(k).location(1),Sensor(k).location(2),'yp','MarkerSize',10,'MarkerFaceColor','y','MarkerEdgeColor','k');
    text(Sensor(k).location(1)+txt_bias,Sensor(k).location(2)+txt_bias,num2str(k),'FontSize',14);
    %传感器边界
    h2 = plot( Circle(k).X , Circle(k).Y,'--','Color',[0.5,0.5,0.5],'LineWidth',1);
end
%====画真实轨迹=====%
%数据预处理-去除NaN
for k = 1:Target_Num
    index = isnan(Xreal_target_time{k,1});
    nanIndex = find(index(1,:));
    Xreal_target_time{k,1}(:,nanIndex) = [];
    %真实轨迹
    h3 = plot(Xreal_target_time{k,1}(1,:), Xreal_target_time{k,1}(3,:),'-k','LineWidth',1);
    %画起点与终点
    h4 = plot(Xreal_target_time{k,1}(1,1),Xreal_target_time{k,1}(3,1),'bs','LineWidth',1,'MarkerSize',8,'MarkerFaceColor','b');
    endIndex = size(Xreal_target_time{k,1},2);
    h5 = plot(Xreal_target_time{k,1}(1,endIndex),Xreal_target_time{k,1}(3,endIndex),'ro','LineWidth',1,'MarkerSize',8,'MarkerFaceColor','r');
end
%% 滤波航迹
Label_mapping = @(X)(X(1,:) * 2000 + X(2,:) + X(3,:) * 20);
%对最终滤波结果进行处理
L_space = unique(L_hat_history','rows')';
x_hat = cell(size(L_space,2),1);
L_k_history_mapping = Label_mapping(L_hat_history);
for i = 1:size(L_space,2)
    thisMapping = Label_mapping(L_space(:,i));
    thisIndex = find(L_k_history_mapping == thisMapping);
    x_hat{i,1} = x_hat_history(:,thisIndex);
end
colorEsti = hsv(size(x_hat,1));
for i = 1:size(x_hat,1)
   temp_x = x_hat{i,1};
   h6(i)=plot(temp_x(1,:),temp_x(3,:),'-o','Color',colorEsti(i,:));
end
for i = 1:size(x_hat,1)
   h6_str{i} = ['Label',num2str(i)];
end
legend([h1,h2,h3,h4,h5,h6([1:size(x_hat,1)])],['Sensor','Sensor Range','True Target','Start Point','Ending Point',h6_str]);
axis equal;

%% 传感器观测
%======传感器观测图=======%
figure
hold on;
box on;
%随机产生一种颜色用于画图
colorArray = hsv(Sensor_Num);
for k = 1:Sensor_Num
    Observe(k).point = [];
    for j = 1:100
       Observe(k).point = [Observe(k).point Sensor(k).Z_dicaer_global{j,1}];
    end
end
for k = 1:Sensor_Num
    %传感器观测点
    h3 = plot(Observe(k).point(1,:),Observe(k).point(2,:),'.','Color',colorArray(k,:));
    %传感器位置
    h1 = plot(Sensor(k).location(1),Sensor(k).location(2),'y^','MarkerSize',10,'MarkerEdgeColor','k','MarkerFaceColor','y');
    text(Sensor(k).location(1)+txt_bias,Sensor(k).location(2)+txt_bias,num2str(k),'FontSize',14);
    %传感器边界
    h2 = plot( Circle(k).X , Circle(k).Y,'--','Color',[0.5,0.5,0.5]);
end
lgd = legend([h1,h2,h3],'Sensor Location','Observation Range','Observation Data');
lgd.FontSize = 14;
xlabel('X-Coordinate / m','FontSize',14);
ylabel('Y-Coordinate / m','FontSize',14);
set(gca,'FontSize',14);
axis equal;
% axis square;
title('Cumulative graph of network observations','FontSize',14);