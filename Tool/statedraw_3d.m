%%三维状态提取模块
%%输入:粒子状态集4*1的cell，分别代表1.权值，2.均值，3.协方差，4.粒子个数
%%输出:当前时刻状态6*？的数组
%%*************************************************************************
function [state_draw,num_draw]=statedraw_3d(state)
JK=0;%%状态个数的计数器
state_draw=zeros(6,2*state{4,1});
for i=1:state{4,1}
    j = min( round(state{1,1}(1,i)) , 2 );
    for k=1:j
        JK=JK+1;
        state_draw(:,JK)=state{2,1}(:,i);
    end
end
state_draw(:,JK+1:2*state{4,1})=[];
num_draw=JK;

end