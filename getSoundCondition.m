%% get PVT from log file
% Judith Nicolas
% Created 2020 at KU Leuven

function getSoundCondition(listSub,dirInput,dirOutput)


filetot = fopen([dirOutput '\behavConditions.csv'],'w');
fprintf(filetot,'%s; %s; %s; %s; %s; %s; \n', ...
    'Sub', 'Sound_react','Sequence_react','Sound_notreact','Sequence_notreact','control_sound');

clc
for idx_sub = 1 : length(listSub)
    sub = listSub{idx_sub};
    
    
    paramFiles = dir([dirInput sub '\behav\MSL_openLoop_' sub '.mat']);
    load([paramFiles(1).folder '\' paramFiles(1).name]);
   
    
    if param.reactivatedSequence == 1
        sound_react = param.Seq1.sound;
        Sequence_react = '1';
        sound_notreact = param.Seq2.sound;
        Sequence_notreact = '2';
        control_sound = param.random.sound;
    else
        sound_react = param.Seq2.sound;
        Sequence_react = '2';
        sound_notreact = param.Seq1.sound;
        Sequence_notreact = '1';
        control_sound = param.random.sound;        
    end
    
    
    fprintf(filetot,'%s; %s; %s; %s; %s; %s; \n', ...
        sub, num2str(sound_react),Sequence_react,num2str(sound_notreact), Sequence_notreact,num2str(control_sound));

end
fclose(filetot);
