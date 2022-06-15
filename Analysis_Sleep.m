%% TMR accuracy
% Judith Nicolas
% Created 2020 at KU Leuven
% Inspired from Genevieve Albouy



%% Incorporate score
pathIn = path.Exp;

[listSub,listSubEEG,listSubBehav] = getScoredDatasets;

fileSleepDur = fopen([path.Exp 'data\group\sleepDuration.csv'],'w');
fprintf(fileSleepDur,'%s; %s; %s; %s\n', 'Sub' , 'Stage','DV','Percentage');

fileSleepLat = fopen([path.Exp 'data\group\sleepLatency.csv'],'w');
fprintf(fileSleepLat,'%s; %s; %s; %s; %s\n', 'Sub' , 'S1','S2', 'S3', 'REM');

fileSleepArousal = fopen([path.Exp 'data\group\sleepArousal.csv'],'w');
fprintf(fileSleepArousal,'%s; %s; %s; %s\n', 'Sub' , 'Nb','perHour','Duration');

fileStimEff= fopen([path.Exp 'data\group\stimEfficiency.csv'],'w');
fprintf(fileStimEff,'%s; %s; %s; %s; %s\n', 'Sub' , 'type','Stage','DV','Percentage'); 

for idx_sub = 1 : length(listSub)
    
    sub = listSub{idx_sub};
    fasstFile     = [path.Exp '\data\OL_CA\' sub '\exp\' sub '.mat'];
    load(fasstFile)
    
    
    if ~strcmp(sub,'OL_22')
    
        scoreFile     = [path.Exp '\data\OL_CA\' sub '\exp\FASST\' sub '_ExtraitEvts.csv'];%included in data directories
        score = tdfread(scoreFile,';');
        scoreSleep=[];
        arousal=[];
        counterStade = 1;
        counterArousal = 1;
        for idx = 1 : length(score.Groupe)

            if strcmp(score.Groupe(idx,1),'S')
                scoreSleep (counterStade,1) = score.Point_0x28Sec0xC9ch0x29(idx);
                scoreSleep (counterStade,2) = score.Point_0x28Sec0xC9ch0x29(idx)+score.Dur0xE9e_0x28Points0x29(idx)-1;
                scoreSleep (counterStade,3) = 0;
                scoreSleep (counterStade,4) = score.Stade(idx);
                counterStade = counterStade +1;
            elseif strcmp(score.Groupe(idx,1),'M')
                arousal (counterArousal,1) = score.Point_0x28Sec0xC9ch0x29(idx);
                arousal (counterArousal,2) = score.Dur0xE9e_0x28Points0x29(idx);
                counterArousal = counterArousal +1;
            end

        end

        scoreSleep(1,1) = 1;
        scoreSleep(end,2) = D.Nsamples-1;
    
    else
        
        counterStade = 1;
        scoreSleep=[];

        for idx = 1 : length(D.other.CRC.score{1})


                scoreSleep (counterStade,1) = (idx-1)*(D.Fsample*D.other.CRC.score{3});
                scoreSleep (counterStade,2) = (idx*(D.Fsample*D.other.CRC.score{3}))-1;
                scoreSleep (counterStade,3) = 0;
                scoreSleep (counterStade,4) = D.other.CRC.score{1}(idx);
                counterStade = counterStade +1;

        end

        scoreSleep(1,1) = 1;
        scoreSleep(end,2) = D.Nsamples-1;
    
        
    end
    save([path.Exp '\data\' sub '\exp\' sub '_scored_epoch.mat'],'scoreSleep') % to be used in processed_continuous for detection

    D.other.CRC.score=[];
    D.other.CRC.score{1,1}= scoreSleep(:,4)' ;
    D.other.CRC.score(2,1)= {'Sonia'};
    D.other.CRC.score(3,1)= {30};
    D.other.CRC.score{4,1} = [0.001 D.Nsamples/D.Fsample];
    D.other.CRC.score{5,1} = []; D.other.CRC.score{7,1} = []; D.other.CRC.score{8,1} = []; 
    if isempty(arousal)
        D.other.CRC.score{6,1}=[];
    else
        D.other.CRC.score{6,1}=[arousal(:,1)/D.Fsample arousal(:,1)/D.Fsample+arousal(:,2)/D.Fsample];
    end
    
    
    load ( [path.Exp '\data\' sub '\exp\' sub '_trl.mat']);%from get_trl.m
    
    selTrigger  = strcmp({D.trials.events.type}, {'Trigger'});
    D.trials.events(selTrigger) = [];
    tmp = D.trials.events(end);

    for idx_trig = 1 : length(trl)
        
        if trl(idx_trig,4)==1
            D.trials.events(idx_trig+3).type     = 'Stim';
        elseif trl(idx_trig,4)==0
            D.trials.events(idx_trig+3).type     = 'Random';
        end
        
        D.trials.events(idx_trig+3).time     = (trl(idx_trig)+2*D.Fsample)/D.Fsample;
        D.trials.events(idx_trig+3).duration = 0;
        D.trials.events(idx_trig+3).offset   = 0;
        
        D.trials.events(idx_trig+3).value = 479;

    end

    D.trials.events(end)=tmp;
    D.other.CRC.goodevents (length(D.trials.events)+1:length(tmp)) = [];
    save(fasstFile, 'D')
    
    
    stimStage = zeros(size(trl,1),2); 
    for i = 1 : size(trl,1)
        clear epoch
        epoch = ceil((trl(i,1)+abs(trl(i,3)))/(D.other.CRC.score{3}*D.Fsample));
        stimStage(i,1) = D.other.CRC.score{1,1}(1,epoch);
        stimStage(i,2) = trl(i,4);
    end

    trl(:,5)= stimStage(:,1);
    save ([path.Exp '\data\OL_CA\' sub '\exp\' sub '_trl_epoch.mat'],'trl')
    
    WakeCues            = nnz(stimStage(:,1) == 0);
    S1Cues              = nnz(stimStage(:,1) == 1);
    S2Cues              = nnz(stimStage(:,1) == 2);
    S3Cues              = nnz(stimStage(:,1) == 3);
    REMCues             = nnz(stimStage(:,1) == 5);
    StNDCues            = nnz(stimStage(:,1) == 9);
    TotalAccuracyCues   = S2Cues+S3Cues;
    
    
    WakeStim            = nnz(stimStage(:,1) == 0 & stimStage(:,2) == 1 );%stim = associated
    S1Stim              = nnz(stimStage(:,1) == 1 & stimStage(:,2) == 1 );
    S2Stim              = nnz(stimStage(:,1) == 2 & stimStage(:,2) == 1 );
    S3Stim              = nnz(stimStage(:,1) == 3 & stimStage(:,2) == 1 );
    REMStim             = nnz(stimStage(:,1) == 5 & stimStage(:,2) == 1 );
    TotalAccuracyStim   = S2Stim+S3Stim;

    WakeRandom          = nnz(stimStage(:,1) == 0 & stimStage(:,2) == 0 );%random = unassociated
    S1Random            = nnz(stimStage(:,1) == 1 & stimStage(:,2) == 0 );
    S2Random            = nnz(stimStage(:,1) == 2 & stimStage(:,2) == 0 );
    S3Random            = nnz(stimStage(:,1) == 3 & stimStage(:,2) == 0 );
    REMRandom           = nnz(stimStage(:,1) == 5 & stimStage(:,2) == 0 );
    TotalAccuracyRandom = S2Random+S3Random;

    totCues= size(trl,1);
    totStim= nnz(stimStage(:,2) == 1 );
    totRandom= nnz(stimStage(:,2) == 0 );

    %% Extract sleep characteristics
    % Create variables
    TRS = []; % Time allowed to sleep (Between CDL (close door light) et ODL (Open door light))
    TPS = []; % Time of the sleeping period
    TST = []; % Total Sleep Period
    LatS1 = []; % S1 Latency
    LatS2 = []; % S2 Latency
    LatREM = []; % REM Latency
    W = []; % Time awake
    S1 = []; % Time in S1
    S2 = []; % Time in S2
    S3 = []; % Time in S3
    REM = []; % Time in REM
    MT = []; % Time in MT
    SEff = []; % Sleep Efficiency
    S1Eff = []; % S1 Efficiency
    S2Eff = [];% S2 Efficiency
    S3Eff = [];% S3 Efficiency
    S4Eff = [];% S4 Efficiency
    REMEff = [];% REM Efficiency
    nbar = []; % Number of Arousal
    Arhour = []; % Number of Arousal per hour
    Ardur = []; % Mean Arousal duration
    
%     compute sleep metrics
%     Determine ODL&CDL
    if strcmp(sub, 'OL_15') |  strcmp(sub, 'OL_22') |  strcmp(sub, 'OL_CA_01') 
        doorLightMkr = [0 D.Nsamples/D.Fsample];
        
    elseif strcmp(sub, 'OL_20') | strcmp(sub, 'OL_21')
        eventfile     = [path.Exp '\data\OL_CA\' sub '\exp\' sub '.vmrk'];
        event = ft_read_event(eventfile);        
        selCDL  = strcmp({event.value}, {'cdl'});
        selODL  = strcmp({event.value}, {'odl'});
        doorLightMkr = [ event(selCDL).sample event(selODL).sample ]/D.Fsample;
    else
        doorLightMkr = [D.trials.events(strcmp({D.trials.events.type}, {'Comment'})).time];
    end
    
    Winsize = D.other.CRC.score{3,size(D.other.CRC.score,2)};
    
    %Time allowed to sleep
    TRS = doorLightMkr(2) - doorLightMkr(1);
        
    %Invalidation
    adapted = 1:length(D.other.CRC.score{1,size(D.other.CRC.score,2)});
    nottobescored = find(adapted < doorLightMkr(1)/Winsize | adapted > doorLightMkr(2)/Winsize);
    iisc = D.other.CRC.score{1,size(D.other.CRC.score,2)};
    iisc(nottobescored)=-1;
    
    Zero = find(iisc==0);
    One = find(iisc==1);
    Two = find(iisc==2);
    Three = find(iisc==3);
    Five = find(iisc==5);
    
    %Time of the sleeping period
    TPS = (max([Two Three Five])-1)*Winsize - (min([Two Three Five])-1)*Winsize;
    
    %Total Sleep Time
    TST = length([Two Three Five])*Winsize;
    
    %Lantency St1
    if length(One) == 0
        LatS1=nan;
    else
        LatS1 = (One(1)-1)*Winsize - doorLightMkr(1);
    end
    
    %Lantency St2
    if length(Two) == 0
        LatS2=nan;
    else
        LatS2 = (Two(1)-1)*Winsize - doorLightMkr(1);
    end
    
    %Lantency St3
    if length(Three) == 0
        LatS3=nan;
    else
        LatS3 = (Three(1)-1)*Winsize - doorLightMkr(1);
    end
    
    %Lantency REM
    if length(Five) == 0
        LatREM = nan;
    else
        LatREM = (Five(1)-1)*Winsize - doorLightMkr(1);
    end
    
    %Min & Percentage of W
    W = length([Zero])*Winsize;
    
    %Min & Percentage of S1
    S1 = length([One])*Winsize;
    
    %Min & Percentage of S2
    S2 = length([Two])*Winsize;
    
    %Min & Percentage of S3
    S3 = length([Three])*Winsize;
    
    %Min & Percentage of REM
    REM = length([Five])*Winsize;
    

    % Extract micro-arousals
    if isempty(D.other.CRC.score{6,1})
        nBar = 0;Arhour= 0; Ardur=0;
    else
        nBar = size(D.other.CRC.score{6,1},1);
        Arhour = nBar/(TST/60/60); %TST in hour
        Ardur = sum(D.other.CRC.score{6,1}(:,2)-D.other.CRC.score{6,1}(:,1)); %in seconds
    end
    sleepStats = {};
    sleepStats.caracteristics.duration.Opportunity = TRS;     fprintf(fileSleepDur,'%s; %s; %5.3f; %3.2f\n', sub , 'opportunity',TRS,TRS/TRS*100);
    sleepStats.caracteristics.duration.sleep       = TST;     fprintf(fileSleepDur,'%s; %s; %5.3f; %3.2f\n', sub , 'sleep',TST,TST/TRS*100);     
    sleepStats.caracteristics.duration.wake        = W;       fprintf(fileSleepDur,'%s; %s; %5.3f; %3.2f\n', sub , 'wake',W,W/TRS*100);
    sleepStats.caracteristics.duration.S1          = S1;      fprintf(fileSleepDur,'%s; %s; %5.3f; %3.2f\n', sub , 'S1',S1,S1/TRS*100);
    sleepStats.caracteristics.duration.S2          = S2;      fprintf(fileSleepDur,'%s; %s; %5.3f; %3.2f\n', sub , 'S2',S2,S2/TRS*100);
    sleepStats.caracteristics.duration.S3          = S3;      fprintf(fileSleepDur,'%s; %s; %5.3f; %3.2f\n', sub , 'S3',S3,S3/TRS*100);
    sleepStats.caracteristics.duration.REM         = REM;     fprintf(fileSleepDur,'%s; %s; %5.3f; %3.2f\n', sub , 'REM',REM,REM/TRS*100);
    sleepStats.caracteristics.Lat.S1               = LatS1;   
    sleepStats.caracteristics.Lat.S2               = LatS2;   
    sleepStats.caracteristics.Lat.S3               = LatS3;   
    sleepStats.caracteristics.Lat.REM              = LatREM;   
    sleepStats.caracteristics.arousal.number       = nBar;   
    sleepStats.caracteristics.arousal.perHour      = Arhour;  
    sleepStats.caracteristics.arousal.duration     = Ardur;   

    fprintf(fileSleepLat,'%s; %5.3f; %5.3f; %5.3f; %5.3f\n', sub , LatS1,LatS2, LatS3, LatREM);
    fprintf(fileSleepArousal,'%s; %i; %5.3f; %5.3f\n',sub, nBar,Arhour,Ardur);

    sleepStats.cues.all.nb             = totCues;           fprintf(fileStimEff,'%s; %s; %s; %i; %3.2f\n', sub , 'all','total',totCues,totCues/totCues*100); 
    sleepStats.cues.all.wake           = WakeCues;          fprintf(fileStimEff,'%s; %s; %s; %i; %3.2f\n', sub , 'all','wake',WakeCues,WakeCues/totCues*100);             
    sleepStats.cues.all.S1             = S1Cues;            fprintf(fileStimEff,'%s; %s; %s; %i; %3.2f\n', sub , 'all','S1',S1Cues,S1Cues/totCues*100);  
    sleepStats.cues.all.S2             = S2Cues;            fprintf(fileStimEff,'%s; %s; %s; %i; %3.2f\n', sub , 'all','S2',S2Cues,S2Cues/totCues*100);
    sleepStats.cues.all.S3             = S3Cues;            fprintf(fileStimEff,'%s; %s; %s; %i; %3.2f\n', sub , 'all','S3',S3Cues,S3Cues/totCues*100);
    sleepStats.cues.all.REM            = REMCues;           fprintf(fileStimEff,'%s; %s; %s; %i; %3.2f\n', sub , 'all','REM',REMCues,REMCues/totCues*100);   
    sleepStats.cues.all.NREM           = S2Cues+S3Cues;     fprintf(fileStimEff,'%s; %s; %s; %i; %3.2f\n', sub , 'all','NREM',S2Cues+S3Cues,(S2Cues+S3Cues)/totCues*100);   
    
    
    sleepStats.cues.stim.nb            = totStim;           fprintf(fileStimEff,'%s; %s; %s; %i; %3.2f\n', sub , 'stim','total',totStim,totStim/totCues*100);
    sleepStats.cues.stim.wake          = WakeStim;          fprintf(fileStimEff,'%s; %s; %s; %i; %3.2f\n', sub , 'stim','wake',WakeStim,WakeStim/totStim*100);
    sleepStats.cues.stim.S1            = S1Stim;            fprintf(fileStimEff,'%s; %s; %s; %i; %3.2f\n', sub , 'stim','S1',S1Stim,S1Stim/totStim*100);
    sleepStats.cues.stim.S2            = S2Stim;            fprintf(fileStimEff,'%s; %s; %s; %i; %3.2f\n', sub , 'stim','S2',S2Stim,S2Stim/totStim*100);
    sleepStats.cues.stim.S3            = S3Stim;            fprintf(fileStimEff,'%s; %s; %s; %i; %3.2f\n', sub , 'stim','S3',S3Stim,S3Stim/totStim*100);
    sleepStats.cues.stim.REM           = REMStim;           fprintf(fileStimEff,'%s; %s; %s; %i; %3.2f\n', sub , 'stim','REM',REMStim,REMStim/totStim*100);
    sleepStats.cues.stim.NREM          = S2Stim+S3Stim;     fprintf(fileStimEff,'%s; %s; %s; %i; %3.2f\n', sub , 'stim','NREM',S2Stim+S3Stim,(S2Stim+S3Stim)/totStim*100);
    
    
    sleepStats.cues.random.nb          = totRandom;         fprintf(fileStimEff,'%s; %s; %s; %i; %3.2f\n', sub , 'random','total',totRandom,totRandom/totCues*100);
    sleepStats.cues.random.wake        = WakeRandom;        fprintf(fileStimEff,'%s; %s; %s; %i; %3.2f\n', sub , 'random','wake',WakeRandom,WakeStim/totRandom*100);
    sleepStats.cues.random.S1          = S1Random;          fprintf(fileStimEff,'%s; %s; %s; %i; %3.2f\n', sub , 'random','S1',S1Random,S1Stim/totRandom*100);
    sleepStats.cues.random.S2          = S2Random;          fprintf(fileStimEff,'%s; %s; %s; %i; %3.2f\n', sub , 'random','S2',S2Random,S2Stim/totRandom*100);
    sleepStats.cues.random.S3          = S3Random;          fprintf(fileStimEff,'%s; %s; %s; %i; %3.2f\n', sub , 'random','S3',S3Random,S3Stim/totRandom*100);
    sleepStats.cues.random.REM         = REMRandom;         fprintf(fileStimEff,'%s; %s; %s; %i; %3.2f\n', sub , 'random','REM',REMRandom,REMStim/totRandom*100);
    sleepStats.cues.random.NREM        = S2Random+S3Random; fprintf(fileStimEff,'%s; %s; %s; %i; %3.2f\n', sub , 'random','NREM',S2Random+S3Random,(S2Random+S3Random)/totRandom*100);

    save( [path.Exp '\data\' sub '\exp\' sub '_sleepStats.mat'],'sleepStats')
end

