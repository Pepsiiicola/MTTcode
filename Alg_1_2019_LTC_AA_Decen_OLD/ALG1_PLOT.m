            
%============»­´«¸ÐÆ÷¹Û²â·¶Î§==========%
w = -pi:0.001:pi;
x1 = Input(1).location(1) + Input(1).R_detect * cos(w);
y1 = Input(1).location(2) + Input(1).R_detect * sin(w);
x2 = Input(2).location(1) + Input(2).R_detect * cos(w);
y2 = Input(2).location(2) + Input(2).R_detect * sin(w);
x3 = Input(3).location(1) + Input(3).R_detect * cos(w);
y3 = Input(3).location(2) + Input(3).R_detect * sin(w);
x4 = Input(4).location(1) + Input(4).R_detect * cos(w);
y4 = Input(4).location(2) + Input(4).R_detect * sin(w);
x5 = Input(5).location(1) + Input(5).R_detect * cos(w);
y5 = Input(5).location(2) + Input(5).R_detect * sin(w);
x6 = Input(6).location(1) + Input(6).R_detect * cos(w);
y6 = Input(6).location(2) + Input(6).R_detect * sin(w);
x7 = Input(7).location(1) + Input(7).R_detect * cos(w);
y7 = Input(7).location(2) + Input(7).R_detect * sin(w);
figure
hold on;
box on;
plot(x1,y1);
plot(x2,y2);
plot(x3,y3);
plot(x4,y4);
plot(x5,y5);
plot(x6,y6);
plot(x7,y7);
plot(Xreal_target_time{1, 1}(1,:),Xreal_target_time{1, 1}(3,:),'k');
plot(Xreal_target_time{2, 1}(1,:),Xreal_target_time{2, 1}(3,:),'k');
plot(Xreal_target_time{3, 1}(1,:),Xreal_target_time{3, 1}(3,:),'k');
 plot(history(1,:),history(3,:),'go');
 axis([-3*Input(1).R_detect,3*Input(1).R_detect,-3*Input(1).R_detect,3*Input(1).R_detect]);
figure
plot(numTarget,'-b');
figure
plot(metric_history,'-ro');