%{
                              ƥ�����
% ע������� Match_part1 ��ά��Ӧ���Ǻ� Matched_GM �ĸ���һ�µ�
%}
function [Solution_match,Mat_match] = ALG5_Match(Match_part1,Match_part2,Matched_GM,cnt_matchedGm,match_threshold)

%1.�������������֮��ľ�����󣬽����볬����ֵ���趨Ϊ��ֵ
% ע: ����У�������������PART1�����ӣ�������������PART2������
%=====����Matched_GM���������Ӿ���Ŀ�����,ȡ���ֿ����е���С���Ǹ�======
[D] = dis_compute_vector(Match_part1{2,1}(1:6,:),Match_part2{2,1}(1:6,:));
for i = 1:cnt_matchedGm
    for j = 2:Matched_GM(i).gm{4,1}
        new_cost = dis_compute_vector( Matched_GM(i).gm{2,1}(1:6,j) , Match_part2{2,1}(1:6,:) );
        for k = 1:size( D , 2 )
            D(i,k) = min( D(i,k) , new_cost(1,k));
        end
    end
end
D = min(match_threshold,D);

%2.����murty�㷨����ԣ�����ԵĽ�����վ��������бȶԣ��������������������ֵ��Ϊ���ʧЧ
Solution = Murty(D, 1);
Solution_match = Solution{1,1}{1,1};
dim_part1 = Match_part1{4,1}; % part1��Ե�ά��
dim_part2 = Match_part2{4,1}; % part2��Ե�ά��
Mat_match = zeros(dim_part1,dim_part2);
for i = 1:size(Solution_match,1)
    if Solution_match(i) ~= 0 && D(i,Solution_match(i)) < match_threshold
        Mat_match(i,Solution_match(i)) = 1;
    elseif Solution_match(i) ~= 0 && D(i,Solution_match(i)) >= match_threshold
        Solution_match(i) = 0;
    end
end

end