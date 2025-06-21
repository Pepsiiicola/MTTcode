function [Results] = ALG11_AGMfusion(Set_AA_Fusion_state, Set_GA_Fusion_state, match_threshold)

InfComplete = struct;
InfComplete.w = [];
InfComplete.m = [];
InfComplete.P = [];

InfComplete.w = [Set_AA_Fusion_state.w Set_GA_Fusion_state.w];
InfComplete.m = [Set_AA_Fusion_state.m Set_GA_Fusion_state.m];
InfComplete.P = [Set_AA_Fusion_state.P Set_GA_Fusion_state.P];


[InfComplete] = Alg11_gm_merge_GA(InfComplete, match_threshold);

Results = InfComplete;

end