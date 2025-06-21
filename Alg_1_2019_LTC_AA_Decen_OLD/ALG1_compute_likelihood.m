function gz_vals= ALG1_compute_likelihood(R,z,X,location)

% compute likelihood vector g= [ log_g(z|x_1), ... , log_g(z|x_M) ] -
% this is for bearings and range case with additive Gaussian noise
location = location([1,2],:);
if size(X,2) == 0
    X = zeros(4,1);
end
M= size(X,2);% 预测粒子数
Location = repmat(location,[1,M]);
P= X([1 3],:)-Location;%x,y位置信息
Phi= zeros(2,M);%用来存放观测预测信息（角度与距离）
Phi(2,:)= atan2d(P(2,:),P(1,:));
%将-180~0的角度转换为180-360
c=find(Phi(2,:)<0);
Phi(2,c) = Phi(2,c) + 360;

Phi(1,:)= sqrt(sum(P.^2));%观测预测
e_sq= sum( (diag(1./diag(R))*(repmat(z,[1 M])- Phi)).^2 );
gz_vals= exp(-e_sq/2 - log(2*pi*prod(diag(R))));%使用似然函数计算每个粒子在观测数据处得到的权重
