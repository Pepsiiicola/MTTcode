%{
                           分布式GA融合方法
%}
function [Results] = ALG7_fusion_AGM_decen(Fusion_center,match_threshold,mat_weight,ID_sensor,l,mat_topo)

%===参数获取===
N_sensor = size( Fusion_center.Inf_recieve , 2 );
dir_connect = find( mat_topo(ID_sensor,:) == 1 ); % 与当前传感器直接连接

%===参数初始化===
Matched_GM = struct;      % 匹配GM集合
Matched_GM.gm =cell(4,1); % 每一个gm中代表一组匹配上的gm粒子组
% Matched_GM.id = [0];    % 每个gm粒子对应的传感器ID
cnt_matchedGm = 0;        % 匹配粒子对计数

%=== 找到第一个非空集合赋值给Match_part1 ===
ID_record = 0; % 第一个Match_part1对应的传感器ID
for i = 1:size(Fusion_center.Inf_recieve,2)
    if Fusion_center.Inf_recieve(i).gm_particles{4,1} ~= 0
        Match_part1 = Fusion_center.Inf_recieve(i).gm_particles;
        ID_record = i;
        break;
    end
end

% 判断是否有效赋值了，如果有则进入匹配环节，没有则跳过匹配环节
if ID_record ~= 0
    
    % 对 Matched_GM 进行赋值
    for i = 1:Match_part1{4,1}
        Matched_GM(i).gm{1,1} = Match_part1{1,1}(1,i);
        Matched_GM(i).gm{2,1} = Match_part1{2,1}(:,i);
        Matched_GM(i).gm{3,1} = Match_part1{3,1}(:,6*i-5:6*i);
        Matched_GM(i).gm{4,1} = 1;
        cnt_matchedGm = cnt_matchedGm + 1;
    end
    
    for i = ID_record+1 : N_sensor
        
        %=== 待匹配分量赋值 ===
        %=== 判断是否有待匹配分量，若有则进入匹配，若无则跳过 ===
        if Fusion_center.Inf_recieve(i).gm_particles{4,1} ~= 0
            Match_part2 = Fusion_center.Inf_recieve(i).gm_particles;
        else
            continue;
        end
        
        %===匹配部分===
        [Solution_match,Mat_match] = ALG7_Match(Match_part1,Match_part2,Matched_GM,cnt_matchedGm,match_threshold);
        
        % 1.将配对组对应的分量存放到 Matched_GM 中去
        for j = 1:size(Solution_match,1)
            if Solution_match(j)~=0
                k = Solution_match(j); % j,k 分别代表part1和part2的对应粒子
                % 权重赋值
                Matched_GM(j).gm{1,1} = [Matched_GM(j).gm{1,1},Match_part2{1,1}(1,k)];
                % 状态赋值
                Matched_GM(j).gm{2,1} = [Matched_GM(j).gm{2,1},Match_part2{2,1}(:,k)];
                % 协方差赋值
                Matched_GM(j).gm{3,1} = [Matched_GM(j).gm{3,1},Match_part2{3,1}(:,6*(k-1)+1:6*k)];
                % 个数更新
                Matched_GM(j).gm{4,1} = Matched_GM(j).gm{4,1} + 1; % 单个匹配组中的匹配粒子计数
            end
        end
        
        %===对未匹配上的粒子进行处理===
        for k = 1:size( Mat_match , 2)
            if sum( Mat_match(:,k) , 1) == 0
                
                %=== 更新匹配粒子集合 ===
                cnt_matchedGm = cnt_matchedGm + 1; % 匹配粒子组数计数增加
                % 权重赋值
                Matched_GM(cnt_matchedGm).gm{1,1} = Match_part2{1,1}(1,k);
                % 状态赋值
                Matched_GM(cnt_matchedGm).gm{2,1} = Match_part2{2,1}(:,k);
                % 协方差赋值
                Matched_GM(cnt_matchedGm).gm{3,1} = Match_part2{3,1}(:,6*(k-1)+1:6*k);
                % 个数更新
                Matched_GM(cnt_matchedGm).gm{4,1} = 1;
                
                %=== 同时更新 Match_part1 ===
                % 权重赋值
                Match_part1{1,1} = [Match_part1{1,1},Match_part2{1,1}(1,k)];
                % 状态赋值
                Match_part1{2,1} = [Match_part1{2,1},Match_part2{2,1}(:,k)];
                % 协方差赋值
                Match_part1{3,1} = [Match_part1{3,1},Match_part2{3,1}(:,6*(k-1)+1:6*k)];
                % 个数更新
                Match_part1{4,1} = Match_part1{4,1} + 1; % 单个匹配组中的匹配粒子计数
                
            end
        end
        
    end
end

%=============== 前置判断 =================
% 若没有有效赋值那么不进行AA融合直接输出空集
if ID_record == 0
    Results = cell(4,1);
    Results{1,1} = zeros(1,0);
    Results{2,1} = zeros(7,0);
    Results{3,1} = zeros(6,6*0);
    Results{4,1} = 0;
    
else
    %========================================AGM融合===============================================
    % 这里会将融合之后的结果作为一个基准去判断观测范围之内还是之外，若数量对应不上，则会相应调整权重
    % 初始化
    n_fusion = size(Matched_GM,2); % 待融合的匹配粒子组
    Results = cell(4,1);
    Results{1,1} = zeros(1,n_fusion);
    Results{2,1} = zeros(7,n_fusion);
    Results{3,1} = zeros(6,6*n_fusion);
    Results{4,1} = n_fusion;
    for i = 1:n_fusion
        
        % 这个地方的融合权重应该根据一致性权重来划分
        n_w2f = Matched_GM(i).gm{4,1};
        pai = zeros(1,n_w2f); % 融合权重
        pai_state = zeros(1,n_w2f); % 状态融合权重

        for j=1:n_w2f
            pai(j) = mat_weight( ID_sensor , Matched_GM(i).gm{2,1}(7,j) );
        end
        % #这个地方是否需要归一化值得讨论
        pai = pai / sum(pai,2);

        for j=1:n_w2f
            pai_state(j) = mat_weight( ID_sensor , Matched_GM(i).gm{2,1}(7,j) );
        end

        pai_state = pai_state / sum(pai_state,2);%归一化

        % 权重融合
        W_AA = 0;
        for j = 1:n_w2f
            W_AA = W_AA + pai(j) * Matched_GM(i).gm{1,1}(1,j);
        end
        
        % 协方差融合
        P_AA = zeros(6,6);
        for j = 1:n_w2f
            P_AA = P_AA + pai_state(j) * inv( Matched_GM(i).gm{3,1}(:,6*(j-1)+1:6*j) );
        end
        P_AA = inv( P_AA );
        
        % 均值融合
        M_AA = [0 0 0 0 0 0]';
        for j = 1:n_w2f
            M_AA = M_AA + pai_state(j) * inv( Matched_GM(i).gm{3,1}(:,6*(j-1)+1:6*j) ) * ...
                Matched_GM(i).gm{2,1}(1:6,j);
        end
        M_AA = P_AA * M_AA;

        %重置权重
        for j=1:n_w2f
            pai(j) = mat_weight( ID_sensor , Matched_GM(i).gm{2,1}(7,j) );
        end

        for j=1:n_w2f
            pai_state(j) = mat_weight( ID_sensor , Matched_GM(i).gm{2,1}(7,j) );
        end
        
        % 视场判断调整权重
        % 说明：由于边界情况的影响，以及分散式多次通信融合的特点，若因为边界下对粒子的个数计算错误，造
        %       成权重增大，那么对后续的跟踪都会有较大的影响，所以对权重过高的情况要进行一定的抑制
        %===每一个粒子都需要去判断在几个传感器的视场内===
        %===只判断邻居节点===
        if l == 1
            cnt_fovIn = 0;
            for k = 1:size( dir_connect,2 )
                flag_FoV = FoV_judge( Fusion_center.sensor_inf( dir_connect(k) ).location, M_AA, ...
                                      Fusion_center.sensor_inf( dir_connect(k) ).R_detect); % 视场判断
                if flag_FoV == 1
                    cnt_fovIn = cnt_fovIn+1;
                end
            end
            if cnt_fovIn == 0
                cnt_fovIn = 1;
            end
        else
            cnt_fovIn = n_w2f;
        end

%=======================================swc修改部分=========================

%先进行粒子所属节点视域的判断
        Index_fovIn = [];
        
        for k = 1:size( dir_connect,2 )
            flag_FoV = FoV_judge( Fusion_center.sensor_inf( dir_connect(k) ).location, M_AA, ...
                                      Fusion_center.sensor_inf( dir_connect(k) ).R_detect); % 视场判断
            if flag_FoV == 1
                Index_fovIn = [Index_fovIn dir_connect(k)];
            end
        end

        noprovide_sensorID = setdiff( dir_connect , Matched_GM(i).gm{2,1}(7,:) ); %没提供粒子的邻居节点
        noprovide_ok_sensorID = setdiff( dir_connect , Index_fovIn ); %可以不提供粒子的邻居节点
        
        %如果有邻居节点没提供粒子，则进入判断是否属于公共视域
        if ~isempty(noprovide_sensorID)   

            
            %判断有没有不需要提供粒子的邻居节点，若有，则把这些连接权重赋给其他连接节点
            if ~isempty(intersect(noprovide_sensorID,noprovide_ok_sensorID))
                nocom_sensorID = intersect(noprovide_sensorID,noprovide_ok_sensorID);
                    
                %基数融合权重调整
                for j=1:n_w2f
                    pai(j) = mat_weight( ID_sensor , Matched_GM(i).gm{2,1}(7,j) );
                end
                pai = pai / sum(pai,2);

                %状态融合权重调整
                for j=1:n_w2f
                    pai_state(j) = mat_weight( ID_sensor , Matched_GM(i).gm{2,1}(7,j) );
                end
                pai_state = pai_state / sum(pai_state,2);

                if ~isempty(setdiff(noprovide_sensorID,noprovide_ok_sensorID))
%                     missTarget_sensorID  = setdiff(noprovide_sensorID,noprovide_ok_sensorID);
                
                    %状态融合权重调整
                    for j=1:n_w2f
                        pai_state(j) = mat_weight( ID_sensor , Matched_GM(i).gm{2,1}(7,j) );
                    end
                    pai_state = pai_state / sum(pai_state,2);
    
                    %基数融合权重调整
                    noprovide_weightSum = sum(mat_weight( ID_sensor , nocom_sensorID ) ); %把不需要提供粒子的传感器连接权重累加
                    eta = 1/(1-noprovide_weightSum); %缩放因子
                    
                    for j=1:n_w2f
                    pai(j) = eta*mat_weight( ID_sensor , Matched_GM(i).gm{2,1}(7,j) );
                    end
                    
                end

                %融合权重调整完，进行融合
                
                % 权重融合
                W_AA = 0;
                for j = 1:n_w2f
                    W_AA = W_AA + pai(j) * Matched_GM(i).gm{1,1}(1,j);
                end
                
                % 协方差融合
                P_AA = zeros(6,6);
                for j = 1:n_w2f
                    P_AA = P_AA + pai_state(j) * inv( Matched_GM(i).gm{3,1}(:,6*(j-1)+1:6*j) );
                end
                P_AA = inv( P_AA );
                
                % 均值融合
                M_AA = [0 0 0 0 0 0]';
                for j = 1:n_w2f
                    M_AA = M_AA + pai_state(j) * inv( Matched_GM(i).gm{3,1}(:,6*(j-1)+1:6*j) ) * ...
                        Matched_GM(i).gm{2,1}(1:6,j);
                end
                M_AA = P_AA * M_AA;


            
            else %未提供粒子的节点全是必须要提供粒子但是没提供的，补虚拟粒子

                %状态融合权重调整
                for j=1:n_w2f
                    pai_state(j) = mat_weight( ID_sensor , Matched_GM(i).gm{2,1}(7,j) );
                end
                pai_state = pai_state / sum(pai_state,2);

                %基数融合权重调整
                for j=1:n_w2f
                    pai(j) = mat_weight( ID_sensor , Matched_GM(i).gm{2,1}(7,j) );
                end

                %融合权重调整完，进行融合
                
                % 权重融合
                W_AA = 0;
                for j = 1:n_w2f
                    W_AA = W_AA + pai(j) * Matched_GM(i).gm{1,1}(1,j);
                end
                
                % 协方差融合
                P_AA = zeros(6,6);
                for j = 1:n_w2f
                    P_AA = P_AA + pai_state(j) * inv( Matched_GM(i).gm{3,1}(:,6*(j-1)+1:6*j) );
                end
                P_AA = inv( P_AA );
                
                % 均值融合
                M_AA = [0 0 0 0 0 0]';
                for j = 1:n_w2f
                    M_AA = M_AA + pai_state(j) * inv( Matched_GM(i).gm{3,1}(:,6*(j-1)+1:6*j) ) * ...
                        Matched_GM(i).gm{2,1}(1:6,j);
                end
                M_AA = P_AA * M_AA;

                
            end
       
        end
                
              
%==================================================================


%         W_AA = W_AA * min( 1, n_w2f / cnt_fovIn); % 对权重比调整过高的情况进行抑制
        
        %=====赋值=====
        Results{1,1}(1,i) = W_AA;
        Results{2,1}(:,i) = [M_AA;ID_sensor];
        Results{3,1}(:,6*(i-1)+1:6*i) = P_AA;
        
    end
end

end