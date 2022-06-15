
setwd("D:/Documents/Research/TMR/openLoop/bimanual_open_loop/data/group/OL")
library('ez')
library('Rmisc')



############ SLEEP Duration
duration = read.csv(file = 'sleepDuration.csv',header = T,sep = ';');

tapply(duration$DV/60,list(duration$Stage),CI)
CI(duration$Percentage[duration$Stage == ' sleep' ])

CI(duration$Percentage[duration$Stage == ' S2']  + 
     duration$Percentage[ duration$Stage == ' S3' ] + duration$Percentage[ duration$Stage == ' REM'] )

all_sub= levels(duration$Sub)
all_stage = levels(duration$Stage)

############ SLEEP Latendy
latency = read.csv(file = 'sleepLatency.csv',header = T,sep = ';');
 CI(latency$S1/60)

############ SLEEP arousal
arousal = read.csv(file = 'sleepArousal.csv',header = T,sep = ';');


############ STIM REPARTION
cuesCount = read.csv(file = 'stimEfficiency.csv',header = T,sep = ';');
cuesCount = cuesCount
tapply(cuesCount$Percentage[cuesCount$Stage==' NREM'],cuesCount$type[cuesCount$Stage==' NREM'],CI)

tapply(cuesCount$DV[cuesCount$type==' all'],list(cuesCount$Stage[cuesCount$type==' all']),CI)
tapply(cuesCount$DV[cuesCount$type==' stim'],list(cuesCount$Stage[cuesCount$type==' stim']),CI)
tapply(cuesCount$DV[cuesCount$type==' random'],list(cuesCount$Stage[cuesCount$type==' all']),CI)

ezANOVA (cuesCount[cuesCount$type!=' all' & (cuesCount$Stage!=' total' & cuesCount$Stage!=' NREM'),], dv = .(DV),wid=.(Sub), within = .(type,Stage), detailed=T)



AOVplot = ezPlot(
  data = cuesCount[cuesCount$type!=' all' & (cuesCount$Stage!=' total' & cuesCount$Stage!=' NREM'),],
  , dv = .(DV)
  , wid = .(Sub)
  , within = .(type,Stage)
  , x = .(Stage)
  , split = .(type)
  , x_lab =    'Block'
  , y_lab =    'RT' )
print(AOVplot)
############ SLEEP instrucitons
questionnaires_Summarize <-  read.csv("D:/Documents/Research/TMR/openLoop/bimanual_open_loop/data/group/OL/questionnaires Summarize.csv", sep=";")
questionnaires_Summarize$Sub = as.factor(questionnaires_Summarize$Sub)
questionnaires_Summarize$Sexe = as.factor(questionnaires_Summarize$Sexe)


CI(questionnaires_Summarize$sleep_duration_estimate_StMary)/60/60
CI(questionnaires_Summarize$sleep_quality_St_Mary)




### Acti + sleep journal
CI(na.omit(questionnaires_Summarize$N.3))/60/60
CI(na.omit(questionnaires_Summarize$N.2))/60/60
CI(na.omit(questionnaires_Summarize$N.1))/60/60



############ Participant characteristics

CI(questionnaires_Summarize$Edinburgh_handeness)
CI(questionnaires_Summarize$Daytime_sleepiness)

CI(questionnaires_Summarize$Beck_depression)
CI(questionnaires_Summarize$Beck_anxiety)
CI(questionnaires_Summarize$PQSI)
CI(questionnaires_Summarize$Chronotype)



