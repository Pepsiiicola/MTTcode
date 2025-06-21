%{
          根据拓扑矩阵生成大都市权重分配矩阵
          拓扑矩阵必须时强连通的
%}
function [mat_weight]=Metropolis_Weights(mat_topo)

% 获取节点个数
num_node = size(mat_topo,2);

% 声明矩阵变量
mat_weight = zeros(num_node,num_node);
num_connect = sum(mat_topo,2); % 每个节点与其他节点的连接数量
% 以行遍历节点计
for i =1 : num_node
    for j = 1 : num_node
       % 同一个节点首先不对自己的权重进行计算
       if i == j
           continue;
       end
       % 若与当前节点有连接关系，那么进行行权重计算,若无则为0
       if mat_topo(i,j) == 1
           mat_weight(i,j) = 1 / max([num_connect(i),num_connect(j)]);
       else
           mat_weight(i,j) = 0;
       end
    end
    % 计算自身的权重
    mat_weight(i,i) = 1 - sum( mat_weight(i,:) ); 
end

end