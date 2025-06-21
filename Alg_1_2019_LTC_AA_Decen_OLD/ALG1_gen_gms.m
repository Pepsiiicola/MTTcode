function X= ALG1_gen_gms(w,m,P,num_par)
% generate samples from Gaussian mixture intensity  �Ӹ�˹���ǿ����������

x_dim=size(m,1);%5
X=zeros(x_dim,num_par);%zeros(5,4000)

w= w/sum(w);
w= sort(w,'descend');%��������

nc= length(w);%4

comps= randsample(1:nc,num_par,true,w);%��wΪȨ�أ���1-4����������ȵ��зŻصĲ���4000����

ns= zeros(nc,1);
for c=1:nc
    ns(c)= nnz(comps==c);%ͳ��comps����1-4������
end

startpt= 1;
for i=1:nc
    endpt= startpt+ns(i)-1;
    X(:,startpt:endpt)= gen_mvs(m(:,i),P,ns(i));%�ھ�ֵ������Э����P���Ȳ���ns����
    startpt= endpt+1;
end

function X= gen_mvs(m,P,ns)

U= chol(P); X= repmat(m,[1 ns]) + U*randn(length(m),ns);


