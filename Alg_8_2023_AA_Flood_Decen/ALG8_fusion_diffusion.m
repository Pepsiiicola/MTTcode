
function [Results] = ALG8_fusion_diffusion(Fusion_center,match_threshold,ID_sensor,l,sensor)

%===参数获取===
N_sensor = size( Fusion_center.Inf_total, 2 ); %收到信息的集合数


InfComplete = struct;
InfComplete.w = [];
InfComplete.m = [];
InfComplete.P = [];

for i = 1:N_sensor
    InfComplete.w = [InfComplete.w [Fusion_center.Inf_total(i).gm_components{1}(:,1:end)]];
    InfComplete.m = [InfComplete.m [Fusion_center.Inf_total(i).gm_components{2}(1:4,1:end)]];
    InfComplete.P = [InfComplete.P [Fusion_center.Inf_total(i).gm_components{3}(:,1:end)]];
end

%总共的高斯分量个数
num_gm_component = size(InfComplete.w,2);

%视域判断,权重调整
[InfComplete] = Alg8_FoV_judge(sensor,InfComplete,num_gm_component,N_sensor);

%匹配融合

[InfComplete] = Alg8_gm_merge(InfComplete,match_threshold);


Results = InfComplete;


end


