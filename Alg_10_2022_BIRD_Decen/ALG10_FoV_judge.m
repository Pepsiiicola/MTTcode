function [flag_FoV]=ALG10_FoV_judge(location,state,r_detect,sensorID)
distance=sqrt((location(1,1)-state(1,1))^2+(location(2,1)-state(3,1))^2+(location(3,1)-state(5,1))^2);

% 若检测半径+一定的余量大于观测距离，则标志位置1，否则置0
if r_detect>=distance
    flag_FoV=sensorID;
else
    flag_FoV=[];
end

end