% clear all
% close all
clc
listSub = getScoredDatasets;
%% Load data & baseline

allSubTF = {};


for idx_sub = 1 : length(listSub)
    
    sub = listSub{idx_sub};
    
    load ([initPath.Exp '\data\' sub '\exp\' sub '_preprocessed_continuous.mat'])%from preprocessing.m
    load ([initPath.Exp '\data\' sub '\exp\' sub '_trlScored.mat'])%from Analysis_sleep.m

    
    trl_corrected = trl;
    trl_corrected(:,1:2) = trl(:,1:2) + 0.44*data.fsample; %from delay computation with oscilloscope
    
    disp (['loading ' sub ' dataset'])
    
    cfg = [];
    cfg.trl      = trl_corrected(find(trl_corrected(:,5) == 2 | trl_corrected(:,5) == 3),1:3);
    data_epoched = ft_redefinetrial(cfg, data);
    
    cfg = [];
    cfg.channel        = [1:6];
    cfg.resamplefs      = 100;
    cfg.demean          = 'yes';
    data_epoched = ft_resampledata(cfg, data_epoched);
    
    data_epoched.trialinfo = trl_corrected(find(trl_corrected(:,5) == 2 | trl_corrected(:,5) == 3),4);
     
    % NREM up vs down and all

    foi = 5:0.5:30; % 0.1 Hz steps
    toi = -1:0.01:3; % 0.1 s steps
    
    %asso
    cfg = [];
    
    cfg.method     = 'mtmconvol';
    cfg.pad        = 'nextpow2';
    cfg.taper      = 'hanning';
    cfg.foi        = foi;
    cfg.toi        = toi;
    cfg.t_ftimwin  = 5./cfg.foi;
    cfg.tapsmofrq  = 0.4 *cfg.foi;   
    cfg.keeptrials = 'no';
    cfg.trials     = find(data_epoched.trialinfo(:,1)==1);
    timelock_data  = ft_freqanalysis(cfg, data_epoched);
    allSubTF.nbTrl(idx_sub,1) =  length(cfg.trials);
    
    cfg = [];
    cfg.baseline     = [-0.3 -0.1] ;
    cfg.baselinetype = 'relchange';
    timelock_data    = ft_freqbaseline(cfg, timelock_data);
    
    timelock_data.cfg        =[];
    timelock_data.freq       = foi;
    allSubTF.react{idx_sub}= timelock_data;
    
    %not reqct
    cfg = [];
    cfg.method     = 'mtmconvol';
    cfg.pad        = 'nextpow2';
    cfg.taper      = 'hanning';
    cfg.foi        = foi; % 0.1 Hz steps
    cfg.toi        = toi; % 0.1 s steps
    cfg.t_ftimwin  = 5./cfg.foi;
    cfg.tapsmofrq  = 0.4 *cfg.foi;    
    cfg.keeptrials = 'no';
    cfg.trials     = find(data_epoched.trialinfo(:,1)==0 );
    timelock_data  = ft_freqanalysis(cfg, data_epoched);
    
    allSubTF.nbTrl(idx_sub,2) =  length(cfg.trials);
     
    cfg = [];
    cfg.baseline     = [-0.3 -0.1] ;
    cfg.baselinetype = 'relchange';
    timelock_data    = ft_freqbaseline(cfg, timelock_data);
    
    timelock_data.cfg        =[];
    timelock_data.freq       = foi;
    allSubTF.notReact{idx_sub}= timelock_data;
    
    %All
    cfg = [];
    cfg.method     = 'mtmconvol';
    cfg.pad        = 'nextpow2';
    cfg.taper      = 'hanning';
    cfg.foi        = foi; % 0.1 Hz steps
    cfg.toi        = toi; % 0.1 s steps
    cfg.t_ftimwin  = 5./cfg.foi;
    cfg.tapsmofrq  = 0.4 *cfg.foi;   
    cfg.keeptrials = 'no';
    cfg.trials     = find(data_epoched.trialinfo(:,1)==1 | data_epoched.trialinfo(:,1)==0);
    timelock_data  = ft_freqanalysis(cfg, data_epoched);
    
    allSubTF.nbTrl(idx_sub,3) =  length(cfg.trials);
    
    cfg = [];
    cfg.baseline     = [-0.3 -0.1] ;
    cfg.baselinetype = 'relchange';
    timelock_data    = ft_freqbaseline(cfg, timelock_data);

    timelock_data.cfg        = [];
    timelock_data.freq       = foi; 
    allSubTF.all{idx_sub}= timelock_data;

    allSubTF.zero{idx_sub} = allSubTF.all{idx_sub};
    allSubTF.zero{idx_sub}.powspctrm = zeros(size(allSubTF.all{idx_sub}.powspctrm,1),size(allSubTF.all{idx_sub}.powspctrm,2),size(allSubTF.all{idx_sub}.powspctrm,3));
 

    cfg = [];
    cfg.parameter = 'powspctrm';
    cfg.operation = 'x1-x2';
    allSubTF.subtracted{idx_sub}= ft_math(cfg,allSubTF.react{idx_sub},allSubTF.notReact{idx_sub});
end


cfg = [];
grdAvgTF.react = ft_freqgrandaverage(cfg, allSubTF.react{:});
grdAvgTF.notReact = ft_freqgrandaverage(cfg, allSubTF.notReact{:});
grdAvgTF.all = ft_freqgrandaverage(cfg, allSubTF.all{:});
grdAvgTF.subtracted = ft_freqgrandaverage(cfg, allSubTF.subtracted{:});

%% Stat

% Comparison

load neighboursPerso.mat
cfg                     = [];
cfg.design(1,1:2*length(listSub))  = [ones(1,length(listSub)) 2*ones(1,length(listSub))];
cfg.design(2,1:2*length(listSub))  = [1:length(listSub) 1:length(listSub)];
cfg.ivar                = 1; 
cfg.uvar                = 2; 
cfg.method              = 'montecarlo';       
cfg.statistic           = 'ft_statfun_depsamplesT';
cfg.correctm            = 'cluster';
cfg.clusterstatistic    = 'maxsum'; 
cfg.minnbchan           = 0;              
cfg.avgoverchan         = 'yes';
cfg.neighbours          = neighbours_perso; 
cfg.alpha               = 0.025; 
cfg.clusteralpha        = 0.05;     
cfg.numrandomization    = 500;      
cfg.latency             = [0 2.5];

[statTF] = ft_freqstatistics(cfg,  allSubTF.react{:}, allSubTF.notReact{:});



% Froom ERP CBP
tfNegPeak = [];

for idx_sub = 1 : length(allSubERP.all)

    cfg = [];
    cfg.avgoverchan         = 'yes';
    cfg.latency             = [0 0.5];
    cfg.avgovertime         = 'yes';
    cfg.frequency           = [12 16];
    cfg.avgoverfreq         = 'yes';

    tmp = ft_selectdata(cfg,allSubTF.react{idx_sub});
    tfNegPeak(idx_sub,1) = tmp.powspctrm;

    tmp = ft_selectdata(cfg,allSubTF.notReact{idx_sub});
    tfNegPeak(idx_sub,2) = tmp.powspctrm;

    cfg.latency             = [1 1.6];
    cfg.avgovertime         = 'yes';
    cfg.frequency           = [12 16];
    cfg.avgoverfreq         = 'yes';

    tmp = ft_selectdata(cfg,allSubTF.react{idx_sub});
    tfNegPeak(idx_sub,3) = tmp.powspctrm;

    tmp = ft_selectdata(cfg,allSubTF.notReact{idx_sub});
    tfNegPeak(idx_sub,4) = tmp.powspctrm;

    
end

csvwrite([initPath.Exp '\data\group\OL\tfEtractedAgains0.csv'],tfNegPeak)



%correlation
% compute statistics with correlationT

% TMR index both early and late with TFR relevant - TFR irrelevant
% Correlation between SO PAC and behaviour
% TMR index both early and late with TFR relevant - TFR irrelevant

[TMRindex , reactGains , notReactGains] = getBehav();

design=[];
design(1,1:length(listSub))          = TMRindex;

cfg = [];
cfg.statistic           = 'ft_statfun_correlationT';
cfg.method              = 'montecarlo';
cfg.correctm            = 'cluster';
cfg.clusterstatistic    = 'maxsum'; 
cfg.neighbours          = neighbours_perso; 
cfg.minnbchan           = 0;              
cfg.alpha               = 0.025; 
cfg.clusteralpha        = 0.05;     
cfg.latency             = [0 2.5];
cfg.frequency           = [5 30];
cfg.numrandomization    = 500;
cfg.design              = design;
cfg.ivar                = 1;
cfg.avgoverchan         = 'yes';
statCor= ft_freqstatistics(cfg, allSubTF.subtracted{:});


cfg = [];
cfg.latency             = [0 2.5];
cfg.avgoverchan         = 'yes';
tmpTF = ft_selectdata(cfg,grdAvgTF.subtracted);

tmpTF.mask= statCorAll.mask;

cfg = [];
cfg.layout        = [initPath.FieldTrip '/template/layout/EEG1020.lay'];
cfg.parameter     = 'rho';
cfg.maskparameter = 'mask';
cfg.maskalpha = 0.7;
cfg.xlim = [0 2.5];
cfg.zlim = [-0.5 0.5];
figure;ft_multiplotTFR(cfg, statCorAll)
figure;ft_singleplotTFR(cfg, tmpTF)

hold on
yyaxis right
ylim([-2.1 2.1])
plot(tmpAll.time,tmpAll.avg,'-k')




% Froom ERP CBP
tfNegPeak = [];

for idx_sub = 1 : length(allSubTF.react)

    cfg = [];
    cfg.avgoverchan         = 'yes';
    cfg.avgovertime         = 'yes';
    cfg.avgoverfreq         = 'yes';

    cfg.latency             = [0.35 1];
    cfg.frequency           = [12 16];
    tmp = ft_selectdata(cfg,allSubTF.react{idx_sub});
    
    tfNegPeak(idx_sub,1) = tmp.powspctrm;

    tmp = ft_selectdata(cfg,allSubTF.notReact{idx_sub});
    tfNegPeak(idx_sub,2) = tmp.powspctrm;

    tmp = ft_selectdata(cfg,allSubTF.subtracted{idx_sub});
    tfNegPeak(idx_sub,3) = tmp.powspctrm;


    
end

csvwrite([initPath.Exp '\data\group\OL\TMRvsClusterSubtraction.csv'],tfNegPeak)

