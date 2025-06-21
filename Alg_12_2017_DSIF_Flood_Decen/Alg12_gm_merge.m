function [merge_result] = Alg12_gm_merge(state,U)


merge_result = struct;
merge_result.w = [];
merge_result.m = [];
merge_result.P = [];
Index = @(x)(4*x-3:4*x);

w_k = state.w;
m_k = state.m;
P_k = state.P;

l = 0;%计算特征数量
% I = find(w_k>Th);%find函数是找到w_k >= T的下标
I = [];
if size(state.w,2) ~= 0
    I = 1:size(state.w,2);
end
w_kb = [];
m_kb = [];
P_kb = [];

while ~isempty(I)%合并时会从I中删除
    l = l+1; %l是合并次数
    [~,jtmp] = max(w_k(I)); %在I中的所有值(即w_k的下标)对应的w_k中找到最大值将这个最大值的下标赋给jtmp
    j = I(jtmp);%将I中第jtmp个数(w_k的下标)赋给j
    
    L = [];
    for i = I
        if (m_k(:,i)-m_k(:,j))'/(P_k(:,Index(i)))*(m_k(:,i)-m_k(:,j))<=U %权重从大到小依次找可以合并的分量
            L = [L i];%可以合并的下标放在L中
        end
    end
    
    w_kb(1,l) = sum(w_k(1,L));
    m_kb(:,l) = zeros(size(m_k(:,1)));
    P_kb(:,Index(l)) = zeros(size(P_k(:,Index(1))));

    %协方差
    for i = L
        P_kb(:,Index(l)) = P_kb(:,Index(l)) + w_k(1,i)/w_kb(1,l)*inv(P_k(:,Index(i)));
    end
    P_kb(:,Index(l)) = inv(P_kb(:,Index(l)));

    %均值
    for i = L
        m_kb(:,l) = m_kb(:,l) + w_k(1,i)/w_kb(1,l)*inv(P_k(:,Index(i)))*m_k(:,i);
    end
    m_kb(:,l) = P_kb(:,Index(l))*m_kb(:,l);
    
    
    I = setdiff(I,L,'stable');%返回在I中有，而L中没有的值，即从I中删除L的元素,'stable'表示结果不排序
end

merge_result.w = w_kb;
merge_result.m = m_kb;
merge_result.P = P_kb;
