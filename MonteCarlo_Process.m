M = Config.M; % ���ؿ������

% ���ؿ��������ʼ��
Monte_ALG = struct; % �������ؿ���ͳ��ָ��
MM_ALG = struct;    % ������ؿ���ͳ��ָ��
% # Monte_ALG(i)����� i ���㷨��������ݣ������������δѡ����㷨�����ɻ�ռһ��λ��
for i = 1:size(Config.AlgCompare,2)
    % �������ؿ���
    Monte_ALG(i).TIME_TOTAL = zeros(M,1);   % �㷨�����ʱ
    Monte_ALG(i).OSPA = zeros(M,N);         % �㷨ƽ��OSPA
    Monte_ALG(i).Num_estimate = zeros(M,N); % �㷨��������
    % ������ؿ���
    MM_ALG(i).TIME_TOTAL = 0;            % �㷨�����ʱ
    MM_ALG(i).OSPA = zeros(1,N);         % �㷨ƽ��OSPA
    MM_ALG(i).Num_estimate = zeros(1,N); % �㷨��������
end


for m = 1:M
    
    inf_loop = ['��ѭ��: ',num2str(Serial_Monte),' ���ؿ���ѭ��: ',num2str(m)];
    disp( inf_loop );
    
    % ����������ʼ��(�۲�����)
    Common_Variable_Initial;
    
    %*****************************
    %          �۲�����
    %*****************************
    for i=1:N_sensor
        
        %***************************
        %        ��ɢʽƽ̨
        %***************************
        %==============�ֲ��۲⼫����=============
        [Sensor_decen(i).Z_polar_part] = observe_FoV_3d(Xreal_time_target,Sensor_decen(i).location,...
            Sensor_decen(i).R_detect,Sensor_decen(i).Pd,Sensor_decen(i).Zr,Sensor_decen(i).R,N,i,Occlusion_flag);
        %======���۲�ֲ�������ת��Ϊȫ��ֱ������=======
        [Sensor_decen(i).Z_dicaer_global] = polar2dicaer_3d( Sensor_decen(i).Z_polar_part,...
            Sensor_decen(i).location(1), Sensor_decen(i).location(2), Sensor_decen(i).location(3) );
        
        %****************************
        %        �ֲ�ʽƽ̨
        %****************************
        % ����1��ȫ��һ�� : ȫ��һ�����������й۲�����һ��������ԱȲ����㷨����
        %==============�ֲ��۲⼫����=============
        Sensor_distr(i).Z_polar_part = Sensor_decen(i).Z_polar_part;
        %======���۲�ֲ�������ת��Ϊȫ��ֱ������=======
        Sensor_distr(i).Z_dicaer_global=Sensor_decen(i).Z_dicaer_global;
        
        % ����2�������۲�
        %==============�ֲ��۲⼫����=============
        %     [Sensor_distr(i).Z_polar_part]=observe_FoV_3d(Xreal_time_target,Sensor_distr(i).location,...
        %         Sensor_distr(i).R_detect,Sensor_distr(i).Pd,Sensor_distr(i).Zr,Sensor_distr(i).R,N);
        %     %======���۲�ֲ�������ת��Ϊȫ��ֱ������=======
        %     [Sensor_distr(i).Z_dicaer_global]=polar2dicaer_3d( Sensor_distr(i).Z_polar_part,...
        %         Sensor_distr(i).location(1), Sensor_distr(i).location(2), Sensor_distr(i).location(3) );
        
    end
    
    %=================
    %   �켣ͼ��ʾ
    %=================
    if Serial_Monte == 1 && m == 1
        sciPlot;
    end
    
    %*****************************
    %          �����㷨
    %*****************************
    if Config.AlgCompare(1) == 1
        % �㷨����
        [Monte_ALG(1).OSPA(m,:), Monte_ALG(1).Num_estimate(m,:), Monte_ALG(1).TIME_TOTAL(m,1)] =...
            PROCESS_OF_ALG1(Xreal_target_time,Xreal_time_target,Sensor_decen,N);
    end
    
    if Config.AlgCompare(2) == 1
        % �㷨����
        [Monte_ALG(2).OSPA(m,:), Monte_ALG(2).Num_estimate(m,:), Monte_ALG(2).TIME_TOTAL(m,1)] =...
            PROCESS_OF_ALG2(Xreal_target_time,Xreal_time_target,Sensor_distr,N);
    end
    
    if Config.AlgCompare(3) == 1
        % �㷨����
        [Monte_ALG(3).OSPA(m,:), Monte_ALG(3).Num_estimate(m,:), Monte_ALG(3).TIME_TOTAL(m,1)] =...
            PROCESS_OF_ALG3(Xreal_target_time,Xreal_time_target,Sensor_distr,N);
    end
    
    if Config.AlgCompare(4) == 1
        % �㷨����
        [Monte_ALG(4).OSPA(m,:), Monte_ALG(4).Num_estimate(m,:), Monte_ALG(4).TIME_TOTAL(m,1)] =...
            PROCESS_OF_ALG4(Xreal_target_time,Xreal_time_target,Sensor_decen,N); 
    end
    
    if Config.AlgCompare(5) == 1
        % �㷨����
        [Monte_ALG(5).OSPA(m,:), Monte_ALG(5).Num_estimate(m,:), Monte_ALG(5).TIME_TOTAL(m,1), Monte_ALG(5).CONSENSUS_OSPA(m,:)] =...
            PROCESS_OF_ALG5(Xreal_target_time,Xreal_time_target,Sensor_decen,N,...
            Num_communicate_decen,mat_weight_decen);
    end
    
    if Config.AlgCompare(6) == 1
        % �㷨����
        [Monte_ALG(6).OSPA(m,:), Monte_ALG(6).Num_estimate(m,:), Monte_ALG(6).TIME_TOTAL(m,1)] =...
            PROCESS_OF_ALG6(Xreal_target_time,Xreal_time_target,Sensor_decen,N,Num_communicate_decen,...
            mat_weight_decen); %mat_weight_decen
    end
    
    if Config.AlgCompare(7) == 1
        % �㷨����
        [Monte_ALG(7).OSPA(m,:), Monte_ALG(7).Num_estimate(m,:), Monte_ALG(7).TIME_TOTAL(m,1)] =...
            PROCESS_OF_ALG7(Xreal_target_time,Xreal_time_target,Sensor_decen,N,Num_communicate_decen,...
            mat_weight_decen);
    end

    if Config.AlgCompare(8) == 1
        % �㷨����
        [Monte_ALG(8).OSPA(m,:), Monte_ALG(8).Num_estimate(m,:), Monte_ALG(8).TIME_TOTAL(m,1)] =...
            PROCESS_OF_ALG8(Xreal_target_time,Xreal_time_target,Sensor_decen,N,Num_communicate_decen);
    end

    if Config.AlgCompare(9) == 1
        % �㷨����
        [Monte_ALG(9).OSPA(m,:), Monte_ALG(9).Num_estimate(m,:), Monte_ALG(9).TIME_TOTAL(m,1)] =...
            PROCESS_OF_ALG9(Xreal_target_time,Xreal_time_target,Sensor_decen,N,Num_communicate_decen);
    end

    if Config.AlgCompare(10) == 1
        % �㷨����
        [Monte_ALG(10).OSPA(m,:), Monte_ALG(10).Num_estimate(m,:), Monte_ALG(10).TIME_TOTAL(m,1)] =...
            PROCESS_OF_ALG10(Xreal_target_time,Xreal_time_target,Sensor_decen,N,Num_communicate_decen,...
            mat_weight_decen);
    end
    
    if Config.AlgCompare(11) == 1
        %�㷨����
        [Monte_ALG(11).OSPA(m,:), Monte_ALG(11).Num_estimate(m,:), Monte_ALG(11).TIME_TOTAL(m,1)] =...
            PROCESS_OF_ALG11(Xreal_target_time,Xreal_time_target,Sensor_decen,N,Num_communicate_decen);
    end

    if Config.AlgCompare(12) == 1
        % �㷨����
        [Monte_ALG(12).OSPA(m,:), Monte_ALG(12).Num_estimate(m,:), Monte_ALG(12).TIME_TOTAL(m,1)] =...
            PROCESS_OF_ALG12(Xreal_target_time,Xreal_time_target,Sensor_decen,N,Num_communicate_decen);
    end
    
end

%******************************
%       ���ؿ�����ͳ��
%******************************
for i = 1:size(Config.AlgCompare,2)
    MM_ALG(i).TIME_TOTAL = sum(Monte_ALG(i).TIME_TOTAL,1)/M;     % �㷨�����ʱ
    MM_ALG(i).OSPA = sum(Monte_ALG(i).OSPA,1)/M;                 % �㷨OSPA
    MM_ALG(i).Num_estimate = sum(Monte_ALG(i).Num_estimate,1)/M; % �㷨��������
end


