%==============ģ�Ͳ�������=============
clear
clc
close all
model;
%==============���ɹ۲�ֵ=============
true_value;
for m = 1:Mnte_count
    %==============��ɢʽƽ̨����������ʼ��=============
    Common_Variable_Initial;     
    for i = 1:N_sensor
        %==============�ֲ��۲⼫����=============
        [Sensor_decen(i).Z_polar_part] = observe_FoV_3d(Xreal_time_target,Sensor_decen(i).location,...
                Sensor_decen(i).R_detect,Sensor_decen(i).Pd,Sensor_decen(i).Zr,Sensor_decen(i).R,N);
        %======���۲�ֲ�������ת��Ϊȫ��ֱ������=======
            [Sensor_decen(i).Z_dicaer_global] = polar2dicaer_3d( Sensor_decen(i).Z_polar_part,...
                Sensor_decen(i).location(1), Sensor_decen(i).location(2), Sensor_decen(i).location(3) );
    end
%     load('Sensor_decen.mat');
    [A,B] = LPHD_ALG(Xreal_target_time,Xreal_time_target,Sensor_decen,N);
    
end
    
    
    

