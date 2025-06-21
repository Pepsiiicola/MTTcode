%{
                              匹配程序
% 注：这里的 Match_part1 的维度应该是和 Matched_GM 的个数一致的
%}
function [Solution_match,Mat_match] = ALG5_Match(Match_part1,Match_part2,Matched_GM,cnt_matchedGm,match_threshold)

%1.计算出两个集合之间的距离矩阵，将距离超过阈值的设定为阈值
% 注: 结果中，纵坐标代表的是PART1的粒子，横坐标代表的是PART2的粒子
%=====考虑Matched_GM中其余粒子距离的可能性,取多种可能中的最小的那个======
[D] = dis_compute_vector(Match_part1{2,1}(1:6,:),Match_part2{2,1}(1:6,:));
for i = 1:cnt_matchedGm
    for j = 2:Matched_GM(i).gm{4,1}
        new_cost = dis_compute_vector( Matched_GM(i).gm{2,1}(1:6,j) , Match_part2{2,1}(1:6,:) );
        for k = 1:size( D , 2 )
            D(i,k) = min( D(i,k) , new_cost(1,k));
        end
    end
end
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

end