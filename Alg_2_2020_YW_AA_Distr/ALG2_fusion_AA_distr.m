%{
                           �ֲ�ʽAA�ںϷ���
%}
function [Results] = ALG2_fusion_AA_distr(sensor_inf, merge_threshold)

%===������ȡ===
N_sensor = size( sensor_inf,2 );
n_AA = 0; % AA�ں�֮�����GM����
for i = 1:N_sensor
    n_AA = n_AA + sensor_inf(i).gm_particles{4,1};
end

%===��ʼ��===
GMs_AA = cell(4,1);
GMs_AA{1,1} = zeros(1,n_AA);    % Ȩ��
GMs_AA{2,1} = zeros(6,n_AA);    % ��ֵ
GMs_AA{3,1} = zeros(6,6*n_AA);  % Э����
GMs_AA{4,1} = n_AA;             % ��������

Cnt_AA = 0; % AA�ں�����ʵʱ��ʱ����
for i = 1:N_sensor
    for j = 1:sensor_inf(i).gm_particles{4,1}
        cnt_fovIn = 0; % �ӳ��ڼ���
        
        %===ÿһ�����Ӷ���Ҫȥ�ж��ڼ������������ӳ���===
        for k = 1:N_sensor
            flag_FoV = FoV_judge( sensor_inf(k).location,...
                sensor_inf(i).gm_particles{2,1}(:,j), sensor_inf(k).R_detect); % �ӳ��ж�
            if flag_FoV == 1 
                cnt_fovIn = cnt_fovIn+1;
            end
        end
        
        %===�����������д������жϽ���===
        if cnt_fovIn == 0
            cnt_fovIn = 1;
        end
        Cnt_AA = Cnt_AA + 1;

        %===���Ӹ�ֵ===
        GMs_AA{1,1}(1,Cnt_AA) = sensor_inf(i).gm_particles{1,1}(1,j)/cnt_fovIn;
        GMs_AA{2,1}(:,Cnt_AA) = sensor_inf(i).gm_particles{2,1}(:,j);
        GMs_AA{3,1}(:,Cnt_AA*6-5:Cnt_AA*6) = sensor_inf(i).gm_particles{3,1}(:,j*6-5:j*6);
        
    end
end

%=====�ϲ�����=====
[Results] = ALG2_merge_AA(GMs_AA,merge_threshold);

end