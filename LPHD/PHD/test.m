% A = [1 1 1 1;
%      1 2 3 4;
%      2 1 1 3;];
% %查找最小平台
% L = [2,3];
% [a,b] = min(A(1,L) * 10 +  A(2,L) + A(3,L) * 2000)
% % min_plate_numebr = find(A(3,L) == min(A(3,L)))
% 
% %查找最小平台中的最小出生时间

A=[2 3 4];
B=[1 2 3;
   2 3 4;
   3 4 5];
[~,ind]=ismember(A,B,'rows')
[~,ind]=ismember(A,B','rows')
