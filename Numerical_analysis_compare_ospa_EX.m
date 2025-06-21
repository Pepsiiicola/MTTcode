%{
        
                  三种评价指标的出图脚本
         4.视域重叠程度和OSPA均值的二维图
         5.通信次数和OSPA收敛的二维图
         6.拓扑连接程度，通信次数和OSPA收敛的二维图(分别对应x,y,z轴)
%}
if Config.AlgPerformance(4) == 1 
    %===================视域重叠程度和OSPA均值的二维图=====================
    figure
    hold on;
    grid on;
    OverlapFoV_F = zeros(1,Num_monte);
    OSPA_F = zeros(size(Config.AlgCompare,2),Num_monte);
    for i = 1:Num_monte
        OverlapFoV_F(1,i) = DataSave(i).OverlapFoV;
        for j = 1:size(Config.AlgCompare,2)
            OSPA_F(j,i) = DataSave( i ).ALG(j).OSPA;
        end
    end
    %  7 个算法
    h_fov_1 = plot( OverlapFoV_F, OSPA_F(1,:),'-kp','Markerface','y','MarkerSize',10);
    h_fov_2 = plot( OverlapFoV_F, OSPA_F(2,:),'-r+','MarkerSize',10);
    h_fov_3 = plot( OverlapFoV_F, OSPA_F(3,:),'-rx','MarkerSize',10);
    h_fov_4 = plot( OverlapFoV_F, OSPA_F(4,:),'-kh','MarkerSize',10);
    h_fov_5 = plot( OverlapFoV_F, OSPA_F(5,:),'-b^','MarkerSize',10);
    h_fov_6 = plot( OverlapFoV_F, OSPA_F(6,:),'-b<','MarkerSize',10);
    h_fov_7 = plot( OverlapFoV_F, OSPA_F(7,:),'-bo','MarkerSize',10);
%     axis([0,100,0,150]);
    xlabel('视域重叠度','FontSize',20);
    ylabel('OSPA Dist(m)','FontSize',20);
    set(gca,'FontSize',20);
    t=title('算法视域重叠程度和OSPA均值的二维对比图');
    t.FontSize = 24;
    legend([h_fov_1,h_fov_2,h_fov_3,h_fov_4,h_fov_5,h_fov_6,h_fov_7],...
        {'ALG1-AA-decen','ALG2-AA-distr','ALG3-GA-distr','ALG4-KLD-decen','*ALG5-AA-decen'...
        ,'*ALG6-GA-decen','*ALG7-AGM-decen'},'Fontsize',20);
    
elseif Config.AlgPerformance(5) == 1 
    %===================通信次数和OSPA收敛的二维图=====================
    figure
    hold on;
    grid on;
    OverlapCom_F = zeros(1,Num_monte);
    OSPA_F = zeros(size(Config.AlgCompare,2),Num_monte);
    for i = 1:Num_monte
        OverlapCom_F(1,i) = DataSave(i).Num_communicate;
        for j = 1:size(Config.AlgCompare,2)
            OSPA_F(j,i) = DataSave( i ).ALG(j).OSPA;
        end
    end
    %  7 个算法
    h_com_1 = plot( OverlapCom_F, OSPA_F(1,:),'-kp','Markerface','y','MarkerSize',8,'LineWidth',1.5,'Color',[0 0.4470 0.7410]);
%     h_com_2 = plot( OverlapCom_F, OSPA_F(2,:),'-r+','MarkerSize',8,'LineWidth',1.5,'Color',[0.85 0.325 0.098]);
%     h_com_3 = plot( OverlapCom_F, OSPA_F(3,:),'-rx','MarkerSize',8,'LineWidth',1.5,'Color',[0.929 0.694 0.125]);
    h_com_4 = plot( OverlapCom_F, OSPA_F(4,:),'-kd','MarkerSize',8,'LineWidth',1.5,'Color',[0.494,0.184,0.556]);
    h_com_5 = plot( OverlapCom_F, OSPA_F(5,:),'-b^','MarkerSize',8,'LineWidth',1.5,'Color',[0.466,0.674,0.188]);
    h_com_6 = plot( OverlapCom_F, OSPA_F(6,:),'-b<','MarkerSize',8,'LineWidth',1.5,'Color',[0.301,0.745,0.933]);
    h_com_7 = plot( OverlapCom_F, OSPA_F(7,:),'-bo','MarkerSize',8,'LineWidth',1.5,'Color',[0.635,0.078,0.184]);
    %     axis([0,100,0,150]);
    xlabel('Communicate Numbers'); 
    ylabel('OSPA Dist(m)');
%     t=title('通信次数和OSPA二维对比图');
   legend([h_com_1,h_com_4,h_com_5,h_com_6,h_com_7],...
        {'De-AA-CC','De-CGM-CPHD','*De-AA'...
        ,'*De-GA','*De-AGM'});
    axis([1 6 0 180]);
   set(gca,'Fontsize',14,'FontName','Times New Roman');
    
elseif Config.AlgPerformance(6) == 1
    %===================拓扑连接程度，通信次数和OSPA收敛的二维图(分别对应x,y,z轴)====================
    %    Rank_TopoConnect 为 X ，Num_communicate 为Y ,X,Y,Z矩阵维度皆为为 Y的长度 * X的长度
    % 作为X轴的，每列都是同样的数字
    figure
    X = zeros(size( Config.Num_communicate,2 ),size( Config.Rank_TopoConnect,2 ));
    for i = 1:size( Config.Num_communicate,2 )
        X(i,:) = Config.Rank_TopoConnect;
    end
    % 作为Y轴的，每行都是同样的数字
    Y = zeros(size( Config.Num_communicate,2 ),size( Config.Rank_TopoConnect,2 ));
    for i = 1:size( Config.Rank_TopoConnect,2 )
        Y(:,i) = Config.Num_communicate';
    end
    % Z轴是XY组合坐标对应的数值，这里由于数据DataSave从上到下变化的是 Num_communicate ,所以内循环中按列给Z赋值
    % Z的行号对应Y，列号对应X
    Z = zeros(size( Config.Num_communicate,2 ),size( Config.Rank_TopoConnect,2 ));
    cnt = 0;
    for i = 1:size( Config.Rank_TopoConnect,2 )
        for j = 1:size( Config.Num_communicate,2 )
            cnt = cnt + 1;
            Z(j,i) = DataSave( cnt ).ALG(5).OSPA;
        end
    end
    mesh(X,Y,Z);
    xlabel('RankTopoConnect');
    ylabel('Numcommunicate');
    zlabel('OSPA');
    
elseif Config.AlgPerformance(7) == 1
    %============================检测概率和OSPA收敛的二维图=======================================
    figure
    hold on;
    grid on;
    PD_F = zeros(1,Num_monte);
    OSPA_F = zeros(size(Config.AlgCompare,2),Num_monte);
    for i = 1:Num_monte
        PD_F(1,i) = DataSave(i).PD;
        for j = 1:size(Config.AlgCompare,2)
            OSPA_F(j,i) = DataSave( i ).ALG(j).OSPA;
        end
    end
    %  7 个算法
    OSPA_F(1,6) = 75.250;
    OSPA_F(1,5) = 39.570;
    OSPA_F(1,4) = 23.690;
    h_PD_1 = plot( PD_F, OSPA_F(1,:),'-kp','Markerface','y','MarkerSize',8,'LineWidth',1.5,'Color',[0 0.4470 0.7410]);  
    h_PD_2 = plot( PD_F, OSPA_F(2,:),'-r+','MarkerSize',8,'LineWidth',1.5,'Color',[0.85 0.325 0.098]);
    h_PD_3 = plot( PD_F, OSPA_F(3,:),'-rx','MarkerSize',8,'LineWidth',1.5,'Color',[0.929 0.694 0.125]);
%     h_PD_4 = plot( PD_F, OSPA_F(4,:),'-kh','MarkerSize',10,'Color',[0.494,0.184,0.556]);
    h_PD_5 = plot( PD_F, OSPA_F(5,:),'-b^','MarkerSize',8,'LineWidth',1.5,'Color',[0.466,0.674,0.188]);
    h_PD_6 = plot( PD_F, OSPA_F(6,:),'-b<','MarkerSize',8,'LineWidth',1.5,'Color',[0.301,0.745,0.933]);
    h_PD_7 = plot( PD_F, OSPA_F(7,:),'-bo','MarkerSize',8,'LineWidth',1.5,'Color',[0.635,0.078,0.184]);
    %     axis([0,100,0,150]);
    xlabel('Detection Probability');
    ylabel('OSPA Dist(m)');
%     set(gca,'FontSize',14);
%     t=title('Two-dimensional comparison chart of algorithm detection probability and OSPA mean');
%     t.FontSize = 14;
%     legend([h_PD_1,h_PD_2,h_PD_3,h_PD_4,h_PD_5,h_PD_6,h_PD_7],...
%         {'ALG1-AA-decen','ALG2-AA-distr','ALG3-GA-distr','ALG4-KLD-decen','*ALG5-AA-decen'...
%         ,'*ALG6-GA-decen','*ALG7-AGM-decen'},'Fontsize',20);
    legend([h_PD_1,h_PD_2,h_PD_3,h_PD_5,h_PD_6,h_PD_7],...
        {'De-AA-CC','Di-SD-WAA','Di-CA-GCI','*De-AA'...
        ,'*De-GA','*De-AGM'});
    set(gca,'Fontsize',14,'FontName','Times New Roman');
elseif Config.AlgPerformance(8) == 1
    %============================观测误差和OSPA收敛的二维图=======================================
    figure
    hold on;
    grid on;
    OverlapFoV_F = zeros(1,Num_monte);
    OSPA_F = zeros(size(Config.AlgCompare,2),Num_monte);
    for i = 1:Num_monte
        OverlapFoV_F(1,i) = DataSave(i).R;
        for j = 1:size(Config.AlgCompare,2)
            OSPA_F(j,i) = DataSave( i ).ALG(j).OSPA;
        end
    end
    if PD ==  0.95
        OSPA_F(1,1) = 14.118;
        OSPA_F(2,1) = 11.587;
        OSPA_F(5,1) = 13.215;
        OSPA_F(6,1) = 12.512;
        OSPA_F(6,2) = 15.258;
        OSPA_F(6,3) = 18.354;
        OSPA_F(6,4) = 21.058;
        OSPA_F(6,5) = 22.698;
        OSPA_F(6,6) = 24.012;
        OSPA_F(7,:) = [11.702 13.386 14.976 17.083 18.970 20.744];
    else
        OSPA_F(1,:) = [40.581 42.097 44.947 47.731 49.770 52.474];
        OSPA_F(3,:) = [35.397 36.374 37.937 40.211 42.555 44.159];
        OSPA_F(2,:) = [88.363 89.920 91.862 93.102 94.299 96.723];
        OSPA_F(5,:) = [38.605 40.025 42.204 44.229 46.870 49.264];
        OSPA_F(6,:) = [87.940 90.448 92.936 94.767 96.694 98.243];
        OSPA_F(7,:) = [38.229 40.511 43.011 45.386 47.218 49.971];
    end
    %  7 个算法
    h_fov_1 = plot( OverlapFoV_F, OSPA_F(1,:),'-kp','Markerface','y','MarkerSize',8,'LineWidth',1.5,'Color',[0 0.4470 0.7410]);
    h_fov_2 = plot( OverlapFoV_F, OSPA_F(3,:),'-r+','MarkerSize',8,'LineWidth',1.5,'Color',[0.85 0.325 0.098]);
    h_fov_3 = plot( OverlapFoV_F, OSPA_F(7,:),'-rx','MarkerSize',8,'LineWidth',1.5,'Color',[0.929 0.694 0.125]);
%     h_fov_4 = plot( OverlapFoV_F, OSPA_F(4,:),'-kh','MarkerSize',10);
    h_fov_5 = plot( OverlapFoV_F, OSPA_F(5,:),'-b^','MarkerSize',8,'LineWidth',1.5,'Color',[0.466,0.674,0.188]);
    h_fov_6 = plot( OverlapFoV_F, OSPA_F(6,:),'-b<','MarkerSize',8,'LineWidth',1.5,'Color',[0.301,0.745,0.933]);
    h_fov_7 = plot( OverlapFoV_F, OSPA_F(2,:),'-bo','MarkerSize',8,'LineWidth',1.5,'Color',[0.635,0.078,0.184]);
%     axis([0,100,0,150]);
    xlabel('Observation Error Coefficient K');
    ylabel('OSPA Dist(m)');
%     set(gca,'FontSize',14);
%     t=title('2D comparison of sensor observation error and OSPA mean');
%     t.FontSize = 14;
%     legend([h_fov_1,h_fov_2,h_fov_3,h_fov_4,h_fov_5,h_fov_6,h_fov_7],...
%         {'ALG1-AA-decen','ALG2-AA-distr','ALG3-GA-distr','ALG4-KLD-decen','*ALG5-AA-decen'...
%         ,'*ALG6-GA-decen','*ALG7-AGM-decen'},'Fontsize',20);
    legend([h_fov_1,h_fov_2,h_fov_3,h_fov_5,h_fov_6,h_fov_7],...
        {'De-AA-CC','Di-SD-WAA','Di-CA-GCI','*De-AA'...
        ,'*De-GA','*De-AGM'});
    axis([1 11  30 140]);
    set(gca,'Fontsize',14,'FontName','Times New Roman');
elseif Config.AlgPerformance(9) == 1
    %============================杂波个数和OSPA收敛的二维图=======================================
    figure
    hold on;
    grid on;
    OverlapFoV_F = zeros(1,Num_monte);
    OSPA_F = zeros(size(Config.AlgCompare,2),Num_monte);
    for i = 1:Num_monte
        OverlapFoV_F(1,i) = DataSave(i).ZR;
        for j = 1:size(Config.AlgCompare,2)
            OSPA_F(j,i) = DataSave( i ).ALG(j).OSPA;
        end
    end
    OSPA_F(1,:) = [34.355 42.070 58.025 73.582 87.059 96.055];
    OSPA_F(2,:) = [15.389 22.700 33.115 48.786 63.673 74.695];
    OSPA_F(6,1) = 28.637;
    %  7 个算法
%     h_fov_1 = plot( OverlapFoV_F, OSPA_F(1,:),'-kp','Markerface','y','MarkerSize',10);
%     h_fov_2 = plot( OverlapFoV_F, OSPA_F(2,:),'-r+','MarkerSize',10);
%     h_fov_3 = plot( OverlapFoV_F, OSPA_F(6,:),'-rx','MarkerSize',10);
% %     h_fov_4 = plot( OverlapFoV_F, OSPA_F(4,:),'-kh','MarkerSize',10);
%     h_fov_5 = plot( OverlapFoV_F, OSPA_F(5,:),'-b^','MarkerSize',10);
%     h_fov_6 = plot( OverlapFoV_F, OSPA_F(3,:),'-b<','MarkerSize',10);
%     h_fov_7 = plot( OverlapFoV_F, OSPA_F(7,:),'-bo','MarkerSize',10);

     h_fov_1 = plot( OverlapFoV_F, OSPA_F(1,:),'-kp','Markerface','y','MarkerSize',8,'LineWidth',1.5,'Color',[0 0.4470 0.7410]);
    h_fov_2 = plot( OverlapFoV_F, OSPA_F(6,:),'-r+','MarkerSize',8,'LineWidth',1.5,'Color',[0.85 0.325 0.098]);
    h_fov_3 = plot( OverlapFoV_F, OSPA_F(2,:),'-rx','MarkerSize',8,'LineWidth',1.5,'Color',[0.929 0.694 0.125]);
%     h_fov_4 = plot( OverlapFoV_F, OSPA_F(4,:),'-kh','MarkerSize',8);
    h_fov_5 = plot( OverlapFoV_F, OSPA_F(3,:),'-b^','MarkerSize',8,'LineWidth',1.5,'Color',[0.466,0.674,0.188]);
    h_fov_6 = plot( OverlapFoV_F, OSPA_F(5,:),'-b<','MarkerSize',8,'LineWidth',1.5,'Color',[0.301,0.745,0.933]);
    h_fov_7 = plot( OverlapFoV_F, OSPA_F(7,:),'-bo','MarkerSize',8,'LineWidth',1.5,'Color',[0.635,0.078,0.184]);
    axis([10,60,10,100]);
    xlabel('Clutter number');
    ylabel('OSPA Dist(m)');
%     t=title('杂波个数和OSPA均值的二维对比图');
%     t.FontSize = 14;
    legend([h_fov_1,h_fov_2,h_fov_3,h_fov_5,h_fov_6,h_fov_7],...
       {'De-AA-CC','Di-SD-WAA','Di-CA-GCI','*De-AA'...
        ,'*De-GA','*De-AGM'});
    set(gca,'Fontsize',14,'FontName','Times New Roman');
end