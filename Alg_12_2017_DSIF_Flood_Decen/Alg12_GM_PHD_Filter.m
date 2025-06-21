function [x_k_history,w_birth,m_birth,P_birth,numTargetbirth,w_bar_k, m_bar_k, P_bar_k,x_k,x_k_w,x_k_P] = Alg12_GM_PHD_Filter(numTargetbirth,m_birth,P_birth,w_birth,F,Q,R,...
    w_k_1,m_k_1,P_k_1,Z,Z_clutter,nClutter,detect_prob,x_k_history,k,location,R_dected)
%*************************************************************************
%                            GM_PHD滤波
%输入参数：新生目标（numTargetbirth，m_birth，P_birth，w_birth）
%输入参数：系统矩阵（F，Q,H,R）
%输入参数：前一时刻滤波状态（w_k_1，m_k_1，P_k_1）
%输入参数：前一时刻观测（Z，Z_clutter），杂波数量：nClutter，w_k,检测概率:detect_prob
%输入参数：截止k时刻为止的滤波状态，x_k_history，步数k
%输出参数：截止k时刻为止的滤波状态，x_k_history
%输出参数：新生目标（w_birth,m_birth,P_birth,numTargetbirth)
%输出参数：经过剪枝留下的高斯分量（w_bar_k, m_bar_k, P_bar_k）
%输出参数：k时刻滤波状态（x_k,x_k_w,x_k_P）




%************************************************
%     GM_PHD预测步骤
%     包含了对新生目标、上一时刻存在的目标预测
%     未考虑衍生目标
%************************************************

i=0;
%对新生目标进行预测
for j=1:numTargetbirth
    i=i+1;
    m_birth(:,j)=F*m_birth(:,j);
    P_birth(:,(j-1)*4+1:j*4)=Q+F*P_birth(:,(j-1)*4+1:j*4)*F';
end
%对存在目标进行预测
survive_prob=1;%先前状态仍存在的可能性
for j=1:size(m_k_1,2)
    i=i+1;
    w_k_1(j)=survive_prob*w_k_1(j);
    m_k_1(:,j)=F*m_k_1(:,j);
    P_k_1(:,(j-1)*4+1:j*4)=Q+F*P_k_1(:,(j-1)*4+1:j*4)*F';
end
%将新生，存在的状态放一起
wk_k_1=[w_k_1,w_birth];
mk_k_1=[m_k_1,m_birth];
Pk_k_1=[P_k_1,P_birth];
numTargetk_k_1=i;%预测概率密度函数高斯分量的个数

%************************************************
%                GM_PHD更新步
%************************************************
%更新步骤中需要的参数
Z_predict=[];%观测预测
S=[];%协方差预测
K=[];%kalman增益
Pk_k=[];%协方差矩阵
dis = @(x,y)sqrt((x.^2 + y.^2));
%====UT变换参数设置====%
% alpha = 1;kappa = 2;beta = 2;
alpha = 0.1;kappa = 0;beta = 2;
for j=1:numTargetk_k_1
     %=======采用UT变换=======%
        %====一：采样得到Sigma点====%
    [Xi,Wi,Pi] = ut(mk_k_1(:,j),Pk_k_1(:,(j-1)*4+1:j*4),alpha,kappa,beta);
        %====二：使用Sigma点是生成观测预测值====%
    Ob_Station = repmat(location,1,length(Wi));
    Zi = [dis(Xi(1,:)-Ob_Station(1,:),Xi(3,:)-Ob_Station(2,:));atan2d(Xi(3,:)-Ob_Station(2,:),Xi(1,:)-Ob_Station(1,:))];
%     Zi = [dis(Xi(1,:),Xi(3,:));atan2d(Xi(3,:),Xi(1,:))]; 
     index = find(Zi(2,:) < 0);
     Zi(2,index) = Zi(2,index) + 360;
        %====三：通过加权求和得到系统预测的均值和协方差====%
    eta = Zi*Wi(:);%Sigma点观测均值   
    S_temp = Zi-repmat(eta,[1,length(Wi)]);
    Pzz = S_temp*diag(Pi)*S_temp' + R;
    G_temp = Xi - repmat(mk_k_1(:,j),[1,length(Wi)]);
    Pxz = G_temp*diag(Pi)*S_temp';
    
    
    S_update=Pzz;
    K_update=Pxz*inv(Pzz);
    P_update=Pk_k_1(:,(j-1)*4+1:j*4) - K_update*Pzz*K_update';
    
    Z_predict=[Z_predict,eta];
    S=[S,S_update];
    K=[K,K_update];
    Pk_k=[Pk_k,P_update];
end
%更新步，利用观测对高斯分量进行更新
w_k=[];
m_k=[];
P_k=[];
for j=1:numTargetk_k_1
   w_k(:,j)=(1-detect_prob)*wk_k_1(:,j);
   m_k(:,j)=mk_k_1(:,j);
   P_k(:,(j-1)*4+1:j*4)=Pk_k_1(:,(j-1)*4+1:j*4);
end
L=0;
model.R = R;
gamma= chi2inv(0.999,2); 
%量测分割
% Z = gate_meas_gms(Z,gamma,model,mk_k_1,Pk_k_1);
for j=1:size(Z,2)
    L=L+1;
    for i=1:numTargetk_k_1
%        w_k(L*numTargetk_k_1+i)=detect_prob*wk_k_1(:,i)*mvnpdf(Z(:,j),Z_predict(:,i),S(:,2*i-1:2*i));
       w_k(L*numTargetk_k_1+i)=detect_prob*wk_k_1(:,i)*exp(-0.5*(Z(:,j)-Z_predict(:,i))'...
            /S(:,2*i-1:2*i)*(Z(:,j)-Z_predict(:,i)))/sqrt(det(S(:,2*i-1:2*i))*(2*pi)^2);
       m_k(:,L*numTargetk_k_1+i)=mk_k_1(:,i)+K(:,2*i-1:2*i)*(Z(:,j)-Z_predict(:,i));
       P_k(:,L*numTargetk_k_1*4+1+(i-1)*4:L*numTargetk_k_1*4+4+(i-1)*4)=Pk_k(:,(i-1)*4+1:i*4);
    end
    %计算所有权重之和
    sum_w=0;
    for i=1:numTargetk_k_1
       sum_w=sum_w+w_k(L*numTargetk_k_1+i);
    end
    %归一化权重
    for i=1:numTargetk_k_1
        w_k(L*numTargetk_k_1+i)=w_k(L*numTargetk_k_1+i)/(nClutter*(1/(R_dected*R_dected*pi))+sum_w);
    end
end
numTarget_k=(L+1)*numTargetk_k_1;%后验概率密度函数中高斯分量的个数

%*************************************************
%        GM_PHD剪枝程序
%        去掉后验概率密度函数中权重小的高斯分量
%        从而减少运算量
%        并对相似的高斯分量进行合并处理
%*************************************************
% T=5e-3;%高斯分量权重阈值
T = 0.01;
U = 200;
I=find(w_k>=T);
l=0;
w_bar_k = [];
m_bar_k = [];
P_bar_k = [];

while isempty(I)==false  %当I中无元素时，返回true，循环结束
   l=l+1;
   %在符合要求的权重中找出最大的权重所对应的的位置
   heighweight=w_k(I);
   [maxW,j]=max(heighweight);
   j=I(j);
   L=[];
   for m=1:length(I)
       thisI=I(m);
       delta_m=m_k(:,thisI)-m_k(:,j);
       distance=delta_m'*inv(P_k(:,thisI*4-3:thisI*4))*delta_m;
       if (distance<U)
           L=[L,thisI];
       end
   end
   w_bar_k_sum=sum(w_k(L));
   m_bar_k_sum=zeros(4,1);
   for m=1:length(L)
       thisL=L(m);
       m_bar_k_sum=m_bar_k_sum+1/w_bar_k_sum*(w_k(thisL)*m_k(:,thisL));
   end
   P_sum=zeros(4,4);
   for m=1:length(L)
      thisI=L(m);
      delta_m=m_bar_k_sum-m_k(:,thisI);
      P_sum=P_sum+w_k(thisI)*(P_k(:,4*thisI-3:4*thisI)+delta_m*delta_m');
   end
   P_bar_k_l=P_sum/w_bar_k_sum;
   for m=1:length(L)
      remove_index=find(I==L(m));
      I(remove_index)=[];
   end
    w_bar_k=[w_bar_k,w_bar_k_sum];
    m_bar_k=[m_bar_k,m_bar_k_sum];
    P_bar_k=[P_bar_k,P_bar_k_l];
    
end
numTarget_k=length(w_bar_k);

 
%**********************************************
%              GM_PHD状态提取
%    对权重大于0.5的高斯分量进行状态提取
%**********************************************
x_k=[];
x_k_w=[];
x_k_P=[];
gate = 0.5;
I=find(w_bar_k>gate);
x_k = m_bar_k(:,I);
x_k_w = w_bar_k(:,I);
for j=1:length(I)
   thisI=I(j);
   thisP=P_bar_k(:,4*thisI-3:4*thisI);
   x_k_P=[x_k_P,thisP];
end
x_k_history=[x_k_history,x_k];

%****************************************************
%          GM_PHD新生目标启动程序
%          根据两个时刻的观测值判断有无新生目标
%          认为达标的观测为新生目标，给定权重进行迭代
%****************************************************
w_birth = [];
m_birth = [];
P_birth = [];
numTargetbirth = 0;
MAX_V=100;
max_v=20;
if (k>=2)
    thisZ_index=k;
    preZ_index=k-1;
    thisZ=Z_clutter{thisZ_index};
    preZ=Z_clutter{preZ_index};
    
        for j_this = 1:size(thisZ,2)%1:52
                for j_prev = 1:1:size(preZ,2)%Match every pair from previous to current 1:52
                    m_this = thisZ(:,j_this);%k时刻观测数据
                    m_prev = preZ(:,j_prev);%k-1时刻观测数据
                    m_i = m_this;
                    thisV = (m_this(1:2) - m_prev(1:2));
                    if(abs(thisV(1)) > MAX_V) || (abs(thisV(2)) > MAX_V)
                        continue;
                    end
                    if abs(thisV(1)) > max_v && thisV(1) >=0
                        thisV(1)=max_v;
                    elseif abs(thisV(1)) > max_v && thisV(1)<0
                        thisV(1)=-max_v;
                    else
                        thisV(1)=thisV(1);    
                    end
                    if abs(thisV(2)) > max_v && thisV(2) >=0
                        thisV(2)=max_v;
                    elseif abs(thisV(2)) > max_v && thisV(2)<0
                        thisV(2)=-max_v;
                    else
                        thisV(2)=thisV(2);    
                    end
                    m_i = [m_i(1), thisV(1),m_i(2),thisV(2)]';%将速度估计加入观测
%                     birthWeight = 0.1*mvnpdf(m_i([1,3]),Target1([1,3],1),diag([400,400]'))+0.1*mvnpdf(m_i([1,3]),Target2([1,3],1),diag([400,400]'))+0.1*mvnpdf(m_i([1,3]),Target3([1,3],1),diag([400,400]'))+0.1*mvnpdf(m_i([1,3]),Target4([1,3],1),diag([400,400]'))+0.1*mvnpdf(m_i([1,3]),Target5([1,3],1),diag([400,400]'))+0.1*mvnpdf(m_i([1,3]),Target6([1,3],1),diag([400,400]'));
                      birthWeight = 0.005;
                        %Birth the target
                        w_i = birthWeight;
                        %Initialise the covariance
                        P_i = diag([R(1,1)*R(2,2), R(1,1)*R(2,2) / 2, R(1,1)*R(2,2),  R(1,1)*R(2,2) / 2]');
                        w_birth = [w_birth, w_i];
                        m_birth = [m_birth,m_i];
                        P_birth = [P_birth, P_i];
                        numTargetbirth = numTargetbirth + 1;
                    end                
                end
            end

     

end

