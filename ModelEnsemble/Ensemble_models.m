%% Ensemble of individual model predictions
%use combined RUL prediction from the various models
% Simple Ensemble, Degradation independent ensemble (DIEn) and Degradation
% stage depedendent ensemble (DSDEn) - refer to the paper for further
% details on these weighting schemes

clear all
datalist={'../Datasets/Training - 169 LFP.mat','../Datasets/Test1 - 169 LFP.mat',...
    '../Datasets/Test2 - 169 LFP.mat','../Datasets/Test3 - 169 LFP.mat'};
load("Results_EUKF_GPR_LSTM_RUL.mat")
NB = [41,42,40,45]; % number of batteries in training and 3 tests.

% gather the training dataset
for mydata=1:1
    tA=[]; tP=[]; tS=[]; tH=[]; % store true RUL, predicted RUL, standard deviation and health index
    load(datalist{mydata})
    for i =1:NB(mydata)
        myHI = ydata{1,i};
        myHI = 1-myHI(fpt_idxs(i):eol_idxs(i))';

        actRUL=actRUL_all{1, mydata, i};
        m=length(actRUL);
        p1=predRUL_all{1, mydata, i}(:,1);  s1=sRUL_all{1, mydata, i}(:,1); %single EUKF
        p2=predRUL_all{2, mydata, i}(:,1);  s2=sRUL_all{2, mydata, i}(:,1); %single GPR
        p3=predRUL_all{3, mydata, i}(:,1);  s3=sRUL_all{3, mydata, i}(:,1); %single LSTM
        [p4, s4] = get_ensemble(predRUL_all{1, mydata, i}, sRUL_all{1, mydata, i}, 0); % EUKF only ensemble
        [p5, s5] = get_ensemble(predRUL_all{3, mydata, i}, sRUL_all{3, mydata, i}, 0); % LSTM only ensemble
        [p6, s6] = get_ensemble([p2,p4, p5], [s2, s4,s5], 0); % Ensemble of GPR, EnEUKF, EnLSTM

        AllP=[p4,p2,p5]; % store EnEUKF, GPR, EnLSTM in order
        AllS=[s4,s2,p5];
        mystart=1;
        tA=cat(1,tA,actRUL);
        tP=cat(1,tP,AllP(mystart:end,:));
        tS=cat(1,tS,AllS(mystart:end,:));
        tH=cat(1,tH,myHI(mystart:end,:));
    end
      
end

%% Constant weights - DIEn
options = optimoptions('fmincon','Display','off');
fun_cw=@(x)mean((tA-tP(:,1)*x(1)-tP(:,2)*x(2)-tP(:,3)*x(3)).^2,'omitnan');  % x of size 1 x 3 for 3 models: GPR, EnEUKF, EnLSTM
cw_wts = fmincon(fun_cw,[0.3,0.3,0.4],[],[],[1,1,1],1,[0,0,0],[1,1,1],[],options);
disp("Constant weights of EnEUKF, GPR and EnLSTM are : " + num2str(cw_wts))

%% Degradation stage dependent weights (weights switch based on HI) DSDEn
% Three sets of weights. HI divided into 3 regions
% Region 1: 1-Capacity -> [0, 0.08]
% Region 2: 1-Capacity -> (0.08,0.14]
% Region 3: 1-Capacity -> (0.14,0.2]

PG1=[];PG2=[];PG3=[];  % three divisions of HI
AG1=[];AG2=[];AG3=[];

for mydata=1:1
    load(datalist{mydata})
    for i =1:NB(mydata)
        myHI = ydata{1,i};
        myHI = 1-myHI(fpt_idxs(i):eol_idxs(i))';
        gidx1 = find(myHI>0.08,2); % second occurence of HI>0.08
        gidx2 = find(myHI>0.14,2); % second occurence of HI>0.14
        gidx1 = gidx1(2);
        gidx2 = gidx2(2);

        actRUL=actRUL_all{1, mydata, i};
        m=length(actRUL);
        p1=predRUL_all{1, mydata, i}(:,1);  s1=sRUL_all{1, mydata, i}(:,1); %single EUKF
        p2=predRUL_all{2, mydata, i}(:,1);  s2=sRUL_all{2, mydata, i}(:,1); %single GPR
        p3=predRUL_all{3, mydata, i}(:,1);  s3=sRUL_all{3, mydata, i}(:,1); %single LSTM
        [p4, s4] = get_ensemble(predRUL_all{1, mydata, i}, sRUL_all{1, mydata, i}, 0); % EUKF only ensemble
        [p5, s5] = get_ensemble(predRUL_all{3, mydata, i}, sRUL_all{3, mydata, i}, 0); % LSTM only ensemble
        [p6, s6] = get_ensemble([p2,p4, p5], [s2, s4,s5], 0);  % Ensemble of GPR, EnEUKF, EnLSTM

        AllP=[p4,p2,p5]; % store EnEUKF, GPR, EnLSTM in order
        AllS=[s4,s2,p5];
        AG1=cat(1,AG1,actRUL(1:gidx1-1)); AG2=cat(1,AG2,actRUL(gidx1:gidx2-1)); AG3=cat(1,AG3,actRUL(gidx2:end));
        PG1=cat(1,PG1,AllP(1:gidx1-1,:)); PG2=cat(1,PG2,AllP(gidx1:gidx2-1,:)); PG3=cat(1,PG3,AllP(gidx2:end,:));
    end
      
end

% Determine weights in Region 1
fun_sw1=@(x)mean((AG1-PG1(:,1)*x(1)-PG1(:,2)*x(2)-PG1(:,3)*x(3)).^2,'omitnan');
sw_wts1 = fmincon(fun_sw1,[0.3,0.3,0.4],[],[],[1,1,1],1,[0,0,0],[1,1,1],[],options);

% Determine weights in Region 2
fun_sw2=@(x)mean((AG2-PG2(:,1)*x(1)-PG2(:,2)*x(2)-PG2(:,3)*x(3)).^2,'omitnan');
sw_wts2 = fmincon(fun_sw2,[0.3,0.3,0.4],[],[],[1,1,1],1,[0,0,0],[1,1,1],[],options);

% Determine weights in Region 3
fun_sw3=@(x)mean((AG3-PG3(:,1)*x(1)-PG3(:,2)*x(2)-PG3(:,3)*x(3)).^2,'omitnan');
sw_wts3 = fmincon(fun_sw3,[0.3,0.3,0.4],[],[],[1,1,1],1,[0,0,0],[1,1,1],[],options);

for region=1:3
    disp("Degradation stage weights of EnEUKF, GPR and EnLSTM in Region: "+num2str(region)+ " are : "...
        + num2str(eval("sw_wts"+num2str(region))));
end

%% Putting all models together for all the datasets: Training + 3 Tests

for mydata=1:4
    tA=[]; tP=[]; tS=[]; tH=[];
    load(datalist{mydata})
    for i =1:NB(mydata)
        myHI = ydata{1,i};
        myHI = 1-myHI(fpt_idxs(i):eol_idxs(i))';

        actRUL=actRUL_all{1, mydata, i};
        m=length(actRUL);
        p1=predRUL_all{1, mydata, i}(:,1);  s1=sRUL_all{1, mydata, i}(:,1); %single EUKF
        p2=predRUL_all{2, mydata, i}(:,1);  s2=sRUL_all{2, mydata, i}(:,1); %single GPR
        p3=predRUL_all{3, mydata, i}(:,1);  s3=sRUL_all{3, mydata, i}(:,1); %single LSTM
        [p4, s4] = get_ensemble(predRUL_all{1, mydata, i}, sRUL_all{1, mydata, i}, 0); % EUKF only ensemble
        [p5, s5] = get_ensemble(predRUL_all{3, mydata, i}, sRUL_all{3, mydata, i}, 0); % LSTM only ensemble

        AllP=[p4,p2,p5];
        AllS=[s4,s2,p5];
        pnan_idx = isnan(AllP);
        % no weights
        [p6, s6] = get_ensemble(AllP, AllS, 0);

        % constant CW model
        [p7, s7] = get_ensemble(AllP,AllS, cw_wts.*ones(m,3));

        %Step model SW
        gidx1 = find(myHI>0.08,2);
        gidx2 = find(myHI>0.14,2);
        gidx1 = gidx1(2);
        if ~isempty(gidx2)
            gidx2 = gidx2(2);
        else
            gidx2=m;
        end

        [p81, s81] = get_ensemble(AllP(1:gidx1-1,:),AllS(1:gidx1-1,:), sw_wts1.*ones(m,3));
        [p82, s82] = get_ensemble(AllP(gidx1:gidx2-1,:),AllS(gidx1:gidx2-1,:), sw_wts2.*ones(m,3));
        [p83, s83] = get_ensemble(AllP(gidx2:end,:),AllS(gidx2:end,:), sw_wts3.*ones(m,3));
        p8 = [p81; p82; p83];
        s8 = [s81; s82; s83];

        Pnet = [p1,p2,p3,p4,p5,p6,p7,p8];
        Snet = [s1,s2,s3,s4,s5,s6,s7,s8];

        tA=cat(1,tA,actRUL);
        tP=cat(1,tP,Pnet);
        tS=cat(1,tS,Snet);
        tH=cat(1,tH,myHI(mystart:end,:));

        % Plot RUL for all batteries-> uncomment below
        if mydata==2 && i==7  % plotting one test battery
         plot_rul
        end

        
        % storing all the data
%         FinalP{mydata,i}=Pnet; FinalS{mydata,i}=Snet; FinalA{mydata,i} = actRUL;
    end

     for j=1:8  % for all models and ensembles
        [netRMSE(mydata,j),netRMSEwt(mydata,j),netalphaacc(mydata,j),netmybeta(mydata,j),netmyPEP(mydata,j),netmyNLL(mydata,j)]=get_postprocess(tA,tP(:,j),tS(:,j));
         % nanp(mydata,j)=sum(isnan(tP(:,j)))/m*100; % calculate the number
         % of NaN entries
     end
      
end

%% Postprocess
% plot the reliability curve: Note that since this is a single run we only
% get a single curve. In the paper we did 5 iterations of the entire
% algorithm

modelslist = {'1-EUKF', '1-GPR', '1-LSTM', 'En-EUKF', 'En-LSTM','En-all' , 'DIEn', 'DSDEn'};
% color set from colorbrewer2.org
newcolors = {'#1b9e77','#d95f02','#7570b3','#e7298a','#66a61e','#e6ab02','#a6761d', '#666666'};

expected_alpha=linspace(1e-100,0.99999,25); % expected alpha = 1-Confidence level
% this alpha is different from alpha accuracy
for j=1:length(expected_alpha)
for i=1:8 % for all the models
    ObservedCI(j,i)=get_CI(tA,tP(:,i),tS(:,i), expected_alpha(j));
end
end

model_plot_selection = [1,2,3,4,8]; % enter models number from 1 to 8
expectedCI=(1-expected_alpha)*100;

figure()
hold all
for i=1:length(model_plot_selection)
    plot(expectedCI,ObservedCI(:,model_plot_selection(i)),'-','linewidth',2)
end
plot([0,100], [0,100], '--k', 'linewidth',2)
set(gca,'fontsize',18)
set(gcf, 'color','w')
legend_list = [modelslist(model_plot_selection), 'True'];
legend(legend_list, 'location', 'northwest')
xlabel('Expected Confidence')
ylabel('Observed Confidence')
colororder(newcolors)

