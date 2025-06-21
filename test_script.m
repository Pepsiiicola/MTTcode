figure
hold on;
flag_realtarget=0;
flag_ob=0;

% 画出平台节点以及其检测范围
for i=1:N_sensor
    text(location(1,i),location(2,i),num2str(i),'Fontsize',20,'Position',...
        [location(1,i),location(2,i)]);
    h_sensor=plot(location(1,i),location(2,i),'k^','Markerface','y','MarkerSize',10);
    draw_circle(location(1,i),location(2,i),R_DETECT);
end

for t=1:N
    %===真实值===
    h_realtarget=plot(Xreal_time_target{t,1}(1,:),Xreal_time_target{t,1}(3,:),'r.');
%     drawnow;
%     pause(0.1);
    hold on;
end



% 获取legend素材
if ~isempty(h_realtarget) && flag_realtarget==0
    leg_realtarget=h_realtarget;
    flag_realtarget=1;
end

xlabel('X轴坐标/m','FontSize',20);
ylabel('Y轴坐标/m','FontSize',20);
set(gca,'FontSize',20);
t=title('跟踪示意图','FontSize',20);
t.FontSize = 20;
grid on;
axis equal
legend([h_sensor,leg_realtarget],...
    {'传感器坐标','真实目标点迹'},'Fontsize',20);