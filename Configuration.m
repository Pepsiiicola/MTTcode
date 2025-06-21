% �����峡������(�����㷨ѡ���ָ��ѡ��)��
Config = struct; % ���ñ���
Config.M = 100;    % ���ؿ������

%  == �Ա��㷨ѡ�� ==
% Ŀ¼
% 1.�����     2019 ��ɢʽ AA�ں� ����PHD
% 2.Yiwei      2020 �ֲ�ʽ AA�ں� GMPHD
% 3.LiGC       2020 �ֲ�ʽ GA�ں� GMPHD
% 4.Giorgio    2013 ��ɢʽ KLD�ں� CPHD
% 5.�����鹤�� 2022 ��ɢʽ AA�ں� GMPHD
% 6.�����鹤�� 2022 ��ɢʽ GA�ں� GMPHD
% 7.�����鹤�� 2022 ��ɢʽ AGM�ں� GMPHD
% 8.���µ�1    2023 ��ɢʽ AA�ں�  GMPHD-------add by swc
% 9.���µ�2    2023 ��ɢʽ AGM2.0�ں� GMPHD  -----add by swc
% 10.����¼    2022 ��ɢʽ BIRD�ں�  GMPHD -------add by swc
% 11.���µ�3   2025 ��ɢʽ AGM3.0�ں� GMPHD ------add by swc
% 12.����ɷ���  2017 ��ɢʽ AGM�ں�  GMPHD ------add by swc
Config.AlgCompare = [0,0,0,0,0,0,1,1,1,1,0,1];
% Config.AlgCompare = [0,0,0,0,0,0,0,1,0,0,0];

% == ָ��ѡ�� == 
% Ŀ¼
% 1.OSPA
% 2.����
% 3.������
% 4.�����ص��̶Ⱥ�OSPA��ֵ�Ķ�άͼ
% 5.ͨ�Ŵ�����OSPA�����Ķ�άͼ
% 6.�������ӳ̶ȣ�ͨ�Ŵ�����OSPA�����Ķ�άͼ(�ֱ��Ӧx,y,z��)--(�ѷ���)
% 7.�����ʺ�OSPA�����Ķ�άͼ
% 8.�۲�����OSPA�����Ķ�άͼ
% 9.�Ӳ���Ŀ��OSPA�����Ķ�άͼ
% 10.ͨ�Ŵ����OSPA�����Ķ�άͼ
% 4��5��6��7��8�Ĵ��ڻ��⣬ÿ��ֻ�ܳ����е�һ��ͼ
Config.AlgPerformance = [1,1,1,0,0,0,0,0,0,0];

%{
  ��˵����
   1.�������������������ö���,��,�ָ�
   2.��û��ѡ����Ӧ������ָ�꣬���㷨Ĭ�ϲ���Ϊ����ĵ�һ������
%}
Config.OverlapFoV = [1.5, 1.5, 2, 2.5, 3, 3.5]; % �����ص���
Config.Num_communicate = [5,2,3,4,5,6];      % ��ɢʽһ���ں�����ͨ�Ŵ���
Config.Rank_TopoConnect= [0];    % ��������ϡ��� -> �����ֵ����ڵ��м������ӵ��ھӽڵ� -- �ѷ���
Config.PD= [ 0.95, 0.6, 0.7,0.8,0.9, 1];     % ������ 
Config.R = [1,3,5,7,9,11];%�۲���1-6��ʾ�˹۲�������ʼ�۲����ı���
Config.ZR = [10,20,30,40,50,60]; %�������Ӳ���Ŀ
Config.ComWD = [10000,50,90,130,170]*3; % ͨ�Ŵ���

% ������ѡ�� Config.AlgPerformance ���漰����4��5��6 ,7��8 ��9������ָ�꣬��ô��Ҫ���ж������ؿ������
% ����ѡ�񣬼������Ҫ���е����ؿ�����Ĵ���
% �˴���4��5��6, 7��8��9��ѡ����ôֻ�ῼ��4
% ��ǰ��ֵ
Num_communicate_decen = Config.Num_communicate(1); 
R_DETECT  = Config.OverlapFoV(1) * R_INTERVAL;  % ���뾶 = �����ص��� * ���������ھӽڵ�ľ���
PD = Config.PD(1);
R = Config.R(1) * R_init;
ZR = Config.ZR(1);
ComWD = 10000;


%ϵ�����ؿ��������Ҳ����"��ѭ��"�����ݲ�ͬ������ָ��Ҫ������
if Config.AlgPerformance(4) == 1
    Num_monte = size( Config.OverlapFoV,2 );
elseif Config.AlgPerformance(5) == 1
    Num_monte = size( Config.Num_communicate,2 );
elseif Config.AlgPerformance(6) == 1
    Num_monte = size( Config.Num_communicate,2 ) * size( Config.Rank_TopoConnect,2 );
elseif Config.AlgPerformance(7) == 1
    Num_monte = size( Config.PD,2 );
elseif Config.AlgPerformance(8) == 1
    Num_monte = size(Config.R,2);
elseif Config.AlgPerformance(9) == 1
    Num_monte = size(Config.ZR,2);
elseif Config.AlgPerformance(10) == 1
    Num_monte = size(Config.ComWD,2);
else
    Num_monte = 1;
end

