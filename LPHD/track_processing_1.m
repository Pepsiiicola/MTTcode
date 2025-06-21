function [L_hat,Fusion] = track_processing_1(L_hat,L_hat_history,Fusion,x_hat,x_hat_history,x_hat_time,k)

%记录当前时刻滤波的标签空间
Label_mapping = @(X)(X(1,:) * 2000 + X(2,:) + X(3,:) * 20);
Dis = @(x,y)sqrt((x(1) - y(1))^2 + (x(3) - y(3))^2);
L_hat_curTime = L_hat;
L_hat_curTime_Mapping = Label_mapping(L_hat_curTime);

%记录之前的标签空间对应的点数L_space_pre_contains_point_number

L_space_pre = unique(L_hat_history','rows')';
L_space_pre_mapping = Label_mapping(L_space_pre);
L_space_pre_contains_point_number = zeros(1,length(L_space_pre_mapping));
L_hat_history_mapping = Label_mapping(L_hat_history);
for i = 1:length(L_space_pre_contains_point_number)
   L_space_pre_contains_point_number(i) = length(find(L_space_pre_mapping(i) == L_hat_history_mapping)); 
end
%成熟标签映射
mature_tracks_mapping = L_space_pre_mapping(:,find(L_space_pre_contains_point_number >= 3));

%判断当前滤波出来的标签是否在成熟标签当中
%记录新出来的标签空间，与漏检的标签空间
new_L_hat_mapping = [];
miss_dected_L_mapping = [];
for i = 1:length(L_hat_curTime_Mapping)
    tempIndex = find(L_hat_curTime_Mapping(i) == mature_tracks_mapping);
    if length(tempIndex) == 0
        new_L_hat_mapping = [new_L_hat_mapping,L_hat_curTime_Mapping(i);];
    else
        mature_tracks_mapping(tempIndex) = [];
    end 
end
%漏检标签空间
miss_dected_L_mapping = mature_tracks_mapping;
%将漏检标签空间对应的标签与新生出来的标签进行匹配
new_L_hat_to_X = [];
for i = 1:length(new_L_hat_mapping)
    new_L_hat_to_X = [new_L_hat_to_X,x_hat(:,find(new_L_hat_mapping(i) == L_hat_curTime_Mapping))];
end
miss_dected_L_mapping_to_X = [];
for i = 1:length(miss_dected_L_mapping)
    tempIndex = find(miss_dected_L_mapping(i) == L_hat_history_mapping);
    miss_dected_L_mapping_to_X = [miss_dected_L_mapping_to_X,x_hat_history(:,tempIndex(length(tempIndex)))];
end
for i = 1:length(new_L_hat_mapping)
    new_L_hat = L_hat_curTime(:,find(new_L_hat_mapping(i) == L_hat_curTime_Mapping));
    for j = 1:length(miss_dected_L_mapping)
        miss_dected_L = L_space_pre(:,find(miss_dected_L_mapping(j) == L_space_pre_mapping));
        %计算要一步预测的次数
        pre_k_Index = find(miss_dected_L_mapping(j) == L_hat_history_mapping);
        pre_k = x_hat_time(pre_k_Index(length(pre_k_Index)));
%         step_predict = new_L_hat(1) - pre_k;
        step_predict = k - pre_k;
        %对step_predict > 10时，不进行处理
        if step_predict > 10
            continue;
        end
        %对new_L_hat_to_X做预测
        new_L_hat_to_X_predict = [new_L_hat_to_X(1,i) + step_predict * new_L_hat_to_X(2,i);new_L_hat_to_X(2,i);new_L_hat_to_X(3,i) + step_predict * new_L_hat_to_X(4,i);new_L_hat_to_X(4,i)];
        miss_dected_L_mapping_to_X_predict = [miss_dected_L_mapping_to_X(1,j) - step_predict * miss_dected_L_mapping_to_X(2,j);miss_dected_L_mapping_to_X(2,j);miss_dected_L_mapping_to_X(3,j) - step_predict * miss_dected_L_mapping_to_X(4,j);miss_dected_L_mapping_to_X(4,j)];
        %计算new_L_hat_to_X_predict与miss_dected_L_mapping_to_X(:,j)的距離
        distance1 = Dis(new_L_hat_to_X_predict,miss_dected_L_mapping_to_X(:,j));
        distance2 = Dis(miss_dected_L_mapping_to_X_predict,new_L_hat_to_X(:,i));
        if distance1 < step_predict * 80 || distance2 < step_predict * 80 
            L_hat(:,find(new_L_hat_mapping(i) == L_hat_curTime_Mapping)) = miss_dected_L;
        end      
    end  
end
%将L_hat反馈到 Fusion(1).L
feedbackIndex = find(Fusion(1).W > 0.5);
Fusion(1).L(:,feedbackIndex) = L_hat;

end

