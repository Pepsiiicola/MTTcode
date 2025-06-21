%% Ŀ����ʵ�켣ͼ
%============Ŀ����ʵ�켣ͼ==========%
txt_bias = 60; % text��ǩƫ����
figure 
hold on;
box on;
%����������
Sensor_Num = size(Sensor,2);
%Ŀ������
Target_Num = size(Xreal_target_time,1);
%�۲ⷶΧ
w = -pi:0.001:pi;
for k = 1:Sensor_Num
    Circle(k).X = Sensor(k).location(1) + Sensor(k).R_detect * cos(w);
    Circle(k).Y = Sensor(k).location(2) + Sensor(k).R_detect * sin(w);
    %������λ��
    h1 = plot(Sensor(k).location(1),Sensor(k).location(2),'yp','MarkerSize',10,'MarkerFaceColor','y','MarkerEdgeColor','k');
    text(Sensor(k).location(1)+txt_bias,Sensor(k).location(2)+txt_bias,num2str(k),'FontSize',14);
    %�������߽�
    h2 = plot( Circle(k).X , Circle(k).Y,'--','Color',[0.5,0.5,0.5],'LineWidth',1);
end
%====����ʵ�켣=====%
%����Ԥ����-ȥ��NaN
for k = 1:Target_Num
    index = isnan(Xreal_target_time{k,1});
    nanIndex = find(index(1,:));
    Xreal_target_time{k,1}(:,nanIndex) = [];
    %��ʵ�켣
    h3 = plot(Xreal_target_time{k,1}(1,:), Xreal_target_time{k,1}(3,:),'-k','LineWidth',1);
    %��������յ�
    h4 = plot(Xreal_target_time{k,1}(1,1),Xreal_target_time{k,1}(3,1),'bs','LineWidth',1,'MarkerSize',8,'MarkerFaceColor','b');
    endIndex = size(Xreal_target_time{k,1},2);
    h5 = plot(Xreal_target_time{k,1}(1,endIndex),Xreal_target_time{k,1}(3,endIndex),'ro','LineWidth',1,'MarkerSize',8,'MarkerFaceColor','r');
end
%% �˲�����
Label_mapping = @(X)(X(1,:) * 2000 + X(2,:) + X(3,:) * 20);
%�������˲�������д���
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

%% �������۲�
%======�������۲�ͼ=======%
figure
hold on;
box on;
%�������һ����ɫ���ڻ�ͼ
colorArray = hsv(Sensor_Num);
for k = 1:Sensor_Num
    Observe(k).point = [];
    for j = 1:100
       Observe(k).point = [Observe(k).point Sensor(k).Z_dicaer_global{j,1}];
    end
end
for k = 1:Sensor_Num
    %�������۲��
    h3 = plot(Observe(k).point(1,:),Observe(k).point(2,:),'.','Color',colorArray(k,:));
    %������λ��
    h1 = plot(Sensor(k).location(1),Sensor(k).location(2),'y^','MarkerSize',10,'MarkerEdgeColor','k','MarkerFaceColor','y');
    text(Sensor(k).location(1)+txt_bias,Sensor(k).location(2)+txt_bias,num2str(k),'FontSize',14);
    %�������߽�
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