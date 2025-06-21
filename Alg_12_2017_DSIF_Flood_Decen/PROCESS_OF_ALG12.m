%{
                                算法8子函数
           输入: 1.真实数据
                 2.观测数据
                 3.传感器属性
                 4.总跟踪时长

           输出: 1.跟踪结果的OSPA (包含每个时刻的OSPA数值)
                 2.跟踪结果的数量 (包含每个时刻的数量)
                 3.算法跟踪总耗时 

           注： 以1号传感器的结果作为结果输出
%}
function [OSPA,Num_estimate,Time] = PROCESS_OF_ALG12(Xreal_target_time,Xreal_time_target,Sensor,N,L)
    X = sprintf('第12个算法运行中...\n');
    fprintf(X);

    ALG8_SensorData;
    Time = 0;
    tic;

%=====虚拟存储中心设置(用于通信)=====
% com_storage = struct;
% Fusion_center = struct;
% Fusion_center.Inf_recieve = struct;
storage_Inf = struct;

    for k = 1:N

%============拓扑时变专用========= 2025.3.12增加

    if k > 25 && k <= 50
        sensor_Num = 14;
    elseif k > 50 && k <= 75
        sensor_Num = 12;
    elseif k > 75
        sensor_Num = 10;
    end
%================================


        Fusion_center = struct;
        Fusion_center.Inf_total = struct; %定义一个结构体====12.21修改

        com_storage = struct;
        com_storage.Inf = struct;
        %单传感器滤波
        for j = 1:sensor_Num            
%             [Input(j).x_k_history,Input(j).w_birth,Input(j).m_birth,Input(j).numTargetbirth,Input(j).w_bar_k,Input(j).m_bar_k,Output(j).x_k,Output(j).x_k_GM,Output(j).w_k_GM,Output(j).P_k_GM] = ALG1_SMC_PHD_Filter(Input(j).numTargetbirth,Input(j).m_birth,Input(j).w_birth,F,H,R,...
%             Input(j).w_bar_k,Input(j).m_bar_k,Input(j).Z{k,1},Input(j).Z_clutter,Input(j).nClutter,Input(j).detect_prob,Input(j).x_k_history,k,Input(j).location,Input(j).R_detect);
            [Input(j).x_k_history,Input(j).w_birth,Input(j).m_birth,Input(j).P_birth,Input(j).numTargetbirth,Input(j).w_bar_k, Input(j).m_bar_k,Input(j).P_bar_k,Output(j).x_k,Output(j).x_k_w,Output(j).x_k_P] = Alg12_GM_PHD_Filter(Input(j).numTargetbirth,Input(j).m_birth,Input(j).P_birth,Input(j).w_birth,F,Q,R,...
            Input(j).w_bar_k,Input(j).m_bar_k,Input(j).P_bar_k,Input(j).Z{k,1},Input(j).Z_clutter,Input(j).nClutter,Input(j).detect_prob,Input(j).x_k_history,k,Input(j).location,Input(j).R_detect);
        end

       %将滤波器输出的高斯分量封装好
       for i =1:sensor_Num
           storage_Inf(i).temp{1} = Output(i).x_k_w;
           storage_Inf(i).temp{2} = Output(i).x_k;
           storage_Inf(i).temp{2}(5,:) = i;   %传感器编号
           storage_Inf(i).temp{3} = Output(i).x_k_P;
           storage_Inf(i).temp{4} = size(Output(i).x_k,2);
           storage_Inf(i).temp{5} = i;
       end

       for i=1:sensor_Num
           com_storage(i).Inf.gm_components = storage_Inf(i).temp;
       end

       %把节点自身的信息装配好
       for i= 1:sensor_Num
           Fusion_center(i).Inf_total = com_storage(i).Inf;
       end

       for i=1:sensor_Num
           Fusion_center(i).Inf_topo = zeros(size(Sensor(i).mat_topo));
           Fusion_center(i).Inf_topo(i,:) = Sensor(i).mat_topo(i,:);
           Fusion_center(i).Inf_topo(:,i) = Sensor(i).mat_topo(:,i);
       end

       
        %开始flooding，L为通信次数
        for l=1:L

            %=======信息接收，每个节点接收邻居的信息==== 12.21修改
            for i = 1:sensor_Num
                [Fusion_center(i).Inf_recieve,Fusion_center(i).Inf_topo] = Alg12_module_com_recieve_modif(com_storage,Sensor(i).mat_topo,i,l,Fusion_center);
            end

            %======通信带宽受限情况  ==== 3.7增加
%             for i = 1:sensor_Num
%                 [Fusion_center(i).Inf_recieve] = ALG12_BandWidth_limit(Fusion_center(i).Inf_recieve,Sensor(i).mat_topo,Sensor(i).Com_BandWidth,i);
%             end

            %======与之前的信息进行合并========12.21修改
            for i = 1:sensor_Num
                [Fusion_center(i)] = Alg12_Inf_merge(Fusion_center(i));
            end


            %======接收完之后，每个节点将再次装配下一轮要发送的信息=======1.11增加
            for i = 1:sensor_Num
                [com_storage(i)] = ALG12_Inf_assemble(Fusion_center(i),i);
            end

            %====将每个节点的信息进行去重复处理=========12.26修改
            for i = 1:sensor_Num
                [Fusion_center(i)] = Alg12_Inf_deduped(Fusion_center(i));
            end

           
        end

        %==================通信结束，开始融合==============
        for i = 1:sensor_Num
            [Sensor(i).state] = ALG12_fusion_diffusion(Fusion_center(i),match_threshold,...
                i,l,Sensor);
        end


        %==================状态提取=================
        for i = 1:sensor_Num
            [Sensor(i).X_est{k,1},Sensor(i).num_est(k)] = Alg12_statedraw(Sensor(i).state);
        end

        % 划分视域(用于反馈)
        for i=1:sensor_Num
            [Sensor(i).state,~]=Alg8_FoV_divide(Sensor(i).state,Sensor(i).location,Sensor(i).R_detect);
            Input(i).w_bar_k = Sensor(i).state.w;
            Input(i).m_bar_k = Sensor(i).state.m;
            Input(i).P_bar_k = Sensor(i).state.P;
        end


    end    



    %======================================评估部分=========================================
    %=== OSPA 计算 ===
    OSPA = zeros(1,N);
    OSPA(1:2) = 0;
    for t=1:N
        % 要对 Xreal_time_target 进行一个数据处理，将内部的nan值删除
        Xreal_time_target{t,1}( :,isnan(Xreal_time_target{t,1}(1,:)) ) = [];
    end
    for t=3:N
        OSPA(t) = ospa_dist(Xreal_time_target{t,1}(1:4,:),Sensor(8).X_est{t,1},120,2);
    end
    
    %=== 数量计算 ===
    Num_estimate = zeros(1,N);
    for t=1:N
        Num_estimate(t) = size(Sensor(8).X_est{t,1},2);
    end


    Time = toc;
    Time = Time / (sensor_Num * N);
%     ALG8_PLOT;

    
end

