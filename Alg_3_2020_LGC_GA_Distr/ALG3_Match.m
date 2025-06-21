%{
                              ƥ�����
%}
function [Solution_match,Mat_match] = ALG3_Match(Match_part1,Match_part2,match_threshold)

%1.�������������֮��ľ�����󣬽����볬����ֵ���趨Ϊ��ֵ
[D]=dis_compute_vector(Match_part1{2,1},Match_part2{2,1});
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