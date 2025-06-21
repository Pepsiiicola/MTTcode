function [Xi,Wi,Pi] = ALG4_ut(x,P,alpha,kappa,beta)
%=======UT变换Sigma采样点生成========%
n = length(x);%状态变量的维数
lambda = alpha^2*(n + kappa)-n;
Psqrtm = chol((n+lambda)*P)';
Xi = repmat(x,[1 2*n+1]) + [zeros(n,1) -Psqrtm Psqrtm];%采样点均值
Wi = [lambda 0.5*ones(1,2*n)]/(n + lambda);
Pi = Wi;
Pi(1) = lambda/(n+lambda) + (1-alpha^2+beta);


end

