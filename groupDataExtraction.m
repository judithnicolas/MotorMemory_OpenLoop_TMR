%% get group data from log file
% Judith Nicolas
% Created 2020 at KU Leuven


clc


dirOutput= [initPath.Exp 'data\group\'];
dirInput= [initPath.Exp 'data\' ];
[listSub ,listReact]= getCompleteDatasets;

nbSessionPVT = 3;
nbSessionMSL = 4; %including training and test
nbSessionrandomSRTT_Generation = 2;
keyPresses = 64;
sequence = [ 1 6 3 5 4 8 2 7; 7 2 6 4 5 1 8 3];
attempts = 4;

PVT= getPVT(listSub,dirOutput,dirInput,nbSessionPVT);
[randomRT,randomAcc]= getRandomSRTT(listSub,dirOutput,dirInput,nbSessionrandomSRTT_Generation,keyPresses );
[MSLRT,MSLAcc,offLineGain]= getSequentialSRTT(listSub,dirOutput,dirInput,nbSessionMSL,keyPresses,sequence,listReact);
[GenerationAcc]= getGeneration(listSub,dirOutput,dirInput,nbSessionrandomSRTT_Generation,attempts ,sequence,listReact);%,listReact);

getSoundCondition(listSub,dirInput,dirOutput)


