[Xreal_target_time,Xreal_time_target] = targetset(N,Set_TargetState);
%用于生成观测值
Xreal_time_target_copy = Xreal_time_target;
%删除真实目标中的NaN值
for t=1:N
    Xreal_time_target_copy{t,1}(:,isnan(Xreal_time_target_copy{t,1}(1,:))) = [];
end
% =======计算每个时刻真实目标数目=======
num_real = zeros(1,N); % 全局真实目标数目
for t=1:N
    num_real(1,t) = size(Xreal_time_target_copy{t,1},2);
end