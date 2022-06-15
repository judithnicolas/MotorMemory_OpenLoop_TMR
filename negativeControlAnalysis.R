
setwd(dir = '/Users/u0129763/Documents/Research/TMR/openLoop/bimanual_open_loop/data/group//')
library(ez)  
library(ggplot2)  
library(Rmisc)
library(matlab)

### Equivalent baseline performance between the two movement sequences
# MSLSummary is computed with MSL_preprocessing.R

#RT

ezANOVA (MSLSummary[MSLSummary$Session ==" TrainingPreNap",], dv = .(Mean), wid = .(Sub),
         within= .(Sequence,Block), detailed=T)

ezANOVA (MSLSummary[MSLSummary$Session ==" TestPreNap",], dv = .(Mean), wid = .(Sub),
         within= .(Sequence,Block), detailed=T)

ezANOVA (MSLSummary[MSLSummary$Block %in% as.factor(c(18:20)),], dv = .(Mean), wid = .(Sub),
         within= .(Sequence,Block), detailed=T)

# Accuracy
ezANOVA (MSLSummary[MSLSummary$Session ==" TrainingPreNap",], dv = .(Acc), wid = .(Sub),
         within= .(Sequence,Block), detailed=T)

ezANOVA (MSLSummary[MSLSummary$Session ==" TestPreNap",], dv = .(Acc), wid = .(Sub),
         within= .(Sequence,Block), detailed=T)



### Equivalent baseline performance between the two conditions 
#RT

ezANOVA (MSLSummary[MSLSummary$Session ==" TrainingPreNap",], dv = .(Mean), wid = .(Sub),
         within= .(Condition,Block), detailed=T)

ezANOVA (MSLSummary[MSLSummary$Session ==" TestPreNap" ,], dv = .(Mean), wid = .(Sub),
         within= .(Condition,Block), detailed=T)

ezANOVA (MSLSummary[MSLSummary$Block %in% as.factor(c(18:20)),], dv = .(Mean), wid = .(Sub),
         within= .(Condition,Block), detailed=T)

# Accuracy
ezANOVA (MSLSummary[MSLSummary$Session ==" TrainingPreNap",], dv = .(Acc), wid = .(Sub),
         within= .(Condition,Block), detailed=T)

ezANOVA (MSLSummary[MSLSummary$Session ==" TestPreNap",], dv = .(Acc), wid = .(Sub),
         within= .(Condition,Block), detailed=T)


### Motor exectution performances
# randomSummary is computed with randomSRTT_preprocessing.R

learningRate=matrix(,length(allSub)*length(allSequence),3)
colnames(learningRate)=c('Sub','Task',"Rate")
learningRate=as.data.frame(learningRate)
counter = 1
for (idx_sub in 1:length(allSub))
{
  
  
  
  tmpMSL = MSLSummary[MSLSummary$Sub==allSub[idx_sub] & 
                        MSLSummary$Block %in% as.factor(c(1:4,37:40)),]
  meanMSLpre = mean(tmpMSL$Mean[tmpMSL$Session==" TrainingPreNap"])
  meanMSLpost = mean(tmpMSL$Mean[tmpMSL$Session==" TestPostNight"])
  
  
  tmpRandom = randomSummary[randomSummary$Sub==allSub[idx_sub] ,]
  meanRandomPre = mean(tmpRandom$Mean[tmpRandom$Session==" preNap"])
  meanRandomPost = mean(tmpRandom$Mean[tmpRandom$Session==" postNight"])
  
  
  learningRate$Sub[counter]   = allSub[idx_sub]
  learningRate$Task[counter]  = 'MSL'
  learningRate$Rate[counter]  =  (meanMSLpre-meanMSLpost)/meanMSLpre*100
  
  learningRate$Sub[counter+1]   = allSub[idx_sub]
  learningRate$Task[counter+1]  = 'Random'
  learningRate$Rate[counter+1]  =  (meanRandomPre-meanRandomPost)/meanRandomPre*100
  
  
  counter = counter +2
  
  
}


learningRate$Sub       = as.factor(learningRate$Sub)
learningRate$Task  = as.factor(learningRate$Task)

t.test(learningRate$Rate[learningRate$Task=='MSL'],learningRate$Rate[learningRate$Task=='Random'],paired = T)
mean(learningRate$Rate[learningRate$Task=='Random']);sd(learningRate$Rate[learningRate$Task=='Random'])
mean(learningRate$Rate[learningRate$Task=='MSL']);sd(learningRate$Rate[learningRate$Task=='MSL'])
cor.test(learningRate$Rate[learningRate$Task=='Random'],learningRate$Rate[learningRate$Task=='MSL'],paired = T)

### PVT
#PVT.csv is extracted with groupDataExtraction.m

PVT = read.csv(file = 'PVT.csv',header = T,sep = ';');

PVT$DV=PVT$DV*1000
PVT$Session= as.factor(PVT$Session)
tapply(PVT$DV,list(PVT$Session),CI)

aovPVT = ezANOVA (PVT, dv = .(DV), wid=.(Sub), within = .(Session), detailed=T)

### SSS
#questionnaires Summarize.csv is included in the data repository 

questionnaires = read.csv(file = 'questionnaires Summarize.csv',header = T,sep = ';');

SSS= matrix(,length(all_sub_complete)*3,3)
colnames(SSS) =c('Sub','Session','DV')
allSub = droplevels(questionnaires$ï..Sub)

SSS=matrix(,length(allSub)*3,3)
colnames(SSS)=c('Sub','Session',"DV")
SSS=as.data.frame(SSS)
counter = 1
for (idx_sub in 1:length(allSub))
{
  for (idx_sess in 1: 3)
  {
    SSS$Sub[counter]     = allSub[idx_sub]
    SSS$Session[counter] = idx_sess
    SSS$DV[counter]      = questionnaires[idx_sub,7+idx_sess]
    
    counter = counter +1
  }
}


SSS$Session=as.factor(SSS$Session)
SSS$Sub=as.factor(SSS$Sub)

aovSSS = ezANOVA (SSS, dv = .(DV), wid=.(Sub), within = .(Session), detailed=T)

tapply(SSS$DV,SSS$Session,CI)


### EEG trial count
#trlCount.csv is included in the data repository 

trlCount <- read.csv("D:/Documents/Research/TMR/openLoop/bimanual_open_loop/data/group/OL/trlCount.csv", header=FALSE)
colnames(trlCount)=c('SentRel','NREMRel','AnalyzedRel','SentIrrel','NREMIrrel','AnalyzedIrrel')
trlCount$PercentageRel = 100-(trlCount$AnalyzedRel/trlCount$NREMRel)*100
trlCount$PercentageIrrel = 100-(trlCount$AnalyzedIrrel/trlCount$NREMIrrel)*100


t.test(trlCount$SentRel,trlCount$SentIrrel,paired = T)
t.test(trlCount$NREMRel,trlCount$NREMIrrel,paired = T)
t.test(trlCount$AnalyzedRel,trlCount$AnalyzedIrrel,paired = T)

