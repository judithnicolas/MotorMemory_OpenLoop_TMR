%% get PVT from log file
% Judith Nicolas
% Created 2020 at KU Leuven

function [outPutAcc]= getGeneration(listSub,dirOutput,dirInput,nbSession,attempts ,sequence,listReact)

    nbSequence=size(sequence,1);lengthSequence=size(sequence,2);
    file = fopen([dirOutput 'generation.csv'],'w');
    fileAll = fopen([dirOutput 'generation_allKeys.csv'],'w');
    fprintf(file,'%s; %s; %s; %s; %s; %s\n', 'Sub' , 'Session','attempts','Sequence','Condition','Accuracy');
    fprintf(fileAll,'%s; %s; %s; %s; %s; %s; %s; %s; %s\n', 'Sub' , 'Session','attempts','Sequence','Condition','OrdinalPosition','Key','Rep','Accuracy');
    
    clc
    for idx_sub = 1 : length(listSub)
        sub = listSub{idx_sub};

        behavFile = [dirInput sub '\behav\MSL_openLoop_' sub '.txt'];

        fid=fopen(behavFile);
        aline = fread(fid, 'char=>char');          % returns a single long string
        fclose(fid);

        aline(aline==uint8(sprintf('\r'))) = [];        % remove cariage return
        aline = tokenize(aline, uint8(sprintf('\n')));  % split on newline

        
        lines= find(~cellfun(@isempty,regexp(aline, '.*GENE.*')));
        if length(lines)/2> nbSession
            warning(['check logfile because more than 2 Generation tasks have been launched Particpant to check: ' sub])
            %depends on design, suggestion is to have a raw log file and a
            %corrected logfile formated as if everything went smotth during
            %data acquisition 
        end
        
        lines= reshape(lines,2,length(lines)/2);
        lines(1,:)=lines(1,:)+1;
        lines(2,:)=lines(2,:)-1;

        cue=[];rep=[];lengthBlock=[];
        for idx_sess = 1: nbSession
            cue = [cue;aline(lines(1,idx_sess):9:lines(2,idx_sess))'];
            rep = [rep;aline(lines(1,idx_sess):lines(2,idx_sess))'];
            lengthBlock=[lengthBlock;length(aline(lines(1,idx_sess):2:lines(2,idx_sess)))/64];
        end
        rep(1:9:end)=[];

        cue = cue';
        rep = reshape(rep,lengthSequence,attempts*nbSession*nbSequence);
        
        if idx_sub==1
            outPutAcc= zeros(length(listSub),attempts*nbSession, nbSequence)    ;
        end
        
        indAcc=zeros(lengthSequence,attempts*nbSession, nbSequence);
        counterSeq1=1;
        counterSeq2=1;
        

        for idx_cue=1 : length(cue)
            firstKey = cue{1,idx_cue};firstKey=strsplit(firstKey,' ');
            firstKey = firstKey {3};
            
            if str2num(firstKey)==1
                counter = counterSeq1;
                idx_seq = 1;
                counterSeq1 = counterSeq1+1;
                if listReact(idx_sub)==1
                    reactCond = 'react';
                else
                    reactCond = 'notReact';
                end

            elseif str2num(firstKey)==2
                if listReact(idx_sub)==1
                    reactCond = 'notReact';
                else
                    reactCond = 'react';
                end
                counter = counterSeq2;
                idx_seq = 2;
                counterSeq2 = counterSeq2+1;
            end

            
            if ismember(idx_cue,[1 5 9 13])
                attempts = 1;
                
            elseif ismember(idx_cue,[2 6 10 14])
                attempts = 2;

            elseif ismember(idx_cue,[3 7 11 15])
                attempts = 3;

            elseif ismember(idx_cue,[4 8 12 16])
                attempts = 4;

            end
            if idx_cue<9
                Session = 'GenerationPre';
            elseif idx_cue>8
                Session = 'GenerationPost';
            end


            for idx_key= 1 : lengthSequence
                key = rep{idx_key,idx_cue};key=strsplit(key,' ');
                key = key {2};
                

                
                
                fprintf(fileAll,'%s; %s; %i; %i; %s; %i; %i; %i; %i\n',sub, Session,attempts,idx_seq, reactCond,idx_key,sequence(idx_seq,idx_key),str2num(key),str2num(key)==sequence(idx_seq,idx_key));

                if str2num(key)==sequence(idx_seq,idx_key)
                    indAcc(idx_key,counter,idx_seq)=1;
                end
            end
        end
        
        for idx_seq = 1: nbSequence
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
            for idx_att = 1 : attempts*2
                if idx_att<attempts+1
                    Session = 'GenerationPre';
                    start=0;
                elseif idx_att>attempts
                    Session = 'GenerationPost';
                    start=4;
                end
                acc = (sum(indAcc(:,idx_att,idx_seq))/8)*100;
                fprintf(file,'%s; %s; %i; %i; %s; %3.1f\n',sub, Session,idx_att-start,idx_seq, reactCond,acc);
                outPutAcc(idx_sub,idx_att,idx_seq)= acc;
            end
        end
    end
    fclose(file);
end