%================���������ݼ���===============%
%         ʹ�ýṹ��洢���д���������
%         ���ݳ�ʼ��
%============================================%
sensor_Num = size(Sensor,2);%����������
for j = 1:sensor_Num
    Input(j).Birth.w_birth = [];
    Input(j).Birth.m_birth = [];
    Input(j).Birth.P_birth = [];
    Input(j).Birth.numTargetbirth = [];
    Input(j).w_bar_k = [];
    Input(j).m_bar_k = [];
    Input(j).P_bar_k = [];
   Input(j).Z = Sensor(j).Z_polar_part;
   Input(j).Z_clutter = Sensor(j).Z_dicaer_global;
   Input(j).nClutter = Sensor(j).Zr;
   Input(j).detect_prob = Sensor(j).Pd;
   Input(j).x_k_history = [];
   Input(j).cdn_update = [1; zeros(20,1)];
   Input(j).location = Sensor(j).location([1,2],:);
   Input(j).R_detect = Sensor(j).R_detect;
   Birth(j).w_birth = [];
   Birth(j).m_birth = [];;
   Birth(j).P_birth = [] ;
   Birth(j).numTargetbirth = [];
end
%========�Դ������۲����ݽ��д���=======%
%       ֻȡ��ά���ݣ�����+��λ��       %
%======================================%
for k = 1:100
    for j = 1:sensor_Num
        Input(j).Z_clutter{k,1} = Sensor(j).Z_dicaer_global{k,1}([1,2],:);  
        Input(j).Z{k,1} = Sensor(j).Z_polar_part{k,1}([1,2],:);
    end
end

%ospa����c��p
cutoff_c=120;
order_p=2;
metric_history=[];%���ڱ���ospaָ��
n_Max=20;
Q=diag([1,0.1,1,0.1]);%��������Э�������
R=Sensor(1).R(1:2,1:2);%�۲�����Э�������
T = 1;
F=[1 T 0 0;
   0 1 0 0;
   0 0 1 T;
   0 0 0 1;];
communicate_Num = Sensor(1).Num_communicate;
history = [];
Target_Num = [];

