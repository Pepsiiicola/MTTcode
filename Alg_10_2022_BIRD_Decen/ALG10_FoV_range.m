
function [FoV_range] = ALG10_FoV_range(mat_topo,label,l)

mat_shortestPath = bfsShortestPaths(mat_topo); %最短路径矩阵
FoV_range = [];

[N_sensor,~] = size(mat_shortestPath);
cnt = 0; % 通信次数计数
for i = 1:N_sensor
    if mat_shortestPath(label,i) <= l
        cnt = cnt+1;
        FoV_range(1,cnt) = i;
    end
end





