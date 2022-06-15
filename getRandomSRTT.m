%% get PVT from log file
% Judith Nicolas
% Created 2020 at KU Leuven

function [outPutRT,outPutAcc]= getRandomSRTT(listSub,dirOutput,dirInput,nbSession,keyPresses )

%     fileMed = fopen([dirOutput 'medianRandomSRTT.csv'],'w');
    fileMed = fopen([dirOutput 'meanRandomSRTT.csv'],'w');
    fprintf(fileMed,'%s; %s; %s; %s; %s\n', 'Sub' , 'Session','Block','RT','Accuracy');
    fileInd = fopen([dirOutput 'RandomSRTT.csv'],'w');
    fprintf(fileInd,'%s; %s; %s; %s; %s; %s; %s; %s; %s\n', 'Sub' , 'Session','Block','Cue','timeCue','Rep','timeRep','RT','Acc');

    clc
    for idx_sub = 1 : length(listSub)
        sub = listSub{idx_sub};
        fprintf('%s\n',sub)

        behavFile = [dirInput sub '\behav\MSL_openLoop_' sub '.txt'];

        fid=fopen(behavFile);
        aline = fread(fid, 'char=>char');          % returns a single long string
        fclose(fid);

        aline(aline==uint8(sprintf('\r'))) = [];        % remove cariage return
        aline = tokenize(aline, uint8(sprintf('\n')));  % split on newline

        
        restLines=find(~cellfun(@isempty,regexp(aline, '.*rest.*')));
        aline(restLines)=[];        
        practiceLines=find(~cellfun(@isempty,regexp(aline, '.*Practice.*')));
        aline(practiceLines)=[];
        lines= find(~cellfun(@isempty,regexp(aline, '.*RC-.*')));
        if length(lines)/2> nbSession
            warning(['check logfile because more than 2 random SRTT have been launched\n Particpant to check: ' sub])
            %depends on design, suggestion is to have a raw log file and a
            %corrected logfile formated as if everything went smotth during
            %data acquisition 
        end
        
        lines= reshape(lines,2,length(lines)/2);
        
        nbBlock = (lines(2,1)-lines(1,1)-1)/2/keyPresses;

        indRT=nan(keyPresses ,nbBlock,nbSession);
        
        if idx_sub==1
            outPutRT= zeros(length(listSub),nbBlock,nbSession)    ;
            outPutAcc= zeros(length(listSub),nbBlock,nbSession)    ;
        end
        
        for idx_sess= 1:nbSession
            cue = aline(lines(1,idx_sess)+1:2:lines(2,idx_sess)-1);
            rep = aline(lines(1,idx_sess)+2:2:lines(2,idx_sess)-1);
            counter=1;

            for idx_block = 1 : nbBlock
               
                for idx_key = 1 : keyPresses
                    t0=cue{counter};t0=strsplit(t0,' ');
                    t1=rep{counter};t1=strsplit(t1,' ');
                    
                    if idx_sess==1
                        Session = 'preNap';
                    elseif idx_sess==2
                        Session = 'postNight';
                    end
                    
                    if strcmp(t0{2},t1{2})
                        indRT(idx_key,idx_block,idx_sess)=(str2num(t1{end})-str2num(t0{end}))*1000;
                        corr=1;
                    else
                        corr=0;
                    end
                    
                    fprintf(fileInd,'%s; %s; %i; %s; %4.4f; %s; %4.4f; %4.4f; %i\n', ...
                        sub, Session,idx_block,t0{2},str2num(t0{end}),t1{2},str2num(t1{end}),(str2num(t1{end})-str2num(t0{end}))*1000,corr);
                    counter=counter+1;
                end
                
                acc = 100-sum(isnan(indRT(:,idx_block,idx_sess)))/64*100;
                fprintf(fileMed,'%s; %i; %i; %1.4f; %3.1f\n',sub, idx_sess,idx_block,nanmean(indRT(:,idx_block,idx_sess)),acc);
                outPutRT(idx_sub,idx_block,idx_sess)= nanmedian(indRT(:,idx_block,idx_sess));
                outPutAcc(idx_sub,idx_block,idx_sess)= acc;
            end
        end
    end
    fclose(fileMed);
    fclose(fileInd);
end