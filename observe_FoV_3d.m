%{
                                    观测函数

            输入：1.Xreal -- 当前时刻的真实值6*n_target的double数组
                  2.location -- 传感器所在位置（3*1的double数组）
                  3.r_detect -- 检测半径
                  4.Pd       -- 检测概率
                  5.Zr       -- 杂波期望数量
                  6.R        -- 观测方差
                  7.N        -- 跟踪周期数

            输出：1.Z_polar_part -- 以当前传感器坐标为圆心的局部极坐标观测

%}
function [Z_polar]=observe_FoV_3d(Xre_time_target,location,r_detect,Pd,Zr,R,N,sensorid,Occlusion_flag)

%===预处理===
% 如果检测概率很高，内部当成1来进行观测
if Pd >= 0.99
    Pd = 1;
end

% 传感器坐标
x_radar=location(1);
y_radar=location(2);
z_radar=location(3);

Z_polar=cell(N,1); % 每一个cell中包含一个时刻的观测集

for t=1:N % 循环t代表第几个时刻，counter_watch为观测到的目标个数
    cnt_watch=0;
    N_target=size(Xre_time_target{t,1},2); % 当前时刻真实目标个数
    for i=1:N_target 
        r=rand;
        d=sqrt( (Xre_time_target{t,1}(1,i)-x_radar)^2 + (Xre_time_target{t,1}(3,i)-y_radar)^2 + ...
            (Xre_time_target{t,1}(5,i)-z_radar)^2);
        
        % 真实目标被观测判断条件
        if d<=r_detect && Pd>r 
            cnt_watch=cnt_watch+1;
            
            %非线性观测方式
            Z_polar{t,1}(:,cnt_watch)=compute_R_theta(Xre_time_target{t,1}(1,i),...
                Xre_time_target{t,1}(3,i),Xre_time_target{t,1}(5,i),x_radar,y_radar,z_radar);
            Z_polar{t,1}(:,cnt_watch)= Z_polar{t,1}(:,cnt_watch)+sqrtm(R)*randn(3,1);
            
        end
    end
    
    if ~isempty(Z_polar{t,1})

        Z_polar{t,1}(2,(Z_polar{t,1}(2,:)<0))=Z_polar{t,1}(2,(Z_polar{t,1}(2,:)<0))+360;
        Z_polar{t,1}(2,(Z_polar{t,1}(2,:)>360))=Z_polar{t,1}(2,(Z_polar{t,1}(2,:)>360))-360;
        Z_polar{t,1}(3,(Z_polar{t,1}(3,:)>=90))=89.99;
        Z_polar{t,1}(3,(Z_polar{t,1}(3,:)<=-90))=-89.99;
    end
    

    for i=cnt_watch+1:Zr+cnt_watch%%这个循环是杂波产生的点
        
        % 以原点为中心均匀分布的随机极坐标产生
        angle1=rand*2*pi;             
        angle2=acos(rand*2-1);        
        r_d=r_detect*power(rand,1/3); 
        
        % 将极坐标转换为以当前平台位置为圆心的直角坐标
        location_noise(1)=x_radar+r_d.*cos(angle1).*sin(angle2);
        location_noise(2)=y_radar+r_d.*sin(angle1).*sin(angle2);
        location_noise(3)=z_radar+r_d.*cos(angle2);
        
        % 将杂波也转化为径向距离的形式,杂波生成坐标都是相对原点的
        Z_polar{t,1}(:,i)=compute_R_theta(location_noise(1),location_noise(2),location_noise(3),...
                                          x_radar,y_radar,z_radar);
    end


    %======如果存在遮挡，则需要删除被遮挡的观测点========
    if Occlusion_flag == 1 && sensorid == 6 %6号传感器存在的遮挡
        for i = Zr+cnt_watch:-1:1
            if Z_polar{t,1}(1,i) > 400 &&  Z_polar{t,1}(2,i) > 45 && Z_polar{t,1}(2,i) < 135 %遮挡角度为45-135,距离400
                Z_polar{t,1}(:,i) = [];
            end
        end
    end

    if Occlusion_flag == 1 && sensorid == 3 %3号传感器存在的遮挡
        for i = Zr+cnt_watch:-1:1
            if Z_polar{t,1}(1,i) > 300 &&  Z_polar{t,1}(2,i) > 60 && Z_polar{t,1}(2,i) < 120 %遮挡角度为60-120,距离400
                Z_polar{t,1}(:,i) = [];
            end
        end
    end

    if Occlusion_flag == 1 && sensorid == 8 %8号传感器存在的遮挡
        for i = Zr+cnt_watch:-1:1
            if Z_polar{t,1}(1,i) > 300 &&  Z_polar{t,1}(2,i) > 315 || Z_polar{t,1}(2,i) < 35 %遮挡角度为315-35,距离240
                Z_polar{t,1}(:,i) = [];
            end
        end
    end


end

end

%{
                将直角坐标系转化为径向距离，相位角，俯仰角
        输入为当前时刻的三维坐标,,x,y,z,平台坐标x_radar,y_radar,z_radar
        输出为对应的径向距离，相位角，俯仰角,3*1的数列

%}
function location_3d=compute_R_theta(x,y,z,x_radar,y_radar,z_radar)

R_d=sqrt((x-x_radar)^2+(y-y_radar)^2+(z-z_radar)^2);

if x-x_radar==0
    if y-y_radar>0%%y轴坐标为正，则为90°
        theta_head=90;
    elseif y-y_radar<0%%y轴坐标为负，则为270°
        theta_head=270;
    elseif y-y_radar==0
        theta_head=nan;%%在 x y 平面的原点
    end
else
    theta_sus_head=rad2deg(atan((y-y_radar)/(x-x_radar)));
    if x-x_radar>=0&&y-y_radar>=0 %%第1象限
        theta_head=theta_sus_head;
    elseif x-x_radar<0&&y-y_radar>=0 %%第2象限
        theta_head=theta_sus_head+180;
    elseif x-x_radar<0&&y-y_radar<0 %%第3象限
        theta_head=theta_sus_head+180;
    elseif x-x_radar>=0&&y-y_radar<0 %%第4象限
        theta_head=theta_sus_head+360;
    end
end

d_xy=sqrt((x-x_radar)^2+(y-y_radar)^2);
if d_xy==0 %%目标与雷达xy平面投影点重合
    if z-z_radar>0
        theta_tilt=90;
    elseif z-z_radar<0
        theta_tilt=-90;
    elseif z-z_radar==0 %%目标和雷达重合
        theta_tilt=nan;
    end
else
    theta_tilt=rad2deg(atan((z-z_radar)/(d_xy)));
end

location_3d=[R_d;theta_head;theta_tilt];

end






