%=========Ŀ����ʵ�켣ͼ==========%
txt_bias = 60; % text��ǩƫ����
figure
% axis([-3500 3500 -3500 3500]);
hold on;
box on;
%����������
Sensor_Num = size(Sensor_decen,2);
%Ŀ������
Target_Num = size(Xreal_target_time,1);
%=====��Բ======%
w = -pi:0.001:pi;
for k = 1:Sensor_Num
    Circle(k).X = Sensor_decen(k).location(1) + Sensor_decen(k).R_detect * cos(w);
    Circle(k).Y = Sensor_decen(k).location(2) + Sensor_decen(k).R_detect * sin(w);
    
    %������λ��
    h1 = plot(Sensor_decen(k).location(1),Sensor_decen(k).location(2),'y^','MarkerSize',8,'MarkerFaceColor','y','MarkerEdgeColor','k');
    text(Sensor_decen(k).location(1)+txt_bias,Sensor_decen(k).location(2)+txt_bias,num2str(k),'FontSize',14);
    %�������߽�
    h2 = plot( Circle(k).X , Circle(k).Y,'--','Color',[0.5,0.5,0.5]);

end
%====����ʵ�켣=====%
%����Ԥ����-ȥ��NaN
for k = 1:Target_Num
    index = isnan(Xreal_target_time{k,1});
    nanIndex = find(index(1,:));
    Xreal_target_time{k,1}(:,nanIndex) = [];
    %��ʵ�켣
    h3 = plot(Xreal_target_time{k,1}(1,:), Xreal_target_time{k,1}(3,:),'-k','LineWidth',2);
    %��������յ�
    h4 = plot(Xreal_target_time{k,1}(1,1),Xreal_target_time{k,1}(3,1),'bs','LineWidth',2,'MarkerSize',8,'MarkerFaceColor','b');
    endIndex = size(Xreal_target_time{k,1},2);
    h5 = plot(Xreal_target_time{k,1}(1,endIndex),Xreal_target_time{k,1}(3,endIndex),'rv','LineWidth',2,'MarkerSize',8,'MarkerFaceColor','r');
end
% �����뵱ǰ�ڵ�����������ӹ�ϵ����
for k = 1:Sensor_Num
    for kk = 1:Sensor_Num
        if mat_topo_decen( k, kk ) == 1
            h_topo = plot( [location(1,k),location(1,kk)],[location(2,k),location(2,kk)],...
                '-','LineWidth',1.2,'color',[54, 195, 201]/255 );
        end
    end  
end

lgd = legend([h1,h3,h4,h5,h_topo],'\fontname{Simsun}������','\fontname{Simsun}��ʵ�켣','\fontname{Simsun}���','\fontname{Simsun}�յ�','\fontname{Simsun}ͨ����·');
lgd.FontSize = 12;
% title('Real target trajectory and sensor observation range ','FontSize',14);
xlabel('{\fontname{Times New Roman}X \fontname{Simsun}���� \fontname{Times New Roman}/m}','FontSize',14);
ylabel('{\fontname{Times New Roman}Y \fontname{Simsun}���� \fontname{Times New Roman}/m}','FontSize',14);
% set(gca,'Fontsize',14,'FontName','Times New Roman');
% axis([-4000 4000 -4000 4000]);
axis equal;
% axis square;
% axis([-2500,2500,-2500,2500]);

%======�������۲�ͼ=======%
figure
% axis([-3500 3500 -3500 3500]);
hold on;
box on;
%�������һ����ɫ���ڻ�ͼ
colorArray = hsv(Sensor_Num);
for k = 1:Sensor_Num
    Observe(k).point = [];
    for j = 1:100
       Observe(k).point = [Observe(k).point Sensor_decen(k).Z_dicaer_global{j,1}];
    end
end
for k = 1:Sensor_Num
    %�������۲��
    h3 = plot(Observe(k).point(1,:),Observe(k).point(2,:),'.','Color',colorArray(k,:));
    %������λ��
    h1 = plot(Sensor_decen(k).location(1),Sensor_decen(k).location(2),'y^','MarkerSize',8,'MarkerEdgeColor','k','MarkerFaceColor','y');
    text(Sensor_decen(k).location(1)+txt_bias,Sensor_decen(k).location(2)+txt_bias,num2str(k),'FontSize',14);
    %�������߽�
    h2 = plot( Circle(k).X , Circle(k).Y,'--','Color',[0.5,0.5,0.5]);
end

%=====��������ڵ����򻭳��ڵ���======
if Occlusion_flag == 1
    Occlusion_pos1 = [Sensor_decen(6).location(1) + 300*cos(deg2rad(120)), Sensor_decen(6).location(2) + 300*sin(deg2rad(120));
                     Sensor_decen(6).location(1) + 300*cos(deg2rad(60)) , Sensor_decen(6).location(2) + 300*sin(deg2rad(60)) ]';

    Occlusion_pos2 = [Sensor_decen(3).location(1) + 300*cos(deg2rad(120)), Sensor_decen(3).location(2) + 300*sin(deg2rad(120));
                     Sensor_decen(3).location(1) + 300*cos(deg2rad(60)) , Sensor_decen(3).location(2) + 300*sin(deg2rad(60)) ]';


    Occlusion_pos3 = [Sensor_decen(8).location(1) + 300*cos(deg2rad(315)), Sensor_decen(8).location(2) + 300*sin(deg2rad(315));
                     Sensor_decen(8).location(1) + 300*cos(deg2rad(35)) , Sensor_decen(8).location(2) + 300*sin(deg2rad(35)) ]';

    h_occ1 = plot(Occlusion_pos1(1,:),Occlusion_pos1(2,:),'-k','LineWidth',5);
    h_occ2 = plot(Occlusion_pos2(1,:),Occlusion_pos2(2,:),'-k','LineWidth',5);
    h_occ3 = plot(Occlusion_pos3(1,:),Occlusion_pos3(2,:),'-k','LineWidth',5);

end


lgd = legend([h1,h2,h3],'\fontname{Simsun}������','\fontname{Simsun}�۲ⷶΧ','\fontname{Simsun}�����');
lgd.FontSize = 12;
xlabel('{\fontname{Times New Roman}X \fontname{Simsun}���� \fontname{Times New Roman}/m}','FontSize',14);
ylabel('{\fontname{Times New Roman}Y \fontname{Simsun}���� \fontname{Times New Roman}/m}','FontSize',14);
% set(gca,'Fontsize',14,'FontName','Times New Roman');
axis equal;
% axis square;
% title('Cumulative graph of network observations','FontSize',14);

%======�������ڵ���Ĵ������Ĺ۲�ͼ======

if Occlusion_flag == 1
    figure
    hold on 
    axis([-4000 2000 -2500 2500]);
    for k = [3,6,8]
        %�������۲��
        h7 = plot(Observe(k).point(1,:),Observe(k).point(2,:),'.','Color',colorArray(k,:));
        %������λ��
        h8 = plot(Sensor_decen(k).location(1),Sensor_decen(k).location(2),'y^','MarkerSize',8,'MarkerEdgeColor','k','MarkerFaceColor','y');
        text(Sensor_decen(k).location(1)+txt_bias,Sensor_decen(k).location(2)+txt_bias,num2str(k),'FontSize',14);
        %�������߽�
        h9 = plot( Circle(k).X , Circle(k).Y,'--','Color',[0.5,0.5,0.5]);
    end
end

if Occlusion_flag == 1
    h_occ1 = plot(Occlusion_pos1(1,:),Occlusion_pos1(2,:),'-k','LineWidth',5);
    h_occ2 = plot(Occlusion_pos2(1,:),Occlusion_pos2(2,:),'-k','LineWidth',5);
    h_occ3 = plot(Occlusion_pos3(1,:),Occlusion_pos3(2,:),'-k','LineWidth',5);
end
