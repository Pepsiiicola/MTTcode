%{
                  三种评价指标的出图脚本
        1.OSPA
        2.数量
        3.计算量
%}

%========定义一个颜色矩阵======
% colorMatrix = [
%                122/255 115/255 116/255; %梓灰
%                138/255 188/255 209/255; %秋波石蓝
%                195/255  86/255 145/255; %电气石红
%                 18/255 170/255 156/255; %美碟绿
%                228/255 191/255  17/255; %香蕉黄
%                255/255 153/255   0/255; %雄黄 
%                126/255  22/255 113/255; %魏紫
%                250/255 134/255   0/255; %橘色
%                 85/255 187/255 138/255; %麦苗绿
%                150/255 194/255  78/255; %芽绿
%                244/255 241/255 222/255; %奶白
%                 86/255 152/255 195/255; %晴蓝
%                239/255  65/255  67/255; %鲜红 
%                193/255  18/255  33/255; %暗红 
%                235/255  38/255  26/255; %丽春红
%                 21/255  85/255 154/255; %海涛蓝 
%                237/255  51/255  33/255; %樱桃红
%                ];

% rgbTriplet =  [0.00, 0.36, 0.67;...
%     0.68, 0.42, 0.89;...
%     0.44, 0.62, 0.98;...
%     0.10, 0.67, 0.59;...
%     0.99, 0.57, 0.59;...
%     0.28, 0.55, 0.86;...
%     0.96, 0.62, 0.24;...
%     0.30, 0.90, 0.56;...
%     0.12, 0.46, 0.71;...
%     0.46, 0.63, 0.90;...
%     0.96, 0.37, 0.40;...
%     0.14, 0.76, 0.71;...
%     0.99, 0.50, 0.02;...
%     0.00, 0.57, 0.76;...
%     0.35, 0.90, 0.89;...
%     0.17, 0.62, 0.47;...
%     0.21, 0.21, 0.67;...
%     0.99, 0.49, 0.00;...
%     0.98, 0.74, 0.44;...
%     0.97, 0.60, 0.58;...
%     0.18, 0.62, 0.17;...
%     0.68, 0.87, 0.53;...
%     0.12, 0.46, 0.70;...
%     0.65, 0.79, 0.89;...
%     0.95, 0.99, 0.69;...
%     0.74, 0.92, 0.68;...
%     0.37, 0.81, 0.72;...
%     0.01, 0.72, 0.77];

% =====================搭配1===================
%
% ====================色系1(偏鲜明)=====================
rgbTriplet = [
              246 083 020;...
              124 187 000;...
              000 161 241;...
              255 187 000;...
              252, 41, 30;...
              250, 200, 205;...
               218,112,214;...
              054, 195, 201;...
              000, 070, 222;...
              250, 135, 0 ]/255;



%====================色系2(偏深暗)=====================
%    [
%         2/255 31/255  36/255；%藏青
%        19/255 59/255  64/255; %深青色
%         0/255 67/255  20/255; %黄橙色
%        94/255 39/255  29/255; %橘红色
%        24/255 17/255  43/255; %深紫
%     ]





colorMatrix = rgbTriplet;




% 如果此处算法未被选择，那么将会是全0的一条线
if Config.AlgPerformance(1) == 1 
  %*********************************  OSPA ************************************ 
    figure
    hold on;
    grid on;
    %  7 个算法\
%     MM_ALG(2).OSPA(34) = 9.3001;
%     MM_ALG(2).OSPA(35) = 9.7211;
%     MM_ALG(2).OSPA(50) = 9.3001;
%     MM_ALG(2).OSPA(51) = 9.7211;
%     MM_ALG(2).OSPA(56) = 9.7211;
%     MM_ALG(2).OSPA(77) = 14.0211;
    h_ospa_1 = plot( MM_ALG(1).OSPA,'-*','color',colorMatrix(1,:),'MarkerSize',6,'LineWidth',1.2);

    h_ospa_2 = plot( MM_ALG(2).OSPA,'-^','color',colorMatrix(2,:),'MarkerSize',6,'LineWidth',1.2);

    h_ospa_10 = plot( MM_ALG(10).OSPA,'-<','color',colorMatrix(10,:),'MarkerSize',6,'LineWidth',1.2);

    h_ospa_3 = plot( MM_ALG(3).OSPA,'-x','color',colorMatrix(3,:),'MarkerSize',6,'LineWidth',1.2);

    h_ospa_4 = plot( MM_ALG(4).OSPA,'-d','color',colorMatrix(4,:),'MarkerSize',6,'LineWidth',1.2);

    h_ospa_5 = plot( MM_ALG(5).OSPA,'->','color',colorMatrix(5,:),'MarkerSize',6,'LineWidth',1.2);

    h_ospa_6 = plot( MM_ALG(6).OSPA,'-<','color',colorMatrix(6,:),'MarkerSize',6,'LineWidth',1.2);

    h_ospa_7 = plot( MM_ALG(7).OSPA,'-o','color',colorMatrix(7,:),'MarkerSize',6,'LineWidth',1.2);

    h_ospa_8 = plot( MM_ALG(8).OSPA,'-s','color',colorMatrix(8,:),'MarkerSize',6,'LineWidth',1.2);

    h_ospa_9 = plot( MM_ALG(9).OSPA,'-v','color',colorMatrix(9,:),'MarkerSize',6,'LineWidth',1.2);

    
    axis([0,100,0,150]);
%分散式项目要求
%     h_ospa_1 = plot( MM_ALG(1).OSPA,'-*r');
%     h_ospa_4 = plot( MM_ALG(4).OSPA,'-*b');
%     h_ospa_5 = plot( MM_ALG(5).OSPA,'-*g');
    xlabel('Time Step','FontSize',14);
    ylabel('OSPA Dist(m)','FontSize',14);
    set(gca,'FontSize',14);
    t=title('Algorithm global OSPA comparison');
    t.FontSize = 14;
    legend([h_ospa_1,h_ospa_2,h_ospa_3,h_ospa_4,h_ospa_5,h_ospa_6,h_ospa_7,h_ospa_8,h_ospa_9,h_ospa_10],...
        {'De-AA-CC','Di-SD-WAA','Di-CA-GCI','De-CGM-CPHD','*De-AA'...
        ,'*De-GA','*De-AGM','*De-Flood','*De-AGM2.0','*De-BIRD'},'NumColumns',3,'Box','off','Location','Northeast','Fontsize',12);
    set(gca,'Fontsize',12,'FontName','Times New Roman');
% 分散式项目画图要求
%     legend([h_ospa_1,h_ospa_4,h_ospa_5],...
%         {'De-AA-CC(2019-Tiancheng Li)','De-CGM-CPHD(2013-G.Battistelli)','*De-AA(2022-课题组提出)'},'Fontsize',18);
%         axis([0,100,0,150]);
    
    % =========== 文字输出 ============
    for i=1:size(Config.AlgCompare,2)
%         err_num = abs ( MM_ALG(i).Num_estimate - num_real );
        INF_SHOW = ['算法【',num2str(i),'】的【OSPA均值】为 ',num2str( DataSave(1).ALG(i).OSPA ),...
                    '算法【',num2str(i),'】的【数量估计误差】为 ',num2str(DataSave(1).ALG(i).Err_num)];
        disp( INF_SHOW );
    end
end 
    
if Config.AlgPerformance(2) == 1 
    %*********************************  全局数量 *************************************************
    figure
    hold on;
    grid on;
    
    h_real = plot(num_real,'-k.'); % 全局目标数量真实值
    
    %  7 个算法
    h_num_1 = plot( MM_ALG(1).Num_estimate,'-*','color',colorMatrix(1,:),'MarkerSize',6,'LineWidth',1.2);
    h_num_2 = plot( MM_ALG(2).Num_estimate,'-^','color',colorMatrix(2,:),'MarkerSize',6,'LineWidth',1.2);
    h_num_10 = plot( MM_ALG(10).Num_estimate,'-<','color',colorMatrix(10,:),'MarkerSize',6,'LineWidth',1.2);
    h_num_3 = plot( MM_ALG(3).Num_estimate,'-x','color',colorMatrix(3,:),'MarkerSize',6,'LineWidth',1.2);
    h_num_4 = plot( MM_ALG(4).Num_estimate,'-d','color',colorMatrix(4,:),'MarkerSize',6,'LineWidth',1.2);
    h_num_5 = plot( MM_ALG(5).Num_estimate,'->','color',colorMatrix(5,:),'MarkerSize',6,'LineWidth',1.2);
    h_num_6 = plot( MM_ALG(6).Num_estimate,'-<','color',colorMatrix(6,:),'MarkerSize',6,'LineWidth',1.2);
    h_num_7 = plot( MM_ALG(7).Num_estimate,'-o','color',colorMatrix(7,:),'MarkerSize',6,'LineWidth',1.2);
    h_num_8 = plot( MM_ALG(8).Num_estimate,'-s','color',colorMatrix(8,:),'MarkerSize',6,'LineWidth',1.2);
    h_num_9 = plot( MM_ALG(9).Num_estimate,'-v','color',colorMatrix(9,:),'MarkerSize',6,'LineWidth',1.2);
    
    %分散式项目要求
%     h_ospa_1 = plot( MM_ALG(1).Num_estimate,'-*r');
%     h_ospa_4 = plot( MM_ALG(4).Num_estimate,'-*b');
%     h_ospa_5 = plot( MM_ALG(5).Num_estimate,'-*g');
    
%     axis([0,100,0,11]);
    xlabel('Time Step','FontSize',14);
    ylabel('Cardinality','FontSize',14);
    set(gca,'FontSize',14);
    t=title('Algorithm target number estimation comparison');
    t.FontSize = 14;
    legend([h_real,h_num_1,h_num_2,h_num_3,h_num_4,h_num_5,h_num_6,h_num_7,h_num_8,h_num_9,h_num_10],...
        {'Real Target Number','De-AA-CC','Di-SD-WAA','Di-CA-GCI','De-CGM-CPHD','*De-AA'...
        ,'*De-GA','*De-AGM','*De-Flood','*De-AGM2.0','*De-BIRD'},'NumColumns',2,'Box','off','Location','Southeast','Fontsize',12); 
    set(gca,'Fontsize',12,'FontName','Times New Roman');

    % 分散式项目画图要求
%     legend([h_ospa_1,h_ospa_4,h_ospa_5],...
%         {'De-AA-CC(2019-Tiancheng Li)','De-CGM-CPHD(2013-G.Battistelli)','*De-AA(2022-课题组提出)'},'Fontsize',18);
%         axis([0,100,0,15]);

end  

if Config.AlgPerformance(3) == 1
    %*********************************  计算时间 *************************************************  
    % =========== 文字输出 ============
    for i=1:size(Config.AlgCompare,2)
        INF_SHOW = ['算法【',num2str(i),'】的【单融合周期消耗时间】为 ',num2str( 1000*DataSave(1).ALG(i).Time),' 毫秒'];
        disp( INF_SHOW );
    end
 
end