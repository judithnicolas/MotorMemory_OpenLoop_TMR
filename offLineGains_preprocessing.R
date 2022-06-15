
setwd("D:/Documents/Research/TMR/openLoop/bimanual_open_loop/data/group/OL//")
library(ez)  
library(ggplot2)  
library(Rmisc)
library(matlab)
library(ungeviz)
#MSL_summary is computed  with MSL_preprocessing.R


offLineGain=matrix(,length(allSub)*length(allSequence)*3,8)
colnames(offLineGain)=c(colnames(MSLSummary)[c(1,4,5)],"Confond",'Time','Gain_RT','Gain_Acc','Gain_PI')
offLineGain=as.data.frame(offLineGain)
startBlock = c(18,21,25)
endBlock = c(20,24,28)

counter = 1
for (idx_sub in 1:length(allSub))
{
  for (idx_seq in 1:length(allSequence))
  {
    
    meanPreRT   = mean(MSLSummary$Mean[MSLSummary$Sub==allSub[idx_sub] & 
                                         MSLSummary$Session==' TestPreNap' &
                                         MSLSummary$Block %in% as.factor(c(startBlock[1]:endBlock[1])) &
                                         MSLSummary$Sequence==allSequence[idx_seq]],na.rm = T)
    meanEarlyRT = mean(MSLSummary$Mean[MSLSummary$Sub==allSub[idx_sub] & 
                                         MSLSummary$Session==' TestPostNap' &
                                         MSLSummary$Block %in% as.factor(c(startBlock[2]:endBlock[2])) &
                                         
                                         MSLSummary$Sequence==allSequence[idx_seq]],na.rm = T)
    meanLateRT  = mean(MSLSummary$Mean[MSLSummary$Sub==allSub[idx_sub] & 
                                         MSLSummary$Session==' TestPostNight' &
                                         MSLSummary$Block %in% as.factor(c(startBlock[3]:endBlock[3])) &
                                         MSLSummary$Sequence==allSequence[idx_seq]],na.rm = T)
    
    meanPreAcc  = mean(MSLSummary$Acc[MSLSummary$Sub==allSub[idx_sub] & 
                                        MSLSummary$Session==' TestPreNap' &
                                        MSLSummary$Block %in% as.factor(c(startBlock[1]:endBlock[1])) &
                                        
                                        MSLSummary$Sequence==allSequence[idx_seq]],na.rm = T)
    meanEarlyAcc= mean(MSLSummary$Acc[MSLSummary$Sub==allSub[idx_sub] & 
                                        MSLSummary$Session==' TestPostNap' &
                                        MSLSummary$Block %in% as.factor(c(startBlock[2]:endBlock[2])) &
                                        
                                        MSLSummary$Sequence==allSequence[idx_seq]],na.rm = T)
    meanLateAcc = mean(MSLSummary$Acc[MSLSummary$Sub==allSub[idx_sub] & 
                                        MSLSummary$Session==' TestPostNight' &
                                        MSLSummary$Block %in% as.factor(c(startBlock[3]:endBlock[3])) &
                                        MSLSummary$Sequence==allSequence[idx_seq]],na.rm = T)
    
    meanPrePI   = mean(MSLSummary$PI[MSLSummary$Sub==allSub[idx_sub] & 
                                       MSLSummary$Session==' TestPreNap' &
                                       MSLSummary$Block %in% as.factor(c(startBlock[1]:endBlock[1])) &
                                       MSLSummary$Sequence==allSequence[idx_seq]],na.rm = T)
    meanEarlyPI = mean(MSLSummary$PI[MSLSummary$Sub==allSub[idx_sub] & 
                                       MSLSummary$Session==' TestPostNap' &
                                       MSLSummary$Block %in% as.factor(c(startBlock[2]:endBlock[2])) &
                                       
                                       MSLSummary$Sequence==allSequence[idx_seq]],na.rm = T)
    meanLatePI  = mean(MSLSummary$PI[MSLSummary$Sub==allSub[idx_sub] & 
                                       MSLSummary$Session==' TestPostNight' &
                                       MSLSummary$Block %in% as.factor(c(startBlock[3]:endBlock[3])) &
                                       MSLSummary$Sequence==allSequence[idx_seq]],na.rm = T)
    
    offLineGain$Sub[c(counter,counter+1,counter+2)]       = allSub[idx_sub]
    offLineGain$Sequence[c(counter,counter+1,counter+2)]  = allSequence[idx_seq]
    offLineGain$Condition[c(counter,counter+1,counter+2)] = as.character(MSLSummary$Condition[MSLSummary$Sub==allSub[idx_sub] & 
                                                                                                MSLSummary$Sequence==allSequence[idx_seq]][1])
    offLineGain$Confond[c(counter,counter+1,counter+2)] = as.character(MSLSummary$Confond[MSLSummary$Sub==allSub[idx_sub] & 
                                                                                            MSLSummary$Sequence==allSequence[idx_seq]][1])
    
    offLineGain$Time[counter]      = 'early'
    offLineGain$Gain_RT[counter]   = ((meanPreRT-meanEarlyRT)/meanPreRT)*100
    offLineGain$Gain_Acc[counter]  = ((meanEarlyAcc-meanPreAcc)/meanPreAcc)*100
    offLineGain$Gain_PI[counter]   = (meanEarlyPI-meanPrePI)/meanPrePI
    
    offLineGain$Time[counter+1] = 'late'
    offLineGain$Gain_RT[counter+1]   = ((meanPreRT-meanLateRT)/meanPreRT)*100
    offLineGain$Gain_Acc[counter+1]  = ((meanLateAcc-meanPreAcc)/meanPreAcc)*100
    offLineGain$Gain_PI[counter+1]   = (meanLatePI-meanPrePI)/meanPrePI
    
    offLineGain$Time[counter+2] = 'both'
    offLineGain$Gain_RT[counter+2]   = mean(c(offLineGain$Gain_RT[counter+1],offLineGain$Gain_RT[counter]))
    offLineGain$Gain_Acc[counter+2]  = mean(c(offLineGain$Gain_Acc[counter+1],offLineGain$Gain_Acc[counter]))
    offLineGain$Gain_PI[counter+2]   = mean(c(offLineGain$Gain_PI[counter+1],offLineGain$Gain_PI[counter]))
    
    
    
    counter = counter+3
  }
}


offLineGain$Sub       = as.factor(offLineGain$Sub)
offLineGain$Sequence  = as.factor(offLineGain$Sequence)
offLineGain$Condition = as.factor(offLineGain$Condition)
offLineGain$Time      = as.factor(offLineGain$Time)




aovGain = ezANOVA(offLineGain[offLineGain$Time!='both' & ! offLineGain$Sub %in% c('OL_13'),], 
                  dv = .(Gain_RT),
                  wid=.(Sub), 
                  within = .(Time,Condition), 
                  detailed=T)

cor.test(offLineGain$Gain_RT[offLineGain$Time=='both' & offLineGain$Condition==' react'] , offLineGain$Gain_RT[offLineGain$Time=='both' & offLineGain$Condition==' notReact'],paired=T) 
#     cor 0.6908237 

t.test(offLineGain$Gain_RT[offLineGain$Time!='both'],alternative = 'greater')
t.test(offLineGain$Gain_RT[offLineGain$Time=='early'],alternative = 'greater')
t.test(offLineGain$Gain_RT[offLineGain$Time=='late'],alternative = 'greater')

t.test(offLineGain$Gain_RT[offLineGain$Time=='early' & offLineGain$Condition==' react'],alternative = 'greater')
t.test(offLineGain$Gain_RT[offLineGain$Time=='late' & offLineGain$Condition==' react'],alternative = 'greater')

t.test(offLineGain$Gain_RT[offLineGain$Time=='early' & offLineGain$Condition==' notReact'],alternative = 'greater')
t.test(offLineGain$Gain_RT[offLineGain$Time=='late' & offLineGain$Condition==' notReact'],alternative = 'greater')

####### Plot offline gain by block and sequence condition. 
#RT
ggplot(summarySE(offLineGain[offLineGain$Time!='both',], measurevar="Gain_RT", 
                 groupvars=c("Sub","Condition","Time")), aes(x=Time, y=Gain_RT, fill = Condition)) +
  geom_boxplot(position=position_dodge(1),outlier.shape = NA,color=c("darkblue","darkviolet","darkblue","darkviolet"))+
  scale_fill_manual(values=c("#AAAAEF","magenta"))+
  stat_summary(fun=mean, geom="point", shape=18, size=10, aes(group=Condition), position=position_dodge(1),color=c("darkblue","darkblue","darkviolet","darkviolet") ) +
  coord_cartesian(ylim=c(-50,50))+
  theme_classic() 


#Acc
aovGain_Acc = ezANOVA(offLineGain[offLineGain$Time!='both',], 
                      dv = .(Gain_Acc),
                      wid=.(Sub), 
                      within = .(Time,Condition), 
                      detailed=T)


ggplot(summarySE(offLineGain[offLineGain$Time!='both',], measurevar="Gain_Acc", 
                 groupvars=c("Sub","Condition","Time")), aes(x=Time, y=Gain_Acc, fill = Condition)) +
  geom_boxplot(position=position_dodge(1),outlier.shape = NA,color=c("darkblue","darkviolet","darkblue","darkviolet"))+
  scale_fill_manual(values=c("#AAAAEF","magenta"))+
  stat_summary(fun=mean, geom="point", shape=18, size=10, aes(group=Condition), position=position_dodge(1),color=c("darkblue","darkblue","darkviolet","darkviolet") ) +
  coord_cartesian(ylim=c(-50,50))+
  theme_classic() 



### TMR index
allTime = levels(offLineGain$Time)

TMRIndex=matrix(,length(allSub)*length(allSequence)*3,3)
colnames(TMRIndex)=c(colnames(MSLSummary)[c(1)],'Time','index_RT')
TMRIndex=as.data.frame(TMRIndex)
counter = 1
for (idx_sub in 1:length(allSub))
{
  for (idx_time in 1:length(allTime))
  {
    
    offlineGainReact    = offLineGain$Gain_RT[offLineGain$Sub==allSub[idx_sub] & offLineGain$Condition==' react' & offLineGain$Time==allTime[idx_time]]
    offlineGainNotReact = offLineGain$Gain_RT[offLineGain$Sub==allSub[idx_sub] & offLineGain$Condition==' notReact' & offLineGain$Time==allTime[idx_time]]
    
    TMRIndex$Sub[counter]       = allSub[idx_sub]
    TMRIndex$Time[counter]      = allTime[idx_time]
    TMRIndex$index_RT[counter]   = (offlineGainReact-offlineGainNotReact)
    
    counter = counter+1
  }

  
}


TMRIndex$Sub       = as.factor(TMRIndex$Sub)
TMRIndex$Time      = as.factor(TMRIndex$Time)

TMRIndex=na.omit(TMRIndex)





#### Review 1

# Test gains against 0
t.test(offLineGain$Gain_RT[offLineGain$Time!='both'],alternative = 'greater')
t.test(offLineGain$Gain_RT[offLineGain$Time=='early'],alternative = 'greater')
t.test(offLineGain$Gain_RT[offLineGain$Time=='late'],alternative = 'greater')

t.test(offLineGain$Gain_RT[offLineGain$Time=='early' & offLineGain$Condition==' react'],alternative = 'greater')
t.test(offLineGain$Gain_RT[offLineGain$Time=='late' & offLineGain$Condition==' react'],alternative = 'greater')

t.test(offLineGain$Gain_RT[offLineGain$Time=='early' & offLineGain$Condition==' notReact'],alternative = 'greater')
t.test(offLineGain$Gain_RT[offLineGain$Time=='late' & offLineGain$Condition==' notReact'],alternative = 'greater')

# Individual data points + line
ggplot(summarySE(offLineGain[offLineGain$Time!='both',], measurevar="Gain_RT", 
                 groupvars=c("Sub","Condition","Time")), aes( y=Gain_RT, fill = Condition,x = Condition)) +
  geom_boxplot(position=position_dodge(1),outlier.shape = NA,color=c("darkblue","darkviolet","darkblue","darkviolet"))+
  stat_summary(fun=mean, geom="point", shape=18, size=10, aes(group=Condition), position=position_dodge(1),color=c("darkblue","darkviolet","darkblue","darkviolet") ) +
  scale_fill_manual(values=c("#AAAAEF","magenta"))+
  geom_line(aes(group=Sub), position = position_dodge(0.2),color = "grey") +
  geom_point(aes(fill=Condition,group=Sub),size=0.5,shape=21, position = position_dodge(0.2)) +
  coord_cartesian(ylim=c(-100,50))+
  facet_grid(. ~ Time)+
  theme_classic() 

# Individual data points + line separatly for condition
ggplot(summarySE(offLineGain[offLineGain$Time!='both' & offLineGain$Condition==' notReact',], measurevar="Gain_RT", 
                 groupvars=c("Sub","Condition","Time")), aes( y=Gain_RT, fill = Time,x = Time)) +
  geom_boxplot(position=position_dodge(1),outlier.shape = NA,color=c("darkblue","darkblue"))+
  stat_summary(fun=mean, geom="point", shape=18, size=10, aes(group=Time), position=position_dodge(1),color=c("darkblue","darkblue") ) +
  scale_fill_manual(values=c("#AAAAEF","#AAAAEF"))+
  geom_line(aes(group=Sub), position = position_dodge(0.2),color = "grey") +
  geom_point(aes(fill=Time,group=Sub),size=0.5,shape=21, position = position_dodge(0.2)) +
  coord_cartesian(ylim=c(-100,100))+
  theme_classic() 

ggplot(summarySE(offLineGain[offLineGain$Time!='both' & offLineGain$Condition==' react',], measurevar="Gain_RT", 
                 groupvars=c("Sub","Condition","Time")), aes( y=Gain_RT, fill = Time,x = Time)) +
  geom_boxplot(position=position_dodge(1),outlier.shape = NA,color=c("darkviolet","darkviolet"))+
  stat_summary(fun=mean, geom="point", shape=18, size=10, aes(group=Time), position=position_dodge(1),color=c("darkviolet","darkviolet") ) +
  scale_fill_manual(values=c("magenta","magenta"))+
  geom_line(aes(group=Sub), position = position_dodge(0.2),color = "grey") +
  geom_point(aes(fill=Time,group=Sub),size=0.5,shape=21, position = position_dodge(0.2)) +
  coord_cartesian(ylim=c(-100,100))+
  theme_classic() 

# Late gains computed as relative change to post nap

offLineGain=matrix(,length(allSub)*length(allSequence)*3,8)
colnames(offLineGain)=c(colnames(MSLSummary)[c(1,4,5)],"Confond",'Time','Gain_RT','Gain_Acc','Gain_PI')
offLineGain=as.data.frame(offLineGain)
startBlock = c(18,21,25)

counter = 1
for (idx_sub in 1:length(allSub))
{
  for (idx_seq in 1:length(allSequence))
  {
    
    meanPreRT   = mean(MSLSummary$Mean[MSLSummary$Sub==allSub[idx_sub] & 
                                         MSLSummary$Session==' TestPreNap' &
                                         MSLSummary$Block %in% as.factor(c(startBlock[1]:20)) &
                                         MSLSummary$Sequence==allSequence[idx_seq]],na.rm = T)
    meanEarlyRT = mean(MSLSummary$Mean[MSLSummary$Sub==allSub[idx_sub] & 
                                         MSLSummary$Session==' TestPostNap' &
                                         MSLSummary$Block %in% as.factor(c(startBlock[2]:24)) &
                                         
                                         MSLSummary$Sequence==allSequence[idx_seq]],na.rm = T)
    meanLateRT  = mean(MSLSummary$Mean[MSLSummary$Sub==allSub[idx_sub] & 
                                         MSLSummary$Session==' TestPostNight' &
                                         MSLSummary$Block %in% as.factor(c(startBlock[3]:28)) &
                                         MSLSummary$Sequence==allSequence[idx_seq]],na.rm = T)
    
    meanPreAcc  = mean(MSLSummary$Acc[MSLSummary$Sub==allSub[idx_sub] & 
                                        MSLSummary$Session==' TestPreNap' &
                                        MSLSummary$Block %in% as.factor(c(startBlock[1]:20)) &
                                        
                                        MSLSummary$Sequence==allSequence[idx_seq]],na.rm = T)
    meanEarlyAcc= mean(MSLSummary$Acc[MSLSummary$Sub==allSub[idx_sub] & 
                                        MSLSummary$Session==' TestPostNap' &
                                        MSLSummary$Block %in% as.factor(c(startBlock[2]:24)) &
                                        
                                        MSLSummary$Sequence==allSequence[idx_seq]],na.rm = T)
    meanLateAcc = mean(MSLSummary$Acc[MSLSummary$Sub==allSub[idx_sub] & 
                                        MSLSummary$Session==' TestPostNight' &
                                        MSLSummary$Block %in% as.factor(c(startBlock[3]:28)) &
                                        MSLSummary$Sequence==allSequence[idx_seq]],na.rm = T)
    
    meanPrePI   = mean(MSLSummary$PI[MSLSummary$Sub==allSub[idx_sub] & 
                                       MSLSummary$Session==' TestPreNap' &
                                       MSLSummary$Block %in% as.factor(c(startBlock[1]:20)) &
                                       MSLSummary$Sequence==allSequence[idx_seq]],na.rm = T)
    meanEarlyPI = mean(MSLSummary$PI[MSLSummary$Sub==allSub[idx_sub] & 
                                       MSLSummary$Session==' TestPostNap' &
                                       MSLSummary$Block %in% as.factor(c(startBlock[2]:24)) &
                                       
                                       MSLSummary$Sequence==allSequence[idx_seq]],na.rm = T)
    meanLatePI  = mean(MSLSummary$PI[MSLSummary$Sub==allSub[idx_sub] & 
                                       MSLSummary$Session==' TestPostNight' &
                                       MSLSummary$Block %in% as.factor(c(startBlock[3]:28)) &
                                       MSLSummary$Sequence==allSequence[idx_seq]],na.rm = T)
    
    offLineGain$Sub[c(counter,counter+1,counter+2)]       = allSub[idx_sub]
    offLineGain$Sequence[c(counter,counter+1,counter+2)]  = allSequence[idx_seq]
    offLineGain$Condition[c(counter,counter+1,counter+2)] = as.character(MSLSummary$Condition[MSLSummary$Sub==allSub[idx_sub] & 
                                                                                                MSLSummary$Sequence==allSequence[idx_seq]][1])
    offLineGain$Confond[c(counter,counter+1,counter+2)] = as.character(MSLSummary$Confond[MSLSummary$Sub==allSub[idx_sub] & 
                                                                                            MSLSummary$Sequence==allSequence[idx_seq]][1])
    
    offLineGain$Time[counter]      = 'early'
    offLineGain$Gain_RT[counter]   = ((meanPreRT-meanEarlyRT)/meanPreRT)*100
    offLineGain$Gain_Acc[counter]  = ((meanEarlyAcc-meanPreAcc)/meanPreAcc)*100
    offLineGain$Gain_PI[counter]   = (meanEarlyPI-meanPrePI)/meanPrePI
    
    offLineGain$Time[counter+1] = 'late'
    offLineGain$Gain_RT[counter+1]   = ((meanEarlyRT-meanLateRT)/meanEarlyRT)*100
    offLineGain$Gain_Acc[counter+1]  = ((meanLateAcc-meanEarlyAcc)/meanEarlyAcc)*100
    offLineGain$Gain_PI[counter+1]   = (meanLatePI-meanEarlyPI)/meanEarlyPI
    
    offLineGain$Time[counter+2] = 'both'
    offLineGain$Gain_RT[counter+2]   = mean(c(offLineGain$Gain_RT[counter+1],offLineGain$Gain_RT[counter]))
    offLineGain$Gain_Acc[counter+2]  = mean(c(offLineGain$Gain_Acc[counter+1],offLineGain$Gain_Acc[counter]))
    offLineGain$Gain_PI[counter+2]   = mean(c(offLineGain$Gain_PI[counter+1],offLineGain$Gain_PI[counter]))
    
    
    
    counter = counter+3
  }
}


offLineGain$Sub       = as.factor(offLineGain$Sub)
offLineGain$Sequence  = as.factor(offLineGain$Sequence)
offLineGain$Condition = as.factor(offLineGain$Condition)
offLineGain$Time      = as.factor(offLineGain$Time)


aovGain = ezANOVA(offLineGain[offLineGain$Time!='both',] , 
                  dv = .(Gain_RT),
                  wid=.(Sub), 
                  within = .(Time,Condition), 
                  detailed=T)
ggplot(summarySE(offLineGain[offLineGain$Time!='both',], measurevar="Gain_RT", 
                 groupvars=c("Sub","Condition","Time")), aes(x=Time, y=Gain_RT, fill = Condition)) +
  geom_boxplot(position=position_dodge(1),outlier.shape = NA,color=c("darkblue","darkviolet","darkblue","darkviolet"))+
  scale_fill_manual(values=c("#AAAAEF","magenta"))+
  stat_summary(fun=mean, geom="point", shape=18, size=10, aes(group=Condition), position=position_dodge(1),color=c("darkblue","darkblue","darkviolet","darkviolet") ) +
  coord_cartesian(ylim=c(-50,50))+
  theme_classic() 

ggplot(summarySE(offLineGain[offLineGain$Time!='both',], measurevar="Gain_RT", 
                 groupvars=c("Sub","Condition","Time")), aes( y=Gain_RT, fill = Condition,x = Condition)) +
  geom_boxplot(position=position_dodge(1),outlier.shape = NA,color=c("darkblue","darkviolet","darkblue","darkviolet"))+
  stat_summary(fun=mean, geom="point", shape=18, size=10, aes(group=Condition), position=position_dodge(1),color=c("darkblue","darkviolet","darkblue","darkviolet") ) +
  scale_fill_manual(values=c("#AAAAEF","magenta"))+
  geom_line(aes(group=Sub), position = position_dodge(0.2),color = "grey") +
  geom_point(aes(fill=Condition,group=Sub),size=2,shape=21, position = position_dodge(0.2)) +
  facet_grid(. ~ Time)+
  theme_classic() 

