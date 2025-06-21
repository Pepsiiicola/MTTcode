figure
hold on;
flag_realtarget=0;
flag_ob=0;

% ����ƽ̨�ڵ��Լ����ⷶΧ
for i=1:N_sensor
    text(location(1,i),location(2,i),num2str(i),'Fontsize',20,'Position',...
        [location(1,i),location(2,i)]);
    h_sensor=plot(location(1,i),location(2,i),'k^','Markerface','y','MarkerSize',10);
    draw_circle(location(1,i),location(2,i),R_DETECT);
end

for t=1:N
    %===��ʵֵ===
    h_realtarget=plot(Xreal_time_target{t,1}(1,:),Xreal_time_target{t,1}(3,:),'r.');
%     drawnow;
%     pause(0.1);
    hold on;
end



% ��ȡlegend�ز�
if ~isempty(h_realtarget) && flag_realtarget==0
    leg_realtarget=h_realtarget;
    flag_realtarget=1;
end

xlabel('X������/m','FontSize',20);
ylabel('Y������/m','FontSize',20);
set(gca,'FontSize',20);
t=title('����ʾ��ͼ','FontSize',20);
t.FontSize = 20;
grid on;
axis equal
legend([h_sensor,leg_realtarget],...
    {'����������','��ʵĿ��㼣'},'Fontsize',20);