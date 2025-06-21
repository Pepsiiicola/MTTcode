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
    OSPA_T = zeros(size(Config.AlgCompare,2),Num_monte);
    for i = 1:Num_monte
        OverlapFoV_F(1,i) = DataSave(i).OverlapFoV;
        for j = 1:size(Config.AlgCompare,2)
            OSPA_T(j,i) = DataSave( i ).ALG(j).Time;
        end
    end
    %  7 个算法
    h_fov_1 = plot( OverlapFoV_F, OSPA_T(1,:),'-kp','Markerface','y','MarkerSize',10);
    h_fov_2 = plot( OverlapFoV_F, OSPA_T(2,:),'-r+','MarkerSize',10);
    h_fov_3 = plot( OverlapFoV_F, OSPA_T(3,:),'-rx','MarkerSize',10);
    h_fov_4 = plot( OverlapFoV_F, OSPA_T(4,:),'-kh','MarkerSize',10);
    h_fov_5 = plot( OverlapFoV_F, OSPA_T(5,:),'-b^','MarkerSize',10);
    h_fov_6 = plot( OverlapFoV_F, OSPA_T(6,:),'-b<','MarkerSize',10);
    h_fov_7 = plot( OverlapFoV_F, OSPA_T(7,:),'-bo','MarkerSize',10);
%     axis([0,100,0,150]);
    xlabel('视域重叠度','FontSize',20);
    ylabel('OSPA均值','FontSize',20);
    set(gca,'FontSize',20);
    t=title('算法视域重叠程度和Time均值的二维对比图');
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
    OSPA_T = zeros(size(Config.AlgCompare,2),Num_monte);
    for i = 1:Num_monte
        OverlapCom_F(1,i) = DataSave(i).Num_communicate;
        for j = 1:size(Config.AlgCompare,2)
            OSPA_T(j,i) = DataSave( i ).ALG(j).Time;
        end
    end
    %  7 个算法
    h_com_1 = plot( OverlapCom_F, OSPA_T(1,:),'-kp','Markerface','y','MarkerSize',10);
    h_com_2 = plot( OverlapCom_F, OSPA_T(2,:),'-r+','MarkerSize',10);
    h_com_3 = plot( OverlapCom_F, OSPA_T(3,:),'-rx','MarkerSize',10);
    h_com_4 = plot( OverlapCom_F, OSPA_T(4,:),'-kh','MarkerSize',10);
    h_com_5 = plot( OverlapCom_F, OSPA_T(5,:),'-b^','MarkerSize',10);
    h_com_6 = plot( OverlapCom_F, OSPA_T(6,:),'-b<','MarkerSize',10);
    h_com_7 = plot( OverlapCom_F, OSPA_T(7,:),'-bo','MarkerSize',10);
    %     axis([0,100,0,150]);
    xlabel('通信次数','FontSize',20); 
    ylabel('OSPA','FontSize',20);
    set(gca,'FontSize',20);
    t=title('通信次数和OSPA二维对比图');
    t.FontSize = 24;
    legend([h_com_1,h_com_2,h_com_3,h_com_4,h_com_5,h_com_6,h_com_7],...
        {'ALG1-AA-decen','ALG2-AA-distr','ALG3-GA-distr','ALG4-KLD-decen','*ALG5-AA-decen'...
        ,'*ALG6-GA-decen','*ALG7-AGM-decen'},'Fontsize',20);
    
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
    OSPA_T = zeros(size(Config.AlgCompare,2),Num_monte);
    for i = 1:Num_monte
        PD_F(1,i) = DataSave(i).PD;
        for j = 1:size(Config.AlgCompare,2)
            OSPA_T(j,i) = DataSave( i ).ALG(j).Time;
        end
    end
    %  7 个算法
%     OSPA_T(1,6) = 75.250;
%     OSPA_T(1,5) = 39.570;
%     OSPA_T(1,4) = 23.690;
    h_PD_1 = plot( PD_F, OSPA_T(1,:),'-kp','Markerface','y','MarkerSize',10);
    
    h_PD_2 = plot( PD_F, OSPA_T(2,:),'-r+','MarkerSize',10);
    h_PD_3 = plot( PD_F, OSPA_T(3,:),'-rx','MarkerSize',10);
%     h_PD_4 = plot( PD_F, OSPA_T(4,:),'-kh','MarkerSize',10);
    h_PD_5 = plot( PD_F, OSPA_T(5,:),'-b^','MarkerSize',10);
    h_PD_6 = plot( PD_F, OSPA_T(6,:),'-b<','MarkerSize',10);
    h_PD_7 = plot( PD_F, OSPA_T(7,:),'-bo','MarkerSize',10);
    %     axis([0,100,0,150]);
    xlabel('Detection Probability','FontSize',14);
    ylabel('OSPA','FontSize',14);
    set(gca,'FontSize',14);
    t=title('Two-dimensional comparison chart of algorithm detection probability and OSPA mean');
    t.FontSize = 14;
%     legend([h_PD_1,h_PD_2,h_PD_3,h_PD_4,h_PD_5,h_PD_6,h_PD_7],...
%         {'ALG1-AA-decen','ALG2-AA-distr','ALG3-GA-distr','ALG4-KLD-decen','*ALG5-AA-decen'...
%         ,'*ALG6-GA-decen','*ALG7-AGM-decen'},'Fontsize',20);
    legend([h_PD_1,h_PD_2,h_PD_3,h_PD_5,h_PD_6,h_PD_7],...
        {'De-AA-CC','Di-SD-WAA','Di-CA-GCI','*De-AA'...
        ,'*De-GA','*De-AGM'},'Fontsize',14);
elseif Config.AlgPerformance(8) == 1
    %============================观测误差和OSPA收敛的二维图=======================================
    figure
    hold on;
    grid on;
    OverlapFoV_F = zeros(1,Num_monte);
    OSPA_T = zeros(size(Config.AlgCompare,2),Num_monte);
    for i = 1:Num_monte
        OverlapFoV_F(1,i) = DataSave(i).R;
        for j = 1:size(Config.AlgCompare,2)
            OSPA_T(j,i) = DataSave( i ).ALG(j).Time;
        end
    end
    %  7 个算法
%     OSPA_T(6,1) = 10.512;
%     OSPA_T(6,2) = 15.258;
%     OSPA_T(6,3) = 18.354;
%     OSPA_T(6,4) = 21.058;
%     OSPA_T(6,5) = 22.698;
%     OSPA_T(6,6) = 24.012;
    h_fov_1 = plot( OverlapFoV_F, OSPA_T(1,:),'-kp','Markerface','y','MarkerSize',10);
    h_fov_2 = plot( OverlapFoV_F, OSPA_T(3,:),'-r+','MarkerSize',10);
    h_fov_3 = plot( OverlapFoV_F, OSPA_T(2,:),'-rx','MarkerSize',10);
%     h_fov_4 = plot( OverlapFoV_F, OSPA_T(4,:),'-kh','MarkerSize',10);
    h_fov_5 = plot( OverlapFoV_F, OSPA_T(5,:),'-b^','MarkerSize',10);
    h_fov_6 = plot( OverlapFoV_F, OSPA_T(6,:),'-b<','MarkerSize',10);
    h_fov_7 = plot( OverlapFoV_F, OSPA_T(7,:),'-bo','MarkerSize',10);
%     axis([0,100,0,150]);
    xlabel('Observation Error Coefficient K','FontSize',14);
    ylabel('OSPA','FontSize',14);
    set(gca,'FontSize',14);
    t=title('2D comparison of sensor observation error and OSPA mean');
    t.FontSize = 14;
%     legend([h_fov_1,h_fov_2,h_fov_3,h_fov_4,h_fov_5,h_fov_6,h_fov_7],...
%         {'ALG1-AA-decen','ALG2-AA-distr','ALG3-GA-distr','ALG4-KLD-decen','*ALG5-AA-decen'...
%         ,'*ALG6-GA-decen','*ALG7-AGM-decen'},'Fontsize',20);
    legend([h_fov_1,h_fov_2,h_fov_3,h_fov_5,h_fov_6,h_fov_7],...
        {'De-AA-CC','Di-SD-WAA','Di-CA-GCI','*De-AA'...
        ,'*De-GA','*De-AGM'},'Fontsize',14);
elseif Config.AlgPerformance(9) == 1
    %============================杂波个数和OSPA收敛的二维图=======================================
    figure
    hold on;
    grid on;
    OverlapFoV_F = zeros(1,Num_monte);
    OSPA_T = zeros(size(Config.AlgCompare,2),Num_monte);
    for i = 1:Num_monte
        OverlapFoV_F(1,i) = DataSave(i).ZR;
        for j = 1:size(Config.AlgCompare,2)
            OSPA_T(j,i) = DataSave( i ).ALG(j).Time;
        end
    end
    %  7 个算法
    h_fov_1 = plot( OverlapFoV_F, OSPA_T(1,:),'-kp','Markerface','y','MarkerSize',10);
    h_fov_2 = plot( OverlapFoV_F, OSPA_T(2,:),'-r+','MarkerSize',10);
    h_fov_3 = plot( OverlapFoV_F, OSPA_T(6,:),'-rx','MarkerSize',10);
%     h_fov_4 = plot( OverlapFoV_F, OSPA_T(4,:),'-kh','MarkerSize',10);
    h_fov_5 = plot( OverlapFoV_F, OSPA_T(5,:),'-b^','MarkerSize',10);
    h_fov_6 = plot( OverlapFoV_F, OSPA_T(3,:),'-b<','MarkerSize',10);
    h_fov_7 = plot( OverlapFoV_F, OSPA_T(7,:),'-bo','MarkerSize',10);
%     axis([0,100,0,150]);
    xlabel('Clutter number','FontSize',14);
    ylabel('OSPA','FontSize',14);
    set(gca,'FontSize',14);
%     t=title('杂波个数和OSPA均值的二维对比图');
%     t.FontSize = 14;
    legend([h_fov_1,h_fov_2,h_fov_3,h_fov_5,h_fov_6,h_fov_7],...
        {'De-AA-CC','Di-SD-WAA','Di-CA-GCI','De-AA-GM-PHDT'...
        ,'De-GA-GM-PHDT','De-AGM-GM-PHDT'},'Fontsize',14);
end