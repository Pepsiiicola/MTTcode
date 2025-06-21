function [fusion_x_k,fusion_w_k,fusion_P_k] = ALG1_AA_fusion(s1_w_bar_k,s1_m_bar_k,s1_P_bar_k,s2_w_bar_k,s2_m_bar_k,s2_P_bar_k)
%************************************************************************
%������CI�ںϺ���
%���������������1��sensor1_w_bar_k,sensor1_m_bar_k,sensor1_P_bar_k��
%���������������2��sensor2_w_bar_k,sensor2_m_bar_k,sensor2_P_bar_k��
%����������ںϺ�����ݣ�fusion_x_k,fusion_w_k,fusion_P_k��
%************************************************************************
fusion_s2_w_k=s2_w_bar_k/(s1_w_bar_k+s2_w_bar_k);
fusion_s1_w_k=1-fusion_s2_w_k;
% P1=inv(s1_P_bar_k);
% P2=inv(s2_P_bar_k);
% fusion_P_k=inv(fusion_s1_w_k*P1+fusion_s2_w_k*P2);
% fusion_x_k=fusion_P_k*(fusion_s1_w_k*P1*s1_m_bar_k+fusion_s2_w_k*P2*s2_m_bar_k);
% fusion_w_k=(s1_w_bar_k+s2_w_bar_k)/2;
fusion_w_k = (s1_w_bar_k + s2_w_bar_k) / 2;
fusion_x_k = fusion_s1_w_k * s1_m_bar_k + fusion_s2_w_k * s2_m_bar_k;
fusion_P_k = fusion_s1_w_k * (s1_P_bar_k + (fusion_x_k-s1_m_bar_k)*(fusion_x_k-s1_m_bar_k)') + fusion_s2_w_k * (s2_P_bar_k + (fusion_x_k-s2_m_bar_k)*(fusion_x_k-s2_m_bar_k)');
end

