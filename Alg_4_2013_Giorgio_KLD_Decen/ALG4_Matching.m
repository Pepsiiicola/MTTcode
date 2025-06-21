function [fusion_x,fusion_w,fusion_P] = Matching(s1_w_bar_k,s1_m_bar_k,s1_P_bar_k,s2_w_bar_k,s2_m_bar_k,s2_P_bar_k,fusion_Times)
%**********************************************************************
%                     ������CIƥ���ں�
%���������������1��s1_w_bar_k,s1_m_bar_k,s1_P_bar_k��
%���������������2��s2_w_bar_k,s2_m_bar_k,s2_P_bar_k��
%����������ںϺ�����ݣ�fusion_x_k,fusion_w_k,fusion_P_k��
%��ȡkʱ�̴������˲���˹������Ŀ
%**********************************************************************

fusion_x=[];
fusion_w=[];
fusion_P=[];
s1_L=length(s1_w_bar_k);%������1�и�˹��������
s2_L=length(s2_w_bar_k);%������2�и�˹��������
Dist=@(x,y)sqrt((x(1)-y(1))^2+(x(3)-y(3))^2);
fusion_gate=300;%�ں���ֵ
index=[];%���ڴ洢������1���ںϹ��ĸ�˹��������

if isempty(s1_w_bar_k)
    fusion_x=s2_m_bar_k;
    fusion_w=s2_w_bar_k;
    fusion_P=s2_P_bar_k;
    return;
end
if isempty(s2_w_bar_k)
    fusion_x=s1_m_bar_k;
    fusion_w=s1_w_bar_k;
    fusion_P=s1_P_bar_k;
    return;
end
    

for fusion_k=1:s1_L
    dist=[];
    for fusion_j=1:s2_L
       dist(fusion_j)=Dist(s1_m_bar_k(:,fusion_k),s2_m_bar_k(:,fusion_j));%�����˹������ֵ֮���ŷʽ����
    end  
    
    if (isempty(dist)) %�ж�dist�����Ƿ�Ϊ�գ�Ϊ�վ���ζ�Ŵ�����2�еĸ�˹�����ѱ�ƥ����
        break;%distΪ��������ѭ��
    else
        [min_dist,min_c]=min(dist);%min_dist��ʾ��Сֵ��min_cΪ��Сֵ��������
        if min_dist<fusion_gate %����С����С���ں���ֵ�����CI�ں�
            [fusion_x_k,fusion_w_k,fusion_P_k] = ALG4_GCI_fusion(s1_w_bar_k(fusion_k),s1_m_bar_k(:,fusion_k),s1_P_bar_k(:,4*fusion_k-3:4*fusion_k),s2_w_bar_k(min_c),s2_m_bar_k(:,min_c),s2_P_bar_k(:,4*min_c-3:4*min_c),fusion_Times);
            %ɾ���ںϹ��ķ���
            s2_w_bar_k(min_c)=[];
            s2_m_bar_k(:,min_c)=[];
            s2_P_bar_k(:,4*min_c-3:4*min_c)=[];
            %�����ں�֮�󴫸���2��ʣ���˹��������
            s2_L=length(s2_w_bar_k);
            %��¼������1���ںϵĸ�˹�������ڵ����������һ��ɾ��
            index=[index,fusion_k];
        else
            fusion_x_k=[];
            fusion_w_k=[];
            fusion_P_k=[];
            %��¼������1���ںϵĸ�˹�������ڵ����������һ��ɾ��
            index=[index,fusion_k];
        end
        %��ÿһ���ںϹ���ĸ�˹������������յ��ںϽ������
        fusion_x=[fusion_x,fusion_x_k];
        fusion_w=[fusion_w,fusion_w_k];
        fusion_P=[fusion_P,fusion_P_k];
    end
end
%�жϴ�����2�����Ƿ��и�˹����ʣ�࣬����������ڴ�����1�з����ں����֮�󣬴�����2�з�������ʣ��������
%��Ҫ��������2��δ�ںϵĸ�˹�������������ں���
if (~isempty(s2_w_bar_k))
    fusion_x=[fusion_x,s2_m_bar_k];
    fusion_w=[fusion_w,s2_w_bar_k];
    fusion_P=[fusion_P,s2_P_bar_k];
end
s2_w_bar_k=[];
s2_m_bar_k=[];
s2_P_bar_k=[];
% %���������1�в����ںϵĸ�˹����
s1_w_bar_k(index)=[];
s1_m_bar_k(:,index)=[];
s1_P_bar_k(:,4*index-3:4*index)=[];
% %�жϴ�����1�����Ƿ��и�˹����ʣ�࣬����������ڴ�����2�з����ں����֮�󣬴�����1�з�������ʣ��������
% %��Ҫ��������1��δ�ںϵĸ�˹�������������ں���
if (~isempty(s1_w_bar_k))
    fusion_x=[fusion_x,s1_m_bar_k];
    fusion_w=[fusion_w,s1_w_bar_k];
    fusion_P=[fusion_P,s1_P_bar_k];
end

end

