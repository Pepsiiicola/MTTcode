%判断程序：判断粒子是否在传感器视域内
%输入为传感器的坐标(3*1)，需要判断的粒子状态（6*1的数组），传感器的检测半径
%输出为flag_mon，当其为1代表在防区内，当期为0代表在防区外
function [state_result]=Alg8_FoV_judge(sensor,state,num_gm_component,N_sensor)
% distance=sqrt((location(1,1)-state(1,1))^2+(location(2,1)-state(3,1))^2);

% Num_sensor = size(sensor,2);
Num_sensor = N_sensor;

for i = 1:num_gm_component
    com_FoV_num = 0;
    for j = 1:Num_sensor
        distance=sqrt((sensor(j).location(1,1)-state.m(1,i))^2+(sensor(j).location(2,1)-state.m(3,i))^2);
        if sensor(j).R_detect >= distance
            com_FoV_num = com_FoV_num+1; %视域计数
        end
    end

    if com_FoV_num == 0
        com_FoV_num = 1;
    end
    
    state.w(1,i) = state.w(1,i)/com_FoV_num;
end

state_result = state;


