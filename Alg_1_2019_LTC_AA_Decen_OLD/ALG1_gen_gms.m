function X= ALG1_gen_gms(w,m,P,num_par)
% generate samples from Gaussian mixture intensity  从高斯混合强度生成样本

x_dim=size(m,1);%5
X=zeros(x_dim,num_par);%zeros(5,4000)

w= w/sum(w);
w= sort(w,'descend');%降序排序

nc= length(w);%4

comps= randsample(1:nc,num_par,true,w);%以w为权重，从1-4当中随机均匀的有放回的采样4000个点

ns= zeros(nc,1);
for c=1:nc
    ns(c)= nnz(comps==c);%统计comps当中1-4的数量
end

startpt= 1;
for i=1:nc
    endpt= startpt+ns(i)-1;
    X(:,startpt:endpt)= gen_mvs(m(:,i),P,ns(i));%在均值附近以协方差P均匀采样ns个点
    startpt= endpt+1;
end

function X= gen_mvs(m,P,ns)

U= chol(P); X= repmat(m,[1 ns]) + U*randn(length(m),ns);


