%{
                      ͨ��ģ��--����ģ��       
         �������˾���N���������������ͨ�Ŵ洢����

         ���룺1.com_storage -- ͨ�Ŵ���ṹ�����飬��ʽΪ com_storage(i).gm_particles
               2.mat_topo    -- ���˾���ṹ 
               3.lable       -- ��ǰ��������ǩ

         �����1.Inf_recieve    -- ĳһ���������Ľ��սṹ������ ��ʽΪ Inf_recieve(i).gm_particles
 
         ע:�ṹ������ı�ǩ gm_particles ���ܱ�
%}
function [Inf_recieve] = module_com_recieve(com_storage,mat_topo,lable,N)
Inf_recieve = struct;
N_sensor = N;
cnt = 0; % ͨ�Ŵ�������
for i = 1:N_sensor
    if mat_topo(lable,i) == 1
        cnt = cnt + 1;
        Inf_recieve(cnt).gm_particles = com_storage(i).gm_particles;
    end
end
end