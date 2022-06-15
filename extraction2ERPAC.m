listSub = getScoredDatasets;


for idx_sub = 1 : length(listSub)
    
    sub = listSub{idx_sub};
    load([initPath.Exp '\data\' sub '\exp\' sub '_preprocessed_continuous.mat'])%from preprocessing.m
    load ([initPath.Exp '\data\' sub '\exp\' sub '_trlScored.mat'])%from Analysis_sleep.m
    
    trl_corrected = trl;
    trl_corrected(:,1:2) = trl(:,1:2) + 0.44*data.fsample; %from delay computation with oscilloscope
    
    disp (['loading ' sub ' dataset'])
    
    cfg = [];
    cfg.trl      = trl_corrected(find(trl_corrected(:,5) == 2 | trl_corrected(:,5) == 3),1:3);
    data_epoched = ft_redefinetrial(cfg, data);
    
    
    idx=find(ismember(trl(:,1),data_epoched.sampleinfo(:,1)));

    data_epoched.trialinfo= trl(idx,4:5);

    disp (['loading ' sub ' dataset'])
    
    cfg = [];
    cfg.channel        = [1:6];
    cfg.baselinewindow = [-0.3 -0.1];
    cfg.demean         = 'yes';
    data_epoched = ft_preprocessing(cfg, data_epoched);
    
    
    cfg = [];
    cfg.channel        = [1:6];
    cfg.avgoverchan    = 'yes';
    data_epoched = ft_selectdata(cfg, data_epoched);
    
    if idx_sub~=1
        cfg            = [];
        cfg.resamplefs = 500;
        data_epoched = ft_resampledata(cfg, data_epoched);
    end
        

    
    data_pac=[];
        
        for idx_trl = 1 :length(data_epoched.trial)
            
            data_pac = vertcat(data_pac,[data_epoched.trial{idx_trl}(1,:) data_epoched.trialinfo(idx_trl,:) idx_trl]);

        end
        
    

    dlmwrite([dir.Exp '\data\' sub '\exp\' sub '_ERpac_avgOverChan.txt'],data_pac)
    
end