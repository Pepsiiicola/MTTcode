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
Fusion_center.sensor_inf =struct;