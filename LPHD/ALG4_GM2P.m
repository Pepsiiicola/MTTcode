function [w_birth,m_birth,P,L_birth] = ALG4_GM2P(w_birth,m_birth,P_birth,L_birth,location,R)
dis = @(x,y)((x(1)-y(1))^2 + (x(3)-y(2))^2);
%   J_birth = 100 * length(w_birth);
%   w_birth = w_birth./sum(w_birth);%出生权重归一化
%   m_birth = gen_gms(w_birth,m_birth,diag([10000, 500, 10000, 500]'),J_birth);                 %append birth particles 在机场附近采样得到粒子
%   w_birth = (sum(w_birth)*ones(J_birth,1)/J_birth)';                           %append birth weights    采样粒子权重 

  n = size(m_birth,2);
  if n == 0
      w_birth = [];
      m_birth = [];
      P = [];
      L = [];
  else
      %=======粒子视域判断=======%
      dis = m_birth([1,3],:) - repmat(location([1,2]),[1,n]);
      dis = sqrt(sum(dis.*dis));
      index = find(dis > R);
      index_2 = find(dis < R);

      w_birth(index) = [];
      m_birth(:,index) = [];
      L_birth(:,index) = [];
%       for k = 1:length(index)
%          P_birth(:,k*4-3:k*4) = [];    
%       end
     P = [];
      for k = 1:length(index_2)
         P = [P,P_birth(:,index_2(k)*4-3:index_2(k)*4)];    
      end

        
  end
%   w_birth = w_birth;
%   m_birth = m_birth;
%   P = P_birth;
end


 




 
 