%{
       根据输入的观测范围覆盖程度，调节传感器的的具体观测半径
       视场重叠度的定义为 节点检测半径与节点自身和邻居节点距离的比值
       本仿真考虑 均匀的网络分布，即节点与所有邻居节点的距离相等
%}
function [R_DETECT] = ModelAdjust_FoV( OverlapFoV ,R_INTERVAL )
R_DETECT = OverlapFoV * R_INTERVAL;
end