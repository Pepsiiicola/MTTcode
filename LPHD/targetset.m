%{
                       跟踪目标运动参数设置

         功能：根据设置仿真出目标所有时刻的运动状态

         输入：跟踪周期N，目标运动模式编号

         输出：1.Xreal_target_time -- 单个目标所有时刻的运动状态  
               2.Xreal_time_target -- 单个时刻所有目标的运动状态   

%}
function [Xreal_target_time,Xreal_time_target]=targetset(N,Target)

n_target=size(Target,2); % 目标数量
Xreal_target_time=cell(n_target,1); % 存放每个目标所有时刻的状态


%=====模拟真实值======
for i=1:n_target
    Xreal_target_time{i,1}=m1_CV(Target(:,i),N);
end

%====真实值格式转化，转化为单个时间所有真实目标状态的形式====
Xreal_time_target=cell(N,1);
for i=1:N
    for k=1:n_target
        Xreal_time_target{i,1}(:,k)=Xreal_target_time{k,1}(:,i);
    end
end

end

%*********************************************
%说明:模式1:匀速直线运动CV+扰动
%输入:1.目标的初始状态 2.仿真周期数 
%输出:1.所有成员所有时刻的运动状态，num_member*1的cell数组，其中每个cell为6*N的double数组
function [state]=m1_CV(initial_state,N)

%=====运动模型参数=====
T=1; % 周期
A=[1 T 0 0 0 0;0 1 0 0 0 0;0 0 1 T 0 0;0 0 0 1 0 0;0 0 0 0 1 T;0 0 0 0 0 1]; % 运动模型
Q=1e-3 * diag([1,0.01,1,0.01,1,0.01]); % 扰动

[dim_state,num_member]=size(initial_state); % 状态维数,成员数量
dim_state=dim_state-2; % 状态维数需要减去开始时间、终止时间、运动模式

member_state=cell(num_member,1); % 所有成员所有时刻的运动状态
for i=1:num_member
    member_state{i,1}=zeros(dim_state,N); % 预先声明内存
end

% 目标的真实轨迹生成
for i=1:num_member
    
    begin_time=initial_state(7,i); % 目标运动开始时间
    end_time=initial_state(8,i);   % 目标运动结束时间
    member_state{i,1}(:,1:begin_time-1)=nan(dim_state,begin_time-1); % 目标出现前时刻赋值
    member_state{i,1}(:,begin_time)=initial_state(1:6,i);            % 出现时刻初始值赋值
    for j=begin_time+1:end_time
        member_state{i,1}(:,j)=A*member_state{i,1}(:,j-1)+sqrtm(Q)*randn(6,1); % 运动仿真
    end
    member_state{i,1}(:,end_time+1:N)=nan(dim_state,N-end_time); % 目标消失后的时刻赋值
    
end
% 当前模式下每次只对一个目标进行仿真
state=member_state{1,1};
end





