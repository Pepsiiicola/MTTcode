nClutter=s1_nClutter;
clutter = zeros(2,nClutter);%The observations are of the form [x; y]
for i = 1:nClutter
    clutterX = rand * (xrange(2) - xrange(1)) + xrange(1); %Random number between xrange(1) and xrange(2), uniformly distributed.
    clutterY = rand * (yrange(2) - yrange(1)) + yrange(1); %Random number between yrange(1) and yrange(2), uniformly distributed.
    
    clutter(1,i) = clutterX;
    clutter(2,i) = clutterY;
end

%判断状态是否可以被传感器检测到 detect_prob=0.98
detect_target1=rand;
detect_target2=rand;
detect_target3=rand;
if k>=Target1_birth_time && k<=Target1_end_time
    Z_withoutClutter_Target1=H*Target1(:,k-Target1_birth_time+1)+sqrt(R)*randn(2,1);
else
    Z_withoutClutter_Target1=[];
end
if k>=Target1_birth_time && k<=Target1_end_time
    if(detect_target1>s1_detect_prob)
        ob_x_target1=[];
        ob_y_target1=[];
    else
        ob_x_target1=Z_withoutClutter_Target1(1);
        ob_y_target1=Z_withoutClutter_Target1(2);
    end
else
    ob_x_target1=[];
    ob_y_target1=[];
end
    

Z_withoutClutter_Target2=H*Target2(:,k)+sqrt(R)*randn(2,1);
if(detect_target2>s1_detect_prob)
    ob_x_target2=[];
    ob_y_target2=[];
else
    ob_x_target2=Z_withoutClutter_Target2(1);
    ob_y_target2=Z_withoutClutter_Target2(2);
end

Z_withoutClutter_Target3=H*Target3(:,k)+sqrt(R)*randn(2,1);
if(detect_target3>s1_detect_prob)
    ob_x_target3=[];
    ob_y_target3=[];
else
    ob_x_target3=Z_withoutClutter_Target3(1);
    ob_y_target3=Z_withoutClutter_Target3(2);
end





 s1_Z=[];%传感器观测数据
%  Z=[ [ob_x_target1;ob_y_target1],[ob_x_target2;ob_y_target2],[ob_x_target3;ob_y_target3],[ob_x_target4;ob_y_target4],[ob_x_target5;ob_y_target5],[ob_x_target6;ob_y_target6] ];
 s1_Z=[ [ob_x_target1;ob_y_target1],[ob_x_target2;ob_y_target2],[ob_x_target3;ob_y_target3]];
 s1_Z=[s1_Z,clutter];
 s1_Z_clutter{k}=s1_Z;


    


    