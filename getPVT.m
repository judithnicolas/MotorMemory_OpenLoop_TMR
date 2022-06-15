%% get PVT from log file
% Judith Nicolas
% Created 2020 at KU Leuven

function outPut= getPVT(listSub,dirOutput,dirInput,nbSession)

    file = fopen([dirOutput 'PVT.csv'],'w');
    fprintf(file,'%s; %s; %s\n', 'Sub' , 'Session','DV');
    outPut = zeros(length(listSub),3);
    clc
    for idx_sub = 1 : length(listSub)
        sub = listSub{idx_sub};

        behavFile = [dirInput sub '\behav\MSL_openLoop_' sub '.txt'];

        fid=fopen(behavFile);
        aline = fread(fid, 'char=>char');          % returns a single long string
        fclose(fid);

        aline(aline==uint8(sprintf('\r'))) = [];        % remove cariage return
        aline = tokenize(aline, uint8(sprintf('\n')));  % split on newline

        lines= find(~cellfun(@isempty,regexp(aline, '.*PVT.*')));
        
        if length(lines)/2> nbSession
            warning(['check logfile because more than 3 PVT have been launched\n Particpant to check: ' sub])
            %depends on design, suggestion is to have a raw log file and a
            %corrected logfile formated as if everything went smotth during
            %data acquisition 
        end
        
        lines= reshape(lines,2,length(lines)/2);

        indRT=zeros(nbSession,(lines(2,1)-lines(1,1)-1)/2);
        for idx_sess= 1 : nbSession
            counter=1;
            for idx = 1 : 2:lines(2,idx_sess)-lines(1,idx_sess)-1
                t0=aline{lines(1,idx_sess)+idx};t0=strsplit(t0,' ');
                t0=str2num(t0{end});
                t1=aline{lines(1,idx_sess)+idx+1};t1=strsplit(t1,' ');
                t1=str2num(t1{end});
                indRT(idx_sess,counter)=t1-t0;
                counter=counter+1;
            end

            fprintf(file,'%s; %i; %1.4f\n',sub, idx_sess,median(indRT(idx_sess,:)));
            outPut(idx_sub,idx_sess)= median(indRT(idx_sess,:));

        end

    end
    fclose(file);
end