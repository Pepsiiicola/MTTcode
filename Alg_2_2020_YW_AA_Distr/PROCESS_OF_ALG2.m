%{
                                �㷨2�Ӻ���
           ����: 1.��ʵ����
                 2.�۲�����
                 3.����������
                 4.�ܸ���ʱ��

           ���: 1.���ٽ����OSPA (����ÿ��ʱ�̵�OSPA��ֵ)
                 2.���ٽ�������� (����ÿ��ʱ�̵�����)
                 3.�㷨�����ܺ�ʱ 

          
%}
function [OSPA,Num_estimate,Time] = PROCESS_OF_ALG2(~,Xreal_time_target,Sensor,N)

%===һЩĬ�ϵĲ���===
Ps = 1; % ������
Vx_thre = 200;
Vy_thre = 200;
Vz_thre = 200;
merge_threshold = 200;
N_sensor = size(Sensor,2);

%===Ԥ����===
% ��������ʺܸߣ��ڲ�����1�������˲�
for i = 1:N_sensor
    if Sensor(i).Pd >= 0.99
        Sensor(i).Pd = 1;
    end
end

%======PHD�������ֵ��ʼ��======
ALG2_PHD_initial;

% ʱ������
Time=0;
for t = 3:N
    
    timing = tic;
    %==================
    % ���������˲�����
    %==================
    for i=1:N_sensor 
        [Sensor(i).state]=ALG2_PHD1time_3d_ukf_distr(Sensor(i).Z_dicaer_global{t-2,1},...
            Sensor(i).Z_dicaer_global{t-1,1},Sensor(i).Z_polar_part{t,1},...
            Sensor(i).state,Sensor(i).Zr,Sensor(i).R,Ps,Sensor(i).Pd,...
            Vx_thre,Vy_thre,Vz_thre,...
            Sensor(i).location(1,1),Sensor(i).location(2,1),Sensor(i).location(3,1));    
    end
    t_sus = toc(timing);
    Time = Time + t_sus/N_sensor;
    timing = tic;
    
    %===�ں����Ľ�����Ϣ===
    for i=1:N_sensor 
        Fusion_center.sensor_inf(i).gm_particles = Sensor(i).state; % ���������Ƶ�״̬��Ϣ
        Fusion_center.sensor_inf(i).location = Sensor(i).location;  % ��������λ����Ϣ
        Fusion_center.sensor_inf(i).R_detect = Sensor(i).R_detect;  % �������Ĺ۲�뾶
        Fusion_center.sensor_inf(i).serial = Sensor(i).serial;      % �������ı��
    end
    
    %===AA�ںϷ���===
    [Fusion_center.results] = ALG2_fusion_AA_distr(Fusion_center.sensor_inf,merge_threshold);
    
    %===״̬��ȡ===
    for i=1:N_sensor  
        [Sensor(i).X_est{t,1},~] = statedraw_3d( Fusion_center.results );       
    end
    
    %=== ������� ===
    %=== �޳��۲ⷶΧ֮���״̬��������ֹ©������Ժ������ٵ�Ӱ�� ===
    for i=1:N_sensor
        [Sensor(i).state,~]=FoV_divide( Fusion_center.results,Sensor(i).location,Sensor(i).R_detect);
    end
    
    t_sus = toc(timing);
    Time = Time + t_sus;
  
end
Time = Time / ( N - 2 ); % �����ں�����ʱ�����

%===�ֲ�ʽ OSPA ����===
OSPA = zeros(1,N);
OSPA(1:2) = 0;

for t=1:N
    % Ҫ�� Xreal_time_target ����һ�����ݴ������ڲ���nanֵɾ��
    Xreal_time_target{t,1}( :,isnan(Xreal_time_target{t,1}(1,:)) ) = [];
end

for t=3:N
    OSPA(t) = ospa_dist(Xreal_time_target{t,1},Sensor(2).X_est{t,1},120,2);
end

%===�ֲ�ʽ��������===
Num_estimate = zeros(1,N);
Num_estimate(1:2) = 0;
for t=3:N
    Num_estimate(t) = size(Sensor(6).X_est{t,1},2);
end

%{
% =======����ÿ��ʱ����ʵĿ����Ŀ=======
num_real = zeros(1,N); % ȫ����ʵĿ����Ŀ
for t=1:N
    num_real(1,t) = size(Xreal_time_target{t,1},2);
end

figure
hold on;
plot(OSPA,'-ko','Markerface','b');
legend('�ֲ�ʽAA','FontSize',14);
t=title('OSPA');
t.FontSize = 14;
xlabel('ʱ�� t/s','FontSize',14)
ylabel('OSPA����','FontSize',14)
disp(num2str(sum(OSPA(3:end))/98));

figure
hold on;
plot(num_real,'-k');
plot(Num_estimate,'-ko','Markerface','b');
legend('��ʵֵ','�ֲ�ʽAA','FontSize',14);
t=title('�������ٶԱ�');
t.FontSize = 14;
xlabel('ʱ�� t/s','FontSize',14)
ylabel('��������','FontSize',14)
%}

end
