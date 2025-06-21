%{
                                 ��������ģ��

           ���ܣ����ݴ������۲ⷶΧ��Ŀ�껮������

           ����: 1.state    -- ��������������Ӽ� (6*1cell)
                 2.location -- ����������(3*1����)
                 3.r_detect -- ��������ⷶΧ

           ���: 1.in_FoV   -- ���������Ӽ���6*1cell)
                 2.out_FoV  -- ���������Ӽ���6*1cell��

%}
function [in_FoV,out_FoV]=FoV_divide(state,location,r_detect)

%===========��ȡ����=============
n_state=state{4,1}; % ���Ӹ���
cnt_in=0;  % ����������������
cnt_out=0; % ����������������
dir_in=zeros(1,n_state);  % ת�������ڵ�����Ŀ¼
dir_out=zeros(1,n_state); % ת�������������Ŀ¼

%====�����ж�====
for i=1:n_state
    flag_FoV=FoV_judge(location,state{2,1}(:,i),r_detect);
    if flag_FoV==1          % ��������
       cnt_in=cnt_in+1;
       dir_in(cnt_in)=i;
    elseif flag_FoV==0      % ��������
        cnt_out=cnt_out+1;
        dir_out(cnt_out)=i;
    end
end

dir_in(cnt_in+1:end)=[];
dir_out(cnt_out+1:end)=[];

%=====��������ת��=====
[in_FoV,out_FoV]=FoV_divide_assifun(state,dir_in,dir_out,cnt_in,cnt_out);

end

%{
************************************************************************
                        ����ת�ƺ���
              ����ת��Ŀ¼�����Ӱ��������������
         ����: 1.state    -- ��������������Ӽ� (6*1cell)
               2.dir_in   -- ���������ӵ�Ŀ¼
               3.dir_out  -- ���������ӵ�Ŀ¼
               4.n_in     -- �����ڵ���������
               5.n_out    -- ���������������

         ���: 1.in_FoV   -- ���������Ӽ���6*1cell)
               2.out_FoV  -- ���������Ӽ���6*1cell��
************************************************************************
%}
function [in_FoV,out_FoV]=FoV_divide_assifun(state,dir_in,dir_out,n_in,n_out)

%=====��ʼ��=====
in_FoV=cell(4,1);
out_FoV=cell(4,1);

%======������ת��======
in_FoV{1,1}=state{1,1}(1,dir_in); % Ȩ��
in_FoV{2,1}=state{2,1}(:,dir_in); % ��ֵ
in_FoV{4,1}=n_in;                 % ��������
% Э����ת��
in_FoV{3,1}=zeros(6,6*n_in);
for i=1:n_in
    in_FoV{3,1}(:,6*i-5:6*i)=state{3,1}(:,6*dir_in(i)-5:6*dir_in(i));
end

%======������ת��======
out_FoV{1,1}=state{1,1}(1,dir_out); % Ȩ��
out_FoV{2,1}=state{2,1}(:,dir_out); % ��ֵ
out_FoV{4,1}=n_out;                 % ��������
% Э����ת��
out_FoV{3,1}=zeros(6,6*n_out);
for i=1:n_out
    out_FoV{3,1}(:,6*i-5:6*i)=state{3,1}(:,6*dir_out(i)-5:6*dir_out(i));
end


end