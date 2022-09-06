function [predRUL,sRUL, tfor, yfor, sfor]=get_GPREn_battery(HI,cutf,nskip,bfunc,kfunc, myparam)
    %Input: 
    %Time series: HI
    %cutoff: cutf
    %number of points to skip: nskip
    %basis function: bfunc
    %covariance function: kfunc
    %GPR parameters: myparam: These parameters are determined from "Determine_Opt_Parameters_UKF_GPR.m"
    %Outputs:
    % predRUL: RUL prediction
    % tfor and yfor: x and y axes for forecasting HI 
    
    % Set up the equations for the bearing - initialize
    dt=nskip+1;     %time interval between measurements
    [Noriginal,~]=size(HI);
    HI=HI(1:nskip+1:end,1); % skipping measurements
    [N,~]=size(HI);
    xx=1:nskip+1:Noriginal;
    xx=xx';

    %GPR update
    GM = fitrgp(xx,HI,'Basis',bfunc,'KernelFunction',kfunc,'KernelParameters',[myparam(1);myparam(2)],'Sigma',myparam(3),'FitMethod','exact','Sigmalowerbound',0.015);
    yfor(1,1)=HI(end);
    tfor(1,1)=0;
    sfor(1,1)=0;
    for k=1:400
        [yfor(k+1,1),sfor(k+1,1)]=predict(GM, xx(end)+k*dt);
        tfor(k+1,1)=k*dt;
        if yfor(end,1)>=cutf
           predRUL=k*dt;
           break
       else
           predRUL=NaN;
        end
    end

    upper = yfor + sfor;
    lower = yfor - sfor;
    
    if isnan(predRUL)
        sRUL=NaN;
    else
        sRUL = (interp1(yfor, tfor, cutf)-interp1(upper, tfor, cutf));
    end

end



