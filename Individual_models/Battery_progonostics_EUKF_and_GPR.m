%% In this code the EUKF and GPR models are used to determinet the RUL for the training and test sets. 

clear all
warning('off','all')
datalist={'../Datasets/Training - 169 LFP.mat','../Datasets/Test1 - 169 LFP.mat','../Datasets/Test2 - 169 LFP.mat','../Datasets/Test3 - 169 LFP.mat'};

%optimized parameters for EUKF and GPR. Determined by LHS
param_EUKF = [0.0045, 6.8e-6, 3.1e-6, 7.1e-6, 0.0294];
param_GPR = [0.1348, 0.0644, 0.0001];
cutf = 0.2; % cutoff (1-0.8)
nskip = 0;  % number of measurements to skip between measurements. if nskip = 1, every alternate point is used

for mymodel=1:2  % model 1 is EUKF and model 2 is GPR
for mydata=1:4   % 1-Training, 2-4 are Test 1-3 dataset

load(datalist{mydata})
[~,nbattery] = size(ydata);
all_actrul=[];
all_pred=[];
all_spred=[];

for mybid=1:nbattery %for each of the training dataset
    disp(['model#: ', num2str(mymodel),' dataset#: ', num2str(mydata), ' battery# :', num2str(mybid)]);
    n_ensemble_models = 5;
    bid=mybid;
    myHI = ydata{1,bid};
    myHI = 1-myHI(fpt_idxs(bid):eol_idxs(bid))';
    [m,~]=size(myHI);
    actRUL=((m-1):-1:0)';
    Pred=zeros(m,1);
    predRUL=zeros(m,n_ensemble_models); sRUL=zeros(m,n_ensemble_models);
    
    for j=1:m %for each measurement being taken from the FPT
        for count=1:n_ensemble_models
            if mymodel==1
            [xV,predRUL(j, count), sRUL(j, count),tfor,yfor,sfor]=get_ExpUKFstatesEn_battery(myHI(1:j),cutf,nskip,param_EUKF);
            else
            [predRUL(j, count), sRUL(j, count),tfor,yfor,sfor]=get_GPREn_battery(myHI(1:j),cutf,nskip,'pureQuadratic','squaredexponential',param_GPR);
            end

%         uncomment below to plot forecasts at each time step
%         plot(myHI)
%         hold all
% 
%         sigmafac=1;
%         upper = yfor+sigmafac*sfor;
%         lower = yfor-sigmafac*sfor;
%         tfor2 = tfor+j;
%         fill([tfor2;flipud(tfor2)], [upper;flipud(lower)], 'r', 'Facealpha', 0.3, 'linestyle', 'none')
%         plot(tfor2, yfor)
%         ylim([0. 0.3])
%         hold off
%         pause(0.5)

        end
    end
    actRUL_all{mymodel, mydata, mybid} = actRUL;
    predRUL_all{mymodel, mydata, mybid} = predRUL;
    sRUL_all{mymodel, mydata, mybid} = sRUL;

%     Plot the entire RUL curve
%     t=1:m;
%     figure()
%     plot(t, actRUL, '--k', 'linewidth', 1.5)
%     hold all
%     plot(t, predRUL(:,1), 'b', 'linewidth', 1.5)
%     xlabel('Time from FPT')
%     ylabel('RUL')
%     ylim([0 m+20])

end

% postprocess 
% [netRMSE(mydata, mymodel),netRMSEwt(mydata, mymodel),netalphaacc(mydata, mymodel),netmybeta(mydata, mymodel),netmyPEP(mydata, mymodel),netmyNLL(mydata, mymodel)]=get_postprocess(all_actrul,all_pred,all_spred);

end
end
% save("Paper_EUKF_GPR_RUL_git"+num2str(iter)+".mat",'actRUL_all','predRUL_all','sRUL_all')