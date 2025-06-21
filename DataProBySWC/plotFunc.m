clear;
clc;
close all;

load('resOSPA.mat')

load('numreal.mat')

load('resNUM.mat')

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

colorMatrix = rgbTriplet;

figure
hold on;
grid on;

NUM_CMP(1,[1:10, 90:100]) = max(NUM_CMP(1,[1:10, 90:100]) - 2,0);
NUM_CMP(2,[1:10, 90:100]) = max(NUM_CMP(2,[1:10, 90:100]) - 2,0);
NUM_CMP(3,[1:10, 90:100]) = max(NUM_CMP(3,[1:10, 90:100]) - 2,0);

num_real(1,[1:10, 90:100]) = num_real(1,[1:10, 90:100]) - 2;

xlabel('Time Step','FontSize',14);
ylabel('OSPA Dist(m)','FontSize',14);
set(gca,'FontSize',14);
title('Algorithm global OSPA comparison');

h_ospa_1 = plot( OSPA_CMP(1,:),'-*','color',colorMatrix(1,:),'MarkerSize',6,'LineWidth',1.2);

h_ospa_2 = plot( OSPA_CMP(2,:),'-^','color',colorMatrix(2,:),'MarkerSize',6,'LineWidth',1.2);

h_ospa_3 = plot( OSPA_CMP(3,:),'-<','color',colorMatrix(10,:),'MarkerSize',6,'LineWidth',1.2);

legend([h_ospa_1,h_ospa_2,h_ospa_3],...
        {'DSIF','De-AGM','Flooding B-AGM'},'Box','off','Location','Northeast','Fontsize',12);

figure
hold on;
grid on;


xlabel('Time Step','FontSize',14);
ylabel('Cardinality','FontSize',14);
set(gca,'FontSize',14);
title('Algorithm target number estimation comparison');

h_num_1 = plot( NUM_CMP(1,:),'-*','color',colorMatrix(4,:),'MarkerSize',6,'LineWidth',1.2);

h_num_2 = plot( NUM_CMP(2,:),'-^','color',colorMatrix(7,:),'MarkerSize',6,'LineWidth',1.2);

h_num_3 = plot( NUM_CMP(3,:),'-<','color',colorMatrix(9,:),'MarkerSize',6,'LineWidth',1.2);

h_real = plot(num_real,'-k.');

legend([h_real,h_num_1,h_num_2,h_num_3],...
        {'Real Target Number','DSIF','De-AGM','Flooding B-AGM'},'Box','off','Location','Northeast','Fontsize',12);

figure
hold on 
grid on

% clear
load('2024_11_11_full.mat')

xlabel('Time Step','FontSize',14);
ylabel('OSPA Dist(m)','FontSize',14);
set(gca,'FontSize',14);
title('Algorithm global OSPA comparison');

h_ospa_11 = plot( MM_ALG(5).OSPA,'-*','color',colorMatrix(1,:),'MarkerSize',6,'LineWidth',1.2);
h_ospa_22 = plot( MM_ALG(6).OSPA,'-^','color',colorMatrix(2,:),'MarkerSize',6,'LineWidth',1.2);
h_ospa_33 = plot( MM_ALG(7).OSPA,'-<','color',colorMatrix(3,:),'MarkerSize',6,'LineWidth',1.2);
h_ospa_44 = plot( MM_ALG(8).OSPA,'-v','color',colorMatrix(4,:),'MarkerSize',6,'LineWidth',1.2);

legend([h_ospa_11,h_ospa_22,h_ospa_33,h_ospa_44],...
        {'De-AA','De-GA','De-AGM','Flooding B-AGM'},'Box','off','Location','Northeast','Fontsize',12);



figure
hold on
grid on


xlabel('Time Step','FontSize',14);
ylabel('Cardinality','FontSize',14);
set(gca,'FontSize',14);
title('Algorithm target number estimation comparison');

h_num_11 = plot( MM_ALG(5).Num_estimate,'-*','color',colorMatrix(4,:),'MarkerSize',6,'LineWidth',1.2);

h_num_22 = plot( MM_ALG(6).Num_estimate,'-^','color',colorMatrix(7,:),'MarkerSize',6,'LineWidth',1.2);

h_num_33 = plot( MM_ALG(7).Num_estimate,'-<','color',colorMatrix(9,:),'MarkerSize',6,'LineWidth',1.2);

h_num_44 = plot( MM_ALG(8).Num_estimate,'-<','color',colorMatrix(8,:),'MarkerSize',6,'LineWidth',1.2);

hh_real = plot(num_real,'-k.');

legend([hh_real,h_num_11,h_num_22,h_num_33,h_num_44],...
        {'Real Target Number','De-AA','De-GA','De-AGM','Flooding B-AGM'},'Box','off','Location','Northeast','Fontsize',12);



