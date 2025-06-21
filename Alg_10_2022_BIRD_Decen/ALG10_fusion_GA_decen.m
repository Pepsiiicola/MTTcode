%{
                           分布式GA融合方法
%}
function [Results] = ALG10_fusion_GA_decen(Fusion_center, match_threshold,sensorID,Sensor)

%===参数获取===
N_sensor = size( Fusion_center.Inf_recieve,2 ); %N_sensor是接收到的信息份数
Match_part1_sus = cell(4,1);

%===序贯融合===
%=== 找到第一个非空集合赋值给Match_part1 ===
ID_record = 0; % 第一个Match_part1对应的传感器ID
for i = 1:size(Fusion_center.Inf_recieve,2)
    if Fusion_center.Inf_recieve(i).gm_particles{4,1} ~= 0
        Match_part1 = Fusion_center.Inf_recieve(i).gm_particles;
        ID_record = i;
        break;
    end
end

% 判断是否有效赋值了，如果有则进入序贯融合环节，没有则跳过
if ID_record == 0
    Results = cell(4,1);
    Results{1,1} = zeros(1,0);
    Results{2,1} = zeros(6,0);
    Results{3,1} = zeros(6,6*0);
    Results{4,1} = 0;
    
else
    t_f = 1;
    for i = ID_record+1:N_sensor
        
        %=== 待匹配分量赋值 ===
        %=== 判断是否有待匹配分量，若有则进入匹配，若无则跳过 ===
        if Fusion_center.Inf_recieve(i).gm_particles{4,1} ~= 0
            Match_part2 = Fusion_center.Inf_recieve(i).gm_particles;
            t_f = t_f + 1;
        else
            continue;
        end
        
        %===初始化===
        n_fusion = Match_part1{4,1} + Match_part2{4,1};
        Match_part1_sus{1,1} = zeros(1,n_fusion);
        Match_part1_sus{2,1} = zeros(7,n_fusion);
        Match_part1_sus{3,1} = zeros(6,6*n_fusion);
        Match_part1_sus{4,1} = 0;
        cnt_GA = 0; % 实际融合次数计数
        
        %===匹配部分===
        [Solution_match,Mat_match] = ALG10_Match(Match_part1,Match_part2,match_threshold,Sensor);%sensorID表示当前传感器编号，i表示
        
        %===融合部分===
        % 匹配组融合
        % 1.将配对组对应的分量进行GA融合，融合结果存放到 Match_part1_sus 中去
        for j = 1:size(Solution_match,1)

            if Solution_match(j)~=0
                k = Solution_match(j); % j,k 分别代表part1和part2的对应粒子           
                cnt_GA = cnt_GA + 1; % 融合计数
                % 协方差的GA融合
                Match_part1_sus{3,1}(:,6*(cnt_GA-1)+1:6*cnt_GA) = ...
                    inv( (1-1/t_f)*inv(Match_part1{3,1}(:,6*(j-1)+1:6*j)) + (1/t_f)*inv(Match_part2{3,1}(:,6*(k-1)+1:6*k)) );
                % 状态的GA融合
                Match_part1_sus{2,1}(1:6,cnt_GA) = Match_part1_sus{3,1}(:,6*(cnt_GA-1)+1:6*cnt_GA) * ...
                    ( (1-1/t_f) *inv(Match_part1{3,1}(:,6*(j-1)+1:6*j)) * Match_part1{2,1}(1:6,j) +...
                    (1/t_f) *inv(Match_part2{3,1}(:,6*(k-1)+1:6*k)) * Match_part2{2,1}(1:6,k) );
                % 权重的GA融合
                Match_part1_sus{1,1}(1,cnt_GA) = ( Match_part1{1,1}(1,j))^((1-1/t_f)) * ...
                    ( Match_part2{1,1}(1,k))^(1/t_f);
                % 数量更新
                cnt_GA = cnt_GA+1-1;
            end
        end
        
        % 非匹配组融合
        % 分别对part1和part2进行遍历
        % 在对part1的单独粒子进行遍历的时候需要判断该粒子是否存在于part2对应传感器的观测范围之内，如果
        % 存在，那么权重需要降低
        for j = 1:size( Mat_match , 1)
            if sum( Mat_match(j,:) , 2) == 0
                cnt_GA = cnt_GA + 1; % 融合计数
                % 协方差的GA融合
                Match_part1_sus{3,1}(:,6*(cnt_GA-1)+1:6*cnt_GA) = Match_part1{3,1}(:,6*(j-1)+1:6*j);
                % 状态的GA融合
                Match_part1_sus{2,1}(1:6,cnt_GA) = Match_part1{2,1}(1:6,j);
                % 权重的GA融合
%                 flag_FoV = FoV_judge( Fusion_center.sensor_inf(i).location, Match_part1{2,1}(1:6,j), ...
%                                       Fusion_center.sensor_inf(i).R_detect); % 视场判断
%                 if flag_FoV == 1
%                     Match_part1_sus{1,1}(1,cnt_GA) = Match_part1{1,1}(1,j)*0.7 ; % 0.7 是自己设定的权重衰减率
% %                     Match_part1_sus{1,1}(1,cnt_GA) = Match_part1{1,1}(1,j);
%                 else 
%                     Match_part1_sus{1,1}(1,cnt_GA) = Match_part1{1,1}(1,j);
%                 end
                Match_part1_sus{1,1}(1,cnt_GA) = Match_part1{1,1}(1,j);
            end
        end
        for k = 1:size( Mat_match , 2)
            if sum( Mat_match(:,k) , 1) == 0
                cnt_GA = cnt_GA + 1; % 融合计数
                % 协方差的GA融合
                Match_part1_sus{3,1}(:,6*(cnt_GA-1)+1:6*cnt_GA) = Match_part2{3,1}(:,6*(k-1)+1:6*k);
                % 状态的GA融合
                Match_part1_sus{2,1}(1:6,cnt_GA) = Match_part2{2,1}(1:6,k);
                % 权重的GA融合
                Match_part1_sus{1,1}(1,cnt_GA) = Match_part2{1,1}(1,k);
            end
        end
        
        % 3.将 Match_part1_sus 进行多余数据处理后赋值给 Match_part1，进行序贯融合的下一步
        Match_part1_sus{1,1}(:,cnt_GA+1:end) = [];
        Match_part1_sus{2,1}(:,cnt_GA+1:end) = [];
        Match_part1_sus{2,1}(7,:) = sensorID;
        Match_part1_sus{3,1}(:,6*cnt_GA+1:end) = [];
        Match_part1_sus{4,1} = cnt_GA;
        Match_part1 = Match_part1_sus;
        
    end
    Results = Match_part1;
end

end