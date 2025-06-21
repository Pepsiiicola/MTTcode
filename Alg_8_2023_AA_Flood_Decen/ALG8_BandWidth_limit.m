function [Inf_recieve] = ALG8_BandWidth_limit(Fusion_center_Inf_recieve,mat_topo,Com_bandwidth,label)

Inf_recieve = Fusion_center_Inf_recieve;

fileMemInfo = whos('Inf_recieve'); % fileMemInfo是一个结构体

MemSize = fileMemInfo.bytes; % 计算接收数据的内存大小，范围是Byte

limit_BandWidth = Com_bandwidth/3 *1000 / 8*(sum(mat_topo(label,:),2) - 1);  % 带宽/8 = 字节数， 字节数*邻居数 = 总带宽，单位是byte/s

while MemSize > limit_BandWidth
%     size(Inf_recieve,2)
    r_num = randi(size(Inf_recieve,2));
    Inf_recieve(r_num) = [];

    fileMemInfo = whos('Inf_recieve');
    MemSize = fileMemInfo.bytes;
end


end