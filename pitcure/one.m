ln = findobj(gca,'Type','line');
legend(ln())
% temp = ln(7).YData;
% temp1 = smoothdata(temp);
% ln(7).YData = temp1; 



% for i = 1:2:length(ln)
%     legend boxoff;
%     if(i == 1) 
%        lg((i+1)/2) = legend(ln(i:i+1));
%     else
%        lg((i+1)/2) = legend(ah,ln(i:i+1)); 
%     end
%     set(lg((i+1)/2),'orientation','horizontal');
%     set(lg((i+1)/2),'FontName','Times New Roman','FontSize',14);
%     ah=axes('position',get(gca,'position'),'visible','off');
% 
% end
