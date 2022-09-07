%function to get observed confidence interval
%actRUL - true RUL
%mypred - prediction RUL
%mystd  - standard deviation of prediction
%myalpha- significance level
%observedCI  - observed confidence interval
function [observedCI]=get_CI(actRUL,mypred,mystd,myalpha)
    
    m=length(actRUL);

    %clearing off any improper entries
    mystd(mystd==0)=1e-2; mystd(isnan(mystd))=1e-2;
    
    prob=[myalpha/2,1-myalpha/2];
    mylimits=norminv(prob,mypred,mystd); %limits of significance level
    
    myscore=(actRUL>=mylimits(:,1))+(actRUL<=mylimits(:,2));
    observedCI=sum(myscore==2)/m*100; %percentage of 

end