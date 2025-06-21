%{
                              匹配程序
%}
function [Solution_match,Mat_match] = ALG10_Match(Match_part1,Match_part2,match_threshold,Sensor)

%1.计算出两个集合之间的距离矩阵，将距离超过阈值的设定为阈值
[D]=dis_compute_vector(Match_part1{2,1},Match_part2{2,1});
D = min(match_threshold,D);

%2.进行murty算法的配对，将配对的结果对照距离矩阵进行比对，配对组若距离若等于阈值认为配对失效
Solution = Murty(D, 1);
Solution_match = Solution{1,1}{1,1};
dim_part1 = Match_part1{4,1}; % part1配对的维数
dim_part2 = Match_part2{4,1}; % part2配对的维数
Mat_match = zeros(dim_part1,dim_part2);

for i = 1:size(Solution_match,1)
    if Solution_match(i) ~= 0 && D(i,Solution_match(i)) < match_threshold
        Mat_match(i,Solution_match(i)) = 1;
    elseif Solution_match(i) ~= 0 && D(i,Solution_match(i)) >= match_threshold
        Solution_match(i) = 0;
    end
end


%后置视域判断,非共视区域的粒子不能匹配

sensorID_part1 = Match_part1{2,1}(7,1);
sensorID_part2 = Match_part2{2,1}(7,1);

for i = 1:size(Solution_match,1)
    if Solution_match(i) ~= 0 && D(i,Solution_match(i)) < match_threshold

        FoV_cnt_part1 = [];
        FoV_cnt_part2 = [];
        for j = 1:size(Sensor,2)
            %匹配双方进行所属视域计数
            flag_FoV1 = ALG10_FoV_judge( Sensor(j).location, Match_part1{2,1}(1:6,i),Sensor(j).R_detect,j); % 视场判断
            if ~isempty(flag_FoV1)
               FoV_cnt_part1 = [FoV_cnt_part1 flag_FoV1];
            end
                                
            flag_FoV2 = ALG10_FoV_judge( Sensor(j).location, Match_part2{2,1}(1:6,Solution_match(i)),Sensor(j).R_detect,j); % 视场判断
            if ~isempty(flag_FoV2)
               FoV_cnt_part2 = [FoV_cnt_part2 flag_FoV2];
            end                        
        end

        if (~isempty(intersect(FoV_cnt_part1,Sensor(sensorID_part1).FoV_range)) && isempty(intersect(FoV_cnt_part1,Sensor(sensorID_part2).FoV_range))) ||... 
            (~isempty(intersect(FoV_cnt_part2,Sensor(sensorID_part2).FoV_range)) && isempty(intersect(FoV_cnt_part2,Sensor(sensorID_part1).FoV_range)))
            Solution_match(i) = 0; 
            Mat_match(i,:) = 0;
        end



    end
end

end