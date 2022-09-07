% Function to get postprocess results
% actRUL: m x 1 true RUL
% mypred: m x 1 predicted RUL
% mystd:  m x 1 predicted standard deviation
% outputs
% RMSE: Root mean squared error
% RMSEwt: weighted RMSE
% alpha_acc: alpha accuracy
% beta_prob: beta probability
% PEP: percentage of early prediction
% NLL: Median of negative log likelihood

function [RMSE,RMSEwt,alpha_acc,beta_prob,PEP,NLL]=get_postprocess(actRUL,mypred,mystd)
    
    m=length(actRUL);
    mystd(mystd==0)=1; % make standard deviation non zero

    %calculate RMSE and wtRMSE
    [RMSE, RMSEwt]=get_rmse(actRUL,mypred);

    myfac=0.25; % 25 percent above and below true line
    act_upper=actRUL.*(1+myfac);
    act_lower=actRUL.*(1-myfac);
    
    %calculate beta probability
    beta_prob=mean(normcdf(act_upper,mypred,mystd)-normcdf(act_lower,mypred,mystd), 'omitnan');
    
    %alpha accuracy
    myscore=(mypred>=act_lower)+(mypred<=act_upper); % calculate points within the alpha region
    alpha_acc=sum(myscore==2)/m*100;
    
    %calculate PEP
    PEP=sum(mypred<=actRUL, 'omitnan')/m*100;
    
    %NLL - NLL is evaluated for all datapoints. Can either choose median or
    %average of top 30%. 
    % Not advisable to average over all predictions as sigma at early
    % predictions can be very high and throw off the values. 

    nll_arr=log(mystd.^2)./2+(actRUL-mypred).^2./2./(mystd.^2);
%     myNLL=median(full_arr, 'omitnan'); 
    nll_sorted =sort(nll_arr);
    NLL=mean(nll_sorted(1:floor(m/4)), 'omitnan'); %take the last 25%
end