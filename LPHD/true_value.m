[Xreal_target_time,Xreal_time_target] = targetset(N,Set_TargetState);
%�������ɹ۲�ֵ
Xreal_time_target_copy = Xreal_time_target;
%ɾ����ʵĿ���е�NaNֵ
for t=1:N
    Xreal_time_target_copy{t,1}(:,isnan(Xreal_time_target_copy{t,1}(1,:))) = [];
end
% =======����ÿ��ʱ����ʵĿ����Ŀ=======
num_real = zeros(1,N); % ȫ����ʵĿ����Ŀ
for t=1:N
    num_real(1,t) = size(Xreal_time_target_copy{t,1},2);
end