%{
                           分布式AA融合方法
%}
function [Results] = ALG2_fusion_AA_distr(sensor_inf, merge_threshold)

%===参数获取===
N_sensor = size( sensor_inf,2 );
n_AA = 0; % AA融合之后的总GM个数
for i = 1:N_sensor
    n_AA = n_AA + sensor_inf(i).gm_particles{4,1};
end

%===初始化===
GMs_AA = cell(4,1);
GMs_AA{1,1} = zeros(1,n_AA);    % 权重
GMs_AA{2,1} = zeros(6,n_AA);    % 均值
GMs_AA{3,1} = zeros(6,6*n_AA);  % 协方差
GMs_AA{4,1} = n_AA;             % 粒子数量

Cnt_AA = 0; % AA融合粒子实时计时参数
for i = 1:N_sensor
    for j = 1:sensor_inf(i).gm_particles{4,1}
        cnt_fovIn = 0; % 视场内计数
        
        %===每一个粒子都需要去判断在几个传感器的视场内===
        for k = 1:N_sensor
            flag_FoV = FoV_judge( sensor_inf(k).location,...
                sensor_inf(i).gm_particles{2,1}(:,j), sensor_inf(k).R_detect); % 视场判断
            if flag_FoV == 1 
                cnt_fovIn = cnt_fovIn+1;
            end
        end
        
        %===单个粒子所有传感器判断结束===
        if cnt_fovIn == 0
            cnt_fovIn = 1;
        end
        Cnt_AA = Cnt_AA + 1;

        %===粒子赋值===
        GMs_AA{1,1}(1,Cnt_AA) = sensor_inf(i).gm_particles{1,1}(1,j)/cnt_fovIn;
        GMs_AA{2,1}(:,Cnt_AA) = sensor_inf(i).gm_particles{2,1}(:,j);
        GMs_AA{3,1}(:,Cnt_AA*6-5:Cnt_AA*6) = sensor_inf(i).gm_particles{3,1}(:,j*6-5:j*6);
        
    end
end

%=====合并程序=====
[Results] = ALG2_merge_AA(GMs_AA,merge_threshold);

end