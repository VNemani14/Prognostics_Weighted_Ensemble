function [xV,predRUL,sRUL, tfor, yfor, sfor]=get_ExpUKFstatesEn_battery(HI,cutf,nskip,myparam)
    %Input: 
    %Time series: HI
    %cutoff: cutf
    %number of points to skip: nskip
    %UKF parameters: myparam: These parameters are determined from "Determine_Opt_Parameters_UKF_GPR.m"
    %Outputs:
    % xV: Updated states
    % predRUL: RUL prediction
    % tfor and yfor: x and y axes for forecasting HI 
    
    % Set up the equations for the bearing - initialize
    n=4;      %number of states - defined within the non linear state eqn below
    dt=nskip+1;     %time interval between measurements
    % myparam=[0.1,0.001,0.001,0.01];
    q=[myparam(1); myparam(2); myparam(3); myparam(4)];   %std of process
    r=myparam(5);                        %std of measurement
    Q=diag(q.*q);                        % covariance of process 
    R=r^2;                               % covariance of measurement  (error in measurements)
    f=@(x)[x(1)+x(2)*dt+x(3)*exp(x(4)*dt);x(2);x(3);x(4)]; % nonlinear state equations
    h=@(x)x(1);                 % measurement equation
    P = 1e-3*eye(n);            % initial state covariance - keeps updating

    [Noriginal,~]=size(HI);
    HI=flipud(HI(Noriginal:-(nskip+1):1)); % skipping measurements
    [N,~]=size(HI);
    xx=1:nskip+1:Noriginal;


    s=[HI(1);0.1;0.1; 0.1];   % initial state
    x=s+q.*randn(n,1);           % initial state with noise

    xV = zeros(n,N);          %allocating memory
    sV = zeros(n,N);          
    zV = zeros(1,N);

    %UKF update iteration
    for k=1:N
        z = HI(k);                              % measurement
        sV(:,k)= s;                             % save actual state
        zV(k)  = z;                             % save measurement
        [x, P] = ukf(f,x,P,h,z,Q,R);            % ukf to get updated state and covariance 
        xV(:,k) = x;                            % save estimate
%         if k~=N
            s = f(s) + q.*randn(n,1);               % update process
%         end
    end

    % do the forecast
    yfor(1)=xV(1,k);
    sfor(1)=P(1,1);
    tfor(1)=0;
    for kk=1:400
        z = yfor(kk)+xV(2,k)*dt+xV(3,k)*xV(1,k)*exp(xV(4,k)*dt);                              % measurement
        sV(:,kk)= s;                             % save actual state
        zV(kk)  = z;                             % save measurement
        [x, P] = ukf(f,x,P,h,z,Q,R);            % ukf to get updated state and covariance 
        xV(:,kk) = x;                            % save estimate
%          s = f(s) + q.*randn(n,1);
        yfor(kk+1)=xV(1,kk);
        sfor(kk+1)=P(1,1);
        tfor(kk+1)=tfor(kk)+dt;
        if yfor(kk+1)>=cutf
            predRUL=kk*dt;
            break
        else
            predRUL=NaN;
        end 
    end
    
    
%     yfor(1)=xV(1,k);
%     tfor(1)=0;
%     for iter=1:250
%         
%         yfor(iter+1)=yfor(iter)+xV(2,k)*dt+xV(3,k)*xV(1,k)*exp(xV(4,k)*dt);
%         tfor(iter+1)=tfor(iter)+dt;
%         if yfor(iter+1)>=cutf
%             predRUL=iter*dt;
%             break
%         else
%             predRUL=NaN;
%         end 
%     end
    tfor=tfor';
    yfor=yfor';
    sfor=sqrt(sfor');
    
    upper = yfor + sfor;
    lower = yfor - sfor;
    
    if isnan(predRUL)
        sRUL=NaN;
    else
        sRUL = (interp1(yfor, tfor, cutf)-interp1(upper, tfor, cutf));
    end
end

