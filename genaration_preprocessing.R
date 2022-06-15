setwd("D:/Documents/Research/TMR/openLoop/bimanual_open_loop/data/group/OL/")
library(ez)  
library(ggplot2)  
library(Rmisc)
library(matlab)

### Preprocessing Generation
generation  = read.csv(file = 'generation_allKeys.csv',header = T,sep = ';')
generation$attempts = as.factor(generation$attempts)
generation$Sequence = as.factor(generation$Sequence)
allSequence = levels(generation$Sequence)
allSub      = levels(generation$Sub)
allSession  = levels(generation$Session)

sorted_Session  = c(' GenerationPre',  ' GenerationPost')
generation$Session = factor(generation$Session, levels = sorted_Session)


generationSummary=matrix(,length(allSub)*length(allSequence)*length(allSession),5)
colnames(generationSummary)=c('Sub','Session','Sequence','Condition','Accuracy')
generationSummary=as.data.frame(generationSummary)
counter = 1
for (idx_sub in 1:length(allSub))
{
  for (idx_sess in 1:length(allSession))
  {
    for (idx_seq in 1:length(allSequence))
    {
      tmp = generation[generation$Sub== allSub[idx_sub] 
                                & generation$Session== allSession[idx_sess] 
                                & generation$Sequence == allSequence[idx_seq]
                                & generation$OrdinalPosition  <3
                       ,]
      generationSummary$Sub[counter]       = allSub[idx_sub]
      generationSummary$Session[counter]   = allSession[idx_sess]
      generationSummary$Sequence[counter]  = allSequence[idx_seq]
      generationSummary$Condition[counter] = as.character(tmp$Condition[1])
      
      generationSummary$Accuracy[counter] = sum(tmp$Accuracy)/length(tmp$Accuracy)*100
      
      counter = counter+1
      
    }
  }
}
generationSummary$Sub= as.factor(generationSummary$Sub)
generationSummary$Sequence= as.factor(generationSummary$Sequence)
generationSummary$Condition= as.factor(generationSummary$Condition)
sorted_Session  = c(' GenerationPre',  ' GenerationPost')
generationSummary$Session = factor(generationSummary$Session, levels = sorted_Session)


ezANOVA (generationSummary, dv = .(Accuracy), wid = .(Sub),
         within= .(Condition,Session), detailed=T)

ggplot(generationSummary,
       aes(x=Session, y=Accuracy, fill = Condition)) +
  geom_boxplot(position=position_dodge(1),outlier.shape = NA,color=c("cyan","darkmagenta","cyan","darkmagenta"))+
  scale_fill_manual(values=c("darkblue","magenta"))+
  stat_summary(fun=mean, geom="point", shape=18, size=10, aes(group=Condition), position=position_dodge(1),color=c("cyan","cyan","darkmagenta","darkmagenta") ) +
  ylim(0,100)+
  theme_classic() 



ezANOVA (generationSummary, dv = .(Accuracy), wid = .(Sub),
         within= .(Sequence,Session), detailed=T)

ggplot(summarySE(generationSummary, measurevar="Accuracy", groupvars=c("Sequence","Session","Sub")),
       aes(x=Session, y=Accuracy, fill = Sequence)) +
  geom_boxplot(position=position_dodge(1),outlier.shape = NA,color=c("cyan","darkmagenta","cyan","darkmagenta"))+
  scale_fill_manual(values=c("darkblue","magenta"))+
  stat_summary(fun=mean, geom="point", shape=18, size=10, aes(group=Sequence), position=position_dodge(1),color=c("cyan","cyan","darkmagenta","darkmagenta") ) +
  ylim(0,100)+
  theme_classic() 



#pre registered (TMRIndex is computed from offlineGains_preprocessing.R)
cor.test(generationSummary$Accuracy[generationSummary$Session==session & generationSummary$Condition==condition],TMRIndex$index_RT [TMRIndex$Time=='both'],paired = T)


