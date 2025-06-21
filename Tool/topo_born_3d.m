%***************************************************************
%
%               ����ͼ�Զ����ɺ���
% 
%      ����: 1. num_sensor -- ����������
%            2. location_center -- ƽ̨���ĵ�
%            3. r_interval -- ƽ̨�ļ��
%            4. r_communicate -- ͨ�Ű뾶
% 
%      ���: 1. mat_topo -- ƽ̨���������˾���
%            2. location -- ƽ̨�����꼰���
%
%      ˵��: ����ͼ��Ϊ �������ΰ����������ε���ʽ��չ
%
%***************************************************************
function [mat_topo,location]=topo_born_3d(num_sensor,location_center,r_interval,r_communicate)
% ��ʼ��
location=zeros(4,num_sensor);     % ǰ��ά�����꣬���һά�Ǳ��
location(:,1)=location_center;    % ����ƽ̨�ı��Ĭ��Ϊ1
state_now=location_center(1:3,1); % ��ǰ״̬
S=1; % ״̬�����
num_seted=1; % �Ѿ����õ�ƽ̨����
num_loop=0;  % ����
%=============��������====================
while(num_seted<num_sensor)

    %==========״̬1=============
    if S==1
        state_now=state_now+[-r_interval;0;0]; 
        num_seted=num_seted+1; 
        location(1:3,num_seted)=state_now; 
        location(4,num_seted)=num_seted;
        S=2; 
        num_loop=num_loop+1;
    %==========״̬2=============
    elseif S==2
        for i=1:num_loop
            state_now=state_now+[r_interval/2;sqrt(3)*r_interval/2;0];
            num_seted=num_seted+1; 
            location(1:3,num_seted)=state_now; 
            location(4,num_seted)=num_seted;
        end
        S=3; 
        
    %==========״̬3=============
    elseif S==3
        for i=1:num_loop
            state_now=state_now+[r_interval;0;0]; 
            num_seted=num_seted+1; 
            location(1:3,num_seted)=state_now; 
            location(4,num_seted)=num_seted;
        end
        S=4; 
        
    %==========״̬4=============    
    elseif S==4
        for i=1:num_loop
            state_now=state_now+[r_interval/2;-sqrt(3)*r_interval/2;0];
            num_seted=num_seted+1; 
            location(1:3,num_seted)=state_now; 
            location(4,num_seted)=num_seted;
        end
        S=5;
        
    %==========״̬5=============     
    elseif S==5
        for i=1:num_loop
            state_now=state_now+[-r_interval/2;-sqrt(3)*r_interval/2;0]; 
            num_seted=num_seted+1; 
            location(1:3,num_seted)=state_now; 
            location(4,num_seted)=num_seted;
        end
        S=6; 
    
    %==========״̬6=============      
    elseif S==6
        for i=1:num_loop
            state_now=state_now+[-r_interval;0;0]; 
            num_seted=num_seted+1; 
            location(1:3,num_seted)=state_now; 
            location(4,num_seted)=num_seted;
        end
        S=7; 

    %==========״̬7=============
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
%                                �������Ӿ�������
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