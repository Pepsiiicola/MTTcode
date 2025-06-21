function [metric_history] = ALG1_ospa_metric(X,k,Target1,Target1_birth_time,Target1_end_time,Target2,Target3,cutoff_c,order_p,metric_history)
%*****************************
%    计算ospa指标函数
%输入参数：滤波估计状态X,时刻k
%输入参数：真实轨迹Target1，Target1_birth_time Target1_end_time，Target2，Target3
%输入参数：ospa两参数c与p
%输入参数：截止k时刻的指标metric_history
%输出参数：metric_history
%*****************************
if k>=Target1_birth_time && k<=Target1_end_time
    Y = [Target1(:,k-Target1_birth_time+1),Target2(:,k),Target3(:,k)];
else
    Y=[Target2(:,k),Target3(:,k)];
end
% if k>=1 && k<Target1_birth_time
%     Y = [Target2(:,k),Target3(:,k),Target5(:,k),Target6(:,k)];
% elseif k>=Target1_birth_time && k<Target4_birth_time
%     Y = [Target1(:,k-Target1_birth_time+1),Target2(:,k),Target3(:,k),Target5(:,k),Target6(:,k)];
% elseif k>=Target4_birth_time && k<=Target1_end_time
%     Y = [Target1(:,k-Target1_birth_time+1),Target2(:,k),Target3(:,k),Target4(:,k-Target4_birth_time+1),Target5(:,k),Target6(:,k)];
% elseif k>Target1_end_time && k<=Target4_end_time
%     Y = [Target2(:,k),Target3(:,k),Target4(:,k-Target4_birth_time+1),Target5(:,k),Target6(:,k)];
% else 
%     Y = [Target2(:,k),Target3(:,k),Target5(:,k),Target6(:,k)];
% end

    metric = ospa_dist(X, Y, cutoff_c, order_p);
    metric_history = [metric_history, metric];
    
end

