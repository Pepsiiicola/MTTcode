function [fusion_x,fusion_w,fusion_P] = Matching(s1_w_bar_k,s1_m_bar_k,s1_P_bar_k,s2_w_bar_k,s2_m_bar_k,s2_P_bar_k,fusion_Times)
%**********************************************************************
%                     传感器CI匹配融合
%输入参数：传感器1（s1_w_bar_k,s1_m_bar_k,s1_P_bar_k）
%输入参数：传感器2（s2_w_bar_k,s2_m_bar_k,s2_P_bar_k）
%输出参数：融合后的数据（fusion_x_k,fusion_w_k,fusion_P_k）
%获取k时刻传感器滤波高斯分量数目
%**********************************************************************

fusion_x=[];
fusion_w=[];
fusion_P=[];
s1_L=length(s1_w_bar_k);%传感器1中高斯分量个数
s2_L=length(s2_w_bar_k);%传感器2中高斯分量个数
Dist=@(x,y)sqrt((x(1)-y(1))^2+(x(3)-y(3))^2);
fusion_gate=300;%融合阈值
index=[];%用于存储传感器1中融合过的高斯分量列数

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
       dist(fusion_j)=Dist(s1_m_bar_k(:,fusion_k),s2_m_bar_k(:,fusion_j));%计算高斯分量均值之间的欧式距离
    end  
    
    if (isempty(dist)) %判断dist向量是否为空，为空就意味着传感器2中的高斯分量已被匹配完
        break;%dist为空则跳出循环
    else
        [min_dist,min_c]=min(dist);%min_dist表示最小值，min_c为最小值所在列数
        if min_dist<fusion_gate %若最小距离小于融合阈值则进行CI融合
            [fusion_x_k,fusion_w_k,fusion_P_k] = ALG4_GCI_fusion(s1_w_bar_k(fusion_k),s1_m_bar_k(:,fusion_k),s1_P_bar_k(:,4*fusion_k-3:4*fusion_k),s2_w_bar_k(min_c),s2_m_bar_k(:,min_c),s2_P_bar_k(:,4*min_c-3:4*min_c),fusion_Times);
            %删除融合过的分量
            s2_w_bar_k(min_c)=[];
            s2_m_bar_k(:,min_c)=[];
            s2_P_bar_k(:,4*min_c-3:4*min_c)=[];
            %计算融合之后传感器2中剩余高斯分量个数
            s2_L=length(s2_w_bar_k);
            %记录传感器1中融合的高斯分量所在的列数，最后一并删除
            index=[index,fusion_k];
        else
            fusion_x_k=[];
            fusion_w_k=[];
            fusion_P_k=[];
            %记录传感器1中融合的高斯分量所在的列数，最后一并删除
            index=[index,fusion_k];
        end
        %将每一次融合过后的高斯分量组加入最终的融合结果当中
        fusion_x=[fusion_x,fusion_x_k];
        fusion_w=[fusion_w,fusion_w_k];
        fusion_P=[fusion_P,fusion_P_k];
    end
end
%判断传感器2当中是否有高斯分量剩余，此情况适用于传感器1中分量融合完毕之后，传感器2中分量仍有剩余的情况。
%需要将传感器2中未融合的高斯分量加入最终融合组
if (~isempty(s2_w_bar_k))
    fusion_x=[fusion_x,s2_m_bar_k];
    fusion_w=[fusion_w,s2_w_bar_k];
    fusion_P=[fusion_P,s2_P_bar_k];
end
s2_w_bar_k=[];
s2_m_bar_k=[];
s2_P_bar_k=[];
% %清除传感器1中参与融合的高斯分量
s1_w_bar_k(index)=[];
s1_m_bar_k(:,index)=[];
s1_P_bar_k(:,4*index-3:4*index)=[];
% %判断传感器1当中是否有高斯分量剩余，此情况适用于传感器2中分量融合完毕之后，传感器1中分量仍有剩余的情况。
% %需要将传感器1中未融合的高斯分量加入最终融合组
if (~isempty(s1_w_bar_k))
    fusion_x=[fusion_x,s1_m_bar_k];
    fusion_w=[fusion_w,s1_w_bar_k];
    fusion_P=[fusion_P,s1_P_bar_k];
end

end

