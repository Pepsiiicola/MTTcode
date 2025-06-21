%{
                                �㷨5�Ӻ���
           ����: 1.��ʵ����
                 2.�۲�����
                 3.����������
                 4.�ܸ���ʱ��
                 5.һ���Բ������
                 6.�ں�Ȩ��

           ���: 1.���ٽ����OSPA (����ÿ��ʱ�̵�OSPA��ֵ)
                 2.���ٽ�������� (����ÿ��ʱ�̵�����)
                 3.�㷨�����ܺ�ʱ 

          
%}
function [OSPA,Num_estimate,Time] = PROCESS_OF_ALG7(~,Xreal_time_target,Sensor,N,L,mat_weight)
    
    X = sprintf('��7���㷨������...\n');
    fprintf(X);

%===һЩĬ�ϵĲ���===
Ps = 1; % ������
Vx_thre = 200;
Vy_thre = 200;
Vz_thre = 200;
match_threshold = 200;
N_sensor = size(Sensor,2);

%===Ԥ����===
% ��������ʺܸߣ��ڲ�����1�������˲�
for i = 1:N_sensor
    if Sensor(i).Pd >= 0.99
        Sensor(i).Pd = 1;
    end
end

%======PHD�������ֵ��ʼ��======
ALG6_PHD_initial;

%=====����洢��������(����ͨ��)=====
com_storage = struct;

% ʱ������
timing = tic;

%============����ʱ��ר��========= 2025.3.12����
mat_topo_copy = Sensor(1).mat_topo;
mat_weight_in = mat_weight;
%========================

for t=3:N


%============����ʱ��ר��========= 2025.3.12����
    
    
        
    if t > 25 && t <= 50
        
        N_sensor = 14;
        mat_weight = mat_weight_in(1:N_sensor,1:N_sensor);  % ���������� mat_weight ���޸�Ϊ mat_weight_in���ǵøĻ���
        for i = 1:N_sensor
            Sensor(i).mat_topo = mat_topo_copy(1:N_sensor,1:N_sensor);
        end

    elseif t > 50 && t <= 75
        N_sensor = 12;
        mat_weight = mat_weight_in(1:N_sensor,1:N_sensor);
        for i = 1:N_sensor
            Sensor(i).mat_topo = mat_topo_copy(1:N_sensor,1:N_sensor);
        end
    elseif t > 75 

        N_sensor = 10;
        mat_weight = mat_weight_in(1:N_sensor,1:N_sensor);
        for i = 1:N_sensor
            Sensor(i).mat_topo = mat_topo_copy(1:N_sensor,1:N_sensor);
        end
    end

    %==================
    % ���������˲�����
    %==================
    for i=1:N_sensor 
        [Sensor(i).state_ex]=ALG7_PHD1time_3d_ukf_decen(Sensor(i).Z_dicaer_global{t-2,1},...
            Sensor(i).Z_dicaer_global{t-1,1},Sensor(i).Z_polar_part{t,1},...
            Sensor(i).state,Sensor(i).Zr,Sensor(i).R,Ps,Sensor(i).Pd,...
            Vx_thre,Vy_thre,Vz_thre,...
            Sensor(i).location(1,1),Sensor(i).location(2,1),Sensor(i).location(3,1),i);    
    end
    
    %*********************
    %     һ���Բ���
    %*********************
    for l = 1:L
        
        % ����
        for i=1:N_sensor
            com_storage(i).gm_particles = Sensor(i).state_ex;
        end
        % ���� 
        % ע���˴��� Fusion_center(i) ������ǵ� i ��������
        for i=1:N_sensor
            Fusion_center(i).Inf_recieve = module_com_recieve(com_storage,Sensor(i).mat_topo,i,N_sensor);
        end
        
        % �ں�
        % ��ɢʽAGM�ںϷ�ʽ
        for i=1:N_sensor
            [Sensor(i).state_ex] = ALG7_fusion_AGM_decen(Fusion_center(i),match_threshold,mat_weight,...
                i,l,Sensor(i).mat_topo);
        end
        
    end
    
    % ״̬��ʽת�� ��Sensor.state_ex ת��Ϊ Sensor.state
    for i=1:N_sensor
        Sensor(i).state = Sensor(i).state_ex;
        Sensor(i).state{2,1}(7,:) = [];
    end
    
    % ״̬��ȡ
    for i=1:N_sensor
        [Sensor(i).X_est{t,1},Sensor(i).num_est(t)] = statedraw_3d(Sensor(i).state);
    end
    
    % ��������(�����Է���)
    for i=1:N_sensor
        [Sensor(i).state,~]=FoV_divide(Sensor(i).state,Sensor(i).location,Sensor(i).R_detect);
    end
    
end
% ʱ�����
Time = toc(timing);
Time = Time/(N-2)/N_sensor; % �����������������������ĵ�ʱ��

%======================================��������=========================================
%=== OSPA ���� ===
OSPA = zeros(1,N);
OSPA(1:2) = 0;
for t=3:N
    % Ҫ�� Xreal_time_target ����һ�����ݴ������ڲ���nanֵɾ��
    Xreal_time_target{t,1}( :,isnan(Xreal_time_target{t,1}(1,:)) ) = [];
end
for t=3:N
    OSPA(t) = ospa_dist(Xreal_time_target{t,1},Sensor(8).X_est{t,1},120,2);
end

%=== �������� ===
Num_estimate = zeros(1,N);
for t=1:N
    Num_estimate(t) = size(Sensor(8).X_est{t,1},2);
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
legend('��ɢʽAGM','FontSize',14);
t=title('OSPA');
t.FontSize = 14;
xlabel('ʱ�� t/s','FontSize',14)
ylabel('OSPA����','FontSize',14)
disp(num2str(sum(OSPA(3:end))/98));

figure
hold on;
plot(num_real,'-k');
plot(Num_estimate,'-ko','Markerface','b');
legend('��ʵֵ','��ɢʽAGM','FontSize',14);
t=title('�������ٶԱ�');
t.FontSize = 14;
xlabel('ʱ�� t/s','FontSize',14)
ylabel('��������','FontSize',14)

figure
hold on;
flag_realtarget=0;
flag_ob=0;
flag_estimate=0;

% ����ƽ̨�ڵ��Լ����ⷶΧ
for i=1:N_sensor
    text(Sensor(i).location(1,1),Sensor(i).location(2,1),num2str(i),'Fontsize',20,'Position',...
        [Sensor(i).location(1,1),Sensor(i).location(2,1)]);
    h_sensor=plot(Sensor(i).location(1,1),Sensor(i).location(2,1),'k^','Markerface','y','MarkerSize',10);
    draw_circle(Sensor(i).location(1,1),Sensor(i).location(2,1),Sensor(i).R_detect);
end

for t=1:N
    
    if t>2
        %===����ֵ===
        h_estimate=plot(Sensor(1).X_est{t,1}(1,:),Sensor(1).X_est{t,1}(3,:),'bo');
        hold on;
        if ~isempty(h_estimate) && flag_estimate==0
            leg_estimate=h_estimate;
            flag_estimate=1;
        end
    end
    
end

for t=1:N
    %===��ʵֵ===
    h_realtarget=plot(Xreal_time_target{t,1}(1,:),Xreal_time_target{t,1}(3,:),'r.');
    hold on;
end

% ��ȡlegend�ز�
if ~isempty(h_realtarget) && flag_realtarget==0
    leg_realtarget=h_realtarget;
    flag_realtarget=1;
end
if isempty(h_estimate)
    h_estimate=plot(0,0,'bo');
    leg_estimate=h_estimate;
    hold on;
end

xlabel('X������/m','FontSize',20);
ylabel('Y������/m','FontSize',20);
set(gca,'FontSize',20);
t=title('xxx','FontSize',20);
t.FontSize = 20;
grid on;
axis equal
legend([h_sensor,leg_realtarget,leg_estimate],...
    {'����������','��ʵĿ��㼣','���������Ƶ㼣'},'Fontsize',20);

%}
end