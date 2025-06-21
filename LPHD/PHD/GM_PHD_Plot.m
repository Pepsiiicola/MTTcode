%�������˲�������д���
L_space = unique(s1_L_k_history','rows')';
x_hat = cell(size(L_space,2),1);
L_k_history_mapping = Label_mapping(s1_L_k_history);
for i = 1:size(L_space,2)
    thisMapping = Label_mapping(L_space(:,i));
    thisIndex = find(L_k_history_mapping == thisMapping);
    x_hat{i,1} = s1_x_k_history(:,thisIndex);
end
figure
hold on; box on;
for i = 1:size(x_hat)
   temp_x = x_hat{i,1};
   plot(temp_x(1,:),temp_x(3,:),'-o','Color',[rand,rand,rand]);
end
axis([-1500 1500 -1500 1500]);
legend('Label-1','Label-2','Label-3');


%% ͼ1 �켣ͼ
figure
hold on; box on;
plot(Target1(1,:),Target1(3,:),'.-k','LineWidth',2.5);
plot(Target2(1,:),Target2(3,:),'.-k','LineWidth',2.5);
plot(Target3(1,:),Target3(3,:),'.-k','LineWidth',2.5);
plot(s1_x_k_history(1,:),s1_x_k_history(3,:),'bo');
legend('Ŀ��1','Ŀ��2','Ŀ��3','�˲��켣');
xlabel('X���� m/s');
ylabel('Y���� m/s');
axis([-1500 1500 -1500 1500]);
title('GM-PHD�˲���');
%% ͼ2 ���ͼ
figure
hold on;
box on;
s1_ospa_err_val=s1_ospa_err/Mnte;
plot(s1_ospa_err_val,'-ks','MarkerFaceColor','b');
legend('GMPHD');
title('OSPA metric/Sensor1������10��������0.6 Sensor2:����20��������0.6');
xlabel('x ����');
ylabel('y/m');
axis([0 100 0 200]);
%% ͼ3 Ŀ����Ŀ����ͼ
figure
hold on;
box on;
plot([2*ones(1,20),3*ones(1,50),2*ones(1,30)],'-k','LineWidth',2);
plot(s1_Target_estimate,'-bo');

% plot(s1_Z_clutter{1,2}(1,:),s1_Z_clutter{1,2}(2,:),'bo');
legend('��ʵĿ����Ŀ','Sensor1');
xlabel('x ����');
ylabel('y/����');
axis([0,100,0,5]);
title('Ŀ����Ŀ����');

