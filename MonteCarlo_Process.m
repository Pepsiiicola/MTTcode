M = Config.M; % 蒙特卡洛次数

% 蒙特卡洛变量初始化
Monte_ALG = struct; % 单次蒙特卡洛统计指标
MM_ALG = struct;    % 多次蒙特卡洛统计指标
% # Monte_ALG(i)代表第 i 个算法的相关数据，如果在配置中未选择此算法，依旧会占一个位置
for i = 1:size(Config.AlgCompare,2)
    % 单次蒙特卡洛
    Monte_ALG(i).TIME_TOTAL = zeros(M,1);   % 算法整体耗时
    Monte_ALG(i).OSPA = zeros(M,N);         % 算法平均OSPA
    Monte_ALG(i).Num_estimate = zeros(M,N); % 算法估计数量
    % 多次蒙特卡洛
    MM_ALG(i).TIME_TOTAL = 0;            % 算法整体耗时
    MM_ALG(i).OSPA = zeros(1,N);         % 算法平均OSPA
    MM_ALG(i).Num_estimate = zeros(1,N); % 算法估计数量
end


for m = 1:M
    
    inf_loop = ['大循环: ',num2str(Serial_Monte),' 蒙特卡洛循环: ',num2str(m)];
    disp( inf_loop );
    
    % 公共变量初始化(观测数据)
    Common_Variable_Initial;
    
    %*****************************
    %          观测生成
    %*****************************
    for i=1:N_sensor
        
        %***************************
        %        分散式平台
        %***************************
        %==============局部观测极坐标=============
        [Sensor_decen(i).Z_polar_part] = observe_FoV_3d(Xreal_time_target,Sensor_decen(i).location,...
            Sensor_decen(i).R_detect,Sensor_decen(i).Pd,Sensor_decen(i).Zr,Sensor_decen(i).R,N,i,Occlusion_flag);
        %======将观测局部极坐标转化为全局直角坐标=======
        [Sensor_decen(i).Z_dicaer_global] = polar2dicaer_3d( Sensor_decen(i).Z_polar_part,...
            Sensor_decen(i).location(1), Sensor_decen(i).location(2), Sensor_decen(i).location(3) );
        
        %****************************
        %        分布式平台
        %****************************
        % 策略1：全部一致 : 全部一致是用于所有观测条件一样的情况对比测试算法性能
        %==============局部观测极坐标=============
        Sensor_distr(i).Z_polar_part = Sensor_decen(i).Z_polar_part;
        %======将观测局部极坐标转化为全局直角坐标=======
        Sensor_distr(i).Z_dicaer_global=Sensor_decen(i).Z_dicaer_global;
        
        % 策略2：独立观测
        %==============局部观测极坐标=============
        %     [Sensor_distr(i).Z_polar_part]=observe_FoV_3d(Xreal_time_target,Sensor_distr(i).location,...
        %         Sensor_distr(i).R_detect,Sensor_distr(i).Pd,Sensor_distr(i).Zr,Sensor_distr(i).R,N);
        %     %======将观测局部极坐标转化为全局直角坐标=======
        %     [Sensor_distr(i).Z_dicaer_global]=polar2dicaer_3d( Sensor_distr(i).Z_polar_part,...
        %         Sensor_distr(i).location(1), Sensor_distr(i).location(2), Sensor_distr(i).location(3) );
        
    end
    
    %=================
    %   轨迹图显示
    %=================
    if Serial_Monte == 1 && m == 1
        sciPlot;
    end
    
    %*****************************
    %          跟踪算法
    %*****************************
    if Config.AlgCompare(1) == 1
        % 算法流程
        [Monte_ALG(1).OSPA(m,:), Monte_ALG(1).Num_estimate(m,:), Monte_ALG(1).TIME_TOTAL(m,1)] =...
            PROCESS_OF_ALG1(Xreal_target_time,Xreal_time_target,Sensor_decen,N);
    end
    
    if Config.AlgCompare(2) == 1
        % 算法流程
        [Monte_ALG(2).OSPA(m,:), Monte_ALG(2).Num_estimate(m,:), Monte_ALG(2).TIME_TOTAL(m,1)] =...
            PROCESS_OF_ALG2(Xreal_target_time,Xreal_time_target,Sensor_distr,N);
    end
    
    if Config.AlgCompare(3) == 1
        % 算法流程
        [Monte_ALG(3).OSPA(m,:), Monte_ALG(3).Num_estimate(m,:), Monte_ALG(3).TIME_TOTAL(m,1)] =...
            PROCESS_OF_ALG3(Xreal_target_time,Xreal_time_target,Sensor_distr,N);
    end
    
    if Config.AlgCompare(4) == 1
        % 算法流程
        [Monte_ALG(4).OSPA(m,:), Monte_ALG(4).Num_estimate(m,:), Monte_ALG(4).TIME_TOTAL(m,1)] =...
            PROCESS_OF_ALG4(Xreal_target_time,Xreal_time_target,Sensor_decen,N); 
    end
    
    if Config.AlgCompare(5) == 1
        % 算法流程
        [Monte_ALG(5).OSPA(m,:), Monte_ALG(5).Num_estimate(m,:), Monte_ALG(5).TIME_TOTAL(m,1), Monte_ALG(5).CONSENSUS_OSPA(m,:)] =...
            PROCESS_OF_ALG5(Xreal_target_time,Xreal_time_target,Sensor_decen,N,...
            Num_communicate_decen,mat_weight_decen);
    end
    
    if Config.AlgCompare(6) == 1
        % 算法流程
        [Monte_ALG(6).OSPA(m,:), Monte_ALG(6).Num_estimate(m,:), Monte_ALG(6).TIME_TOTAL(m,1)] =...
            PROCESS_OF_ALG6(Xreal_target_time,Xreal_time_target,Sensor_decen,N,Num_communicate_decen,...
            mat_weight_decen); %mat_weight_decen
    end
    
    if Config.AlgCompare(7) == 1
        % 算法流程
        [Monte_ALG(7).OSPA(m,:), Monte_ALG(7).Num_estimate(m,:), Monte_ALG(7).TIME_TOTAL(m,1)] =...
            PROCESS_OF_ALG7(Xreal_target_time,Xreal_time_target,Sensor_decen,N,Num_communicate_decen,...
            mat_weight_decen);
    end

    if Config.AlgCompare(8) == 1
        % 算法流程
        [Monte_ALG(8).OSPA(m,:), Monte_ALG(8).Num_estimate(m,:), Monte_ALG(8).TIME_TOTAL(m,1)] =...
            PROCESS_OF_ALG8(Xreal_target_time,Xreal_time_target,Sensor_decen,N,Num_communicate_decen);
    end

    if Config.AlgCompare(9) == 1
        % 算法流程
        [Monte_ALG(9).OSPA(m,:), Monte_ALG(9).Num_estimate(m,:), Monte_ALG(9).TIME_TOTAL(m,1)] =...
            PROCESS_OF_ALG9(Xreal_target_time,Xreal_time_target,Sensor_decen,N,Num_communicate_decen);
    end

    if Config.AlgCompare(10) == 1
        % 算法流程
        [Monte_ALG(10).OSPA(m,:), Monte_ALG(10).Num_estimate(m,:), Monte_ALG(10).TIME_TOTAL(m,1)] =...
            PROCESS_OF_ALG10(Xreal_target_time,Xreal_time_target,Sensor_decen,N,Num_communicate_decen,...
            mat_weight_decen);
    end
    
    if Config.AlgCompare(11) == 1
        %算法流程
        [Monte_ALG(11).OSPA(m,:), Monte_ALG(11).Num_estimate(m,:), Monte_ALG(11).TIME_TOTAL(m,1)] =...
            PROCESS_OF_ALG11(Xreal_target_time,Xreal_time_target,Sensor_decen,N,Num_communicate_decen);
    end

    if Config.AlgCompare(12) == 1
        % 算法流程
        [Monte_ALG(12).OSPA(m,:), Monte_ALG(12).Num_estimate(m,:), Monte_ALG(12).TIME_TOTAL(m,1)] =...
            PROCESS_OF_ALG12(Xreal_target_time,Xreal_time_target,Sensor_decen,N,Num_communicate_decen);
    end
    
end

%******************************
%       蒙特卡洛结果统计
%******************************
for i = 1:size(Config.AlgCompare,2)
    MM_ALG(i).TIME_TOTAL = sum(Monte_ALG(i).TIME_TOTAL,1)/M;     % 算法整体耗时
    MM_ALG(i).OSPA = sum(Monte_ALG(i).OSPA,1)/M;                 % 算法OSPA
    MM_ALG(i).Num_estimate = sum(Monte_ALG(i).Num_estimate,1)/M; % 算法估计数量
end


