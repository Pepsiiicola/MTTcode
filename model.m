%******************************
%       ȫ��ϵͳ��������
%******************************
N  = 100;     % ����ʱ��
T  = 1;       % ����ʱ����1s
Ps = 1;       % Ŀ�������
ZR_init = 60;       % �Ӳ�����
% PD = 1;     % ������ --> �� Configuration.m�ļ�������
N_sensor = 16; % ����������
% R_DETECT = 1000;  % �۲ⷶΧ���� --> �� Configuration.m�ļ�������
R_INTERVAL = 1000; % ƽ̨֮��ļ��
R_COMMUNICATE = R_INTERVAL;  % ͨ�Ű뾶
R_init = diag([100,1,1]); % �۲����Э����

%=======�Ƿ�����ڵ�======
Occlusion_flag = 0;

%===========================
%     ��ɢʽ���˾�������
%===========================
location_center = [0;0;0;1]; % ƽ̨ԭ������(ǰ3ά)��ƽ̨���(��4ά)
[mat_topo_decen,location] = topo_born_3d(N_sensor,location_center,R_INTERVAL,R_COMMUNICATE);
% ����Ȩ�ط���
[mat_weight_decen] = Metropolis_Weights(mat_topo_decen);


%=============2024.11.5 �������˱仯=============
% N_sensor_extra = 11;
% Num_communicate_decen_extra = 11;
% [mat_topo_decen_extra,location_extra] = topo_born_3d(N_sensor_extra,location_center,R_INTERVAL,R_COMMUNICATE);


%==========================
%    �ֲ�ʽ���˾�������
%==========================
% �ֲ�ʽ��Ҫ�����нڵ������Ľڵ�(��Ϊ�ں�����)�������˹���������ȡ��������ڵ����˵Ĺ���
% Ĭ��1�Žڵ�Ϊ�ں����Ľڵ�
mat_topo_distr = mat_topo_decen * 0;
mat_topo_distr(1,:) = 1;
mat_topo_distr(:,1) = 1;

% == �˶�Ŀ���״̬�������� == 
% 1.��ʼX����  2.X�ٶ�  3.Y����  4.Y�ٶ�  5.Z����  6.Z�ٶ�  7.����ʱ��   8.����ʱ��  9.�˶�ģʽ
% ע: ���һά���˶�ģʽ���������˶�ģʽ��CV,CA,CT  ����ʵ�ּ����� targetset.mat
motion_pattern_default = 1; % Ĭ���˶�ģʽ
Set_TargetState=[
%          400   -10   100    -10   0    0    20   N   motion_pattern_default; % 1
%         -1500   0   -500     10   0    0    1    80   motion_pattern_default; % 2
%         -1000   15  1700    0    0    0     1    N   motion_pattern_default;%3
        -1000   25  -2000    8    0    0    50   N   motion_pattern_default; % 4
%         -800   -10   400     10   0    0    20   60  motion_pattern_default; % 5
        -800    0    300    -10   0    0    1    N   motion_pattern_default; % 6
         600   -15   1000   -10   0    0    20   N   motion_pattern_default; % 7       
        -300    10  -500    -10   0    0    20   80  motion_pattern_default; % 8
%          1500    5    1000   -15  0    0    1    80   motion_pattern_default; % 9
        -1400  -10   1500   -20   0    0    20   80  motion_pattern_default; % 10
        -500    15   250      0   0    0    1    N   motion_pattern_default; % 11
%         -2000   13   2000     7   0    0    1    N  motion_pattern_default; % 12
%         -3000   5    -300     8   0    0    1    N  motion_pattern_default; % 13
%          1100   6    -2300   16   0    0    20   80 motion_pattern_default; % 14
%         -2000   0    -800    -6   0    0    1    N  motion_pattern_default; % 15
         500     3     3000   -8   0    0   1   N  motion_pattern_default; % 16
         1800     7     2200   -8   0    0   1   N  motion_pattern_default; % 16
         2000     9     -1750   10   0    0   1   N  motion_pattern_default; % 16
         
        ]';
% Set_TargetState=[
%          400   -10   100    -10   100    10    20   N   motion_pattern_default; % 1
%         -1500   0   -500     10   -500   5    1    80   motion_pattern_default; % 2
%         -1000   15   1700    0    800    -5    1    N   motion_pattern_default; % 3
%         -1500   25   2300    10    1000    20    50   N   motion_pattern_default; % 4
%         -800   -10   400     10   -800    0    20   60  motion_pattern_default; % 5
%         -800    0    300    -10   -1000    15    1    N   motion_pattern_default; % 6
%          600   -15   1000   -10   1000    -10    20   N   motion_pattern_default; % 7       
%         -300    10  -500    -10   -1000    10    20   80  motion_pattern_default; % 8
%          1000    5    2000   -15   250    10    1    80   motion_pattern_default; % 9
%         -1400  -10   1500   -20   -250    -10    20    80  motion_pattern_default; % 10
%         -500    15   250     0    0    -10    1    N   motion_pattern_default; % 11
%         ]';