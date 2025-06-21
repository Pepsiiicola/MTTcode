%{
****************************************************************************************************

         polar2dicaer_3d:��ά�ֲ�������ת��Ϊ��άȫ�ֵѿ�������

         ���룺 Z_polar  -- ���ʱ�̵ļ�����(�ֲ�)�۲��  [ N*1 ��cell]
                location_x  -- ��ǰ������ x �������λ�� 
                location_y  -- ��ǰ������ y �������λ��
                location_z  -- ��ǰ������ z �������λ��

         ����� Z_dicaer -- ���ʱ�̵ľ���ת���ĵѿ�������(ȫ��)�۲��  [ N*1��cell]

         ע����
====================================================================================================
%}
function [Z_dicaer]=polar2dicaer_3d(Z_polar,location_x,location_y,location_z)

%   �۲�ʱ����
N=size(Z_polar,1);

% %   ����location_�г��Ȳ�һ������ִ���
% if(N~=size(location_x,2))
%     error('ʱ������һ��');
% end

Z_dicaer=cell(N,1);
for t=1:N                      % ʱ����
    n_ob=size(Z_polar{t,1},2); % ��ǰʱ�̹۲⵽��Ŀ������
    for i=1:n_ob
        %===================�Թ۲��Ϊԭ��ĵѿ�������ת����ʽ=========================
        x=abs(Z_polar{t,1}(1,i)*cos(deg2rad(Z_polar{t,1}(3,i)))) * cos(deg2rad(Z_polar{t,1}(2,i)));
        y=abs(Z_polar{t,1}(1,i)*cos(deg2rad(Z_polar{t,1}(3,i))))*sin(deg2rad(Z_polar{t,1}(2,i)));
        z=Z_polar{t,1}(1,i)*sin(deg2rad(Z_polar{t,1}(3,i)));
        
        %=======================ת��Ϊȫ�ֵѿ�������===================================
        Z_dicaer{t,1}(1,i)=x+location_x;
        Z_dicaer{t,1}(2,i)=y+location_y;
        Z_dicaer{t,1}(3,i)=z+location_z;
    end
end
end


