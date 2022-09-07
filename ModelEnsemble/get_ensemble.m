% this function calculates the weighted ensemble of n individual predictions 
% for m time steps
% predRUL - m x n RUL prediction of individual models
% sRUL    - m x n standard deviation of individual models
% wt      - m x n. 0 if simple averaging. 
% Outputs
% predRUL_en, sRUL_en - ensemble prediction and standard deviation

function [predRUL_en, sRUL_en] = get_ensemble(predRUL, sRUL, wt)
    % adding some corrections
    wt(wt<0)=0;
    sRUL=abs(sRUL);
    [m, n]=size(predRUL); % m is time steps, n is the number of models
    if wt==0
        for i=1:m
            predRUL_en(i,1)=mean(predRUL(i,:), 'omitnan');
            sRUL_en(i,1)=sqrt(abs(mean(sRUL(i,:).*sRUL(i,:)+predRUL(i,:).*predRUL(i,:),'omitnan')-predRUL_en(i,1)^2));
        end
    else
        for i=1:m
            p=predRUL(i,:);
            s=sRUL(i,:);
            nanidx = ~isnan(p);% index of models with non nans
            wt2=wt(i,nanidx);
            wt2=wt2/sum(wt2);  %normalizing wts across all models at this time step
            model_preds=p(nanidx);
            models_=s(nanidx);
            
            predRUL_en(i,1)=sum(wt2.*model_preds);
            sRUL_en(i,1)=sqrt(sum(wt2.*(model_preds.^2+models_.^2))- predRUL_en(i,1).^2);

        end
    end       
end