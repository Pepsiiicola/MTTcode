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

fun_motion_pattern={@m1_CV,@m2_CA,@m3_CT}; 

%=====ģ����ʵֵ======
for i=1:n_target
    Xreal_target_time{i,1}=fun_motion_pattern{Target(9,i)}(Target(:,i),N);
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
Q=diag([1,0.01,1,0.01,1,0.01]); % �Ŷ�

[dim_state,num_member]=size(initial_state); % ״̬ά��,��Ա����
dim_state=dim_state-3; % ״̬ά����Ҫ��ȥ��ʼʱ�䡢��ֹʱ�䡢�˶�ģʽ

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

%*********************************************
%˵��:ģʽ2:�ȼ����˶�CA+�Ŷ�
%����:1.���г�Ա�ĳ�ʼ״̬ 2.�ܵĸ���ʱ����
%���:1.���г�Ա����ʱ�̵��˶�״̬��num_member*1��cell���飬����ÿ��cellΪ6*N��doubel����
function [state]=m2_CA(initial_state,N)

%=====�˶�ģ�Ͳ���=====
V_max=250; % ���������᷽�������ٶ�
a=[1,-1,1]; % ��ά���ٶ�
T=1;
A_part=[1 T 0.5*T^2;
        0 1 T;
        0 0 1]; % ��ά���˶������
A=blkdiag(A_part,A_part,A_part); % ��ά���˶�ģ��
Q=diag([1,0.1,0.1,1,0.1,0.1,1,0.1,0.1]); % �Ŷ�
[dim_state,num_member]=size(initial_state); % ״̬ά��,��Ա����
dim_state=dim_state-3; % ״̬ά����Ҫ��ȥ��ʼʱ�䡢��ֹʱ�䡢�˶�ģʽ

% Ԥ�������ڴ�
member_state=cell(num_member,1); % ���г�Ա����ʱ�̵��˶�״̬
for i=1:num_member
    member_state{i,1}=zeros(dim_state,N);%%Ԥ�������ڴ�
end

% ע:������Ҫ������ٶ����һά���ʱ�ԭ�ȵ�ά��Ҫ��3ά(x,y,z�ļ��ٶ�)
dim_state=dim_state+3;
member_state_exten=cell(num_member,1);%%���г�Ա����ʱ�̵��˶�״̬
for i=1:num_member
    member_state_exten{i,1}=zeros(dim_state,N);%%Ԥ�������ڴ�
end

%%Ŀ�����ʵ�켣����
for i=1:num_member
    begin_time=initial_state(7,i); % Ŀ���˶���ʼʱ��
    end_time=initial_state(8,i);   % Ŀ���˶�����ʱ��
    member_state_exten{i,1}(:,1:begin_time-1)=nan(dim_state,begin_time-1);%%Ŀ�����ǰʱ�̸�ֵ
    %%����ʱ�̳�ʼֵ��ֵ
    %%˵���������ⲿ��6ά���ݣ����ڲ���9ά(�����˼��ٶ�),����Ҫ���½���״̬��ֵ
    %x��
    member_state_exten{i,1}(1:2,begin_time)=initial_state(1:2,i);
    member_state_exten{i,1}(3,begin_time)=a(1);
    %y��
    member_state_exten{i,1}(4:5,begin_time)=initial_state(3:4,i);
    member_state_exten{i,1}(6,begin_time)=a(2);
    %z��
    member_state_exten{i,1}(7:8,begin_time)=initial_state(5:6,i);
    member_state_exten{i,1}(9,begin_time)=a(3);
    %�˶�����
    for j=begin_time+1:end_time
        member_state_exten{i,1}(:,j)=A*member_state_exten{i,1}(:,j-1)+sqrtm(Q)*randn(9,1);
        % �ж��ٶȾ���ֵ�Ƿ�ﵽ��󣬳����趨����ٶ�����ٶȹ���
        if abs( member_state_exten{i,1}(2,j) )>V_max
           member_state_exten{i,1}(2,j)=V_max*member_state_exten{i,1}(2,j)/abs(member_state_exten{i,1}(2,j)); % X���ٶ�
           member_state_exten{i,1}(3,j)=0;%%X����ٶ�
        elseif abs(member_state_exten{i,1}(5,j))>V_max
           member_state_exten{i,1}(5,j)=V_max*member_state_exten{i,1}(5,j)/abs(member_state_exten{i,1}(5,j)); % Y���ٶ�
           member_state_exten{i,1}(6,j)=0;%%Y����ٶ�
        elseif abs(member_state_exten{i,1}(8,j))>V_max
           member_state_exten{i,1}(8,j)=V_max*member_state_exten{i,1}(8,j)/abs(member_state_exten{i,1}(8,j)); % Z���ٶ�
           member_state_exten{i,1}(9,j)=0;%%Z����ٶ�
        end
    end
    member_state_exten{i,1}(:,end_time+1:N)=nan(dim_state,N-end_time);%%Ŀ����ʧ���ʱ�̸�ֵ
end
%��ʽת������9ά��״̬���ݱ��6ά��״̬����
for i=1:num_member
    for j=1:N
    %x��
    member_state{i,1}(1:2,j)=member_state_exten{i,1}(1:2,j);
    %y��
    member_state{i,1}(3:4,j)=member_state_exten{i,1}(4:5,j);
    %z��
    member_state{i,1}(5:6,j)=member_state_exten{i,1}(7:8,j);
    end
end

% ��ǰģʽ��ÿ��ֻ��һ��Ŀ����з���
state=member_state{1,1};

end


%*********************************************
%˵��:ģʽ3:����ת��CT+�Ŷ�
%����:1.���г�Ա�ĳ�ʼ״̬ 2.�ܵĸ���ʱ����
%���:1.���г�Ա����ʱ�̵��˶�״̬��num_member*1��cell���飬����ÿ��cellΪ6*N��doubel����
function [state]=m3_CT(initial_state,N)
%�˶�ģ�Ͳ���
a=[1,1,1]'; % ��ά���ٶ�
T=1;        % ����ʱ��
[dim_state,num_member]=size(initial_state); % ״̬ά��,��Ա����
dim_state=dim_state-3;    % ״̬ά����Ҫ��ȥ��ʼʱ�䡢��ֹʱ�䡢�˶�ģʽ
Q=diag([1,1,1]); % ����ά�ȼ��ٶȵ���������
%%Ԥ�������ڴ�
member_state=cell(num_member,1);%%���г�Ա����ʱ�̵��˶�״̬
for i=1:num_member
    member_state{i,1}=zeros(dim_state,N);%%Ԥ�������ڴ�
end
%%ע:������Ҫ������ٶ����һά���ʱ�ԭ�ȵ�ά��Ҫ��3ά(x,y,z�ļ��ٶ�)
dim_state=dim_state+3;
member_state_exten=cell(num_member,1);%%���г�Ա����ʱ�̵��˶�״̬
for i=1:num_member
    member_state_exten{i,1}=zeros(dim_state,N);%%Ԥ�������ڴ�
end
%%Ŀ�����ʵ�켣����
for i=1:num_member
    begin_time=initial_state(7,i); % Ŀ���˶���ʼʱ��
    end_time=initial_state(8,i);   % Ŀ���˶�����ʱ��
    %%���ٶȵ�ȷ��
    a=a+sqrtm(Q)*randn(3,1);%%���ٶ�����Ӳ�����
    omiga=sqrt(a(1)^2+a(2)^2+a(3)^2)/sqrt(initial_state(2,i)^2+initial_state(4,i)^2+...
        initial_state(6,i)^2);%%���ٶ�
    A_part=[1 sin(omiga*T)/omiga (1-cos(omiga*T))/(omiga^2);
        0 cos(omiga*T) sin(omiga*T)/omiga;
        0 -omiga*sin(omiga*T) cos(omiga*T)];%%��ά���˶������
    A=blkdiag(A_part,A_part,A_part);%%��ά���˶�ģ��
    member_state_exten{i,1}(:,1:begin_time-1)=nan(dim_state,begin_time-1);%%Ŀ�����ǰʱ�̸�ֵ
    %%����ʱ�̳�ʼֵ��ֵ
    %%˵���������ⲿ��6ά���ݣ����ڲ���9ά(�����˼��ٶ�),����Ҫ���½���״̬��ֵ
    %x��
    member_state_exten{i,1}(1:2,begin_time)=initial_state(1:2,i);
    member_state_exten{i,1}(3,begin_time)=a(1);
    %y��
    member_state_exten{i,1}(4:5,begin_time)=initial_state(3:4,i);
    member_state_exten{i,1}(6,begin_time)=a(2);
    %z��
    member_state_exten{i,1}(7:8,begin_time)=initial_state(5:6,i);
    member_state_exten{i,1}(9,begin_time)=a(3);
    %%�˶�����
    for j=begin_time+1:end_time
        member_state_exten{i,1}(:,j)=A*member_state_exten{i,1}(:,j-1);
    end
    member_state_exten{i,1}(:,end_time+1:N)=nan(dim_state,N-end_time);%%Ŀ����ʧ���ʱ�̸�ֵ
end
%��ʽת������9ά��״̬���ݱ��6ά��״̬����
for i=1:num_member
    for j=1:N
    %x��
    member_state{i,1}(1:2,j)=member_state_exten{i,1}(1:2,j);
    %y��
    member_state{i,1}(3:4,j)=member_state_exten{i,1}(4:5,j);
    %z��
    member_state{i,1}(5:6,j)=member_state_exten{i,1}(7:8,j);
    end
end

% ��ǰģʽ��ÿ��ֻ��һ��Ŀ����з���
state=member_state{1,1};

end



