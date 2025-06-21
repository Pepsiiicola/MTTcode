function [w_birth,m_birth] = ALG1_GM2P(w_birth,m_birth,location,R)
dis = @(x,y)((x(1)-y(1))^2 + (x(3)-y(2))^2);
%   J_birth = 100 * length(w_birth);
%   w_birth = w_birth./sum(w_birth);%����Ȩ�ع�һ��
%   m_birth = gen_gms(w_birth,m_birth,diag([10000, 500, 10000, 500]'),J_birth);                 %append birth particles �ڻ������������õ�����
%   w_birth = (sum(w_birth)*ones(J_birth,1)/J_birth)';                           %append birth weights    ��������Ȩ�� 
  
  n = size(m_birth,2);
  if n == 0
      w_birth = [];
      m_birth = [];
  else
      %=======���������ж�=======%
      dis = m_birth([1,3],:) - repmat(location([1,2]),[1,n]);
      dis = sqrt(sum(dis.*dis));
      index = find(dis > R);

      w_birth(index) = [];
      m_birth(:,index) = [];
  end
  
end


 




 
 