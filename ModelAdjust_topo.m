%{
               ���ݵ�ǰ���˵���������Լ�����ϡ��̶ȣ��������˵�������� 
               �޷��Զ���������Ҫ�ֶ����þ�������˾���
%}
function [mat_topo_decen] = ModelAdjust_topo( mat_topo_decen , Rank_TopoConnect )

% mat_topo_decen_copy = mat_topo_decen;
% mat_topo_decen = diag( ones( 1,size(mat_topo_decen,2)) );

% % �������ӳ̶� 2/N_sensor
% % ÿ��������ֻ����2���ھӴ�����
% if Rank_TopoConnect == 2
%     mat_topo_decen(1,[6,7]) = 1;
%     mat_topo_decen(2,[3,7]) = 1;
%     mat_topo_decen(3,[2,4]) = 1;
%     mat_topo_decen(4,[3,5]) = 1;
%     mat_topo_decen(5,[4,6]) = 1;
%     mat_topo_decen(6,[1,5]) = 1;
%     mat_topo_decen(7,[1,2]) = 1;
%     
%     mat_topo_decen([6,7],1) = 1;
%     mat_topo_decen([3,7],2) = 1;
%     mat_topo_decen([2,4],3) = 1;
%     mat_topo_decen([3,5],4) = 1;
%     mat_topo_decen([4,6],5) = 1;
%     mat_topo_decen([1,5],6) = 1;
%     mat_topo_decen([1,2],7) = 1;
% end
% 
% % �������ӳ̶� 3/N_sensor
% if Rank_TopoConnect == 3
%     mat_topo_decen = mat_topo_decen_copy;
% end
% 
% % �������ӳ̶� 4/N_sensor
% if Rank_TopoConnect == 4
%     mat_topo_decen(1,[2,3,4,5]) = 1;
%     mat_topo_decen(2,[1,3,4,6,7]) = 1;
%     mat_topo_decen(3,[1,2,4,5]) = 1;
%     mat_topo_decen(4,[1,2,3,5]) = 1;
%     mat_topo_decen(5,[1,3,4,6]) = 1;
%     mat_topo_decen(6,[1,2,5,7]) = 1;
%     mat_topo_decen(7,[1,2,6]) = 1;
%     
%     mat_topo_decen([2,3,4,5],1) = 1;
%     mat_topo_decen([1,3,4,6,7],2) = 1;
%     mat_topo_decen([1,2,4,5],3) = 1;
%     mat_topo_decen([1,2,3,5],4) = 1;
%     mat_topo_decen([1,3,4,6],5) = 1;
%     mat_topo_decen([1,2,5,7],6) = 1;
%     mat_topo_decen([1,2,6],7) = 1;
% end
% 
% % �������ӳ̶� 5/N_sensor
% if Rank_TopoConnect == 5
%     mat_topo_decen(1,[2,3,4,5,6]) = 1;
%     mat_topo_decen(2,[1,3,4,6,7]) = 1;
%     mat_topo_decen(3,[1,2,4,5,7]) = 1;
%     mat_topo_decen(4,[1,2,3,5,6]) = 1;
%     mat_topo_decen(5,[1,3,4,6,7]) = 1;
%     mat_topo_decen(6,[1,2,4,5,7]) = 1;
%     mat_topo_decen(7,[2,3,5,6]) = 1;
%     
%     mat_topo_decen([2,3,4,5,6],1) = 1;
%     mat_topo_decen([1,3,4,6,7],2) = 1;
%     mat_topo_decen([1,2,4,5,7],3) = 1;
%     mat_topo_decen([1,2,3,5,6],4) = 1;
%     mat_topo_decen([1,3,4,6,7],5) = 1;
%     mat_topo_decen([1,2,4,5,7],6) = 1;
%     mat_topo_decen([2,3,5,6],7) = 1;
% end
% 
% % �������ӳ̶� 6/N_sensor
% if Rank_TopoConnect == 6
%     mat_topo_decen = ones( size(mat_topo_decen,1), size(mat_topo_decen,2) );
% end

end