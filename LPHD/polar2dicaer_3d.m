%{
****************************************************************************************************

         polar2dicaer_3d:三维局部极坐标转换为三维全局笛卡尔坐标

         输入： Z_polar  -- 多个时刻的极坐标(局部)观测点  [ N*1 的cell]
                location_x  -- 当前传感器 x 轴的坐标位置 
                location_y  -- 当前传感器 y 轴的坐标位置
                location_z  -- 当前传感器 z 轴的坐标位置

         输出： Z_dicaer -- 多个时刻的经过转化的笛卡尔坐标(全局)观测点  [ N*1的cell]

         注：无
====================================================================================================
%}
function [Z_dicaer]=polar2dicaer_3d(Z_polar,location_x,location_y,location_z)

%   观测时刻数
N=size(Z_polar,1);

% %   若于location_列长度不一致则出现错误
% if(N~=size(location_x,2))
%     error('时刻数不一致');
% end

Z_dicaer=cell(N,1);
for t=1:N                      % 时刻数
    n_ob=size(Z_polar{t,1},2); % 当前时刻观测到的目标数量
    for i=1:n_ob
        %===================以观测点为原点的笛卡尔坐标转换公式=========================
        x=abs(Z_polar{t,1}(1,i)*cos(deg2rad(Z_polar{t,1}(3,i)))) * cos(deg2rad(Z_polar{t,1}(2,i)));
        y=abs(Z_polar{t,1}(1,i)*cos(deg2rad(Z_polar{t,1}(3,i))))*sin(deg2rad(Z_polar{t,1}(2,i)));
        z=Z_polar{t,1}(1,i)*sin(deg2rad(Z_polar{t,1}(3,i)));
        
        %=======================转换为全局笛卡尔坐标===================================
        Z_dicaer{t,1}(1,i)=x+location_x;
        Z_dicaer{t,1}(2,i)=y+location_y;
        Z_dicaer{t,1}(3,i)=z+location_z;
    end
end
end


