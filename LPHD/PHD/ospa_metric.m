function [metric_history] = ospa_metric(X,k,Target1,Target1_birth_time,Target1_end_time,Target2,Target3,cutoff_c,order_p,metric_history)
%*****************************
%    ����ospaָ�꺯��
%����������˲�����״̬X,ʱ��k
%�����������ʵ�켣Target1��Target1_birth_time Target1_end_time��Target2��Target3
%���������ospa������c��p
%�����������ֹkʱ�̵�ָ��metric_history
%���������metric_history
%*****************************
if k>=Target1_birth_time && k<=Target1_end_time
    Y = [Target1(:,k-Target1_birth_time+1),Target2(:,k),Target3(:,k)];
else
    Y=[Target2(:,k),Target3(:,k)];
end
    metric = ospa_dist(X, Y, cutoff_c, order_p);
    metric_history = [metric_history, metric];
    
end

