%{
                           �ֲ�ʽGA�ںϷ���
%}
function [Results] = ALG3_fusion_GA_distr(sensor_inf, match_threshold)

%===������ȡ===
N_sensor = size( sensor_inf,2 );
Match_part1_sus = cell(4,1);

%===����ں�===
%=== �ҵ���һ���ǿռ��ϸ�ֵ��Match_part1 ===
ID_record = 0; % ��һ��Match_part1��Ӧ�Ĵ�����ID
for i = 1:size(sensor_inf,2)
    if sensor_inf(i).gm_particles{4,1} ~= 0
        Match_part1 = sensor_inf(i).gm_particles;
        ID_record = i;
        break;
    end
end

% �ж��Ƿ���Ч��ֵ�ˣ���������������ںϻ��ڣ�û��������
if ID_record == 0
    Results = cell(4,1);
    Results{1,1} = zeros(1,0);
    Results{2,1} = zeros(6,0);
    Results{3,1} = zeros(6,6*0);
    Results{4,1} = 0;
    
else
    t_f = 1;
    for i = ID_record+1:N_sensor
        
        %=== ��ƥ�������ֵ ===
        %=== �ж��Ƿ��д�ƥ����������������ƥ�䣬���������� ===
        if sensor_inf(i).gm_particles{4,1} ~= 0
            Match_part2 = sensor_inf(i).gm_particles;
            t_f = t_f + 1;
        else
            continue;
        end
        
        %===��ʼ��===
        n_fusion = Match_part1{4,1} + Match_part2{4,1};
        Match_part1_sus{1,1} = zeros(1,n_fusion);
        Match_part1_sus{2,1} = zeros(6,n_fusion);
        Match_part1_sus{3,1} = zeros(6,6*n_fusion);
        Match_part1_sus{4,1} = 0;
        cnt_GA = 0; % ʵ���ںϴ�������
        
        %===ƥ�䲿��===
        [Solution_match,Mat_match] = ALG3_Match(Match_part1,Match_part2,match_threshold);
        
        %===�ںϲ���===
        % ƥ�����ں�
        % 1.��������Ӧ�ķ�������GA�ںϣ��ںϽ����ŵ� Match_part1_sus ��ȥ
        for j = 1:size(Solution_match,1)

            if Solution_match(j)~=0
                k = Solution_match(j); % j,k �ֱ����part1��part2�Ķ�Ӧ����           
                cnt_GA = cnt_GA + 1; % �ںϼ���
                % Э�����GA�ں�
                Match_part1_sus{3,1}(:,6*(cnt_GA-1)+1:6*cnt_GA) = ...
                    inv( (1-1/t_f)*inv(Match_part1{3,1}(:,6*(j-1)+1:6*j)) + (1/t_f)*inv(Match_part2{3,1}(:,6*(k-1)+1:6*k)) );
                % ״̬��GA�ں�
                Match_part1_sus{2,1}(:,cnt_GA) = Match_part1_sus{3,1}(:,6*(cnt_GA-1)+1:6*cnt_GA) * ...
                    ( (1-1/t_f) *inv(Match_part1{3,1}(:,6*(j-1)+1:6*j)) * Match_part1{2,1}(:,j) +...
                    (1/t_f) *inv(Match_part2{3,1}(:,6*(k-1)+1:6*k)) * Match_part2{2,1}(:,k) );
                % Ȩ�ص�GA�ں�
                Match_part1_sus{1,1}(1,cnt_GA) = ( Match_part1{1,1}(1,j))^((1-1/t_f)) * ...
                    ( Match_part2{1,1}(1,k))^(1/t_f);
                % ��������
                cnt_GA = cnt_GA+1-1;
            end
        end
        
        % ��ƥ�����ں�
        % �ֱ��part1��part2���б���
        % �ڶ�part1�ĵ������ӽ��б�����ʱ����Ҫ�жϸ������Ƿ������part2��Ӧ�������Ĺ۲ⷶΧ֮�ڣ����
        % ���ڣ���ôȨ����Ҫ����
        for j = 1:size( Mat_match , 1)
            if sum( Mat_match(j,:) , 2) == 0
                cnt_GA = cnt_GA + 1; % �ںϼ���
                % Э�����GA�ں�
                Match_part1_sus{3,1}(:,6*(cnt_GA-1)+1:6*cnt_GA) = Match_part1{3,1}(:,6*(j-1)+1:6*j);
                % ״̬��GA�ں�
                Match_part1_sus{2,1}(:,cnt_GA) = Match_part1{2,1}(:,j);
                % Ȩ�ص�GA�ں�
                flag_FoV = FoV_judge( sensor_inf(i).location, Match_part1{2,1}(:,j), ...
                                      sensor_inf(i).R_detect); % �ӳ��ж�
                if flag_FoV == 1
                Match_part1_sus{1,1}(1,cnt_GA) = Match_part1{1,1}(1,j) * 0.7; % 0.7 ���Լ��趨��Ȩ��˥����
                else
                    Match_part1_sus{1,1}(1,cnt_GA) = Match_part1{1,1}(1,j);
                end
            end
        end
        for k = 1:size( Mat_match , 2)
            if sum( Mat_match(:,k) , 1) == 0
                cnt_GA = cnt_GA + 1; % �ںϼ���
                % Э�����GA�ں�
                Match_part1_sus{3,1}(:,6*(cnt_GA-1)+1:6*cnt_GA) = Match_part2{3,1}(:,6*(k-1)+1:6*k);
                % ״̬��GA�ں�
                Match_part1_sus{2,1}(:,cnt_GA) = Match_part2{2,1}(:,k);
                % Ȩ�ص�GA�ں�
                Match_part1_sus{1,1}(1,cnt_GA) = Match_part2{1,1}(1,k);
            end
        end
        
        % 3.�� Match_part1_sus ���ж������ݴ����ֵ�� Match_part1����������ںϵ���һ��
        Match_part1_sus{1,1}(:,cnt_GA+1:end) = [];
        Match_part1_sus{2,1}(:,cnt_GA+1:end) = [];
        Match_part1_sus{3,1}(:,6*cnt_GA+1:end) = [];
        Match_part1_sus{4,1} = cnt_GA;
        Match_part1 = Match_part1_sus;
        
    end
    Results = Match_part1;
end

end