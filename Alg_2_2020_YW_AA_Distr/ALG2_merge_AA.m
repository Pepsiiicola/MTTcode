%{
                              合并程序
%}
function [Results] = ALG2_merge_AA( GMs_AA , merge_threshold )


n = GMs_AA{4,1}; % GMs_AA 集合中所含分量个数

% 初始化
W_AA = zeros(1,n);
M_AA = zeros(6,n);
P_AA = zeros(6,6*n);
e = 0; % 合并之后的分量个数计数

n_copy = n;
while n>0
    e = e + 1;
    wmax = max(GMs_AA{1,1}(1,:));             % 找到GMs_AA{1，1}(1,:)最大的权值
    [~,col] = find( GMs_AA{1,1}(1,:)==wmax ); % col的值就是最大权值的位置
    k=0;            % 用来计数每个循环中从GMs_AA中拿走的个数
    c = zeros(1,n); % c数列用来记录GMs_AA中符合融合的分量坐标
    L = cell(3,1);  % 把符合的分量加入L中，L有三个元胞，分别代表权值，均值，方差
    for i=1:n
        % 用欧式距离来判断
        if sqrt(( GMs_AA{2,1}([1,3,5],i) - GMs_AA{2,1}([1,3,5],col(1,1)))'*...
                ( GMs_AA{2,1}([1,3,5],i) - GMs_AA{2,1}([1,3,5],col(1,1))) ) <= merge_threshold
            k = k + 1;
            c(k) = i;
            L{1,1}(1,k) = GMs_AA{1,1}(1,i);
            L{2,1}(:,k) = GMs_AA{2,1}(:,i);
            L{3,1}(:,6*k-5:6*k) = GMs_AA{3,1}(:,6*i-5:6*i);
        end
    end
    c(k+1:n)=[];%%释放内存
    
    %===至此，对于一次循环里需要融合的参量全部放在了L中，个数为k个===
    % 权值计算
    W_AA(1,e) = sum(L{1,1}(1,:));
    
    % 均值计算
    M_AA(:,e) = [0 0 0 0 0 0]';
    for i=1:k %%k代表L中的分量个数
        M_AA(1:6,e) = M_AA(1:6,e) + L{1,1}(1,i)*L{2,1}(1:6,i);
    end
    M_AA(1:6,e) = M_AA(1:6,e) / W_AA(1,e); % 均值
    
    % 协方差计算
    P_AA(:,6*(e-1)+1:6*e) = zeros(6,6);
    for i=1:k % k代表L中的分量个数
        P_AA(:,6*(e-1)+1:6*e) = P_AA(:,6*(e-1)+1:6*e)+...
            L{1,1}(1,i)*(L{3,1}(:,6*(i-1)+1:6*i)+(M_AA(1:6,e)-L{2,1}(1:6,i))*(M_AA(1:6,e)-L{2,1}(1:6,i))');
    end
    P_AA(:,6*(e-1)+1:6*e) = P_AA(:,6*(e-1)+1:6*e)/W_AA(1,e);%%协方差
    
    % 删除I中用于融合的权值
    GMs_AA{1,1}(:,c)=[];
    % 删除I中用于融合的均值
    GMs_AA{2,1}(:,c)=[];
    % 用于删除I中用于融合的协方差
    GMs_AA{3,1}(:,6*(c(1)-1)+1:6*c(1))=[];
    for i=2:k
        GMs_AA{3,1}(:,6*(c(i)-i)+1:6*(c(i)-i+1))=[];%%用于删除I中用于融合的协方差
    end
    % 更新剩余数量
    n=n-k; % I中剩余分量的个数，当为零时，结束循环
end

% 释放内存
W_AA(e+1:n_copy)=[];
M_AA(:,e+1:n_copy)=[];
P_AA(:,6*e+1:6*n_copy)=[];

Results = cell(4,1);
Results{1,1} = W_AA;
Results{2,1} = M_AA;
Results{3,1} = P_AA;
Results{4,1} = e;

end