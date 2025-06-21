%{
                                    �۲⺯��

            ���룺1.Xreal -- ��ǰʱ�̵���ʵֵ6*n_target��double����
                  2.location -- ����������λ�ã�3*1��double���飩
                  3.r_detect -- ���뾶
                  4.Pd       -- ������
                  5.Zr       -- �Ӳ���������
                  6.R        -- �۲ⷽ��
                  7.N        -- ����������

            �����1.Z_polar_part -- �Ե�ǰ����������ΪԲ�ĵľֲ�������۲�

%}
function [Z_polar]=observe_FoV_3d(Xre_time_target,location,r_detect,Pd,Zr,R,N,sensorid,Occlusion_flag)

%===Ԥ����===
% ��������ʺܸߣ��ڲ�����1�����й۲�
if Pd >= 0.99
    Pd = 1;
end

% ����������
x_radar=location(1);
y_radar=location(2);
z_radar=location(3);

Z_polar=cell(N,1); % ÿһ��cell�а���һ��ʱ�̵Ĺ۲⼯

for t=1:N % ѭ��t����ڼ���ʱ�̣�counter_watchΪ�۲⵽��Ŀ�����
    cnt_watch=0;
    N_target=size(Xre_time_target{t,1},2); % ��ǰʱ����ʵĿ�����
    for i=1:N_target 
        r=rand;
        d=sqrt( (Xre_time_target{t,1}(1,i)-x_radar)^2 + (Xre_time_target{t,1}(3,i)-y_radar)^2 + ...
            (Xre_time_target{t,1}(5,i)-z_radar)^2);
        
        % ��ʵĿ�걻�۲��ж�����
        if d<=r_detect && Pd>r 
            cnt_watch=cnt_watch+1;
            
            %�����Թ۲ⷽʽ
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
    

    for i=cnt_watch+1:Zr+cnt_watch%%���ѭ�����Ӳ������ĵ�
        
        % ��ԭ��Ϊ���ľ��ȷֲ���������������
        angle1=rand*2*pi;             
        angle2=acos(rand*2-1);        
        r_d=r_detect*power(rand,1/3); 
        
        % ��������ת��Ϊ�Ե�ǰƽ̨λ��ΪԲ�ĵ�ֱ������
        location_noise(1)=x_radar+r_d.*cos(angle1).*sin(angle2);
        location_noise(2)=y_radar+r_d.*sin(angle1).*sin(angle2);
        location_noise(3)=z_radar+r_d.*cos(angle2);
        
        % ���Ӳ�Ҳת��Ϊ����������ʽ,�Ӳ��������궼�����ԭ���
        Z_polar{t,1}(:,i)=compute_R_theta(location_noise(1),location_noise(2),location_noise(3),...
                                          x_radar,y_radar,z_radar);
    end


    %======��������ڵ�������Ҫɾ�����ڵ��Ĺ۲��========
    if Occlusion_flag == 1 && sensorid == 6 %6�Ŵ��������ڵ��ڵ�
        for i = Zr+cnt_watch:-1:1
            if Z_polar{t,1}(1,i) > 400 &&  Z_polar{t,1}(2,i) > 45 && Z_polar{t,1}(2,i) < 135 %�ڵ��Ƕ�Ϊ45-135,����400
                Z_polar{t,1}(:,i) = [];
            end
        end
    end

    if Occlusion_flag == 1 && sensorid == 3 %3�Ŵ��������ڵ��ڵ�
        for i = Zr+cnt_watch:-1:1
            if Z_polar{t,1}(1,i) > 300 &&  Z_polar{t,1}(2,i) > 60 && Z_polar{t,1}(2,i) < 120 %�ڵ��Ƕ�Ϊ60-120,����400
                Z_polar{t,1}(:,i) = [];
            end
        end
    end

    if Occlusion_flag == 1 && sensorid == 8 %8�Ŵ��������ڵ��ڵ�
        for i = Zr+cnt_watch:-1:1
            if Z_polar{t,1}(1,i) > 300 &&  Z_polar{t,1}(2,i) > 315 || Z_polar{t,1}(2,i) < 35 %�ڵ��Ƕ�Ϊ315-35,����240
                Z_polar{t,1}(:,i) = [];
            end
        end
    end


end

end

%{
                ��ֱ������ϵת��Ϊ������룬��λ�ǣ�������
        ����Ϊ��ǰʱ�̵���ά����,,x,y,z,ƽ̨����x_radar,y_radar,z_radar
        ���Ϊ��Ӧ�ľ�����룬��λ�ǣ�������,3*1������

%}
function location_3d=compute_R_theta(x,y,z,x_radar,y_radar,z_radar)

R_d=sqrt((x-x_radar)^2+(y-y_radar)^2+(z-z_radar)^2);

if x-x_radar==0
    if y-y_radar>0%%y������Ϊ������Ϊ90��
        theta_head=90;
    elseif y-y_radar<0%%y������Ϊ������Ϊ270��
        theta_head=270;
    elseif y-y_radar==0
        theta_head=nan;%%�� x y ƽ���ԭ��
    end
else
    theta_sus_head=rad2deg(atan((y-y_radar)/(x-x_radar)));
    if x-x_radar>=0&&y-y_radar>=0 %%��1����
        theta_head=theta_sus_head;
    elseif x-x_radar<0&&y-y_radar>=0 %%��2����
        theta_head=theta_sus_head+180;
    elseif x-x_radar<0&&y-y_radar<0 %%��3����
        theta_head=theta_sus_head+180;
    elseif x-x_radar>=0&&y-y_radar<0 %%��4����
        theta_head=theta_sus_head+360;
    end
end

d_xy=sqrt((x-x_radar)^2+(y-y_radar)^2);
if d_xy==0 %%Ŀ�����״�xyƽ��ͶӰ���غ�
    if z-z_radar>0
        theta_tilt=90;
    elseif z-z_radar<0
        theta_tilt=-90;
    elseif z-z_radar==0 %%Ŀ����״��غ�
        theta_tilt=nan;
    end
else
    theta_tilt=rad2deg(atan((z-z_radar)/(d_xy)));
end

location_3d=[R_d;theta_head;theta_tilt];

end






