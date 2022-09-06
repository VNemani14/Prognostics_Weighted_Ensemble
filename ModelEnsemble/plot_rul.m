% Few lines of code to plot RUL
tt=(1:m)'; % data was subsampled 5 times
figure()
plot(tt,actRUL,'--k','linewidth',1.5)
hold all

modelno = 6; % Enall
mypred = eval("p"+num2str(modelno));
mys = eval("s"+num2str(modelno));
sigmafac=1; % plot width factor
upper = mypred+sigmafac*mys; upper(isnan(upper))=0.01;
lower = mypred-sigmafac*mys; lower(isnan(lower))=0.01;
fill([tt;flipud(tt)], [upper;flipud(lower)], 'r', 'Facealpha', 0.2, 'linestyle', 'none')
plot(tt, mypred,'r','linewidth',1.5)

modelno = 8; % DSDEn
mypred = eval("p"+num2str(modelno));
mys = eval("s"+num2str(modelno));
upper = mypred+sigmafac*mys; upper(isnan(upper))=0.01;
lower = mypred-sigmafac*mys; lower(isnan(lower))=0.01;
fill([tt;flipud(tt)], [upper;flipud(lower)], 'b', 'Facealpha', 0.2, 'linestyle', 'none')
plot(tt, mypred,'b','linewidth',1.5)

legend('True','' ,'En-all','','DSDEn')
xlabel('Cycle Number/5')
ylabel('RUL (cycles)/5')
set(gca,'fontsize',18)
set(gcf, 'color','w')
ylim([0 m+30])