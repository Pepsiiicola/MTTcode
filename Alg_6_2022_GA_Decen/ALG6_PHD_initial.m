%{
                           �ֲ�ʽ��PHD��ز������г�ʼ��
%}
for i=1:N_sensor
    
    %***********************
    %   �˲���ز�����ʼ��
    %***********************
    % ȫ�����ӳ�ʼ��
    Sensor(i).state{1,1}=0;           % Ȩ��
    Sensor(i).state{2,1}=zeros(6,1);  % ��ֵ
    Sensor(i).state{3,1}=zeros(6,6);  % Э����
    Sensor(i).state{4,1}=0;           % ��������
    
    %***********************
    %   ������ز�����ʼ��
    %***********************
    % ��һ��ʱ�̵ĳ�ʼֵ��ֵ
    Sensor(i).X_est{1,1}=zeros(6,0); % ȫ��Ŀ����ƽ��
    Sensor(i).X_est{2,1}=zeros(6,0); % ȫ��Ŀ����ƽ��
    
end

% �ں����ı�����ʼ��
Fusion_center = struct;
Fusion_center.sensor_inf = struct;
Fusion_center.Inf_recieve = struct;

%===ÿ�����������ں�������֪��һЩ������Ϣ===
for i=1:N_sensor
    for j = 1: N_sensor
        Fusion_center(i).sensor_inf(j).location = Sensor(j).location;  % ��������λ����Ϣ
        Fusion_center(i).sensor_inf(j).R_detect = Sensor(j).R_detect;  % �������Ĺ۲�뾶
        Fusion_center(i).sensor_inf(j).serial   = Sensor(j).serial;    % �������ı��
    end
end