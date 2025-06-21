function [state_draw,num_draw]=Alg8_statedraw(state)

Xhat_k = [];
Xhat_w = [];

w_k = state.w;
m_k = state.m;
J_k = size(w_k,2);

for i = 1:J_k
    if w_k(1,i) > 0.5
        Jw=min(round(w_k(1,i)),2);
        for j = 1:Jw%四舍五入取整
            Xhat_k = [Xhat_k , m_k(:,i)];
            Xhat_w = [Xhat_w , w_k(:,i)];
        end
    end
end

state_draw = Xhat_k;
num_draw = size(state_draw,2);
