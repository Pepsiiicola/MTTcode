%615project
%����2�Ŵ������۲�����

Observe = [];
for j = 1:100
    Observe = [Observe Sensor_decen(3).Z_dicaer_global{j,1}];
end
figure
hold on;
grid on;
view(3)
h1 = plot3(Observe(1,:),Observe(2,:),Observe(3,:),'g*');

Target_Num = size(Xreal_target_time,1);
for k = 1:Target_Num
    index = isnan(Xreal_target_time{k,1});
    nanIndex = find(index(1,:));
    Xreal_target_time{k,1}(:,nanIndex) = [];
    %��ʵ�켣
    h3 = plot3(Xreal_target_time{k,1}(1,:), Xreal_target_time{k,1}(3,:),Xreal_target_time{k,1}(5,:),'-b','LineWidth',1);
end
legend([h1,h3],'�۲��','��ʵ�켣','FontSize',18);
xlabel('x��/m','FontSize',14);
ylabel('y��/m','FontSize',14);
zlabel('z��/m','FontSize',14);
