function [com_storage] = ALG8_Inf_assemble(Fusion_center,sensorID)

com_storage.Inf.gm_components = [];
m = size(Fusion_center.Inf_recieve,2);
cnt = 0;
if isfield(Fusion_center.Inf_recieve,'gm_components') == 1 
    for i = 1:m
        if Fusion_center.Inf_recieve(i).gm_components{1,5} ~= sensorID
            cnt = cnt+1;
            com_storage.Inf(cnt).gm_components = Fusion_center.Inf_recieve(i).gm_components;
        end
    end
end
end
        
