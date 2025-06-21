function z_gate= ALG4_gate_meas_ukf(z,gamma,m,P,alpha,kappa,beta)
dis = @(x,y)sqrt((x.^2 + y.^2));
valid_idx = [];
zlength = size(z,2); if zlength==0, z_gate= []; return; end
plength = size(m,2);%预测高斯分量的个数

for j=1:plength
    [Xi,Wi,Pi] = ALG4_ut(m(:,j),P(:,(j-1)*4+1:j*4),alpha,kappa,beta);
    Z_pred  = [dis(Xi(1,:),Xi(3,:));atan2d(Xi(3,:),Xi(1,:))];
%     index = find(Z_pred(2,:) < 0);
%     Z_pred(2,index) = Z_pred(2,index) + 360;
    eta = Z_pred*Wi(:);
    Sj_temp = Z_pred - repmat(eta,[1,length(Wi)]);
    Sj = Sj_temp*diag(Pi)*Sj_temp';
    Vs= chol(Sj); det_Sj= prod(diag(Vs))^2; inv_sqrt_Sj= inv(Vs);
    iSj= inv_sqrt_Sj*inv_sqrt_Sj';
    
    x_ob_pred = [dis(m(1,j),m(3,j));atan2d(m(3,j),m(1,j))];
    nu= z- repmat(x_ob_pred,[1,size(z,2)]);
    dist= sum((inv_sqrt_Sj'*nu).^2);
    valid_idx= union(valid_idx,find( dist < gamma ));
end
z_gate = z(:,valid_idx);