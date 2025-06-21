%画高斯函数
x = -20:0.1:20;
%第一个正态分布函数N（0，25）* 0.99;
y1 = 0.99 * normpdf(x,0,5);
y2 = 0.01 * normpdf(x,0,5);
%AA融合
y3 = 0.5 * normpdf(x,0,5);
%GA融合
y4 = 0.99^0.5 * 0.01^0.5 * normpdf(x,0,5);
figure
hold on;
box on;
grid on;
plot(x,y1,'--','LineWidth',1.5,'Color',[0 0.4470 0.7410]);
plot(x,y2,'--','LineWidth',1.5,'Color',[0.85 0.325 0.098]);
plot(x,y3,'-','LineWidth',1.5,'Color',[0.929 0.694 0.125]);
plot(x,y4,'-','LineWidth',1.5,'Color',[0.494,0.184,0.556]);
xlabel('State');
ylabel('Probability');
legend('PHD of Sensor1','PHD of Sensor2','PHD of AA fusion','PHD of GA fusion');
set(gca,'Fontsize',14,'FontName','Times New Roman');