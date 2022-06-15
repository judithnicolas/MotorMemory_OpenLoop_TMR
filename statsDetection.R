
setwd("D:/Documents/Research/TMR/openLoop/bimanual_open_loop/data/group/OL/")
library(ggplot2)
library(ggpubr)
library(ez)
library(Rmisc)
library(readr)
library(lme4)
library(REdaS)

## ERP & TF
erpNegPeak <- read.csv("erpNegPeak.csv", header=FALSE)#From analysis_ERP.m
shapiro.test(c(erpNegPeak$V1,erpNegPeak$V2))
erpNegTest = wilcox.test(erpNegPeak$V1,erpNegPeak$V2,paired = T,alternative = 'less')
mean(erpNegPeak$V1);sd(erpNegPeak$V1)
mean(erpNegPeak$V2);sd(erpNegPeak$V2)

cor.test(erpNegPeak$V2,erpNegPeak$V1,paired = T)
# yes 
#no correlation for cohen d computation

erp = matrix(,24*2,4)
colnames(erp)=c("Sub","Condition","erpCond","DV")
erp = as.data.frame(erp)
counter = 1
for (idx_sub in 1:length(allSub))
{
  erp$Sub [c(counter,counter+1)] =allSub[idx_sub]
  
  erp$Condition [counter]= 'rel'
  erp$erpCond [counter]= 'negPeak'
  erp$DV [counter]= erpNegPeak$V1[idx_sub]
  
  erp$Condition [counter+1]= 'irrel'
  erp$erpCond [counter+1]= 'negPeak'
  erp$DV [counter+1]= erpNegPeak$V2[idx_sub]
  counter = counter +2
  
}
erp$erpCond = factor(erp$erpCond)



ggplot(summarySE(erp, measurevar="DV", groupvars=c("Sub","Condition","erpCond")), aes(x=erpCond, y=DV, fill = Condition )) + 
  geom_boxplot(position=position_dodge(1),outlier.shape = NA,color=c("darkblue","darkmagenta"))+
  scale_fill_manual(values=c("#AAAAEF","magenta"))+
  stat_summary(fun=mean, geom="point", shape=18, size=10, aes(group=Condition), position=position_dodge(1),color=c("darkblue","darkmagenta") ) +
  theme_classic() + 
  scale_y_continuous(breaks=seq(-6,6,1))+
  coord_cartesian(ylim = c(-5.5,5.5))

## New plot for review
ggplot(summarySE(erp, measurevar="DV", groupvars=c("Sub","Condition")), aes(x=Condition, y=DV, fill = Condition )) + 
  geom_boxplot(position=position_dodge(1),outlier.shape = NA,color=c("darkgoldenrod2","darkmagenta"))+
  scale_fill_manual(values=c("gold","magenta"))+
  stat_summary(fun=mean, geom="point", shape=18, size=10, aes(group=Condition), position=position_dodge(1),color=c("darkgoldenrod2","darkmagenta") ) +
  scale_y_continuous(breaks=seq(-6,6,1))+
  # coord_cartesian(ylim = c(-5.5,5.5))+
  geom_line(aes(group=Sub), position = position_dodge(0.2),color = "grey90") +
  geom_point(aes(fill=Condition,group=Sub),size=2,shape=21, position = position_dodge(0.2)) +
  theme_classic() 

## review Cor between erp and pac
tfNegPeak <- read.csv("D:/Documents/Research/TMR/openLoop/bimanual_open_loop/data/group/OL/PAC_relVsIrrelForCor.csv", header=FALSE)#From statPAC_SO.m

cor.test(PAC_relVsIrrel$V3,  , paired = T)


tf = matrix(,22*3,4)
colnames(tf)=c("Sub",'Condition',"DVTF","DVTMR")
tf = as.data.frame(tf)
counter = 1

allSubTmp= allSub[c(1:8, 10:12, 14:24)]
for (idx_sub in 1:length(allSubTmp)){
  tf$Sub [c(counter,counter+1,counter+2)] =allSubTmp[idx_sub]
  
  tf$Condition [counter]= 'rel'
  tf$DVTF [counter]= tfNegPeak$V1[idx_sub]
  tf$DVTMR [counter]= offLineGain$Gain_RT[offLineGain$Condition==' react' & offLineGain$Time=='both' & offLineGain$Sub == allSubTmp[idx_sub]]
  
  tf$Condition [counter+1]= 'irrel'
  tf$DVTF [counter+1]= tfNegPeak$V2[idx_sub]
  tf$DVTMR [counter+1]= offLineGain$Gain_RT[offLineGain$Condition==' notReact' & offLineGain$Time=='both' & offLineGain$Sub == allSubTmp[idx_sub]]
  
  tf$Condition [counter+2]= 'diff'
  tf$DVTF [counter+2]= tfNegPeak$V1[idx_sub]
  tf$DVTMR [counter+2]= TMRIndex$index_RT[TMRIndex$Time=='both' & TMRIndex$Sub == allSubTmp[idx_sub]]
  
  counter = counter +3  
  
}
tf$Cond = factor(tf$Cond)

ggplot(tf[tf$Condition=='diff',], aes(x=DVTMR, y=DVTF)) +
  geom_point(color=c("darkblue")) +
  geom_smooth(method = lm,color="magenta",alpha=0.2,fill='magenta') +
  # stat_cor(method = "spearman")+
  coord_cartesian(ylim = c(-0.15, 0.15 ))+
  theme_light()
  
## Detection

swto2 <- read_csv("swto05-2_withRest.csv",  col_types = cols(Stage = col_character()))#From SO_spindles_analysis.py


swto2$Stage = as.factor(swto2$Stage)
swto2$Sub = as.factor(swto2$Sub)
swto2$Channel = as.factor(swto2$Channel)
CI(tapply(swto2$Count, swto2$Channel, sum))
swCount = tapply(swto2$Count, list(swto2$Channel,swto2$Stage), CI)
tmp = mean(tapply(swto2$Count, list(swto2$Channel,swto2$Sub), sum))

spindles <- read_csv("Spindles_withRest.csv",  col_types = cols(Stage = col_character()))#From SO_spindles_analysis.py

spindles$Stage = as.factor(spindles$Stage)
spindles$Sub = as.factor(spindles$Sub)
spindles$Channel = as.factor(spindles$Channel)
spCount = tapply(spindles$Count, list(spindles$Channel,spindles$Stage), CI)

tmp = tapply(spindles$Count, list(spindles$Channel,spindles$Sub), sum)
mean(na.omit(tmp[2,]))


swto2$Stim[swto2$Stage %in% c(0,1) ] = 'Yes'
swto2$Stim[swto2$Stage %in% c(2) ] = 'No'
spindles$Stim[spindles$Stage %in% c(0,1) ] = 'Yes'
spindles$Stim[spindles$Stage %in% c(2) ] = 'No'


### Relevant vs Irrelevant
#exclusion of OL_13 and OL_09 because not enough SW


#Auditory stimulation during sleep increases SO amplitude
tmp = summarySE(swto2[ !swto2$Sub %in% c('OL_13','OL_09'),], measurevar="PTP", groupvars=c("Sub","Stage"),na.rm=T)
shapiro.test(tmp$PTP)

t.test (tmp$PTP[tmp$Stage==1],tmp$PTP[tmp$Stage==0], paired=T,alternative = 'greater')
mean(tmp$PTP[tmp$Stage==1]);sd(tmp$PTP[tmp$Stage==1])
mean(tmp$PTP[tmp$Stage==0]);sd(tmp$PTP[tmp$Stage==0])
cor.test(tmp$PTP[tmp$Stage==1],tmp$PTP[tmp$Stage==0], paired=T)
#yes

#rest
testIrrel = t.test(tmp$PTP[tmp$Stage=='0'],tmp$PTP[tmp$Stage=='2'], paired=T)
testRel = t.test(tmp$PTP[tmp$Stage=='1'],tmp$PTP[tmp$Stage=='2'], paired=T)
p.adjust(c(testIrrel$p.value,testRel$p.value),n=2,method = 'fdr')


ggplot(summarySE(swto2[ !swto2$Sub %in% c('OL_13','OL_09'),], measurevar="PTP", groupvars=c("Sub","Stage"),na.rm=T), aes(x=Stage, y=PTP,fill=Stage )) +
  geom_boxplot(position=position_dodge(1),outlier.shape = NA,color=c("darkblue","darkmagenta",'black'))+
  scale_fill_manual(values=c("#AAAAEF","magenta",'grey'))+
  stat_summary(fun=mean, geom="point", shape=18, size=10, aes(group=Stage), 
               position=position_dodge(1),color=c("darkblue","darkmagenta","black") ) +
  scale_y_continuous(breaks=seq(100,150,25))+
  coord_cartesian(ylim = c(90, 150))+
  theme_classic() 

## New plot for review
ggplot(summarySE(swto2[ !swto2$Sub %in% c('OL_13','OL_09'),], measurevar="PTP", groupvars=c("Sub","Stage"),na.rm=T), aes(x=Stage, y=PTP,fill=Stage )) +
  geom_boxplot(position=position_dodge(1),outlier.shape = NA,color=c("darkgoldenrod2","darkmagenta",'black'))+
  scale_fill_manual(values=c("gold","magenta",'grey'))+
  stat_summary(fun=mean, geom="point", shape=18, size=10, aes(group=Stage), position=position_dodge(1),color=c("darkgoldenrod2","darkmagenta",'black') ) +
  # ylim(-20,20)+
  theme_classic() + 
  scale_y_continuous(breaks=seq(100,150,25))+
  coord_cartesian(ylim = c(90, 150))+
  geom_line(aes(group=Sub), position = position_dodge(0.2),color = "grey90") +
  geom_point(aes(fill=Stage,group=Sub),size=2,shape=21, position = position_dodge(0.2)) +
  theme_classic() 


#Auditory stimulation during sleep increases SO density

tmp = summarySE(swto2[ !swto2$Sub %in% c('OL_13','OL_09'),], measurevar="Density", groupvars=c("Sub","Stage"),na.rm=T)
shapiro.test(tmp$Density)

wilcox.test (c(tmp$Density[tmp$Stage==1] ),c(tmp$Density[tmp$Stage==0]), paired=T,alternative = 'greater')
mean(tmp$Density[tmp$Stage==1]);sd(tmp$Density[tmp$Stage==1])
mean(tmp$Density[tmp$Stage==0]);sd(tmp$Density[tmp$Stage==0])
cor.test(tmp$Density[tmp$Stage==1],tmp$Density[tmp$Stage==0], paired=T)
#yes

#rest
testIrrel = wilcox.test(tmp$Density[tmp$Stage=='0'],tmp$Density[tmp$Stage=='2'], paired=T)
mean(tmp$Density[tmp$Stage==2]);sd(tmp$Density[tmp$Stage==2])
mean(tmp$Density[tmp$Stage==0]);sd(tmp$Density[tmp$Stage==0])
cor.test(tmp$Density[tmp$Stage==2],tmp$Density[tmp$Stage==0], paired=T)

testRel = wilcox.test(tmp$Density[tmp$Stage=='1'],tmp$Density[tmp$Stage=='2'], paired=T)
mean(tmp$Density[tmp$Stage==2]);sd(tmp$Density[tmp$Stage==2])
mean(tmp$Density[tmp$Stage==1]);sd(tmp$Density[tmp$Stage==1])
cor.test(tmp$Density[tmp$Stage==2],tmp$Density[tmp$Stage==1], paired=T)

p.adjust(c(testIrrel$p.value,testRel$p.value),n=2,method = 'fdr')

ggplot(summarySE(swto2[ !swto2$Sub %in% c('OL_13','OL_09'),], measurevar="Density", groupvars=c("Sub","Stage"),na.rm=T), aes(x=Stage, y=Density,fill=Stage )) +
  geom_boxplot(position=position_dodge(1),outlier.shape = NA,color=c("darkblue","darkmagenta",'black'))+
  scale_fill_manual(values=c("#AAAAEF","magenta",'grey'))+
  stat_summary(fun=mean, geom="point", shape=18, size=10, aes(group=Stage),
               position=position_dodge(1),color=c("darkblue","darkmagenta","black") ) +
  scale_y_continuous(breaks=seq(0,15,5))+
  coord_cartesian(ylim = c(0, 15))+
  theme_classic() 


## New plot for review
ggplot(summarySE(swto2[ !swto2$Sub %in% c('OL_13','OL_09'),], measurevar="Density", groupvars=c("Sub","Stage"),na.rm=T), aes(x=Stage, y=Density,fill=Stage )) +
  geom_boxplot(position=position_dodge(1),outlier.shape = NA,color=c("darkgoldenrod2","darkmagenta",'black'))+
  scale_fill_manual(values=c("gold","magenta",'grey'))+
  stat_summary(fun=mean, geom="point", shape=18, size=10, aes(group=Stage), position=position_dodge(1),color=c("darkgoldenrod2","darkmagenta",'black') ) +
  # ylim(-20,20)+
  theme_classic() + 
  scale_y_continuous(breaks=seq(0,30,5))+
  coord_cartesian(ylim = c(0, 30))+
  geom_line(aes(group=Sub), position = position_dodge(0.2),color = "grey90") +
  geom_point(aes(fill=Stage,group=Sub),size=2,shape=21, position = position_dodge(0.2)) +
  theme_classic() 

## review Cor between SW characteristics and pac
PAC_relVsIrrel <- read.csv("D:/Documents/Research/TMR/openLoop/bimanual_open_loop/data/group/OL/PAC_relVsIrrelForCor.csv", header=FALSE)#From statPAC_SO.m
shapiro.test(PAC_relVsIrrel$V3)

tmp1 = summarySE(swto2[ !swto2$Sub %in% c('OL_13','OL_09') & swto2$Stage=='0',], measurevar="Density", groupvars=c("Sub"))
shapiro.test(tmp1$Density)
cor.test(PAC_relVsIrrel$V3,  tmp1$Density, paired = T,alternative = 'less')

tmp2 = summarySE(swto2[ !swto2$Sub %in% c('OL_13','OL_09') & swto2$Stage=='0',], measurevar="PTP", groupvars=c("Sub"))
shapiro.test(tmp2$PTP)
cor.test(PAC_relVsIrrel$V3,  tmp2$PTP, paired = T,alternative = 'less',method = 'spearman')

cor.test(PAC_relVsIrrel$V3,  erpNegPeak$V2[c(1:8 , 10:12 , 14:24)], paired = T,alternative = 'less')

PACvsSW  = matrix(,22,7)
colnames(PACvsSW )=c("Sub","PAC_rel","PAC_irrel","PAC_diff","TMRndex","Density","PTP")
PACvsSW  = as.data.frame(PACvsSW )

allSubTmp= allSub[c(1:8, 10:12, 14:24)]
for (idx_sub in 1:length(allSubTmp))
{
  PACvsSW$Sub [idx_sub] =allSubTmp[idx_sub]
  PACvsSW$PAC_rel [idx_sub] =PAC_relVsIrrel$V2[idx_sub]
  PACvsSW$PAC_irrel [idx_sub] =PAC_relVsIrrel$V3[idx_sub]
  PACvsSW$PAC_diff [idx_sub] =PAC_relVsIrrel$V1[idx_sub]
  PACvsSW$TMRndex [idx_sub] =TMRIndex$index_RT[TMRIndex$Time=='both' & TMRIndex$Sub == allSubTmp[idx_sub]]
  PACvsSW$Density [idx_sub] =tmp1$Density[idx_sub]
  PACvsSW$PTP [idx_sub] =tmp2$PTP[idx_sub]
}

ggplot(PACvsSW, aes( x=TMRndex,y=PAC_diff)) +
  geom_point(color=c("darkblue")) +
  geom_smooth(method = lm,color="magenta",alpha=0.2,fill='magenta') +
  coord_cartesian(ylim = c(-0.15, 0.15 ))+
  stat_cor(method = "spearman")+
  theme_light()

ggplot(PACvsSW, aes( x=Density,y=PAC_irrel)) +
  geom_point(color=c("darkblue")) +
  geom_smooth(method = lm,color="magenta",alpha=0.2,fill='magenta') +
  coord_cartesian(ylim = c(-0.15, 0.15 ))+
  # stat_cor(method = "pearson")+
  
  theme_light()

ggplot(PACvsSW, aes( x=PTP,y=PAC_irrel)) +
  geom_point(color=c("darkblue")) +
  geom_smooth(method = lm,color="magenta",alpha=0.2,fill='magenta') +
  coord_cartesian(ylim = c(-0.15, 0.15 ))+
  # stat_cor(method = "spearman")+
  theme_light()

#Frequency and durantion
tmp = summarySE(swto2[ !swto2$Sub %in% c('OL_13','OL_09'),], measurevar="Frequency", groupvars=c("Sub","Stim"),na.rm=T)
testIrrel = t.test(tmp$Duration[tmp$Stage=='0'],tmp$Duration[tmp$Stage=='2'], paired=T)
testRel = t.test(tmp$Duration[tmp$Stage=='1'],tmp$Duration[tmp$Stage=='2'], paired=T)
test = t.test(tmp$Duration[tmp$Stage=='1'],tmp$Duration[tmp$Stage=='0'], paired=T)

test = t.test(tmp$Frequency[tmp$Stim=='No'],tmp$Frequency[tmp$Stim=='Yes'], paired=T)
p.adjust(c(testIrrel$p.value,testRel$p.value),n=2,method = 'fdr')



#TMR increases spindles density
#exclusion of OL_16  because not enough spindles

tmp = summarySE(spindles[ !spindles$Sub %in% c('OL_16'),], measurevar="Density", groupvars=c("Sub", "Stage"),na.rm=T)
shapiro.test(tmp$Density)

wilcox.test (c(tmp$Density[tmp$Stage==1]),c(tmp$Density[tmp$Stage==0] ), paired=T,alternative = 'greater')
#rest
tmp = summarySE(spindles[ !spindles$Sub %in% c('OL_16'),], measurevar="Density", groupvars=c("Sub","Stim"),na.rm=T)
shapiro.test(tmp$Density)
testStimvsRest = wilcox.test(tmp$Density[tmp$Stim=='Yes'],tmp$Density[tmp$Stim=='No'], paired=T)

ggplot(summarySE(spindles[ !spindles$Sub %in% c('OL_16'),], measurevar="Density", groupvars=c("Sub","Stim"),na.rm=T), aes(x=Stim, y=Density,fill=Stim )) +
  geom_boxplot(position=position_dodge(1),outlier.shape = NA,color=c("black","grey39"))+
  stat_summary(fun=mean, geom="point", shape=18, size=10, aes(group=Stim), position=position_dodge(1),color=c("black","grey39") ) +
  scale_fill_manual(values=c("grey",'black'))+
  theme_classic() 


## New plot for review
ggplot(summarySE(spindles[ !spindles$Sub %in% c('OL_16'),], measurevar="Density", groupvars=c("Sub","Stim"),na.rm=T), aes(x=Stim, y=Density,fill=Stim )) +
  geom_boxplot(position=position_dodge(1),outlier.shape = NA,color=c("black","grey39"))+
  stat_summary(fun=mean, geom="point", shape=18, size=10, aes(group=Stim), position=position_dodge(1),color=c("black","grey39") ) +
  scale_fill_manual(values=c("grey",'black'))+
  geom_line(aes(group=Sub), position = position_dodge(0.2),color = "grey90") +
  geom_point(aes(fill=Stim,group=Sub),size=2,shape=21, position = position_dodge(0.2)) +
  theme_classic() 

#TMR increases spindles Frequency
tmp = summarySE(spindles[ !spindles$Sub %in% c('OL_16'),], measurevar="Frequency", groupvars=c("Sub", "Stage"),na.rm=T)
shapiro.test(tmp$Frequency)
t.test (c(tmp$Frequency[tmp$Stage==1]),c(tmp$Frequency[tmp$Stage==0]), paired=T,alternative = 'greater')
#No
#rest
tmp = summarySE(spindles[ !spindles$Sub %in% c('OL_16'),], measurevar="Frequency", groupvars=c("Sub","Stim"),na.rm=T)
shapiro.test(tmp$Frequency)
testStimvsRest = t.test(tmp$Frequency[tmp$Stim=='Yes'],tmp$Frequency[tmp$Stim=='No'], paired=T)
mean(tmp$Frequency[tmp$Stim=='Yes']);sd(tmp$Frequency[tmp$Stim=='Yes'])
mean(tmp$Frequency[tmp$Stim=='No']);sd(tmp$Frequency[tmp$Stim=='No'])
cor.test(tmp$Frequency[tmp$Stim=='Yes'],tmp$Frequency[tmp$Stim=='No'], paired=T)


ggplot(summarySE(spindles[ !spindles$Sub %in% c('OL_16'),], measurevar="Frequency", groupvars=c("Sub","Stim"),na.rm=T), aes(x=Stim, y=Frequency,fill=Stim )) +
  geom_boxplot(position=position_dodge(1),outlier.shape = NA,color=c("black","grey39"))+
  stat_summary(fun=mean, geom="point", shape=18, size=10, aes(group=Stim), position=position_dodge(1),color=c("black","grey39") ) +
  scale_fill_manual(values=c("grey",'black'))+
  theme_classic() 

## New plot for review
ggplot(summarySE(spindles[ !spindles$Sub %in% c('OL_16'),], measurevar="Frequency", groupvars=c("Sub","Stim"),na.rm=T), aes(x=Stim, y=Frequency,fill=Stim )) +
  geom_boxplot(position=position_dodge(1),outlier.shape = NA,color=c("black","grey39"))+
  stat_summary(fun=mean, geom="point", shape=18, size=10, aes(group=Stim), position=position_dodge(1),color=c("black","grey39") ) +
  scale_fill_manual(values=c("grey",'black'))+
  geom_line(aes(group=Sub), position = position_dodge(0.2),color = "grey90") +
  geom_point(aes(fill=Stim,group=Sub),size=2,shape=21, position = position_dodge(0.2)) +
  theme_classic() 

#TMR increases spindles Amplitude
tmp = summarySE(spindles[ !spindles$Sub %in% c('OL_16'),], measurevar="Amplitude", groupvars=c("Sub", "Stage"),na.rm=T)
shapiro.test(tmp$Amplitude)

wilcox.test (c(tmp$Amplitude[tmp$Stage==1]),c(tmp$Amplitude[tmp$Stage==0]), paired=T,alternative = 'greater')
#No
#rest

tmp = summarySE(spindles[ !spindles$Sub %in% c('OL_16'),], measurevar="Amplitude", groupvars=c("Sub","Stim"),na.rm=T)
shapiro.test(tmp$Amplitude)
testStimvsRest = wilcox.test(tmp$Amplitude[tmp$Stim=='Yes'],tmp$Amplitude[tmp$Stim=='No'], paired=T)
mean(tmp$Amplitude[tmp$Stim=='Yes']);sd(tmp$Amplitude[tmp$Stim=='Yes'])
mean(tmp$Amplitude[tmp$Stim=='No']);sd(tmp$Amplitude[tmp$Stim=='No'])
cor.test(tmp$Amplitude[tmp$Stim=='Yes'],tmp$Amplitude[tmp$Stim=='No'], paired=T)


ggplot(summarySE(spindles[ !spindles$Sub %in% c('OL_16'),], measurevar="Amplitude", groupvars=c("Sub","Stim"),na.rm=T), aes(x=Stim, y=Amplitude,fill=Stim )) +
  geom_boxplot(position=position_dodge(1),outlier.shape = NA,color=c("black","grey39"))+
  scale_fill_manual(values=c("grey",'black'))+
  stat_summary(fun=mean, geom="point", shape=18, size=10, aes(group=Stim), position=position_dodge(1),color=c("black","grey39") ) +
  theme_classic() 

tmp = summarySE(spindles[ !spindles$Sub %in% c('OL_16'),], measurevar="Amplitude_filtered", groupvars=c("Sub","Stim"),na.rm=T)
shapiro.test(tmp$Amplitude_filtered)
testStimvsRest = wilcox.test(tmp$Amplitude_filtered[tmp$Stim=='Yes'],tmp$Amplitude_filtered[tmp$Stim=='No'], paired=T)
mean(tmp$Amplitude_filtered[tmp$Stim=='Yes']);sd(tmp$Amplitude_filtered[tmp$Stim=='Yes'])
mean(tmp$Amplitude_filtered[tmp$Stim=='No']);sd(tmp$Amplitude_filtered[tmp$Stim=='No'])
cor.test(tmp$Amplitude_filtered[tmp$Stim=='Yes'],tmp$Amplitude_filtered[tmp$Stim=='No'], paired=T)


ggplot(summarySE(spindles[ !spindles$Sub %in% c('OL_16'),], measurevar="Amplitude_filtered", groupvars=c("Sub","Stim"),na.rm=T), aes(x=Stim, y=Amplitude_filtered,fill=Stim )) +
  geom_boxplot(position=position_dodge(1),outlier.shape = NA,color=c("black","grey39"))+
  scale_fill_manual(values=c("grey",'black'))+
  stat_summary(fun=mean, geom="point", shape=18, size=10, aes(group=Stim), position=position_dodge(1),color=c("black","grey39") ) +
  theme_classic() 

## New plot for review
ggplot(summarySE(spindles[ !spindles$Sub %in% c('OL_16'),], measurevar="Amplitude_filtered", groupvars=c("Sub","Stim"),na.rm=T), aes(x=Stim, y=Amplitude_filtered,fill=Stim )) +
  geom_boxplot(position=position_dodge(1),outlier.shape = NA,color=c("black","grey39"))+
  stat_summary(fun=mean, geom="point", shape=18, size=10, aes(group=Stim), position=position_dodge(1),color=c("black","grey39") ) +
  scale_fill_manual(values=c("grey",'black'))+
  geom_line(aes(group=Sub), position = position_dodge(0.2),color = "grey90") +
  geom_point(aes(fill=Stim,group=Sub),size=2,shape=21, position = position_dodge(0.2)) +
  theme_classic()


#Plot SO Gd Avg
gdAvgSO <- read.table("D:/Documents/Research/TMR/openLoop/bimanual_open_loop/data/group/OL/gdAvg_SO.csv", quote="\"", comment.char="")#from pplot_grand_average.py
colnames(gdAvgSO)=c("Stage",'Time','Amplitude','SE')
gdAvgSO$Stage = as.factor(gdAvgSO$Stage)
gdAvgSO$Time = as.numeric(gdAvgSO$Time)
gdAvgSO$Amplitude = as.numeric(gdAvgSO$Amplitude)
gdAvgSO$SE = as.numeric(gdAvgSO$SE)


ggplot( gdAvgSO, aes(x=Time, y=Amplitude,group=Stage,colour=Stage )) + 
  geom_line(size = 0.5) +
  scale_color_manual(values=c("darkgoldenrod2","magenta",'grey')) +
  geom_ribbon(aes(ymin=Amplitude-SE, ymax=Amplitude+SE,fill = Stage),alpha= 0.5,colour = NA)+
  scale_fill_manual(values=c("darkgoldenrod2","magenta",'grey')) +
  # scale_y_continuous(breaks=seq(-80,20,20))+
  # scale_x_continuous(breaks=seq(-0.4,1,0.2))+
  # coord_cartesian(ylim = c(-90, 30),xlim = c(-1.1,2.1))+
  scale_y_continuous(breaks=seq(-90,-60,10))+
  scale_x_continuous(breaks=seq(-0.1,0.1,0.05))+
  coord_cartesian(ylim = c(-90, -60),xlim = c(-0.1,0.1))+
  theme_classic()


### Correlations

# relative change between theERP Amplitude at trough and TMR
erpVsTMR = cor.test((erp$DV[erp$erpCond=='negPeak' & erp$Condition=='rel']-erp$DV[erp$erpCond=='negPeak' & erp$Condition=='irrel'])/erp$DV[erp$erpCond=='negPeak' & erp$Condition=='irrel'],
                    TMRIndex$index_RT[TMRIndex$Time=='both'],paired =T,alternative = 'greater',method='spearman')
shapiro.test(erp$DV[erp$erpCond=='negPeak' & erp$Condition=='rel']-erp$DV[erp$erpCond=='negPeak' & erp$Condition=='irrel'])
shapiro.test(TMRIndex$index_RT[TMRIndex$Time=='both'])

# no

#relative change between the density of spontaneous SO  and TMR index

tmp = summarySE(swto2[ !swto2$Sub %in% c('OL_13','OL_09'),], measurevar="Density", groupvars=c("Sub","Stage"),na.rm=T)
shapiro.test((tmp$Density[tmp$Stage=='1']-tmp$Density[tmp$Stage=='0'])/tmp$Density[tmp$Stage=='0'])
shapiro.test(TMRIndex$index_RT[TMRIndex$Time=='both' &  !TMRIndex$Sub %in% c('OL_13','OL_09') ])
SOVsTMR = cor.test((tmp$Density[tmp$Stage=='1']-tmp$Density[tmp$Stage=='0'])/tmp$Density[tmp$Stage=='0'],TMRIndex$index_RT[TMRIndex$Time=='both' &  !TMRIndex$Sub %in% c('OL_13','OL_09') ],
         paired=T,alternative = 'greater',method = 'spearman')


#relative change between the density of spontaneous spindles  and TMR index

tmp = summarySE(spindles[ !spindles$Sub %in% c('OL_16'),], measurevar="Density", groupvars=c("Sub","Stage"),na.rm=T)
shapiro.test((tmp$Density[tmp$Stage=='1']-tmp$Density[tmp$Stage=='0'])/tmp$Density[tmp$Stage=='0'])
spVsTMR = cor.test(TMRIndex$index_RT[TMRIndex$Time=='both' &  !TMRIndex$Sub %in% c('OL_16') ],(tmp$Density[tmp$Stage=='1']-tmp$Density[tmp$Stage=='0']),
         paired=T,alternative = 'greater',method = "spearman")


p.adjust(c(erpVsTMR$p.value,SOVsTMR$p.value,spVsTMR$p.value),n=3,method = 'fdr')




#relative change between the amplitude of spontaneous spindles and TMR index

#Without OL_16

tmp = summarySE(spindles[ !spindles$Sub %in% c('OL_16'),], measurevar="Amplitude", groupvars=c("Sub","Stage"),na.rm=T)
shapiro.test((tmp$Amplitude[tmp$Stage=='1']-tmp$Amplitude[tmp$Stage=='0'])/tmp$Amplitude[tmp$Stage=='0'])
cor.test(TMRIndex$index_RT[TMRIndex$Time=='both' &  !TMRIndex$Sub %in% c('OL_16') ],(tmp$Amplitude[tmp$Stage=='1']-tmp$Amplitude[tmp$Stage=='0'])/tmp$Amplitude[tmp$Stage=='0'],
         paired=T,alternative = 'greater',method = "spearman")


tmpPlot = matrix(,23,3)
colnames(tmpPlot)=c("Sub","TMRIndex","Relative_Change_Spindle_Amplitude")
tmpPlot = as.data.frame(tmpPlot)
tmpPlot$Sub = allSub[c(1:12,14:24)]
tmpPlot$TMRIndex =TMRIndex$index_RT[TMRIndex$Time=='both' &  !TMRIndex$Sub %in% c('OL_13') ]
tmpPlot$Relative_Change_Spindle_Amplitude = (tmp$Amplitude[tmp$Stage=='1']-tmp$Amplitude[tmp$Stage=='0'])/tmp$Amplitude[tmp$Stage=='0']

ggplot(tmpPlot, aes(x=TMRIndex, y=Relative_Change_Spindle_Amplitude)) +
  geom_point(aes(colour = factor(Sub))) +
  geom_smooth(method = lm,color="magenta",alpha=0.2) +
  stat_cor(method = "spearman")






# Correlation extracted from Fieldtrip
TMRvsClusterSubtraction <- read.delim("TMRvsClusterSubtraction.csv", header=F,sep=',')
TMRvsPAC <- read.delim("TMRvsPAC.csv", header=F,sep=',')

recapDF = matrix(,24*3,7)
colnames(recapDF)=c("Sub","Condition","Gain","Cluster1",'PAC')
recapDF = as.data.frame(recapDF)
counter = 1
for (idx_sub in 1:length(allSub))
{
  recapDF$Sub [c(counter, counter+1, counter+2)] =allSub[idx_sub]
  
  recapDF$Condition[counter]   = 'diff'
  recapDF$Gain[counter]        = TMRIndex$index_RT[TMRIndex$Sub==allSub[idx_sub]  & TMRIndex$Time=='both' ]
  recapDF$Cluster1[counter]    = TMRvsClusterSubtraction$Diff1[idx_sub]
  recapDF$Cluster2[counter]    = TMRvsClusterSubtraction$Diff2[idx_sub]
  recapDF$Cluster3[counter]    = TMRvsClusterSubtraction$Diff3[idx_sub]
  recapDF$PAC[counter]         = TMRvsPAC$V1[idx_sub]
  
  
  
  recapDF$Condition[counter+1] = 'react'
  recapDF$Gain[counter+1]      = offLineGain$Gain_RT[offLineGain$Sub==allSub[idx_sub]  & offLineGain$Time=='both' & offLineGain$Condition==' react']
  recapDF$Cluster1[counter+1]  = TMRvsClusterSubtraction$Stim1[idx_sub]
  recapDF$Cluster2[counter+1]  = TMRvsClusterSubtraction$Stim2[idx_sub]
  recapDF$Cluster3[counter+1]  = TMRvsClusterSubtraction$Stim3[idx_sub]
  recapDF$PAC[counter+1]       = TMRvsPAC$V2[idx_sub]
  
  recapDF$Condition[counter+2] = 'notReact'
  recapDF$Gain[counter+2]      = offLineGain$Gain_RT[offLineGain$Sub==allSub[idx_sub]  & offLineGain$Time=='both' & offLineGain$Condition==' notReact']
  recapDF$Cluster1[counter+2]  = TMRvsClusterSubtraction$Random1[idx_sub]
  recapDF$Cluster2[counter+2]  = TMRvsClusterSubtraction$Random2[idx_sub]
  recapDF$Cluster3[counter+2]  = TMRvsClusterSubtraction$Random3[idx_sub]
  recapDF$PAC[counter+2]       = TMRvsPAC$V2[idx_sub]
  
  
  counter = counter+3
  
}


#Normality check
shapiro.test(TMRvsClusterSubtraction$Diff1)
shapiro.test(TMRvsClusterSubtraction$Diff2)
shapiro.test(TMRvsClusterSubtraction$Diff3)
shapiro.test(TMRvsClusterSubtraction$Stim1)
shapiro.test(TMRvsClusterSubtraction$Stim2)
shapiro.test(TMRvsClusterSubtraction$Stim3)
shapiro.test(TMRvsClusterSubtraction$Random1)
shapiro.test(TMRvsClusterSubtraction$Random2)
shapiro.test(TMRvsClusterSubtraction$Random3)
#=> Not normal spearman correlations

#Diff vs Index

ggplot(recapDF[recapDF$Condition=='diff'& !recapDF$Sub %in% c('OL_13','OL_09','OL_01'),], aes(x=Gain, y=PAC)) +
  geom_point() +
  geom_smooth(method = lm,color="magenta",alpha=0.2) +
  stat_cor(method = "spearman")


ggplot(recapDF[recapDF$Condition=='diff' & !recapDF$Sub %in% c('OL_13','OL_01'),], aes(x=Gain, y=Cluster1)) +
  geom_point(aes(colour = factor(Sub))) +
  geom_smooth(method = lm,color="magenta",alpha=0.2) +
  stat_cor(method = "spearman")

ggplot(recapDF[recapDF$Condition=='diff'  ,], aes(x=Gain, y=Cluster1)) +
  geom_point(aes(colour = factor(Sub))) +
  geom_smooth(method = lm,color="magenta",alpha=0.2) +
  stat_cor(method = "spearman")


ggplot(recapDF[recapDF$Condition=='diff' & !recapDF$Sub %in% c('OL_13','OL_01'),], aes(x=Gain, y=Cluster2)) +
  geom_point(aes(colour = factor(Sub))) +
  geom_smooth(method = lm,color="magenta",alpha=0.2) +
  stat_cor(method = "spearman")

ggplot(recapDF[recapDF$Condition=='diff',], aes(x=Gain, y=Cluster2)) +
  geom_point(aes(colour = factor(Sub))) +
  geom_smooth(method = lm,color="magenta",alpha=0.2) +
  stat_cor(method = "spearman")



ggplot(recapDF[recapDF$Condition=='diff' & !recapDF$Sub %in% c('OL_13','OL_01'),], aes(x=Gain, y=Cluster3)) +
  geom_point(aes(colour = factor(Sub))) +
  geom_smooth(method = lm,color="magenta",alpha=0.2) +
  stat_cor(method = "spearman")

ggplot(recapDF[recapDF$Condition=='diff' ,], aes(x=Gain, y=Cluster3)) +
  geom_point(aes(colour = factor(Sub))) +
  geom_smooth(method = lm,color="magenta",alpha=0.2) +
  stat_cor(method = "spearman")


