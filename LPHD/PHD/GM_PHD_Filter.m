function [x_k_history,L_k_history,w_birth,m_birth,P_birth,Label_birth,numTargetbirth,w_bar_k, m_bar_k,P_bar_k,L_bar_k,x_k,x_k_w,x_k_P] = GM_PHD_Filter(numTargetbirth,m_birth,P_birth,w_birth,L_birth,F,Q,H,R,...
    w_k_1,m_k_1,P_k_1,L_k_1,Z,Z_clutter,nClutter,detect_prob,x_k_history,L_k_history,k)
%*************************************************************************
%                            GM_PHD�˲�
%�������������Ŀ�꣨numTargetbirth��m_birth��P_birth��w_birth��
%���������ϵͳ����F��Q,H,R��
%���������ǰһʱ���˲�״̬��w_k_1��m_k_1��P_k_1��
%���������ǰһʱ�̹۲⣨Z��Z_clutter�����Ӳ�������nClutter��w_k,������:detect_prob
%�����������ֹkʱ��Ϊֹ���˲�״̬��x_k_history������k
%�����������ֹkʱ��Ϊֹ���˲�״̬��x_k_history
%�������������Ŀ�꣨w_birth,m_birth,P_birth,numTargetbirth)
%���������������֦���µĸ�˹������w_bar_k, m_bar_k, P_bar_k��
%���������kʱ���˲�״̬��x_k,x_k_w,x_k_P��




%************************************************
%     GM_PHDԤ�ⲽ��
%     �����˶�����Ŀ�ꡢ��һʱ�̴��ڵ�Ŀ��Ԥ��
%     δ��������Ŀ��
%************************************************

i=0;
%������Ŀ�����Ԥ��
for j=1:numTargetbirth
    i=i+1;
    m_birth(:,j)=F*m_birth(:,j);
    P_birth(:,(j-1)*4+1:j*4)=Q+F*P_birth(:,(j-1)*4+1:j*4)*F';
end
%�Դ���Ŀ�����Ԥ��
survive_prob=1;%��ǰ״̬�Դ��ڵĿ�����
for j=1:size(m_k_1,2)
    i=i+1;
    w_k_1(j)=survive_prob*w_k_1(j);
    m_k_1(:,j)=F*m_k_1(:,j);
    P_k_1(:,(j-1)*4+1:j*4)=Q+F*P_k_1(:,(j-1)*4+1:j*4)*F';
end
%�����������ڵ�״̬��һ��
wk_k_1=[w_k_1,w_birth];
mk_k_1=[m_k_1,m_birth];
Pk_k_1=[P_k_1,P_birth];
Lk_k_1 = [L_k_1,L_birth];
numTargetk_k_1=i;%Ԥ������ܶȺ�����˹�����ĸ���

%************************************************
%                GM_PHD���²�
%************************************************
%���²�������Ҫ�Ĳ���
Z_predict=[];%�۲�Ԥ��
S=[];%Э����Ԥ��
K=[];%kalman����
Pk_k=[];%Э�������
for j=1:numTargetk_k_1
    Z_predict_onestep=H*mk_k_1(:,j);
    S_update=R+H*Pk_k_1(:,(j-1)*4+1:j*4)*H';
    K_update=Pk_k_1(:,(j-1)*4+1:j*4)*H'*inv(S_update);
    P_update=[eye(4)-K_update*H]*Pk_k_1(:,(j-1)*4+1:j*4);
    
    Z_predict=[Z_predict,Z_predict_onestep];
    S=[S,S_update];
    K=[K,K_update];
    Pk_k=[Pk_k,P_update];
end
%���²������ù۲�Ը�˹�������и���
for j=1:numTargetk_k_1
   w_k(:,j)=(1-detect_prob)*wk_k_1(:,j);
   m_k(:,j)=mk_k_1(:,j);
   P_k(:,(j-1)*4+1:j*4)=Pk_k_1(:,(j-1)*4+1:j*4);
   L_k(:,j) = Lk_k_1(:,j);
end
L=0;
model.H = H;
model.R = R;
gamma= chi2inv(0.999,2); 
%����ָ�
Z = gate_meas_gms(Z,gamma,model,mk_k_1,Pk_k_1);
for j=1:size(Z,2)
    L=L+1;
    for i=1:numTargetk_k_1
%        w_k(L*numTargetk_k_1+i)=detect_prob*wk_k_1(:,i)*mvnpdf(Z(:,j),Z_predict(:,i),S(:,2*i-1:2*i));
       w_k(L*numTargetk_k_1+i)=detect_prob*wk_k_1(:,i)*exp(-0.5*(Z(:,j)-Z_predict(:,i))'...
            /S(:,2*i-1:2*i)*(Z(:,j)-Z_predict(:,i)))/sqrt(det(S(:,2*i-1:2*i))*(2*pi)^2);
       m_k(:,L*numTargetk_k_1+i)=mk_k_1(:,i)+K(:,2*i-1:2*i)*(Z(:,j)-Z_predict(:,i));
       P_k(:,L*numTargetk_k_1*4+1+(i-1)*4:L*numTargetk_k_1*4+4+(i-1)*4)=Pk_k(:,(i-1)*4+1:i*4);
       L_k(:,L*numTargetk_k_1+i) = Lk_k_1(:,i);
    end
    %��������Ȩ��֮��
    sum_w=0;
    for i=1:numTargetk_k_1
       sum_w=sum_w+w_k(L*numTargetk_k_1+i);
    end
    %��һ��Ȩ��
    for i=1:numTargetk_k_1
        w_k(L*numTargetk_k_1+i)=w_k(L*numTargetk_k_1+i)/(nClutter*(1/(3000*3000))+sum_w);
    end
end
numTarget_k=(L+1)*numTargetk_k_1;%��������ܶȺ����и�˹�����ĸ���

%*************************************************
%        GM_PHD��֦����
%        ȥ����������ܶȺ�����Ȩ��С�ĸ�˹����
%        �Ӷ�����������
%        �������Ƶĸ�˹�������кϲ�����
%*************************************************
T=5e-3;%��˹����Ȩ����ֵ
I=find(w_k>=T);        
l=0;
w_bar_k = [];
m_bar_k = [];
P_bar_k = [];
L_bar_k = [];
while isempty(I)==false  %��I����Ԫ��ʱ������true��ѭ������
   l=l+1;
   %�ڷ���Ҫ���Ȩ�����ҳ�����Ȩ������Ӧ�ĵ�λ��
   heighweight=w_k(I);
   [maxW,j]=max(heighweight);
   j=I(j);
   L=[];
   for m=1:length(I)
       thisI=I(m);
       delta_m=m_k(:,thisI)-m_k(:,j);
       distance=delta_m'*inv(P_k(:,thisI*4-3:thisI*4))*delta_m;
%        distance=sqrt(delta_m' * delta_m);
       if (distance<4)
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
   L_bar_k_sum = zeros(3,1);
   %Label�ϲ���������L�����Ԫ�ر�ǩ���кϲ�����
   L_yingshe = L_k(1,L) * 10 +  L_k(2,L) + L_k(3,L) * 2000;
   [L_min,L_min_Index] = min(L_yingshe);
   L_bar_k_sum = L_k(:,L(L_min_Index(1)));
   for m=1:length(L)
      remove_index=find(I==L(m));
      I(remove_index)=[];
   end
    w_bar_k=[w_bar_k,w_bar_k_sum];
    m_bar_k=[m_bar_k,m_bar_k_sum];
    P_bar_k=[P_bar_k,P_bar_k_l];
    L_bar_k = [L_bar_k,L_bar_k_sum];
end
numTarget_k=length(w_bar_k);






 
%**********************************************
%              GM_PHD״̬��ȡ
%    ��Ȩ�ش���0.5�ĸ�˹��������״̬��ȡ
%**********************************************
x_k=[];
x_k_w=[];
x_k_P=[];
x_k_L = [];
gate=0.5;
I=find(w_bar_k>gate);
x_k = m_bar_k(:,I);
x_k_w = w_bar_k(:,I);
x_k_L = L_bar_k(:,I)
for j=1:length(I)
   thisI=I(j);
   thisP=P_bar_k(:,4*thisI-3:4*thisI);
   x_k_P=[x_k_P,thisP];
end
x_k_history=[x_k_history,x_k];
L_k_history=[L_k_history,x_k_L];
%****************************************************
%          GM_PHD����Ŀ����������
%          ��������ʱ�̵Ĺ۲�ֵ�ж���������Ŀ��
%          ��Ϊ���Ĺ۲�Ϊ����Ŀ�꣬����Ȩ�ؽ��е���
%****************************************************
w_birth = [];
m_birth = [];
P_birth = [];
Label_birth = [];%��¼������ǩ
number_birth = 0;%��¼��������
numTargetbirth = 0;
MAX_V=100;
max_v=30;
if (k>=2)
    thisZ_index=k;
    preZ_index=k-1;
    thisZ=Z_clutter{thisZ_index};
    preZ=Z_clutter{preZ_index};
        for j_this = 1:size(thisZ,2)%1:52
                for j_prev = 1:1:size(preZ,2)%Match every pair from previous to current 1:52
                    m_this = thisZ(:,j_this);%kʱ�̹۲�����
                    m_prev = preZ(:,j_prev);%k-1ʱ�̹۲�����
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
                    m_i = [m_i(1), thisV(1),m_i(2),thisV(2)]';%���ٶȹ��Ƽ���۲�
%                     birthWeight = 0.1*mvnpdf(m_i([1,3]),Target1([1,3],1),diag([400,400]'))+0.1*mvnpdf(m_i([1,3]),Target2([1,3],1),diag([400,400]'))+0.1*mvnpdf(m_i([1,3]),Target3([1,3],1),diag([400,400]'))+0.1*mvnpdf(m_i([1,3]),Target4([1,3],1),diag([400,400]'))+0.1*mvnpdf(m_i([1,3]),Target5([1,3],1),diag([400,400]'))+0.1*mvnpdf(m_i([1,3]),Target6([1,3],1),diag([400,400]'));
                      birthWeight = 0.01;
                        %Birth the target
                        w_i = birthWeight;
                        %Initialise the covariance
                        P_i = diag([100, 25, 100, 25]');
                        numTargetbirth = numTargetbirth + 1;
                        label = [k - 1;numTargetbirth;1];%��һ�б�ʾ����ʱ�䣬�ڶ��б�ʾ���������������б�ʾ���ԵĴ��������
                        w_birth = [w_birth, w_i];
                        m_birth = [m_birth,m_i];
                        P_birth = [P_birth, P_i];
                        Label_birth = [Label_birth,label];
                    end                
                end
            end
end

