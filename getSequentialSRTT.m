%% get PVT from log file
% Judith Nicolas
% Created 2020 at KU Leuven

function [outPutRT,outPutAcc,offLineGain]= getSequentialSRTT(listSub,dirOutput,dirInput,nbSession,keyPresses,sequence,listReact)

nbSequence=size(sequence,1);lengthSequence=size(sequence,2);
filetot = fopen([dirOutput 'sequentialSRTT.csv'],'w');
fprintf(filetot,'%s; %s; %s; %s; %s; %s; %s; %s; %s; %s; %s; %s; %s\n', 'Sub' , 'Session','Block','Sequence','Condition', 'OrdinalPos','Repetition','SeqinBlock','Cue','timeCue','Rep','timeRep','RT');
file1 = fopen([dirOutput 'meanSequentialSRTT.csv'],'w');
fprintf(file1,'%s; %s; %s; %s; %s; %s; %s\n', 'Sub' , 'Session','Block','Sequence', 'Condition','RT','Accuracy');
file2 = fopen([dirOutput 'offLineGain.csv'],'w');
fprintf(file2,'%s; %s; %s; %s; %s\n', 'Sub' , 'Sequence','Condition','Time','Gain');

clc
for idx_sub = 1:length(listSub)
    sub = listSub{idx_sub};
    
    behavFile = [dirInput sub '\behav\MSL_openLoop_' sub ];
    
    fid=fopen([behavFile '.txt']);
    load([behavFile '.mat'])
    aline = fread(fid, 'char=>char');          % returns a single long string
    fclose(fid);
    
    aline(aline==uint8(sprintf('\r'))) = [];        % remove cariage return
    aline = tokenize(aline, uint8(sprintf('\n')));  % split on newline
    
    
    restLines=find(~cellfun(@isempty,regexp(aline, '.*rest.*')));
    aline(restLines)=[];
    practiceLines=find(~cellfun(@isempty,regexp(aline, '.*Practice.*')));
    aline(practiceLines)=[];
    lines= find(~cellfun(@isempty,regexp(aline, '.*SL-.*')));
    if length(lines)/2> nbSession
        warning(['check logfile because more than 3 sequential SRTT have been launched Particpant to check: ' sub])
        %depends on design, suggestion is to have a raw log file and a
        %corrected logfile formated as if everything went smotth during
        %data acquisition
    end
    
    lines= reshape(lines,2,length(lines)/2);
    lines(1,:)=lines(1,:)+1;
    lines(2,:)=lines(2,:)-1;
    
    cue=[];rep=[];lengthBlock=[];
    for idx_sess = 1: nbSession
        cue = [cue;aline(lines(1,idx_sess):2:lines(2,idx_sess))'];
        rep = [rep;aline(lines(1,idx_sess)+1:2:lines(2,idx_sess))'];
        lengthBlock=[lengthBlock;length(aline(lines(1,idx_sess):2:lines(2,idx_sess)))/64];
    end
    nbBlock = length(cue)/keyPresses;
    indRT=nan(keyPresses/nbSequence ,nbBlock, nbSequence);
    
    cue = reshape(cue,keyPresses,nbBlock);
    rep = reshape(rep,keyPresses,nbBlock);
    
    if idx_sub==1
        outPutRT= zeros(length(listSub),nbBlock,nbSequence)    ;
        outPutAcc= zeros(length(listSub),nbBlock,nbSequence)    ;
        offLineGain= zeros(length(listSub),2,nbSequence)    ;
    end
    
    
    for idx_block=1 : nbBlock
        counterSeq1=1;
        counterSeq2=1;
        firstKey = cue{1,idx_block};firstKey=strsplit(firstKey,' ');
        firstKey = firstKey {2};
        for idx_key= 1 : keyPresses
            if ismember(idx_key, 1 :8 :keyPresses)
                counterOrd =0;
            end
            counterOrd = counterOrd+1;
            
            if ismember(idx_key, 1 :1 :8) | ismember(idx_key, 33 :1 :40)
                repet =1;
            elseif ismember(idx_key, 9 :1 :16) | ismember(idx_key, 41 :1 :48)
                repet =2;
            elseif ismember(idx_key, 17 :1 :24) | ismember(idx_key, 49 :1 :56)
                repet =3;
            elseif ismember(idx_key, 25 :1 :32)  | ismember(idx_key, 57 :1 :64)
                repet =4;
            end
            
            if idx_key<33
                SeqInBlock ='start';
            elseif idx_key>32
                SeqInBlock ='end';
            end
            
            t0=cue{idx_key,idx_block};t0=strsplit(t0,' ');
            t1=rep{idx_key,idx_block};t1=strsplit(t1,' ');
            
            if strcmp(firstKey,num2str(sequence(1,1)))
                if idx_key<33
                    counter = counterSeq1;
                    idx_seq = 1;
                    counterSeq1 = counterSeq1+1;
                else
                    counter = counterSeq2;
                    idx_seq = 2;
                    counterSeq2 = counterSeq2+1;
                end
            elseif strcmp(firstKey,num2str(sequence(2,1)))
                if idx_key<33
                    counter = counterSeq2;
                    idx_seq = 2;
                    counterSeq2 = counterSeq2+1;
                else
                    counter = counterSeq1;
                    idx_seq = 1;
                    counterSeq1 = counterSeq1+1;
                end
            end
            
            
            if idx_seq==1
                if listReact(idx_sub)==1
                    reactCond = 'react';
                else
                    reactCond = 'notReact';
                end
            elseif idx_seq==2
                if listReact(idx_sub)==1
                    reactCond = 'notReact';
                else
                    reactCond = 'react';
                end
            end
            if idx_block<lengthBlock+1
                Session = 'TrainingPreNap';
            elseif idx_block>lengthBlock(1)& idx_block<lengthBlock(1)+lengthBlock(2)+1
                Session = 'TestPreNap';
            elseif idx_block>lengthBlock(1)+lengthBlock(2) & idx_block<lengthBlock(1)+lengthBlock(2)+lengthBlock(3)+1
                Session = 'TestPostNap';
            elseif idx_block>sum(lengthBlock)-lengthBlock(4)
                Session = 'TestPostNight';
            end
            
            if strcmp(t0{2},t1{2})
                indRT(counter,idx_block,idx_seq)=(str2num(t1{end})-str2num(t0{end}))*1000;
            end
            fprintf(filetot,'%s; %s; %i; %i; %s; %i; %i; %s; %s; %4.4f; %s; %4.4f; %4.4f\n', ...
                sub, Session,idx_block,idx_seq,reactCond,counterOrd,repet,SeqInBlock,t0{2},str2num(t0{end}),t1{2},str2num(t1{end}),(str2num(t1{end})-str2num(t0{end}))*1000);

        end
        
        limInf=[];limSup=[];
        limInf = mean(indRT(:,idx_block,:),'all','omitnan')-3*std(indRT(:,idx_block,:),0,'all','omitnan');
        limSup = mean(indRT(:,idx_block,:),'all','omitnan')+3*std(indRT(:,idx_block,:),0,'all','omitnan');
        


        
        for idx_seq = 1: nbSequence
            
            indRT(indRT(:,idx_block,idx_seq)<limInf ,idx_block,idx_seq )= nan;
            indRT(indRT(:,idx_block,idx_seq)>limSup ,idx_block,idx_seq )= nan;
            
            if idx_seq==1
                if listReact(idx_sub)==1
                    reactCond = 'react';
                else
                    reactCond = 'notReact';
                end
            elseif idx_seq==2
                if listReact(idx_sub)==1
                    reactCond = 'notReact';
                else
                    reactCond = 'react';
                end
            end
            if idx_block<lengthBlock+1
                Session = 'TrainingPreNap';
            elseif idx_block>lengthBlock(1)& idx_block<lengthBlock(1)+lengthBlock(2)+1
                Session = 'TestPreNap';
            elseif idx_block>lengthBlock(1)+lengthBlock(2) & idx_block<lengthBlock(1)+lengthBlock(2)+lengthBlock(3)+1
                Session = 'TestPostNap';
            elseif idx_block>sum(lengthBlock)-lengthBlock(4)
                Session = 'TestPostNight';
            end
            acc = 100-sum(isnan(indRT(:,idx_block,idx_seq)))/(keyPresses/nbSequence)*100;
            fprintf(file1,'%s; %s; %i; %i; %s; %4.3f; %3.1f\n',sub, Session,idx_block,idx_seq,reactCond,nanmean(indRT(:,idx_block,idx_seq)),acc);
            outPutRT(idx_sub,idx_block,idx_seq)= nanmean(indRT(:,idx_block,idx_seq));
            outPutAcc(idx_sub,idx_block,idx_seq)= acc;
        end
        
    end
    
    for idx_seq = 1 : nbSequence
        meanPre = mean(outPutRT(idx_sub,17:20,idx_seq));
        meanEarly = mean(outPutRT(idx_sub,21:24,idx_seq));
        meanLate = mean(outPutRT(idx_sub,25:28,idx_seq));
        offLineGain(idx_sub,1,idx_seq) = (meanPre-meanEarly)/meanPre;
        offLineGain(idx_sub,2,idx_seq) = (meanPre-meanLate)/meanPre;
        
        if idx_seq==1
            if listReact(idx_sub)==1
                reactCond = 'react';
            else
                reactCond = 'notReact';
            end
        elseif idx_seq==2
            if listReact(idx_sub)==1
                reactCond = 'notReact';
            else
                reactCond = 'react';                
            end            
        end
        
        fprintf(file2,'%s; %i; %s; %s; %s\n', sub , idx_seq, reactCond, 'early',(meanPre-meanEarly)/meanPre);
        fprintf(file2,'%s; %i; %s; %s; %s\n', sub , idx_seq, reactCond, 'late',(meanPre-meanLate)/meanPre);

    end
end
fclose(file1);
fclose(file2);
fclose(filetot);
