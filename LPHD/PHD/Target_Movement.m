%****************************************************
%            GM_PHD运动方程
%            包含了目标真实轨迹
%****************************************************
T=1;%采样间隔时间
numT=100;%采样时长
% Mnte=50;%蒙特卡洛次数
Target1=[];%目标1
Target1_birth_time=20;
Target1_end_time=70;
Target2=[];%目标2
Target3=[];%目标3
Target1(:,1)=[-1250,40,1250,0]';
Target2(:,1)=[-1000,20 ,1000,-20 ]';
Target3(:,1)=[-1000,20,-1000,20 ]';
delta_w=1e-3;%过程噪声调整参数，越大，目标运动轨迹越随机
Q=delta_w*diag([1,0.1,1,0.1]);%过程噪声协方差矩阵
R=100*eye(2);%观测噪声协方差矩阵
F=[1 T 0 0;
   0 1 0 0;
   0 0 1 T;
   0 0 0 1;];
H=[1 0 0 0;
    0 0 1 0;];
%状态方程
for k=2:numT
    Target2(:,k)=F*Target2(:,k-1)+sqrt(Q)*randn(4,1);
    Target3(:,k)=F*Target3(:,k-1)+sqrt(Q)*randn(4,1);
end
for k=2:Target1_end_time-Target1_birth_time+1
    Target1(:,k)=F*Target1(:,k-1)+sqrt(Q)*randn(4,1);
end