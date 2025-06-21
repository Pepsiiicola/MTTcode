%{
%%***********************************************************************************
%     
%                            单个时刻的PHD计算程序(内嵌UKF)
%        
%       输入： Z_bef1_d : 上个时刻笛卡尔坐标系观测        -- 6*<观测数量> double数组
%              Z_bef2_d  : 当前时刻的笛卡尔坐标系观测      -- 6*<观测数量> double数组
%              Z_now_p  : 当前时刻极坐标观测              -- 6*<观测数量> double数组
%              X_new    : 上个时刻新生分量                -- 4*1 cell
%              X_last   : 上一时刻PHD全局后验分量         -- 4*1 cell
%              Zr,A,Q,R,Psk,Pdk     -- 杂波强度，相关系统参数,航迹自启始阈值参数
%              Vx_max,Vy_max,Vz_max -- 新生分量三个方向最大的速度设定
%
%       输出：更新之后的粒子集（4*1cell）
%
%**************************************************************************************
%}
function [X_now]=ALG10_PHD1time_3d_ukf_decen(Z_bef1_d,Z_bef2_d,Z_now_p,X_last,Zr,R,Psk,Pdk,Vx_thre,...
                                       Vy_thre,Vz_thre,x_radar,y_radar,z_radar,ID_sensor)

T=1;
A=[1 T 0 0 0 0;0 1 0 0 0 0;0 0 1 T 0 0;0 0 0 1 0 0;0 0 0 0 1 T;0 0 0 0 0 1];
Q=diag([1,0.1,1,0.1,1,0.1]);


w_priori=X_last{1,1};%%权重
m_priori=X_last{2,1};%%均值
P_priori=X_last{3,1};%%协方差
J_priori=X_last{4,1};%%先验粒子数量

w_pre(1,10000)=0;
m_pre=zeros(6,1);
P_pre=zeros(6,6);
% J_pre=0;
Z_obpre=zeros(3,1);%%对观测值的预测

w_pos(1,20000)=0;
m_pos=zeros(6,1);
P_pos=zeros(6,6);
% J_pos=0;

P_z=eye(3);%%预测的协方差
K_ukf=zeros(6,3);%%增益初始化
P_ukf=zeros(6,6);%%初始化


[~,n_zbef1]=size(Z_bef1_d);
[~,n_zbef2]=size(Z_bef2_d);
[w_new,m_new,P_new,J_new]=generate(Z_bef1_d,n_zbef1,Z_bef2_d,n_zbef2,Vx_thre,Vy_thre,Vz_thre);

i=0;%先验混合高斯分量计数
for j=1:J_new
    i=i+1;
    w_pre(1,i)=w_new(1,i);
    m_pre(:,i)=A*m_new(:,i);%%对新生粒子进行一步预测
    P_pre(:,6*(i-1)+1:6*i)=A*P_new(:,6*(i-1)+1:6*i)*A'+Q;
end

for j=1:J_priori
    i=i+1;
    w_pre(1,i)=Psk*w_priori(1,j);
    m_pre(:,i)=A*m_priori(:,j);
    P_pre(:,6*(i-1)+1:6*i)=Q+A*P_priori(:,6*(j-1)+1:6*j)*A';
end

J_pre=i;%%预测之后高斯混合模型的分量数，即目标数,若没有目标生成则直接设置为空集
if J_pre==0
    W_phd=[];
    M_phd=[];
    P_phd=[];
    e=0;
else

    for j=1:J_pre
        w_pos(1,j)=(1-Pdk)*w_pre(1,j);
        m_pos(:,j)=m_pre(:,j);
        P_pos(:,6*(j-1)+1:6*j)=P_pre(:,6*(j-1)+1:6*j);
    end

    flag_jump=zeros(1,J_pre);
    for j=1:J_pre
        [Z_obpre(:,j),P_z(:,3*(j-1)+1:3*j),K_ukf(:,3*(j-1)+1:3*j),P_ukf(:,6*(j-1)+1:6*j),flag_jump(1,j)]=...
            UKFpart(m_pre(1:6,j),P_pre(:,6*(j-1)+1:6*j),R,x_radar,y_radar,z_radar);
    end

    e=0;
    [~,n_znow]=size(Z_now_p);
    
    % 量测更新
    for i=1:n_znow
        e=e+1;
        for j=1:J_pre
      
            w_pos(1,e*J_pre+j)=w_pre(1,j)*(1/(2*pi*sqrt(det(P_z(:,3*(j-1)+1:3*j)))))*exp(-0.5*(Z_now_p(:,i)-Z_obpre(:,j))'/(P_z(:,3*(j-1)+1:3*j))*(Z_now_p(:,i)-Z_obpre(:,j)));
            P_pos(:,6*(e*J_pre+j-1)+1:6*(e*J_pre+j))=P_ukf(:,6*(j-1)+1:6*j);
            m_pos(1:6,e*J_pre+j)=M_UKF(m_pre(1:6,j),Z_now_p(:,i),Z_obpre(:,j),K_ukf(:,3*(j-1)+1:3*j),flag_jump(1,j));
        end
        if max(w_pos(1,e*J_pre+1:e*J_pre+J_pre))<=0.00000001
            w_pos(1,e*J_pre+1:e*J_pre+J_pre)=0;
        else
            wsum=sum(w_pos(1,e*J_pre+1:e*J_pre+J_pre));
            w_pos(1,e*J_pre+1:e*J_pre+J_pre)=Pdk*w_pos(1,e*J_pre+1:e*J_pre+J_pre)./((Zr/(2000*2000*2000))+wsum);
        end
    end
    J_pos=e*J_pre+J_pre;

%     T=0.01;%%设定剪枝阈值
    T=0.2*(1-Pdk)*0.99 + 0.00001;
    U=135;%%合并门限
    Jmax=200;%%允许的最大高斯分量数
    I=cell(3,1);%%生成三个集合，分别代表剪枝过后的混合高斯参数,权重，均值，方差
    k=0;
 
    for i=1:J_pos
        if w_pos(1,i)>=T
            k=k+1;
            I{1,1}(1,k)=w_pos(1,i);%%权值采集
            I{2,1}(:,k)=m_pos(:,i);%%均值采集
            I{3,1}(:,6*(k-1)+1:6*k)=P_pos(:,6*(i-1)+1:6*i);%%协方差采集
        end
    end
    Jj=k;%%I集合中所含分量个数

    W_phd=zeros(1,Jj);
    M_phd=zeros(6,Jj);
    P_phd=zeros(6,6*Jj);
    e=0;
    Jj_copy=Jj;
    while Jj>0
        e=e+1;
        wmax=max(I{1,1}(1,:));%%找到I{1，1}(1,:)最大的权值
        [~,col]=find(I{1,1}(1,:)==wmax);%%col的值就是最大权值的位置
        k=0;%%用来计数每个循环中从I中拿走的个数
        c=zeros(1,Jj);%%c数列用来记录I中符合融合的分量坐标
        L=cell(3,1);%%把符合的分量加入L中，L有三个元胞，分别代表权值，均值，方差
        for i=1:Jj
            
            % 用欧式距离来判断
            if sqrt(( I{2,1}([1,3,5],i)-I{2,1}([1,3,5],col(1,1)))'*(I{2,1}([1,3,5],i)-I{2,1}([1,3,5],col(1,1))))<=U                    
                k=k+1;
                c(k)=i;
                L{1,1}(1,k)=I{1,1}(1,i);
                L{2,1}(:,k)=I{2,1}(:,i);
                L{3,1}(:,6*(k-1)+1:6*k)=I{3,1}(:,6*(i-1)+1:6*i);
                
            end
            
        end
        c(k+1:Jj)=[];%%释放内存
        %%至此，对于一次循环里需要融合的参量全部放在了L中，个数为k个
        %%权值计算
        W_phd(1,e)=sum(L{1,1}(1,:));
        %%均值计算
        M_phd(:,e)=[0 0 0 0 0 0]';
        for i=1:k %%k代表L中的分量个数
            M_phd(1:6,e)=M_phd(1:6,e)+L{1,1}(1,i)*L{2,1}(1:6,i);
        end
        M_phd(1:6,e)=M_phd(1:6,e)/W_phd(1,e);%%均值
        %%协方差计算
        P_phd(:,6*(e-1)+1:6*e)=zeros(6,6);
        for i=1:k %%k代表L中的分量个数
            P_phd(:,6*(e-1)+1:6*e)=P_phd(:,6*(e-1)+1:6*e)+L{1,1}(1,i)*(L{3,1}(:,6*(i-1)+1:6*i)+(M_phd(1:6,e)-L{2,1}(1:6,i))*(M_phd(1:6,e)-L{2,1}(1:6,i))');
        end
        P_phd(:,6*(e-1)+1:6*e)=P_phd(:,6*(e-1)+1:6*e)/W_phd(1,e);%%协方差
        %删除I中用于融合的权值
        I{1,1}(:,c)=[];
        %%删除I中用于融合的均值
        I{2,1}(:,c)=[];
        %%用于删除I中用于融合的协方差
        I{3,1}(:,6*(c(1)-1)+1:6*c(1))=[];
        for i=2:k
            I{3,1}(:,6*(c(i)-i)+1:6*(c(i)-i+1))=[];%%用于删除I中用于融合的协方差
        end
        %%更新剩余数量
        Jj=Jj-k;%%I中剩余分量的个数，当为零时，结束循环
    end
    %%释放内存
    W_phd(e+1:Jj_copy)=[];
    M_phd(:,e+1:Jj_copy)=[];
    P_phd(:,6*e+1:6*Jj_copy)=[];
    
    if e>Jmax
        for i=1:Jmax
            wmax=max(W_phd(1,:));%%找到最大值
            col=find((W_phd(1,:)-wmax)<0.0001);
            G=cell(3,1);%%创建胞组G，存放权值，均值和方差
            G{1,1}(:,i)=W_phd(:,col(1));%%权值采集
            G{2,1}(:,i)=M_phd(:,col(1));%%均值采集
            G{3,1}(:,6*(i-1)+1:6*i)=P_phd(:,6*(col(1)-1)+1:6*col(1));%%协方差采集
            W_phd(:,col(1))=[];%%删除最大的权值
            M_phd(:,col(1))=[];%%删除最大权值对应的均值
            P_phd(:,6*(col(1)-1)+1:6*col(1))=[];%%用于删除最大权值对应的协方差
        end
        %%得到最后的权值，均值和方差，再放回Wphd,Mphd,Pphd中
        W_phd=[0;0];%%清零
        M_phd=zeros(6,1);%%清零
        P_phd=zeros(6,6);%%清零
        for i=1:Jmax
            W_phd(:,i)=G{1,1}(:,i);
            M_phd(:,i)=G{2,1}(:,i);
            P_phd(:,6*(i-1)+1:6*i)=G{3,1}(:,6*(i-1)+1:6*i);
        end
        e=200;
    end
end

%=====进行状态提取=====12.27修改
X_now=cell(4,1);
gate = 0.5;
Index = find(W_phd>gate);
X_now{1,1}=W_phd(:,Index);
X_now{2,1}=[M_phd(:,Index);ID_sensor*ones(1,size(Index,2))];

for ii = 1:length(Index)
    thisIndex = Index(ii);
    thisP = P_phd(:,6*thisIndex-5:6*thisIndex);
    X_now{3,1} = [X_now{3,1},thisP];
end
X_now{4,1} = size(X_now{1,1},2);

% X_now=cell(4,1);
% X_now{1,1}=W_phd;
% X_now{2,1}=[M_phd;ID_sensor*ones(1,size(M_phd,2))];
% X_now{3,1}=P_phd;
% X_now{4,1}=e;

end


%%**************************************************************************************************
%                                 新生分量启始程序
%%**************************************************************************************************
%%说明：输入为上一时刻的观测集(数组3*?)及其观测个数，这一时刻的观测集(数组3*?)及其个数,以及两个方向的阈值
%%输出为此时新生分量(数组的形式6*?),%%注，这里是以笛卡尔坐标的差值来进行新生启始的
function [w_new,m_new,P_new,J_new]=generate(z_last,n_last,z_now,n_now,Vx_thre,Vy_thre,Vz_thre)
w_new=zeros(1,n_last*n_now);%%最多新生为n_last*n_now
m_new=zeros(6,n_last*n_now);
P_new=zeros(6,6*n_last*n_now);
Vx_max = 25;
Vy_max = 25;
Vz_max = 5;
k=0;%%新生分量的个数
for i=1:n_now
    for j=1:n_last
        z_delta=z_now(:,i)-z_last(:,j);
        if abs(z_delta(1,1))<Vx_thre&&abs(z_delta(2,1))<Vy_thre&&abs(z_delta(3,1))<Vz_thre
            k=k+1; % 新生分量计数 
            % X轴速度
            % 判断是否到达最大速度，以及速度的方向，下同
            if abs(z_delta(1,1))>Vx_max && z_delta(1,1)>=0
                m_new(2,k)=Vx_max;
            elseif abs(z_delta(1,1))>Vx_max && z_delta(1,1)<0
                m_new(2,k)=-Vx_max;
            else
                m_new(2,k)=z_delta(1,1);%%X轴速度
            end
            %   Y轴速度
            if abs(z_delta(2,1))>Vy_max && z_delta(2,1)>=0
                m_new(4,k)=Vy_max;
            elseif abs(z_delta(2,1))>Vy_max && z_delta(2,1)<0
                m_new(4,k)=-Vy_max;
            else
                m_new(4,k)=z_delta(2,1);%%Y轴速度
            end
            %   Z轴速度
            if abs(z_delta(3,1))>Vz_max && z_delta(3,1)>=0
                m_new(6,k)=Vz_max;
            elseif abs(z_delta(3,1))>Vz_max && z_delta(3,1)<0
                m_new(6,k)=-Vz_max;
            else
                m_new(6,k)=z_delta(3,1);%%Z轴速度
            end
            m_new(1,k)=z_now(1,i); % X位置
            m_new(3,k)=z_now(2,i); % Y轴位置
            m_new(5,k)=z_now(3,i); % Z轴位置
            w_new(1,k)=0.2;        % 新生分量的权重设置
            P_new(:,6*(k-1)+1:6*k) = diag([1000 100 1000 100 1000 100]);%%新生分量的协方差  
        end
    end
end
%%至此得到可能的新生分量参数w_new，m_new，P_new数量为k
w_new((k+1):n_last*n_now)=[];%%将为零的分量删去
m_new(:,(k+1):n_last*n_now)=[];
P_new(:,6*k+1:6*n_last*n_now)=[];
J_new=k;

end


%%*******************************************************************************************************************
%%PHD部分中的UKF部分，给函数下方的PHD权重提供1.观测预测状态得到的值；2.观测之后的协方差；3.UKF增益矩阵;4.最后更新的协方差
%%输入:1.预测目标的状态(一个预测高斯粒子的状态)6*1;2.对应的协方差6*6
%%输出:1.观测预测状态得到的值；2.观测之后的协方差；3.UKF增益矩阵;4.最后更新的协方差5.角度跳变标志
%%*******************************************************************************************************************
function [Z_fusion_ob,P_fusion_ob,k_ukf,Pnew,flag_jump]=UKFpart(X_fusion_pre,P_fusion_pre,R,x_radar,y_radar,z_radar)
%%UKF参量定义
Variable_dimension=size(X_fusion_pre,1); 
Z_ob_diffusion=zeros(3,2*Variable_dimension+1);%由第二次得到的sigama点所得出的观测值
w_m=zeros(1,2*Variable_dimension+1);
w_P=zeros(1,2*Variable_dimension+1);
alpha=0.1;%α
beta=2;%β
kap=0;%κ
lambda=(alpha^2)*(Variable_dimension+kap)-Variable_dimension;%λ

X_pre_diffusion=zeros(6,2*Variable_dimension+1);%第二次得到的sigama点分布
X_pre_diffusion(:,1)=X_fusion_pre;

try chol( P_fusion_pre );
catch
    % 奇异值分解
    [~,S,V]=svd(P_fusion_pre);
    H = V*S*V';
    P_fusion_pre = ( P_fusion_pre + P_fusion_pre'+ H + H')/4;
end

degree_diffusion=real(sqrtm((Variable_dimension+lambda)*P_fusion_pre)');%%分布程度，为6*6的矩阵

%**************************************************************************
for i=1:Variable_dimension
    X_pre_diffusion(:,i+1)=X_fusion_pre+degree_diffusion(:,i);
    X_pre_diffusion(:,i+Variable_dimension+1)=X_fusion_pre-degree_diffusion(:,i);
end
%权值计算
w_m(1)=lambda/(Variable_dimension+lambda);
w_P(1)=lambda/(Variable_dimension+lambda)+(1-alpha^2+beta);
for i=1:2*Variable_dimension
    w_m(i+1)=0.5/(Variable_dimension+lambda);
    w_P(i+1)=0.5/(Variable_dimension+lambda);
end

for i=1:2*Variable_dimension+1

    Z_ob_diffusion(1,i)=sqrt(( X_pre_diffusion(1,i)-x_radar)^2+(X_pre_diffusion(3,i)-y_radar)^2+( X_pre_diffusion(5,i)-z_radar)^2);%%非线性的观测方程

    theta_sus_head=rad2deg(atan((X_pre_diffusion(3,i)-y_radar)/(X_pre_diffusion(1,i)-x_radar)));
    if X_pre_diffusion(1,i)-x_radar>=0&&X_pre_diffusion(3,i)-y_radar>=0 %%第1象限
        Z_ob_diffusion(2,i)=theta_sus_head;
    elseif X_pre_diffusion(1,i)-x_radar<0&&X_pre_diffusion(3,i)-y_radar>=0 %%第2象限
        Z_ob_diffusion(2,i)=theta_sus_head+180;
    elseif X_pre_diffusion(1,i)-x_radar<0&&X_pre_diffusion(3,i)-y_radar<0 %%第3象限
        Z_ob_diffusion(2,i)=theta_sus_head+180;
    elseif X_pre_diffusion(1,i)-x_radar>=0&&X_pre_diffusion(3,i)-y_radar<0 %%第4象限
        Z_ob_diffusion(2,i)=theta_sus_head+360;
    end

    d_xy=sqrt(( X_pre_diffusion(1,i)-x_radar)^2+(X_pre_diffusion(3,i)-y_radar)^2);
    Z_ob_diffusion(3,i)=rad2deg(atan((X_pre_diffusion(5,i)-z_radar)/(d_xy)));
end

flag_jump=0;
max_theta=0;
for i=2:2*Variable_dimension+1
    d_theta=abs(Z_ob_diffusion(2,1)-Z_ob_diffusion(2,i));
    if d_theta>max_theta
        max_theta=d_theta;
    end
end

if max_theta>180%%表示出现跳变的点
    for i=1:2*Variable_dimension+1
        if Z_ob_diffusion(2,i)>270
            Z_ob_diffusion(2,i)=Z_ob_diffusion(2,i)-360;
        end
    end
    flag_jump=1;
end

Z_fusion_ob=[0;0;0];
for i=1:2*Variable_dimension+1
    Z_fusion_ob=Z_fusion_ob+w_m(i)*Z_ob_diffusion(:,i);
end

P_fusion_ob=R;
for i=1:2*Variable_dimension+1
    P_fusion_ob=P_fusion_ob+w_P(i)*(Z_ob_diffusion(:,i)-Z_fusion_ob)*(Z_ob_diffusion(:,i)-Z_fusion_ob)';%%3*3
end

Pzx=zeros(6,3);
for i=1:2*Variable_dimension+1
    Pzx=Pzx+w_P(i)*(X_fusion_pre-X_pre_diffusion(:,i))*(Z_fusion_ob-Z_ob_diffusion(:,i))';%%6*3
end

k_ukf=Pzx/(P_fusion_ob);%%6*3
Pnew=P_fusion_pre-k_ukf*P_fusion_ob*k_ukf';%%6*6
end

%***************************************************************************************************
%ukf均值的求解
%输入：1.估计值6*1的数组；2.当前时刻的观测值3*1的数组；3.预测状态的观测值3*1的数组；4.UKF增益；4.跳变标志位
%输出：1.当前状态估计值6*1的数组
%***************************************************************************************************
function [X_ukf]=M_UKF(X_fusion_pre,Z_polar,Z_fusion_ob,k_ukf,flag_jump)
complement=[0;360;0];
if abs(Z_polar(2,1)-Z_fusion_ob(2,1)) > 180 && flag_jump==0
    if Z_polar(2,1)-Z_fusion_ob(2,1)<0
        X_ukf=X_fusion_pre+k_ukf*(Z_polar(:,1)-Z_fusion_ob+complement);
    else
        X_ukf=X_fusion_pre+k_ukf*(Z_polar(:,1)-(Z_fusion_ob+complement));
    end
elseif abs(Z_polar(2,1)-Z_fusion_ob(2,1)) > 180 && flag_jump==1
    X_ukf=X_fusion_pre+k_ukf*(Z_polar(:,1)-(Z_fusion_ob+complement));
else
    X_ukf=X_fusion_pre+k_ukf*(Z_polar(:,1)-Z_fusion_ob);
end
end