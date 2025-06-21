%{
%%***********************************************************************************
%     
%                            ����ʱ�̵�PHD�������(��ǶUKF)
%        
%       ���룺 Z_bef1_d : �ϸ�ʱ�̵ѿ�������ϵ�۲�        -- 6*<�۲�����> double����
%              Z_bef2_d  : ��ǰʱ�̵ĵѿ�������ϵ�۲�      -- 6*<�۲�����> double����
%              Z_now_p  : ��ǰʱ�̼�����۲�              -- 6*<�۲�����> double����
%              X_new    : �ϸ�ʱ����������                -- 4*1 cell
%              X_last   : ��һʱ��PHDȫ�ֺ������         -- 4*1 cell
%              Zr,A,Q,R,Psk,Pdk     -- �Ӳ�ǿ�ȣ����ϵͳ����,��������ʼ��ֵ����
%              Vx_max,Vy_max,Vz_max -- ���������������������ٶ��趨
%
%       ���������֮������Ӽ���4*1cell��
%
%**************************************************************************************
%}
function [X_now]=ALG5_PHD1time_3d_ukf_decen(Z_bef1_d,Z_bef2_d,Z_now_p,X_last,Zr,R,Psk,Pdk,Vx_thre,...
                                       Vy_thre,Vz_thre,x_radar,y_radar,z_radar,ID_sensor)

T=1;
A=[1 T 0 0 0 0;0 1 0 0 0 0;0 0 1 T 0 0;0 0 0 1 0 0;0 0 0 0 1 T;0 0 0 0 0 1];
Q=diag([1,0.1,1,0.1,1,0.1]);


w_priori=X_last{1,1};%%Ȩ��
m_priori=X_last{2,1};%%��ֵ
P_priori=X_last{3,1};%%Э����
J_priori=X_last{4,1};%%������������

w_pre(1,10000)=0;
m_pre=zeros(6,1);
P_pre=zeros(6,6);
% J_pre=0;
Z_obpre=zeros(3,1);%%�Թ۲�ֵ��Ԥ��

w_pos(1,20000)=0;
m_pos=zeros(6,1);
P_pos=zeros(6,6);
% J_pos=0;

P_z=eye(3);%%Ԥ���Э����
K_ukf=zeros(6,3);%%�����ʼ��
P_ukf=zeros(6,6);%%��ʼ��


[~,n_zbef1]=size(Z_bef1_d);
[~,n_zbef2]=size(Z_bef2_d);
[w_new,m_new,P_new,J_new]=generate(Z_bef1_d,n_zbef1,Z_bef2_d,n_zbef2,Vx_thre,Vy_thre,Vz_thre);

i=0;%�����ϸ�˹��������
for j=1:J_new
    i=i+1;
    w_pre(1,i)=w_new(1,i);
    m_pre(:,i)=A*m_new(:,i);%%���������ӽ���һ��Ԥ��
    P_pre(:,6*(i-1)+1:6*i)=A*P_new(:,6*(i-1)+1:6*i)*A'+Q;
end

for j=1:J_priori
    i=i+1;
    w_pre(1,i)=Psk*w_priori(1,j);
    m_pre(:,i)=A*m_priori(:,j);
    P_pre(:,6*(i-1)+1:6*i)=Q+A*P_priori(:,6*(j-1)+1:6*j)*A';
end

J_pre=i;%%Ԥ��֮���˹���ģ�͵ķ���������Ŀ����,��û��Ŀ��������ֱ������Ϊ�ռ�
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
    
    % �������
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

%     T=0.01;%%�趨��֦��ֵ
    T=0.2*(1-Pdk)*0.99 + 0.00001;
    U=135;%%�ϲ�����
    Jmax=200;%%���������˹������
    I=cell(3,1);%%�����������ϣ��ֱ�����֦����Ļ�ϸ�˹����,Ȩ�أ���ֵ������
    k=0;
 
    for i=1:J_pos
        if w_pos(1,i)>=T
            k=k+1;
            I{1,1}(1,k)=w_pos(1,i);%%Ȩֵ�ɼ�
            I{2,1}(:,k)=m_pos(:,i);%%��ֵ�ɼ�
            I{3,1}(:,6*(k-1)+1:6*k)=P_pos(:,6*(i-1)+1:6*i);%%Э����ɼ�
        end
    end
    Jj=k;%%I������������������

    W_phd=zeros(1,Jj);
    M_phd=zeros(6,Jj);
    P_phd=zeros(6,6*Jj);
    e=0;
    Jj_copy=Jj;
    while Jj>0
        e=e+1;
        wmax=max(I{1,1}(1,:));%%�ҵ�I{1��1}(1,:)����Ȩֵ
        [~,col]=find(I{1,1}(1,:)==wmax);%%col��ֵ�������Ȩֵ��λ��
        k=0;%%��������ÿ��ѭ���д�I�����ߵĸ���
        c=zeros(1,Jj);%%c����������¼I�з����ںϵķ�������
        L=cell(3,1);%%�ѷ��ϵķ�������L�У�L������Ԫ�����ֱ����Ȩֵ����ֵ������
        for i=1:Jj
            
            % ��ŷʽ�������ж�
            if sqrt(( I{2,1}([1,3,5],i)-I{2,1}([1,3,5],col(1,1)))'*(I{2,1}([1,3,5],i)-I{2,1}([1,3,5],col(1,1))))<=U                    
                k=k+1;
                c(k)=i;
                L{1,1}(1,k)=I{1,1}(1,i);
                L{2,1}(:,k)=I{2,1}(:,i);
                L{3,1}(:,6*(k-1)+1:6*k)=I{3,1}(:,6*(i-1)+1:6*i);
                
            end
            
        end
        c(k+1:Jj)=[];%%�ͷ��ڴ�
        %%���ˣ�����һ��ѭ������Ҫ�ںϵĲ���ȫ��������L�У�����Ϊk��
        %%Ȩֵ����
        W_phd(1,e)=sum(L{1,1}(1,:));
        %%��ֵ����
        M_phd(:,e)=[0 0 0 0 0 0]';
        for i=1:k %%k����L�еķ�������
            M_phd(1:6,e)=M_phd(1:6,e)+L{1,1}(1,i)*L{2,1}(1:6,i);
        end
        M_phd(1:6,e)=M_phd(1:6,e)/W_phd(1,e);%%��ֵ
        %%Э�������
        P_phd(:,6*(e-1)+1:6*e)=zeros(6,6);
        for i=1:k %%k����L�еķ�������
            P_phd(:,6*(e-1)+1:6*e)=P_phd(:,6*(e-1)+1:6*e)+L{1,1}(1,i)*(L{3,1}(:,6*(i-1)+1:6*i)+(M_phd(1:6,e)-L{2,1}(1:6,i))*(M_phd(1:6,e)-L{2,1}(1:6,i))');
        end
        P_phd(:,6*(e-1)+1:6*e)=P_phd(:,6*(e-1)+1:6*e)/W_phd(1,e);%%Э����
        %ɾ��I�������ںϵ�Ȩֵ
        I{1,1}(:,c)=[];
        %%ɾ��I�������ںϵľ�ֵ
        I{2,1}(:,c)=[];
        %%����ɾ��I�������ںϵ�Э����
        I{3,1}(:,6*(c(1)-1)+1:6*c(1))=[];
        for i=2:k
            I{3,1}(:,6*(c(i)-i)+1:6*(c(i)-i+1))=[];%%����ɾ��I�������ںϵ�Э����
        end
        %%����ʣ������
        Jj=Jj-k;%%I��ʣ������ĸ�������Ϊ��ʱ������ѭ��
    end
    %%�ͷ��ڴ�
    W_phd(e+1:Jj_copy)=[];
    M_phd(:,e+1:Jj_copy)=[];
    P_phd(:,6*e+1:6*Jj_copy)=[];
    
    if e>Jmax
        for i=1:Jmax
            wmax=max(W_phd(1,:));%%�ҵ����ֵ
            col=find((W_phd(1,:)-wmax)<0.0001);
            G=cell(3,1);%%��������G�����Ȩֵ����ֵ�ͷ���
            G{1,1}(:,i)=W_phd(:,col(1));%%Ȩֵ�ɼ�
            G{2,1}(:,i)=M_phd(:,col(1));%%��ֵ�ɼ�
            G{3,1}(:,6*(i-1)+1:6*i)=P_phd(:,6*(col(1)-1)+1:6*col(1));%%Э����ɼ�
            W_phd(:,col(1))=[];%%ɾ������Ȩֵ
            M_phd(:,col(1))=[];%%ɾ�����Ȩֵ��Ӧ�ľ�ֵ
            P_phd(:,6*(col(1)-1)+1:6*col(1))=[];%%����ɾ�����Ȩֵ��Ӧ��Э����
        end
        %%�õ�����Ȩֵ����ֵ�ͷ���ٷŻ�Wphd,Mphd,Pphd��
        W_phd=[0;0];%%����
        M_phd=zeros(6,1);%%����
        P_phd=zeros(6,6);%%����
        for i=1:Jmax
            W_phd(:,i)=G{1,1}(:,i);
            M_phd(:,i)=G{2,1}(:,i);
            P_phd(:,6*(i-1)+1:6*i)=G{3,1}(:,6*(i-1)+1:6*i);
        end
        e=200;
    end
end

X_now=cell(4,1);
X_now{1,1}=W_phd;
X_now{2,1}=[M_phd;ID_sensor*ones(1,size(M_phd,2))];
X_now{3,1}=P_phd;
X_now{4,1}=e; %����Ŀ����

end


%%**************************************************************************************************
%                                 ����������ʼ����
%%**************************************************************************************************
%%˵��������Ϊ��һʱ�̵Ĺ۲⼯(����3*?)����۲��������һʱ�̵Ĺ۲⼯(����3*?)�������,�Լ������������ֵ
%%���Ϊ��ʱ��������(�������ʽ6*?),%%ע���������Եѿ�������Ĳ�ֵ������������ʼ��
function [w_new,m_new,P_new,J_new]=generate(z_last,n_last,z_now,n_now,Vx_thre,Vy_thre,Vz_thre)
w_new=zeros(1,n_last*n_now);%%�������Ϊn_last*n_now
m_new=zeros(6,n_last*n_now);
P_new=zeros(6,6*n_last*n_now);
Vx_max = 20;
Vy_max = 20;
Vz_max = 5;
k=0;%%���������ĸ���
for i=1:n_now
    for j=1:n_last
        z_delta=z_now(:,i)-z_last(:,j);
        if abs(z_delta(1,1))<Vx_thre&&abs(z_delta(2,1))<Vy_thre&&abs(z_delta(3,1))<Vz_thre
            k=k+1; % ������������ 
            % X���ٶ�
            % �ж��Ƿ񵽴�����ٶȣ��Լ��ٶȵķ�����ͬ
            if abs(z_delta(1,1))>Vx_max && z_delta(1,1)>=0
                m_new(2,k)=Vx_max;
            elseif abs(z_delta(1,1))>Vx_max && z_delta(1,1)<0
                m_new(2,k)=-Vx_max;
            else
                m_new(2,k)=z_delta(1,1);%%X���ٶ�
            end
            %   Y���ٶ�
            if abs(z_delta(2,1))>Vy_max && z_delta(2,1)>=0
                m_new(4,k)=Vy_max;
            elseif abs(z_delta(2,1))>Vy_max && z_delta(2,1)<0
                m_new(4,k)=-Vy_max;
            else
                m_new(4,k)=z_delta(2,1);%%Y���ٶ�
            end
            %   Z���ٶ�
            if abs(z_delta(3,1))>Vz_max && z_delta(3,1)>=0
                m_new(6,k)=Vz_max;
            elseif abs(z_delta(3,1))>Vz_max && z_delta(3,1)<0
                m_new(6,k)=-Vz_max;
            else
                m_new(6,k)=z_delta(3,1);%%Z���ٶ�
            end
            m_new(1,k)=z_now(1,i); % Xλ��
            m_new(3,k)=z_now(2,i); % Y��λ��
            m_new(5,k)=z_now(3,i); % Z��λ��
            w_new(1,k)=0.2;        % ����������Ȩ������
            P_new(:,6*(k-1)+1:6*k) = diag([1000 100 1000 100 1000 100]);%%����������Э����  
        end
    end
end
%%���˵õ����ܵ�������������w_new��m_new��P_new����Ϊk
w_new((k+1):n_last*n_now)=[];%%��Ϊ��ķ���ɾȥ
m_new(:,(k+1):n_last*n_now)=[];
P_new(:,6*k+1:6*n_last*n_now)=[];
J_new=k;

end


%%*******************************************************************************************************************
%%PHD�����е�UKF���֣��������·���PHDȨ���ṩ1.�۲�Ԥ��״̬�õ���ֵ��2.�۲�֮���Э���3.UKF�������;4.�����µ�Э����
%%����:1.Ԥ��Ŀ���״̬(һ��Ԥ���˹���ӵ�״̬)6*1;2.��Ӧ��Э����6*6
%%���:1.�۲�Ԥ��״̬�õ���ֵ��2.�۲�֮���Э���3.UKF�������;4.�����µ�Э����5.�Ƕ������־
%%*******************************************************************************************************************
function [Z_fusion_ob,P_fusion_ob,k_ukf,Pnew,flag_jump]=UKFpart(X_fusion_pre,P_fusion_pre,R,x_radar,y_radar,z_radar)
%%UKF��������
Variable_dimension=size(X_fusion_pre,1); 
Z_ob_diffusion=zeros(3,2*Variable_dimension+1);%�ɵڶ��εõ���sigama�����ó��Ĺ۲�ֵ
w_m=zeros(1,2*Variable_dimension+1);
w_P=zeros(1,2*Variable_dimension+1);
alpha=0.1;%��
beta=2;%��
kap=0;%��
lambda=(alpha^2)*(Variable_dimension+kap)-Variable_dimension;%��

X_pre_diffusion=zeros(6,2*Variable_dimension+1);%�ڶ��εõ���sigama��ֲ�
X_pre_diffusion(:,1)=X_fusion_pre;

try chol( P_fusion_pre );
catch
    % ����ֵ�ֽ�
    [~,S,V]=svd(P_fusion_pre);
    H = V*S*V';
    P_fusion_pre = ( P_fusion_pre + P_fusion_pre'+ H + H')/4;
end

degree_diffusion=real(sqrtm((Variable_dimension+lambda)*P_fusion_pre)');%%�ֲ��̶ȣ�Ϊ6*6�ľ���

%**************************************************************************
for i=1:Variable_dimension
    X_pre_diffusion(:,i+1)=X_fusion_pre+degree_diffusion(:,i);
    X_pre_diffusion(:,i+Variable_dimension+1)=X_fusion_pre-degree_diffusion(:,i);
end
%Ȩֵ����
w_m(1)=lambda/(Variable_dimension+lambda);
w_P(1)=lambda/(Variable_dimension+lambda)+(1-alpha^2+beta);
for i=1:2*Variable_dimension
    w_m(i+1)=0.5/(Variable_dimension+lambda);
    w_P(i+1)=0.5/(Variable_dimension+lambda);
end

for i=1:2*Variable_dimension+1

    Z_ob_diffusion(1,i)=sqrt(( X_pre_diffusion(1,i)-x_radar)^2+(X_pre_diffusion(3,i)-y_radar)^2+( X_pre_diffusion(5,i)-z_radar)^2);%%�����ԵĹ۲ⷽ��

    theta_sus_head=rad2deg(atan((X_pre_diffusion(3,i)-y_radar)/(X_pre_diffusion(1,i)-x_radar)));
    if X_pre_diffusion(1,i)-x_radar>=0&&X_pre_diffusion(3,i)-y_radar>=0 %%��1����
        Z_ob_diffusion(2,i)=theta_sus_head;
    elseif X_pre_diffusion(1,i)-x_radar<0&&X_pre_diffusion(3,i)-y_radar>=0 %%��2����
        Z_ob_diffusion(2,i)=theta_sus_head+180;
    elseif X_pre_diffusion(1,i)-x_radar<0&&X_pre_diffusion(3,i)-y_radar<0 %%��3����
        Z_ob_diffusion(2,i)=theta_sus_head+180;
    elseif X_pre_diffusion(1,i)-x_radar>=0&&X_pre_diffusion(3,i)-y_radar<0 %%��4����
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

if max_theta>180%%��ʾ��������ĵ�
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
%ukf��ֵ�����
%���룺1.����ֵ6*1�����飻2.��ǰʱ�̵Ĺ۲�ֵ3*1�����飻3.Ԥ��״̬�Ĺ۲�ֵ3*1�����飻4.UKF���棻4.�����־λ
%�����1.��ǰ״̬����ֵ6*1������
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