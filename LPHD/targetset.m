%{
                       ����Ŀ���˶���������

         ���ܣ��������÷����Ŀ������ʱ�̵��˶�״̬

         ���룺��������N��Ŀ���˶�ģʽ���

         �����1.Xreal_target_time -- ����Ŀ������ʱ�̵��˶�״̬  
               2.Xreal_time_target -- ����ʱ������Ŀ����˶�״̬   

%}
function [Xreal_target_time,Xreal_time_target]=targetset(N,Target)

n_target=size(Target,2); % Ŀ������
Xreal_target_time=cell(n_target,1); % ���ÿ��Ŀ������ʱ�̵�״̬


%=====ģ����ʵֵ======
for i=1:n_target
    Xreal_target_time{i,1}=m1_CV(Target(:,i),N);
end

%====��ʵֵ��ʽת����ת��Ϊ����ʱ��������ʵĿ��״̬����ʽ====
Xreal_time_target=cell(N,1);
for i=1:N
    for k=1:n_target
        Xreal_time_target{i,1}(:,k)=Xreal_target_time{k,1}(:,i);
    end
end

end

%*********************************************
%˵��:ģʽ1:����ֱ���˶�CV+�Ŷ�
%����:1.Ŀ��ĳ�ʼ״̬ 2.���������� 
%���:1.���г�Ա����ʱ�̵��˶�״̬��num_member*1��cell���飬����ÿ��cellΪ6*N��double����
function [state]=m1_CV(initial_state,N)

%=====�˶�ģ�Ͳ���=====
T=1; % ����
A=[1 T 0 0 0 0;0 1 0 0 0 0;0 0 1 T 0 0;0 0 0 1 0 0;0 0 0 0 1 T;0 0 0 0 0 1]; % �˶�ģ��
Q=1e-3 * diag([1,0.01,1,0.01,1,0.01]); % �Ŷ�

[dim_state,num_member]=size(initial_state); % ״̬ά��,��Ա����
dim_state=dim_state-2; % ״̬ά����Ҫ��ȥ��ʼʱ�䡢��ֹʱ�䡢�˶�ģʽ

member_state=cell(num_member,1); % ���г�Ա����ʱ�̵��˶�״̬
for i=1:num_member
    member_state{i,1}=zeros(dim_state,N); % Ԥ�������ڴ�
end

% Ŀ�����ʵ�켣����
for i=1:num_member
    
    begin_time=initial_state(7,i); % Ŀ���˶���ʼʱ��
    end_time=initial_state(8,i);   % Ŀ���˶�����ʱ��
    member_state{i,1}(:,1:begin_time-1)=nan(dim_state,begin_time-1); % Ŀ�����ǰʱ�̸�ֵ
    member_state{i,1}(:,begin_time)=initial_state(1:6,i);            % ����ʱ�̳�ʼֵ��ֵ
    for j=begin_time+1:end_time
        member_state{i,1}(:,j)=A*member_state{i,1}(:,j-1)+sqrtm(Q)*randn(6,1); % �˶�����
    end
    member_state{i,1}(:,end_time+1:N)=nan(dim_state,N-end_time); % Ŀ����ʧ���ʱ�̸�ֵ
    
end
% ��ǰģʽ��ÿ��ֻ��һ��Ŀ����з���
state=member_state{1,1};
end





