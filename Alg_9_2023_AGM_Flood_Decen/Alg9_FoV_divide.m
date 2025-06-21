%{
                                 划分视域模块

           功能：根据传感器观测范围将目标划分视域

           输入: 1.state    -- 待划分视域的粒子集 (6*1cell)
                 2.location -- 传感器坐标(3*1数组)
                 3.r_detect -- 传感器检测范围

           输出: 1.in_FoV   -- 视域内粒子集（6*1cell)
                 2.out_FoV  -- 视域外粒子集（6*1cell）

%}
function [In_FoV,Out_FoV]=Alg9_FoV_divide(state,location,r_detect)
In_FoV = struct;
Out_FoV = struct;

%===========获取参数=============
% n_state=state{4,1}; % 粒子个数
n_state = size(state.m,2); % 粒子个数
cnt_in=0;  % 视域内粒子数计数
cnt_out=0; % 视域外粒子数计数
dir_in=zeros(1,n_state);  % 转入视域内的粒子目录
dir_out=zeros(1,n_state); % 转入视域外的粒子目录

%====视域判断====
for i=1:n_state
    flag_FoV=FoV_judgefun(location,state.m(:,i),r_detect);
    if flag_FoV==1          % 在视域内
       cnt_in=cnt_in+1;
       dir_in(cnt_in)=i;
    elseif flag_FoV==0      % 在视域外
        cnt_out=cnt_out+1;
        dir_out(cnt_out)=i;
    end
end

dir_in(cnt_in+1:end)=[];
dir_out(cnt_out+1:end)=[];

%=====根据视域转移=====
[in_FoV,out_FoV]=FoV_divide_assifun(state,dir_in,dir_out,cnt_in,cnt_out);

In_FoV.w = in_FoV{1,1};
In_FoV.m = in_FoV{2,1};
In_FoV.P = in_FoV{3,1};
In_FoV.num = in_FoV{4,1};

Out_FoV.w = out_FoV{1,1};
Out_FoV.m = out_FoV{2,1};
Out_FoV.P = out_FoV{3,1};
Out_FoV.num = out_FoV{4,1};

end

%{
************************************************************************
                        粒子转移函数
              根据转移目录将粒子按照视域进行区分
         输入: 1.state    -- 待划分视域的粒子集 (6*1cell)
               2.dir_in   -- 视域内粒子的目录
               3.dir_out  -- 视域外粒子的目录
               4.n_in     -- 视域内的粒子数量
               5.n_out    -- 视域外的粒子数量

         输出: 1.in_FoV   -- 视域内粒子集（6*1cell)
               2.out_FoV  -- 视域外粒子集（6*1cell）
************************************************************************
%}
function [in_FoV,out_FoV]=FoV_divide_assifun(state,dir_in,dir_out,n_in,n_out)

%=====初始化=====
in_FoV=cell(4,1);
out_FoV=cell(4,1);

%======视域内转移======
in_FoV{1,1}=state.w(dir_in); % 权重
in_FoV{2,1}=state.m(:,dir_in); % 均值
in_FoV{4,1}=n_in;    % 粒子数量
% 协方差转移
in_FoV{3,1}=zeros(4,4*n_in);
for i=1:n_in
    in_FoV{3,1}(:,4*i-3:4*i)=state.P(:,4*dir_in(i)-3:4*dir_in(i));
end

%======视域外转移======
out_FoV{1,1}=state.w(dir_out); % 权重
out_FoV{2,1}=state.m(:,dir_out); % 均值
out_FoV{4,1}=n_out;                 % 粒子数量
% 协方差转移
out_FoV{3,1}=zeros(4,4*n_out);
for i=1:n_out
    out_FoV{3,1}(:,4*i-3:4*i)=state.P(:,4*dir_out(i)-3:4*dir_out(i));
end


end