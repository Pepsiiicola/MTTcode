%==============================
%    ��ɢʽƽ̨�������Գ�ʼ��
%==============================
Sensor_decen = struct; % ��ɢʽƽ̨
for i=1:N_sensor
    
    % ��������������
    Sensor_decen(i).Pd = PD; % ��ⷶΧ
    Sensor_decen(i).R  = R;  % �۲����Э����
    Sensor_decen(i).Zr = ZR; % �Ӳ�����
    Sensor_decen(i).R_detect = R_DETECT;        % ��ⷶΧ
%     Sensor_decen(i).R_communicate=R_INTERVAL; % ͨ�ž���(Ĭ��Ϊƽ̨�ľ���)
    Sensor_decen(i).location = location(1:3,i); % ƽ̨����(ȫ�ֵѿ�������)
    Sensor_decen(i).serial = location(4,i);     % ƽ̨��� 
    Sensor_decen(i).mat_topo = mat_topo_decen;  % ƽ̨���˾���
    Sensor_decen(i).Num_communicate = Num_communicate_decen; % �����ں�����ͨ�Ŵ���
    Sensor_decen(i).Com_BandWidth = ComWD;
    
    % �۲���ر���
    Sensor_decen(i).Z_polar_part = cell(N,1);    % ������ϵ�µľֲ��۲�(��ƽ̨Ϊ����)
    Sensor_decen(i).Z_dicaer_global = cell(N,1); % �ѿ�������ϵ�µ�ȫ�ֹ۲�
    
end

%================================
%       �ֲ�ʽƽ̨���Գ�ʼ��
%================================
Sensor_distr=struct; % ��ɢʽƽ̨
for i=1:N_sensor
    
    % ��������������
    Sensor_distr(i).Pd = PD; % ��ⷶΧ
    Sensor_distr(i).R = R;   % �۲����Э����
    Sensor_distr(i).Zr = ZR; % �Ӳ�����
    Sensor_distr(i).R_detect = R_DETECT;         % ��ⷶΧ
%     Sensor_distr(i).R_communicate=R_INTERVAL;  % ͨ�ž���(Ĭ��Ϊƽ̨�ľ���)
    Sensor_distr(i).location = location(1:3,i);  % ƽ̨����(ȫ�ֵѿ�������)
    Sensor_distr(i).serial = location(4,i);      % ƽ̨���
    Sensor_distr(i).mat_topo = mat_topo_distr; % ƽ̨���˾���
   
    % �۲���ر���
    Sensor_distr(i).Z_polar_part = cell(N,1);    % ������ϵ�µľֲ��۲�(��ƽ̨Ϊ����)
    Sensor_distr(i).Z_dicaer_global = cell(N,1); % �ѿ�������ϵ�µ�ȫ�ֹ۲�
    
end