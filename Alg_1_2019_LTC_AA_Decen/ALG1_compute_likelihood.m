function gz_vals= ALG1_compute_likelihood(R,z,X,location)

% compute likelihood vector g= [ log_g(z|x_1), ... , log_g(z|x_M) ] -
% this is for bearings and range case with additive Gaussian noise
location = location([1,2],:);
if size(X,2) == 0
    X = zeros(4,1);
end
M= size(X,2);% Ԥ��������
Location = repmat(location,[1,M]);
P= X([1 3],:)-Location;%x,yλ����Ϣ
Phi= zeros(2,M);%������Ź۲�Ԥ����Ϣ���Ƕ�����룩
Phi(2,:)= atan2d(P(2,:),P(1,:));
%��-180~0�ĽǶ�ת��Ϊ180-360
c=find(Phi(2,:)<0);
Phi(2,c) = Phi(2,c) + 360;

Phi(1,:)= sqrt(sum(P.^2));%�۲�Ԥ��
e_sq= sum( (diag(1./diag(R))*(repmat(z,[1 M])- Phi)).^2 );
gz_vals= exp(-e_sq/2 - log(2*pi*prod(diag(R))));%ʹ����Ȼ��������ÿ�������ڹ۲����ݴ��õ���Ȩ��
