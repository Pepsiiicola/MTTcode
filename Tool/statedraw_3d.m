%%��ά״̬��ȡģ��
%%����:����״̬��4*1��cell���ֱ����1.Ȩֵ��2.��ֵ��3.Э���4.���Ӹ���
%%���:��ǰʱ��״̬6*��������
%%*************************************************************************
function [state_draw,num_draw]=statedraw_3d(state)
JK=0;%%״̬�����ļ�����
state_draw=zeros(6,2*state{4,1});
for i=1:state{4,1}
    j = min( round(state{1,1}(1,i)) , 2 );
    for k=1:j
        JK=JK+1;
        state_draw(:,JK)=state{2,1}(:,i);
    end
end
state_draw(:,JK+1:2*state{4,1})=[];
num_draw=JK;

end