% A = [1 1 1 1;
%      1 2 3 4;
%      2 1 1 3;];
% %������Сƽ̨
% L = [2,3];
% [a,b] = min(A(1,L) * 10 +  A(2,L) + A(3,L) * 2000)
% % min_plate_numebr = find(A(3,L) == min(A(3,L)))
% 
% %������Сƽ̨�е���С����ʱ��

A=[2 3 4];
B=[1 2 3;
   2 3 4;
   3 4 5];
[~,ind]=ismember(A,B,'rows')
[~,ind]=ismember(A,B','rows')
