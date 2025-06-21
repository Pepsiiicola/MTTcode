function [Fusion_center] = Alg11_Inf_merge(Fusion_center)

n = size(Fusion_center.Inf_recieve,2); %新接收多少数据量
m = size(Fusion_center.Inf_total,2); %现有多少数据量
cnt = 0;
if n > 0
    for i = m+1:m+n
        cnt = cnt + 1;
        Fusion_center.Inf_total(i).gm_components = Fusion_center.Inf_recieve(cnt).gm_components;
    end
end

mm = size(Fusion_center.Inf_total,2); %现有多少数据量

for i = 1:mm
    if isempty(Fusion_center.Inf_total(i).gm_components)
        Fusion_center.Inf_total(i) = [];
        break;
    end
end

end