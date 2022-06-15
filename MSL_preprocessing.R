setwd("D:/Documents/Research/TMR/openLoop/bimanual_open_loop/data/group/OL//")
library(ez)  
library(ggplot2)  
library(Rmisc)
library(matlab)

#sequentialSRTT.csv is extracted with groupDataExtraction.m
MSLData = read.csv(file = 'sequentialSRTT.csv',header = T,sep = ';')

MSLData$Acc=MSLData$Cue==MSLData$Rep
MSLData$Acc = as.numeric(MSLData$Acc)
MSLData$Sequence   = as.factor(MSLData$Sequence)
MSLData$Block      = as.factor(MSLData$Block)
MSLData$OrdinalPos = as.factor(MSLData$OrdinalPos)
MSLData$Cue        = as.factor(MSLData$Cue)
MSLData$Rep        = as.factor(MSLData$Rep)
MSLData$Repetition = as.factor(MSLData$Repetition)

sorted_Block  = paste(sort(as.integer(levels(MSLData$Block))))
MSLData$Block = factor(MSLData$Block, levels = sorted_Block)

sorted_Session  = c(' TrainingPreNap',  ' TestPreNap',  ' TestPostNap',  ' TestPostNight')
MSLData$Session = factor(MSLData$Session, levels = sorted_Session)

allSess       = levels(MSLData$Session)
allSequence   = levels(MSLData$Sequence)
allBlock      = levels(MSLData$Block)
allOrdinalPos = levels(MSLData$OrdinalPos)
allCue        = levels(MSLData$Cue)
allRep        = levels(MSLData$Rep)
allSub        = levels(MSLData$Sub)

for (idx in 1:length(MSLData$Condition))
{
  if (MSLData$Condition[idx]==' react' & MSLData$Sequence[idx]=='1')
  {
    MSLData$Confond[idx] = 'reactivated_1'
  }
  if (MSLData$Condition[idx]==' react' & MSLData$Sequence[idx]=='2')
  {
    MSLData$Confond[idx] = 'reactivated_2'
  }
  
  if (MSLData$Condition[idx]==' notReact' & MSLData$Sequence[idx]=='1')
  {
    MSLData$Confond[idx] = 'reactivated_2'
  }
  if (MSLData$Condition[idx]==' notReact' & MSLData$Sequence[idx]=='2')
  {
    MSLData$Confond[idx] = 'reactivated_1'
  }
  
}


Seq1 = as.factor(c(1,	6,	3,	5,	4,	8,	2,	7))
Seq2 = as.factor(c(7,	2,	6,	4,	5,	1,	8,	3))
blockOfInterst = as.factor(c(17:28))




####### Compute Accuracy by Block, mean rt per key press PI 

MSLSummary=matrix(,length(allSub)*length(allBlock)*length(allSequence),9)
colnames(MSLSummary)=c(colnames(MSLData)[c(1:5,8)],"Mean", "Acc","Confond")
MSLSummary=as.data.frame(MSLSummary)
counter = 1
for (idx_sub in 1:length(allSub))
{
  for (idx_block in 1 : length(allBlock))
  {

    
    for (idx_seq in 1:length(allSequence))
    {
      tmp = MSLData[MSLData$Sub==allSub[idx_sub] & 
                      MSLData$Block==allBlock[idx_block] &
                      MSLData$Sequence==allSequence[idx_seq] ,]
      limInf = mean(tmp$RT[tmp$Acc=='1' ])-3*sd(tmp$RT[tmp$Acc=='1' ])
      limSup = mean(tmp$RT[tmp$Acc=='1' ])+3*sd(tmp$RT[tmp$Acc=='1' ])
      
      MSLSummary$Sub[counter]       = allSub[idx_sub]
      MSLSummary$Block[counter]     = allBlock[idx_block]
      MSLSummary$Sequence[counter]  = allSequence[idx_seq]
      MSLSummary$Session[counter]   = as.character(tmp$Session[1])
      MSLSummary$Condition[counter] = as.character(tmp$Condition[1])
      MSLSummary$Confond[counter] = as.character(tmp$Confond[1])
      MSLSummary$SeqinBlock[counter] = as.character(tmp$SeqinBlock[1])
      
      
      # % Accuracy per block
      MSLSummary$Acc[counter]       = sum(tmp$Acc)/length(tmp$Acc)
      MSLData$PerCorr[MSLData$Sub==allSub[idx_sub] & 
                        MSLData$Block==allBlock[idx_block] &
                        MSLData$Sequence==allSequence[idx_seq]] = repmat(sum(tmp$Acc)/length(tmp$Acc),length(tmp$Sequence),1)
      
      #Mean RT per key presses
      MSLSummary$Mean[counter]      = mean(tmp$RT[tmp$Acc=='1' & tmp$RT>limInf & tmp$RT<limSup ])
      MSLData$Outlier[MSLData$Sub==allSub[idx_sub] & 
                        MSLData$Block==allBlock[idx_block] &
                        MSLData$Sequence==allSequence[idx_seq]] = tmp$Acc=='1' & tmp$RT>limInf & tmp$RT<limSup 
      
      
      #Mean RT per key presses
      
      seqDuration = mean(tmp$timeRep[tmp$OrdinalPos==8] - tmp$timeRep[tmp$OrdinalPos==1] )
      counterOrdPos = 1
      nbCorrectSeq = 0
      for (idx_rep in 1: (length(tmp$Acc)/length(Seq2)))
      {
        if (sum(tmp$Acc[ seq(counterOrdPos,counterOrdPos +length(Seq2)-1,1)])==8)
        {
          nbCorrectSeq = nbCorrectSeq+1
        }
        counterOrdPos= counterOrdPos+length(Seq2)
        
      }
      
      B = ((length(tmp$Acc)/length(Seq2))-nbCorrectSeq)/(length(tmp$Acc)/length(Seq2))
      MSLSummary$PI[counter]       = exp(-seqDuration)*exp(-B)*100
      counter = counter+1
      
    }
  }
}


MSLSummary$Sub       = as.factor(MSLSummary$Sub)
MSLSummary$Sequence  = as.factor(MSLSummary$Sequence)
MSLSummary$Session   = as.factor(MSLSummary$Session)
MSLSummary$Condition = as.factor(MSLSummary$Condition)
MSLSummary$Block     = as.factor(MSLSummary$Block)
MSLSummary$Session   = as.factor(MSLSummary$Session)
MSLSummary$Confond   = as.factor(MSLSummary$Confond)
MSLSummary$SeqinBlock   = as.factor(MSLSummary$SeqinBlock)
sorted_Block  = paste(sort(as.integer(levels(MSLSummary$Block))))
MSLSummary$Block = factor(MSLSummary$Block, levels = sorted_Block)
sorted_Session  = c(' TrainingPreNap',  ' TestPreNap',  ' TestPostNap',  ' TestPostNight')
MSLSummary$Session = factor(MSLSummary$Session, levels = sorted_Session)


length(MSLData$Acc[MSLData$Acc=='1' & MSLData$Outlier=='TRUE'])/length(MSLData$Acc[MSLData$Acc=='1'])*100

####### Plot raw by block and sequence condition. 
#RT
ggplot(summarySE(MSLSummary[MSLSummary$Block %in% as.factor(c(17:20,21:24)),], measurevar="Mean", groupvars=c(  "Session", "Condition"),na.rm=T),
       aes(x=Session, y=Mean, group = Condition )       ) + 
  geom_point(aes(color=Condition,shape=Condition,size=Condition))+
  scale_shape_manual(values=c(15, 16))+
  scale_size_manual(values=c(2,4))+
  geom_ribbon(aes(ymin = Mean-se,
                  ymax = Mean+se,fill=factor(Condition)), alpha = 0.3)+
  scale_color_manual(values=c("darkblue","magenta")) +
  scale_fill_manual(values=c("darkblue","magenta")) +
  ylab("Reaction time (ms)")+
  xlab("Block of training")+
  theme_classic() +
  coord_cartesian(ylim=c(250,350))


ggplot(summarySE(MSLSummary[MSLSummary$Block %in% as.factor(c(18:20,21:24)),], measurevar="Mean", 
                 groupvars=c("Sub","Condition","Session")), aes(x=Session, y=Mean, fill = Condition)) +
  geom_boxplot(position=position_dodge(1),outlier.shape = NA,color=c("darkblue","darkviolet","darkblue","darkviolet"))+
  scale_fill_manual(values=c("#AAAAEF","magenta"))+
  stat_summary(fun=mean, geom="point", shape=18, size=10, aes(group=Condition), position=position_dodge(1),color=c("darkblue","darkblue","darkviolet","darkviolet") ) +
  theme_classic() 

#RT with Random SRTT (randomSRTT is computed with randomSRTT_preprocessing.R)
ggplot(rbind(summarySE(MSLSummary, measurevar="Mean", groupvars=c(  "Block", "Sequence"),na.rm=T),summarySE(randomSummary, measurevar="Mean", groupvars=c(  "Block","Condition"),na.rm=T)),
       aes(x=Block, y=Mean, group = Sequence )) + 
  geom_point(aes(color=Sequence,shape=Sequence,size=Sequence))+
  scale_shape_manual(values=c(16, 16,16,16))+
  scale_size_manual(values=c(2,2,2,2))+
  geom_ribbon(aes(ymin = Mean-se,
                  ymax = Mean+se,fill=factor(Sequence)),alpha = 0.4)+
  scale_color_manual(values=c("#AAAAEF","magenta","Black","Black")) +
  scale_fill_manual(values=c("#AAAAEF","magenta","Black","Black")) +
  ylab("Reaction time (ms)")+
  xlab("Block of training")+
  theme_classic() +
  ylim(150,650)


#Accuracy
ggplot(summarySE(MSLSummary, measurevar="Mean", groupvars=c(  "Block", "Sequence"),na.rm=T),
       aes(x=Block, y=Mean, group = Sequence )       ) + 
  geom_point(aes(color=Sequence))+
  # scale_shape_manual(values=c(15, 16))+
  # scale_size_manual(values=c(2,2))+
  geom_ribbon(aes(ymin = Mean-se,
                  ymax = Mean+se,fill=factor(Sequence)), alpha = 0.4)+
  scale_color_manual(values=c("#AAAAEF","magenta")) +
  scale_fill_manual(values=c("#AAAAEF","magenta")) +
  ylab("Accuracy (%)")+
  xlab("Block of training")+
  theme_classic() 

#Accuracy with Random SRTT
ggplot(rbind(summarySE(MSLSummary, measurevar="Acc", groupvars=c(  "Block", "Condition"),na.rm=T),summarySE(randomSummary, measurevar="Acc", groupvars=c(  "Block","Condition"),na.rm=T)),
       aes(x=Block, y=Acc, group = Condition )       ) + 
  geom_point(aes(color=Condition,shape=Condition,size=Condition))+
  scale_shape_manual(values=c(16, 16,16,16))+
  scale_size_manual(values=c(2,2,2,2))+
  geom_ribbon(aes(ymin = Acc-se,
                  ymax = Acc+se,fill=factor(Condition)), alpha = 0.4)+
  scale_color_manual(values=c("#AAAAEF","magenta","Black","Black")) +
  scale_fill_manual(values=c("#AAAAEF","magenta","Black","Black")) +
  ylab("Accuracy (%)")+
  xlab("Block of training")+
  coord_cartesian(xlim = c(1,20))+
  theme_classic() +
  ylim(0.9,1)


####### With Sequence as factor
#RT
ggplot(summarySE(MSLSummary, measurevar="Mean", groupvars=c(  "Block", "Sequence"),na.rm=T),
       aes(x=Block, y=Mean, group = Sequence )       ) + 
  geom_point(aes(color=Sequence))+
  geom_ribbon(aes(ymin = Mean-se,
                  ymax = Mean+se,fill=factor(Sequence)), alpha = 0.3)+
  ylab("Reaction time (ms)")+
  xlab("Block of training")+
  theme_classic() +
  coord_cartesian(ylim=c(150,650),xlim = c(1,20))

#Accuracy
ggplot(summarySE(MSLSummary, measurevar="Acc", groupvars=c(  "Block", "Sequence"),na.rm=T),
       aes(x=Block, y=Acc, group = Sequence )       ) + 
  geom_point(aes(color=Sequence))+
  geom_ribbon(aes(ymin = Acc-se,
                  ymax = Acc+se,fill=factor(Sequence)), alpha = 0.4)+
  ylab("Accuracy (%)")+
  xlab("Block of training")+
  theme_classic() +  
  coord_cartesian(ylim=c(0.9,1),xlim = c(1,20))

