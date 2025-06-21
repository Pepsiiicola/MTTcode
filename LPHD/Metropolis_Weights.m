%{
          �������˾������ɴ���Ȩ�ط������
          ���˾������ʱǿ��ͨ��
%}
function [mat_weight]=Metropolis_Weights(mat_topo)

% ��ȡ�ڵ����
num_node = size(mat_topo,2);

% �����������
mat_weight = zeros(num_node,num_node);
num_connect = sum(mat_topo,2); % ÿ���ڵ��������ڵ����������
% ���б����ڵ��
for i =1 : num_node
    for j = 1 : num_node
       % ͬһ���ڵ����Ȳ����Լ���Ȩ�ؽ��м���
       if i == j
           continue;
       end
       % ���뵱ǰ�ڵ������ӹ�ϵ����ô������Ȩ�ؼ���,������Ϊ0
       if mat_topo(i,j) == 1
           mat_weight(i,j) = 1 / max([num_connect(i),num_connect(j)]);
       else
           mat_weight(i,j) = 0;
       end
    end
    % ���������Ȩ��
    mat_weight(i,i) = 1 - sum( mat_weight(i,:) ); 
end

end