%***************************************************************
%
%               拓扑图自动生成函数
% 
%      输入: 1. num_sensor -- 传感器数量
%            2. location_center -- 平台中心点
%            3. r_interval -- 平台的间距
%            4. r_communicate -- 通信半径
% 
%      输出: 1. mat_topo -- 平台关联的拓扑矩阵
%            2. location -- 平台的坐标及编号
%
%      说明: 生成图形为 正三角形按照正六边形的样式扩展
%
%***************************************************************
function [mat_topo,location]=topo_born_3d(num_sensor,location_center,r_interval,r_communicate)
% 初始化
location=zeros(4,num_sensor);     % 前三维是坐标，最后一维是编号
location(:,1)=location_center;    % 中心平台的编号默认为1
state_now=location_center(1:3,1); % 当前状态
S=1; % 状态机编号
num_seted=1; % 已经设置的平台数量
num_loop=0;  % 环数
%=============拓扑生成====================
while(num_seted<num_sensor)

    %==========状态1=============
    if S==1
        state_now=state_now+[-r_interval;0;0]; 
        num_seted=num_seted+1; 
        location(1:3,num_seted)=state_now; 
        location(4,num_seted)=num_seted;
        S=2; 
        num_loop=num_loop+1;
    %==========状态2=============
    elseif S==2
        for i=1:num_loop
            state_now=state_now+[r_interval/2;sqrt(3)*r_interval/2;0];
            num_seted=num_seted+1; 
            location(1:3,num_seted)=state_now; 
            location(4,num_seted)=num_seted;
        end
        S=3; 
        
    %==========状态3=============
    elseif S==3
        for i=1:num_loop
            state_now=state_now+[r_interval;0;0]; 
            num_seted=num_seted+1; 
            location(1:3,num_seted)=state_now; 
            location(4,num_seted)=num_seted;
        end
        S=4; 
        
    %==========状态4=============    
    elseif S==4
        for i=1:num_loop
            state_now=state_now+[r_interval/2;-sqrt(3)*r_interval/2;0];
            num_seted=num_seted+1; 
            location(1:3,num_seted)=state_now; 
            location(4,num_seted)=num_seted;
        end
        S=5;
        
    %==========状态5=============     
    elseif S==5
        for i=1:num_loop
            state_now=state_now+[-r_interval/2;-sqrt(3)*r_interval/2;0]; 
            num_seted=num_seted+1; 
            location(1:3,num_seted)=state_now; 
            location(4,num_seted)=num_seted;
        end
        S=6; 
    
    %==========状态6=============      
    elseif S==6
        for i=1:num_loop
            state_now=state_now+[-r_interval;0;0]; 
            num_seted=num_seted+1; 
            location(1:3,num_seted)=state_now; 
            location(4,num_seted)=num_seted;
        end
        S=7; 

    %==========状态7=============
    elseif S==7
        for i=1:num_loop-1
            state_now=state_now+[-r_interval/2;sqrt(3)*r_interval/2;0]; 
            num_seted=num_seted+1; 
            location(1:3,num_seted)=state_now; 
            location(4,num_seted)=num_seted;
        end
        state_now=state_now+[-r_interval/2;sqrt(3)*r_interval/2;0]; 
        S=1;     
    end
end


%***************************************************************************************************
%
%                                拓扑连接矩阵生成
%
%***************************************************************************************************

X=location(1:3,:);
Y=location(1:3,:);

n = size(X,2);
m = size(Y,2);

XX = repmat(X,[1 m]);
YY = reshape(repmat(Y,[n 1]),[size(Y,1) n*m]);

mat_topo = reshape(sqrt(sum((XX-YY).^2)),[n m]);

mat_topo(mat_topo<=r_communicate + 5)=1;
mat_topo(mat_topo>r_communicate + 5)=0;

end