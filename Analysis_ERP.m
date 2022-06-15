% clear all
% close all
clc


listSub = getScoredDatasets;


%% Load data & baseline

allSubERP = {};

for idx_sub = 1 : length(listSub)
    
    sub = listSub{idx_sub};
    load ([initPath.Exp '\data\' sub '\exp\' sub '_preprocessed_continuous.mat'])%from preprocessing.m
    load ([initPath.Exp '\data\' sub '\exp\' sub '_trlScored.mat'])%from Analysis_sleep.m

    
    trl_corrected = trl;
    trl_corrected(:,1:2) = trl(:,1:2) + 0.44*data.fsample;%from delay computation with oscilloscope
    
    trl_corrected(:,2) = trl_corrected(:,2) + 1*data.fsample;

    cfg = [];
    cfg.trl      = trl_corrected(find(trl_corrected(:,5) == 2 | trl_corrected(:,5) == 3),1:3);
    data_epoched = ft_redefinetrial(cfg, data);
    
    cfg = [];
    cfg.resamplefs      = 100;
    data_epoched = ft_resampledata(cfg, data_epoched);
    data_epoched.trialinfo = trl_corrected(find(trl_corrected(:,5) == 2 | trl_corrected(:,5) == 3),4);
     

    
    %NREM react vs not react and all
    cfg = [];
    cfg.baselinewindow = [-0.3 -0.1];
    cfg.demean         = 'yes';
    data_epoched = ft_preprocessing(cfg, data_epoched);

    %associated
    cfg = [];
    cfg.keeptrials = 'no';
    cfg.trials     = find(data_epoched.trialinfo(:,1) == 1);
    timelock_data  = ft_timelockanalysis(cfg, data_epoched);
    allSubERP.nbTrl(idx_sub,1) =  length(cfg.trials);

    timelock_data.cfg=[];
    allSubERP.react{idx_sub}= timelock_data;
    
    % unassociated
    cfg = [];
    cfg.keeptrials = 'no';
    cfg.trials     = find(data_epoched.trialinfo(:,1)== 0 );
    timelock_data  = ft_timelockanalysis(cfg, data_epoched);
    allSubERP.nbTrl(idx_sub,2) =  length(cfg.trials);

    timelock_data.cfg=[];
    allSubERP.notReact{idx_sub}= timelock_data;

    % all
    cfg = [];
    cfg.keeptrials = 'no';
    cfg.trials     =find(data_epoched.trialinfo(:,1)== 0  |  data_epoched.trialinfo(:,1)== 1  );
    timelock_data  = ft_timelockanalysis(cfg, data_epoched);
    allSubERP.nbTrl(idx_sub,3) =  length(cfg.trials);
 
    timelock_data.cfg=[];
    allSubERP.all{idx_sub} = timelock_data;
    allSubERP.zero{idx_sub} = allSubERP.all{idx_sub};
    allSubERP.zero{idx_sub}.avg = zeros(size(allSubERP.all{idx_sub}.avg,1),size(allSubERP.all{idx_sub}.avg,2));

end

cfg = [];
% cfg.keepindividual = 'yes';%for effect size computation
grdAvgERP.react = ft_timelockgrandaverage(cfg, allSubERP.react{:});
grdAvgERP.notReact = ft_timelockgrandaverage(cfg, allSubERP.notReact{:});
grdAvgERP.all = ft_timelockgrandaverage(cfg, allSubERP.all{:});
grdAvgERP.zero = ft_timelockgrandaverage(cfg, allSubERP.zero{:});
grdAvgERP.early.all = ft_timelockgrandaverage(cfg, allSubERP.early.all{:});
grdAvgERP.late.all = ft_timelockgrandaverage(cfg, allSubERP.late.all{:});
grdAvgERP.early.react = ft_timelockgrandaverage(cfg, allSubERP.early.react{:});
grdAvgERP.late.react = ft_timelockgrandaverage(cfg, allSubERP.late.react{:});
grdAvgERP.early.notReact = ft_timelockgrandaverage(cfg, allSubERP.early.notReact{:});
grdAvgERP.late.notReact = ft_timelockgrandaverage(cfg, allSubERP.late.notReact{:});



%% Plot all ERP

cfg = [];
cfg.channel= 'all';
cfg.xlim = [-0.31 2.5];
cfg.ylim = [-11 5.1];
figure
cfg.color = 'k';
h_plot_erf(cfg,allSubERP.all');

% From cluster based analysis
xline(0.44,'Color',[227, 227, 227]/255);xline(0.63,'Color',[227, 227, 227]/255);xline(0,'Color',[227, 227, 227]/255);xline(-0.3,'Color',[227, 227, 227]/255)
xline(0,'g','Color',[227, 227, 227]/255);yline(5,'Color',[227, 227, 227]/255);yline(-5,'Color',[227, 227, 227]/255)


%% Plot two conditions ERP


cfg = [];
cfg.channel= allSubERP.all{1}.label{idx_channel};%'all'
cfg.xlim = [-0.31 2.5];
cfg.ylim = [-11 5.1];
figure

cfg.color = 'm';
h_plot_erf(cfg,allSubERP.react')
cfg.color = 'k';
h_plot_erf(cfg,allSubERP.notReact');hold on

xline(0.44,'Color',[227, 227, 227]/255);xline(0.63,'Color',[227, 227, 227]/255);xline(0,'Color',[227, 227, 227]/255);xline(-0.3,'Color',[227, 227, 227]/255)
xline(0,'g','Color',[227, 227, 227]/255);yline(5,'Color',[227, 227, 227]/255);yline(-5,'Color',[227, 227, 227]/255)


%% Plots per channel

for idx_channel = 1 : length(allSubERP.all{1}.label)
    
    cfg = [];
    cfg.channel= allSubERP.all{1}.label{idx_channel};%'all'
    cfg.xlim = [-0.31 2.5];
    cfg.ylim = [-11 5.1];
    figure
    cfg.color = 'k';
    h_plot_erf(cfg,allSubERP.all');hold on
    
    xline(0.44,'Color',[227, 227, 227]/255);xline(0.63,'Color',[227, 227, 227]/255);xline(0,'Color',[227, 227, 227]/255);xline(-0.3,'Color',[227, 227, 227]/255)
    xline(0,'g','Color',[227, 227, 227]/255);yline(5,'Color',[227, 227, 227]/255);yline(-5,'Color',[227, 227, 227]/255)
    
    hold off

    
    figure
    cfg.color = 'm';
    h_plot_erf(cfg,allSubERP.react')
    cfg.color = 'k';
    h_plot_erf(cfg,allSubERP.notReact');hold on
    
    xline(0.44,'Color',[227, 227, 227]/255);xline(0.63,'Color',[227, 227, 227]/255);xline(0,'Color',[227, 227, 227]/255);xline(-0.3,'Color',[227, 227, 227]/255)
    xline(0,'g','Color',[227, 227, 227]/255);yline(5,'Color',[227, 227, 227]/255);yline(-5,'Color',[227, 227, 227]/255)
    
    hold off
end

%% Stat

load neighboursPerso.mat

cfg                     = [];
cfg.design(1,1:2*(length(listSub)))  = [ones(1,(length(listSub))) 2*ones(1,(length(listSub)))];
cfg.design(2,1:2*(length(listSub)))  = [1:(length(listSub)) 1:(length(listSub))];
cfg.ivar                = 1; % the 1st row in cfg.design contains the independent variable
cfg.uvar                = 2; % the 2nd row in cfg.design contains the subject number
cfg.method              = 'montecarlo';       
cfg.statistic           = 'ft_statfun_depsamplesT';
cfg.correctm            = 'cluster';
cfg.clusterstatistic    = 'maxsum'; 
cfg.minnbchan           = 0;              
cfg.avgoverchan         = 'yes';
cfg.neighbours          = neighbours_perso; 
cfg.tail                = 0;                    
cfg.clustertail         = 0;
cfg.alpha               = 0.025; 
cfg.clusteralpha        = 0.05;     
cfg.numrandomization    = 500;      % number of draws from the permutation distribution
cfg.latency             = [0 2.5];

[stat] = ft_timelockstatistics(cfg,  allSubERP.all{:}, allSubERP.zero{:});


erpNegPeak = [];

for idx_sub = 1 : length(allSubERP.all)

    cfg = [];
    cfg.avgoverchan         = 'yes';
    cfg.latency             = [0.44 0.63];% From cluster based analysis
    cfg.avgovertime         = 'yes';
    tmp = ft_selectdata(cfg,allSubERP.react{idx_sub});

    erpNegPeak(idx_sub,1) = tmp.avg;

    tmp = ft_selectdata(cfg,allSubERP.notReact{idx_sub});
    erpNegPeak(idx_sub,2) = tmp.avg;
  
end

csvwrite([initPath.Exp '\data\group\OL\erpNegPeak.csv'],erpNegPeak)%for amplitude comparison (in statsDetection.R)

%Effect size computation
cfg = [];
cfg.channel = 'all';
cfg.latency = [0.44 0.63];
cfg.avgoverchan = 'yes';  
cfg.avgovertime = 'yes';  
all = ft_selectdata(cfg, grdAvgERP.all);
zero  = ft_selectdata(cfg, grdAvgERP.zero);

cfg = [];
cfg.method = 'analytic';
cfg.statistic = 'cohensd'; % see FT_STATFUN_COHENSD
cfg.ivar = 1;
cfg.uvar = 2;
cfg.design(1,1:2*(length(listSub)))  = [ones(1,(length(listSub))) 2*ones(1,(length(listSub)))];
cfg.design(2,1:2*(length(listSub)))  = [1:(length(listSub)) 1:(length(listSub))];
effect_roiTrough = ft_timelockstatistics(cfg, all, zero);
disp(effect_roiTrough)


