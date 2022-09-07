% function to get RMSE and RMSEwt given the actual RUL and predicted
% RUL curves
% weighted RMSE is calculated to give more importance close to EOL

function [RMSE,RMSEwt]=get_rmse(actRUL,predrul)

%     actRUL=fliplr(0:m-1);
    RMSE = sqrt(mean((actRUL - predrul).^2,'omitnan'));    
    mywts=flipud(actRUL);
    mywts=mywts/sum(mywts);
    RMSEwt = sqrt(mean(mywts.*(actRUL - predrul).^2,'omitnan'));
    
end