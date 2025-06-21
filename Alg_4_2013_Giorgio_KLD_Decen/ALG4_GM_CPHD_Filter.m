function [x_k_history,Birth,w_bar_k, m_bar_k, P_bar_k,Output,cdn_update] = ALG4_GM_CPHD_Filter(Birth,F,Q,R,...
    w_k_1,m_k_1,P_k_1,Z,Z_clutter,nClutter,detect_prob,x_k_history,cdn_update,k,location)
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
%�������������������(n_Max)����ʼ����Ԥ�⣨cdn_Update��,Ps

w_birth = Birth.w_birth;
m_birth = Birth.m_birth;
P_birth = Birth.P_birth;
numTargetbirth = Birth.numTargetbirth;


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
survive_prob=0.99;%��ǰ״̬�Դ��ڵĿ�����
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
numTargetk_k_1=i;%Ԥ������ܶȺ�����˹�����ĸ���

%������Ԥ��
if k >= 3
    n_max=20;
    survive_cdn_predict = zeros(n_max+1,1);
    for j = 0:n_max
        idxj=j+1;
        terms=zeros(n_max+1,1);
        for ell =j:n_max
            idxl=ell+1;
            terms(idxl)=exp(sum(log(1:ell))-sum(log(1:j))-sum(log(1:ell-j))+j*log(survive_prob)+(ell-j)*log(1-survive_prob))*cdn_update(idxl);
        end
        survive_cdn_predict(idxj) = sum(terms);
    end
    %����Ԥ��=�������ֲ�����������ֲ��ľ��
    cdn_predict = zeros(n_max+1,1);
    for n = 0:n_max
        idxn = n+1;
        terms=zeros(n_max+1,1);
        for j=0:n
            idxj = j+1;
            terms(idxj)=exp(-sum(w_birth)+(n-j)*log(sum(w_birth))-sum(log(1:n-j)))*survive_cdn_predict(idxj);
        end
        cdn_predict(idxn) = sum(terms);
    end
    cdn_predict = cdn_predict/sum(cdn_predict);
end





%************************************************
%                GM_PHD���²�
%************************************************
%���²�������Ҫ�Ĳ���
Z_predict=[];%�۲�Ԥ��
S=[];%Э����Ԥ��
K=[];%kalman����
Pk_k=[];%Э�������
dis = @(x,y)sqrt((x.^2 + y.^2));
%====UT�任��������====%
alpha = 1;kappa = 2;beta = 2;
for j=1:numTargetk_k_1
    %=======����UT�任=======%
        %====һ�������õ�Sigma��====%
    [Xi,Wi,Pi] = ALG4_ut(mk_k_1(:,j),Pk_k_1(:,(j-1)*4+1:j*4),alpha,kappa,beta);
        %====����ʹ��Sigma�������ɹ۲�Ԥ��ֵ====%
     Ob_Station = repmat(location,1,length(Wi));
     Zi = [dis(Xi(1,:)-Ob_Station(1,:),Xi(3,:)-Ob_Station(2,:));atan2d(Xi(3,:)-Ob_Station(2,:),Xi(1,:)-Ob_Station(1,:))];
% Zi = [dis(Xi(1,:),Xi(3,:));atan2d(Xi(3,:),Xi(1,:))];
     index = find(Zi(2,:) < 0);
     Zi(2,index) = Zi(2,index) + 360;
        %====����ͨ����Ȩ��͵õ�ϵͳԤ��ľ�ֵ��Э����====%
     eta = Zi*Wi(:);%Sigma��۲��ֵ
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
%���²������ù۲�Ը�˹�������и���
w_k=[];
m_k=[];
P_k=[];
for j=1:numTargetk_k_1
   w_k(:,j)=(1-detect_prob)*wk_k_1(:,j);
   m_k(:,j)=mk_k_1(:,j);
   P_k(:,(j-1)*4+1:j*4)=Pk_k_1(:,(j-1)*4+1:j*4);
end

L=0;
% model.H = H;
% model.R = R;
% gamma= chi2inv(0.999,2); 
%����ָ�
% Z = ALG4_gate_meas_ukf(Z,gamma,mk_k_1,Pk_k_1,alpha,kappa,beta);
for j=1:size(Z,2)
    L=L+1;
    for i=1:numTargetk_k_1
%        w_k(L*numTargetk_k_1+i)=detect_prob*wk_k_1(:,i)*mvnpdf(Z(:,j),Z_predict(:,i),S(:,2*i-1:2*i));
       w_k(L*numTargetk_k_1+i)=exp(-0.5*(Z(:,j)-Z_predict(:,i))'...
            /S(:,2*i-1:2*i)*(Z(:,j)-Z_predict(:,i)))/sqrt(det(S(:,2*i-1:2*i))*(2*pi)^2);
       m_k(:,L*numTargetk_k_1+i)=mk_k_1(:,i)+K(:,2*i-1:2*i)*(Z(:,j)-Z_predict(:,i));
       P_k(:,L*numTargetk_k_1*4+1+(i-1)*4:L*numTargetk_k_1*4+4+(i-1)*4)=Pk_k(:,(i-1)*4+1:i*4);
    end
    
end
    numTarget_k=(L+1)*numTargetk_k_1;%��������ܶȺ����и�˹�����ĸ���
    
    
    
 %*******************************************************
%***********************************************************************
m=size(Z,2);
XI_vals=zeros(m,1);
if k >= 3
for ell=1:m
    XI_vals(ell)=detect_prob*wk_k_1*w_k(:,ell*numTargetk_k_1+1:(ell+1)*numTargetk_k_1)'*(10000*10000*pi);
end
esfvals_E = ALG4_esf(XI_vals);
esfavls_D = zeros(m,m);
for ell=1:m
    esfvals_D(:,ell) = ALG4_esf([XI_vals(1:ell-1);XI_vals(ell+1:m)]);
end
%upsilons ��Ԥ����
upsilon0_E = zeros(n_max+1,1);
upsilon1_E = zeros(n_max+1,1);
upsilon1_D = zeros(n_max+1,m);

for n=0:n_max
    idxn= n+1;
    
    terms0_E= zeros(min(m,n)+1,1);  %calculate upsilon0_E(idxn)
    for j=0:min(m,n)
        idxj= j+1;
        terms0_E(idxj) = exp(-nClutter+(m-j)*log(nClutter)+sum(log(1:n))-sum(log(1:n-j))+(n-j)*log(1-detect_prob)-j*log(sum(wk_k_1)))*esfvals_E(idxj);
    end
    upsilon0_E(idxn)= sum(terms0_E);
    
    terms1_E= zeros(min(m,n)+1,1);  %calculate upsilon1_E(idxn)
    for j=0:min(m,n)
        idxj= j+1;
        if n>=j+1
            terms1_E(idxj) = exp(-nClutter+(m-j)*log(nClutter)+sum(log(1:n))-sum(log(1:n-(j+1)))+(n-(j+1))*log(1-detect_prob)-(j+1)*log(sum(wk_k_1)))*esfvals_E(idxj);
        end
    end
    upsilon1_E(idxn)= sum(terms1_E);
    
    if m~= 0                        %calculate upsilon1_D(idxn,:) if m>0
        terms1_D= zeros(min((m-1),n)+1,m);
        for ell=1:m
            for j=0:min((m-1),n)
                idxj= j+1;
                if n>=j+1
                    terms1_D(idxj,ell) = exp(-nClutter+((m-1)-j)*log(nClutter)+sum(log(1:n))-sum(log(1:n-(j+1)))+(n-(j+1))*log(1-detect_prob)-(j+1)*log(sum(wk_k_1)))*esfvals_D(idxj,ell);
                end
            end
        end
        upsilon1_D(idxn,:)= sum(terms1_D,1);
    end
end
%δ��⵽�Ĺ۲�
w_k(1:numTargetk_k_1)=(upsilon1_E'*cdn_predict)/(upsilon0_E'*cdn_predict)*w_k(:,1:numTargetk_k_1)';
for ell=1:m
    w_k(ell*numTargetk_k_1+1:(ell+1)*numTargetk_k_1)= (upsilon1_D(:,ell)'*cdn_predict)/(upsilon0_E'*cdn_predict)*...
        detect_prob.*w_k(:,ell*numTargetk_k_1+1:(ell+1)*numTargetk_k_1)'*(10000*10000*pi).*wk_k_1';
end
%��������
    cdn_update= upsilon0_E.*cdn_predict;
    cdn_update= cdn_update/sum(cdn_update);
end
%*************************************************
%        GM_PHD��֦����
%        ȥ����������ܶȺ�����Ȩ��С�ĸ�˹����
%        �Ӷ�����������
%        �������Ƶĸ�˹�������кϲ�����
%*************************************************
T=1e-3;%��˹����Ȩ����ֵ
I=find(w_k>=T);
l=0;
w_bar_k = [];
m_bar_k = [];
P_bar_k = [];

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
%              GM_PHD״̬��ȡ
%    ��Ȩ�ش���0.5�ĸ�˹��������״̬��ȡ
%**********************************************

x_k=[];
x_k_w=[];
x_k_P=[];
[~,idx_max_cdn] = max(cdn_update);
map_cdn = idx_max_cdn-1;
N_k=min(length(w_bar_k),map_cdn);
[~,idx_m_srt]= sort(-w_bar_k);
x_k=m_bar_k(:,idx_m_srt(1:N_k));
x_k_w=w_bar_k(:,idx_m_srt(1:N_k));
for j=1:N_k
    x_k_P=[ x_k_P,P_bar_k(:,idx_m_srt(j)*4-3:idx_m_srt(j)*4)];
end


    
x_k_history=[x_k_history,x_k];

%****************************************************
%          GM_PHD����Ŀ����������
%          ��������ʱ�̵Ĺ۲�ֵ�ж���������Ŀ��
%          ��Ϊ���Ĺ۲�Ϊ����Ŀ�꣬����Ȩ�ؽ��е���
%****************************************************
w_birth = [];
m_birth = [];
P_birth = [];
numTargetbirth = 0;
MAX_V=100;
max_v=50;
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
                      birthWeight = 0.1;
                        %Birth the target
                        w_i = birthWeight;
                        %Initialise the covariance
                        P_i = diag([500, 40, 500, 40]');
                        w_birth = [w_birth, w_i];
                        m_birth = [m_birth,m_i];
                        P_birth = [P_birth, P_i];
                        numTargetbirth = numTargetbirth + 1;
                    end                
                end
end


if isempty(w_birth) 
    Birth.w_birth = eps;
    Birth.m_birth = [0;0;0;0];
    Birth.P_birth = diag([500, 40, 500, 40]');
    Birth.numTargetbirth = 1;
else
    Birth.w_birth = w_birth;
    Birth.m_birth = m_birth;
    Birth.P_birth = P_birth ;
    Birth.numTargetbirth = numTargetbirth;
    
end

Output.x_k = x_k;
Output.x_k_w = x_k_w;
Output.x_k_P = x_k_P; 
Output.N_k = N_k; 

end


