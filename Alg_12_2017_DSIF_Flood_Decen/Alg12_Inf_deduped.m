function [Fusion_center] = Alg12_Inf_deduped(Fusion_center)
Index = [];
n = size(Fusion_center.Inf_total,2);
for i = 1:n
    Index(i) = Fusion_center.Inf_total(i).gm_components{5};  
end

[c,ia,~] = unique(Index,'stable');

% m = size(ia,1);
for i = n:-1:1
    if isempty(intersect(ia,i))
        Fusion_center.Inf_total(i) = [];
    end
end
