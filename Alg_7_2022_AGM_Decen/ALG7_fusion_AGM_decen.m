%{
                           �ֲ�ʽGA�ںϷ���
%}
function [Results] = ALG7_fusion_AGM_decen(Fusion_center,match_threshold,mat_weight,ID_sensor,l,mat_topo)

%===������ȡ===
N_sensor = size( Fusion_center.Inf_recieve , 2 );
dir_connect = find( mat_topo(ID_sensor,:) == 1 ); % �뵱ǰ������ֱ������

%===������ʼ��===
Matched_GM = struct;      % ƥ��GM����
Matched_GM.gm =cell(4,1); % ÿһ��gm�д���һ��ƥ���ϵ�gm������
% Matched_GM.id = [0];    % ÿ��gm���Ӷ�Ӧ�Ĵ�����ID
cnt_matchedGm = 0;        % ƥ�����ӶԼ���

%=== �ҵ���һ���ǿռ��ϸ�ֵ��Match_part1 ===
ID_record = 0; % ��һ��Match_part1��Ӧ�Ĵ�����ID
for i = 1:size(Fusion_center.Inf_recieve,2)
    if Fusion_center.Inf_recieve(i).gm_particles{4,1} ~= 0
        Match_part1 = Fusion_center.Inf_recieve(i).gm_particles;
        ID_record = i;
        break;
    end
end

% �ж��Ƿ���Ч��ֵ�ˣ�����������ƥ�价�ڣ�û��������ƥ�价��
if ID_record ~= 0
    
    % �� Matched_GM ���и�ֵ
    for i = 1:Match_part1{4,1}
        Matched_GM(i).gm{1,1} = Match_part1{1,1}(1,i);
        Matched_GM(i).gm{2,1} = Match_part1{2,1}(:,i);
        Matched_GM(i).gm{3,1} = Match_part1{3,1}(:,6*i-5:6*i);
        Matched_GM(i).gm{4,1} = 1;
        cnt_matchedGm = cnt_matchedGm + 1;
    end
    
    for i = ID_record+1 : N_sensor
        
        %=== ��ƥ�������ֵ ===
        %=== �ж��Ƿ��д�ƥ����������������ƥ�䣬���������� ===
        if Fusion_center.Inf_recieve(i).gm_particles{4,1} ~= 0
            Match_part2 = Fusion_center.Inf_recieve(i).gm_particles;
        else
            continue;
        end
        
        %===ƥ�䲿��===
        [Solution_match,Mat_match] = ALG7_Match(Match_part1,Match_part2,Matched_GM,cnt_matchedGm,match_threshold);
        
        % 1.��������Ӧ�ķ�����ŵ� Matched_GM ��ȥ
        for j = 1:size(Solution_match,1)
            if Solution_match(j)~=0
                k = Solution_match(j); % j,k �ֱ����part1��part2�Ķ�Ӧ����
                % Ȩ�ظ�ֵ
                Matched_GM(j).gm{1,1} = [Matched_GM(j).gm{1,1},Match_part2{1,1}(1,k)];
                % ״̬��ֵ
                Matched_GM(j).gm{2,1} = [Matched_GM(j).gm{2,1},Match_part2{2,1}(:,k)];
                % Э���ֵ
                Matched_GM(j).gm{3,1} = [Matched_GM(j).gm{3,1},Match_part2{3,1}(:,6*(k-1)+1:6*k)];
                % ��������
                Matched_GM(j).gm{4,1} = Matched_GM(j).gm{4,1} + 1; % ����ƥ�����е�ƥ�����Ӽ���
            end
        end
        
        %===��δƥ���ϵ����ӽ��д���===
        for k = 1:size( Mat_match , 2)
            if sum( Mat_match(:,k) , 1) == 0
                
                %=== ����ƥ�����Ӽ��� ===
                cnt_matchedGm = cnt_matchedGm + 1; % ƥ������������������
                % Ȩ�ظ�ֵ
                Matched_GM(cnt_matchedGm).gm{1,1} = Match_part2{1,1}(1,k);
                % ״̬��ֵ
                Matched_GM(cnt_matchedGm).gm{2,1} = Match_part2{2,1}(:,k);
                % Э���ֵ
                Matched_GM(cnt_matchedGm).gm{3,1} = Match_part2{3,1}(:,6*(k-1)+1:6*k);
                % ��������
                Matched_GM(cnt_matchedGm).gm{4,1} = 1;
                
                %=== ͬʱ���� Match_part1 ===
                % Ȩ�ظ�ֵ
                Match_part1{1,1} = [Match_part1{1,1},Match_part2{1,1}(1,k)];
                % ״̬��ֵ
                Match_part1{2,1} = [Match_part1{2,1},Match_part2{2,1}(:,k)];
                % Э���ֵ
                Match_part1{3,1} = [Match_part1{3,1},Match_part2{3,1}(:,6*(k-1)+1:6*k)];
                % ��������
                Match_part1{4,1} = Match_part1{4,1} + 1; % ����ƥ�����е�ƥ�����Ӽ���
                
            end
        end
        
    end
end

%=============== ǰ���ж� =================
% ��û����Ч��ֵ��ô������AA�ں�ֱ������ռ�
if ID_record == 0
    Results = cell(4,1);
    Results{1,1} = zeros(1,0);
    Results{2,1} = zeros(7,0);
    Results{3,1} = zeros(6,6*0);
    Results{4,1} = 0;
    
else
    %========================================AGM�ں�===============================================
    % ����Ὣ�ں�֮��Ľ����Ϊһ����׼ȥ�жϹ۲ⷶΧ֮�ڻ���֮�⣬��������Ӧ���ϣ������Ӧ����Ȩ��
    % ��ʼ��
    n_fusion = size(Matched_GM,2); % ���ںϵ�ƥ��������
    Results = cell(4,1);
    Results{1,1} = zeros(1,n_fusion);
    Results{2,1} = zeros(7,n_fusion);
    Results{3,1} = zeros(6,6*n_fusion);
    Results{4,1} = n_fusion;
    for i = 1:n_fusion
        
        % ����ط����ں�Ȩ��Ӧ�ø���һ����Ȩ��������
        n_w2f = Matched_GM(i).gm{4,1};
        pai = zeros(1,n_w2f); % �ں�Ȩ��
        pai_state = zeros(1,n_w2f); % ״̬�ں�Ȩ��

        for j=1:n_w2f
            pai(j) = mat_weight( ID_sensor , Matched_GM(i).gm{2,1}(7,j) );
        end
        % #����ط��Ƿ���Ҫ��һ��ֵ������
        pai = pai / sum(pai,2);

        for j=1:n_w2f
            pai_state(j) = mat_weight( ID_sensor , Matched_GM(i).gm{2,1}(7,j) );
        end

        pai_state = pai_state / sum(pai_state,2);%��һ��

        % Ȩ���ں�
        W_AA = 0;
        for j = 1:n_w2f
            W_AA = W_AA + pai(j) * Matched_GM(i).gm{1,1}(1,j);
        end
        
        % Э�����ں�
        P_AA = zeros(6,6);
        for j = 1:n_w2f
            P_AA = P_AA + pai_state(j) * inv( Matched_GM(i).gm{3,1}(:,6*(j-1)+1:6*j) );
        end
        P_AA = inv( P_AA );
        
        % ��ֵ�ں�
        M_AA = [0 0 0 0 0 0]';
        for j = 1:n_w2f
            M_AA = M_AA + pai_state(j) * inv( Matched_GM(i).gm{3,1}(:,6*(j-1)+1:6*j) ) * ...
                Matched_GM(i).gm{2,1}(1:6,j);
        end
        M_AA = P_AA * M_AA;

        %����Ȩ��
        for j=1:n_w2f
            pai(j) = mat_weight( ID_sensor , Matched_GM(i).gm{2,1}(7,j) );
        end

        for j=1:n_w2f
            pai_state(j) = mat_weight( ID_sensor , Matched_GM(i).gm{2,1}(7,j) );
        end
        
        % �ӳ��жϵ���Ȩ��
        % ˵�������ڱ߽������Ӱ�죬�Լ���ɢʽ���ͨ���ںϵ��ص㣬����Ϊ�߽��¶����ӵĸ������������
        %       ��Ȩ��������ô�Ժ����ĸ��ٶ����нϴ��Ӱ�죬���Զ�Ȩ�ع��ߵ����Ҫ����һ��������
        %===ÿһ�����Ӷ���Ҫȥ�ж��ڼ������������ӳ���===
        %===ֻ�ж��ھӽڵ�===
        if l == 1
            cnt_fovIn = 0;
            for k = 1:size( dir_connect,2 )
                flag_FoV = FoV_judge( Fusion_center.sensor_inf( dir_connect(k) ).location, M_AA, ...
                                      Fusion_center.sensor_inf( dir_connect(k) ).R_detect); % �ӳ��ж�
                if flag_FoV == 1
                    cnt_fovIn = cnt_fovIn+1;
                end
            end
            if cnt_fovIn == 0
                cnt_fovIn = 1;
            end
        else
            cnt_fovIn = n_w2f;
        end

%=======================================swc�޸Ĳ���=========================

%�Ƚ������������ڵ�������ж�
        Index_fovIn = [];
        
        for k = 1:size( dir_connect,2 )
            flag_FoV = FoV_judge( Fusion_center.sensor_inf( dir_connect(k) ).location, M_AA, ...
                                      Fusion_center.sensor_inf( dir_connect(k) ).R_detect); % �ӳ��ж�
            if flag_FoV == 1
                Index_fovIn = [Index_fovIn dir_connect(k)];
            end
        end

        noprovide_sensorID = setdiff( dir_connect , Matched_GM(i).gm{2,1}(7,:) ); %û�ṩ���ӵ��ھӽڵ�
        noprovide_ok_sensorID = setdiff( dir_connect , Index_fovIn ); %���Բ��ṩ���ӵ��ھӽڵ�
        
        %������ھӽڵ�û�ṩ���ӣ�������ж��Ƿ����ڹ�������
        if ~isempty(noprovide_sensorID)   

            
            %�ж���û�в���Ҫ�ṩ���ӵ��ھӽڵ㣬���У������Щ����Ȩ�ظ����������ӽڵ�
            if ~isempty(intersect(noprovide_sensorID,noprovide_ok_sensorID))
                nocom_sensorID = intersect(noprovide_sensorID,noprovide_ok_sensorID);
                    
                %�����ں�Ȩ�ص���
                for j=1:n_w2f
                    pai(j) = mat_weight( ID_sensor , Matched_GM(i).gm{2,1}(7,j) );
                end
                pai = pai / sum(pai,2);

                %״̬�ں�Ȩ�ص���
                for j=1:n_w2f
                    pai_state(j) = mat_weight( ID_sensor , Matched_GM(i).gm{2,1}(7,j) );
                end
                pai_state = pai_state / sum(pai_state,2);

                if ~isempty(setdiff(noprovide_sensorID,noprovide_ok_sensorID))
%                     missTarget_sensorID  = setdiff(noprovide_sensorID,noprovide_ok_sensorID);
                
                    %״̬�ں�Ȩ�ص���
                    for j=1:n_w2f
                        pai_state(j) = mat_weight( ID_sensor , Matched_GM(i).gm{2,1}(7,j) );
                    end
                    pai_state = pai_state / sum(pai_state,2);
    
                    %�����ں�Ȩ�ص���
                    noprovide_weightSum = sum(mat_weight( ID_sensor , nocom_sensorID ) ); %�Ѳ���Ҫ�ṩ���ӵĴ���������Ȩ���ۼ�
                    eta = 1/(1-noprovide_weightSum); %��������
                    
                    for j=1:n_w2f
                    pai(j) = eta*mat_weight( ID_sensor , Matched_GM(i).gm{2,1}(7,j) );
                    end
                    
                end

                %�ں�Ȩ�ص����꣬�����ں�
                
                % Ȩ���ں�
                W_AA = 0;
                for j = 1:n_w2f
                    W_AA = W_AA + pai(j) * Matched_GM(i).gm{1,1}(1,j);
                end
                
                % Э�����ں�
                P_AA = zeros(6,6);
                for j = 1:n_w2f
                    P_AA = P_AA + pai_state(j) * inv( Matched_GM(i).gm{3,1}(:,6*(j-1)+1:6*j) );
                end
                P_AA = inv( P_AA );
                
                % ��ֵ�ں�
                M_AA = [0 0 0 0 0 0]';
                for j = 1:n_w2f
                    M_AA = M_AA + pai_state(j) * inv( Matched_GM(i).gm{3,1}(:,6*(j-1)+1:6*j) ) * ...
                        Matched_GM(i).gm{2,1}(1:6,j);
                end
                M_AA = P_AA * M_AA;


            
            else %δ�ṩ���ӵĽڵ�ȫ�Ǳ���Ҫ�ṩ���ӵ���û�ṩ�ģ�����������

                %״̬�ں�Ȩ�ص���
                for j=1:n_w2f
                    pai_state(j) = mat_weight( ID_sensor , Matched_GM(i).gm{2,1}(7,j) );
                end
                pai_state = pai_state / sum(pai_state,2);

                %�����ں�Ȩ�ص���
                for j=1:n_w2f
                    pai(j) = mat_weight( ID_sensor , Matched_GM(i).gm{2,1}(7,j) );
                end

                %�ں�Ȩ�ص����꣬�����ں�
                
                % Ȩ���ں�
                W_AA = 0;
                for j = 1:n_w2f
                    W_AA = W_AA + pai(j) * Matched_GM(i).gm{1,1}(1,j);
                end
                
                % Э�����ں�
                P_AA = zeros(6,6);
                for j = 1:n_w2f
                    P_AA = P_AA + pai_state(j) * inv( Matched_GM(i).gm{3,1}(:,6*(j-1)+1:6*j) );
                end
                P_AA = inv( P_AA );
                
                % ��ֵ�ں�
                M_AA = [0 0 0 0 0 0]';
                for j = 1:n_w2f
                    M_AA = M_AA + pai_state(j) * inv( Matched_GM(i).gm{3,1}(:,6*(j-1)+1:6*j) ) * ...
                        Matched_GM(i).gm{2,1}(1:6,j);
                end
                M_AA = P_AA * M_AA;

                
            end
       
        end
                
              
%==================================================================


%         W_AA = W_AA * min( 1, n_w2f / cnt_fovIn); % ��Ȩ�رȵ������ߵ������������
        
        %=====��ֵ=====
        Results{1,1}(1,i) = W_AA;
        Results{2,1}(:,i) = [M_AA;ID_sensor];
        Results{3,1}(:,6*(i-1)+1:6*i) = P_AA;
        
    end
end

end