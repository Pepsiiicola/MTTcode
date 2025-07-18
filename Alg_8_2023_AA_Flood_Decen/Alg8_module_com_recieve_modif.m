%{
                      通信模块--接收模块       
         根据拓扑矩阵将N个传感器结果放入通信存储块中

         输入：1.com_storage -- 通信储存结构体数组，形式为 com_storage(i).gm_particles
               2.mat_topo    -- 拓扑矩阵结构 
               3.lable       -- 当前传感器标签

         输出：1.Inf_recieve    -- 某一个传感器的接收结构体数组 形式为 Inf_recieve(i).gm_particles
 
         注:结构体数组的标签 gm_particles 不能变
%}
function [Inf_recieve,Inf_topo] = Alg8_module_com_recieve_modif(com_storage,mat_topo,label,l,Fusion_center)

%=================已废弃==============
% mat_shortestPath = bfsShortestPaths(mat_topo); %最短路径矩阵
% Inf_recieve = struct;
% [N_sensor,~] = size(mat_shortestPath);
% cnt = 0; % 通信次数计数
% for i = 1:N_sensor
%     if mat_shortestPath(label,i) <= l 
%         cnt = cnt + 1;
%         Inf_recieve(cnt).gm_components = com_storage(i).gm_components;
%     end
% end
mat_shortestPath = bfsShortestPaths(Fusion_center(label).Inf_topo); %最短路径矩阵

Inf_recieve = struct;
N_sensor = size(Fusion_center,2);
cnt = 0;
for i = 1:N_sensor
    if mat_topo(label,i) == 1 %判断是不是自己的邻居

        if label == i  %不接收自身的信息（自己传给自己的信息）
            continue
        end

        mm = size(com_storage(i).Inf,2);


        for j = 1:mm
            if isfield(com_storage(i).Inf(j),'gm_components') == 1 && ~isempty(com_storage(i).Inf(j).gm_components)
                if (com_storage(i).Inf(j).gm_components{5} ~= label) && (mat_shortestPath(label,com_storage(i).Inf(j).gm_components{5}) == l)%处理信息回流
                    %还要处理
                     cnt = cnt + 1;
                     Inf_recieve(cnt).gm_components = com_storage(i).Inf(j).gm_components;
                end
            end
            
        end

%         for
       
    end
end

%=============接收拓扑信息============
Inf_topo = Fusion_center(label).Inf_topo;
for i = 1:N_sensor
    if mat_topo(label,i) == 1
        if label == i
            continue
        end

        Inf_topo = max(Inf_topo,Fusion_center(i).Inf_topo);

    end
end



end