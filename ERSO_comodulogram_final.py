# -*- coding: utf-8 -*-
"""
Created on Fri Nov 13 15:31:59 2020

@author: u0129763
"""




import mne
import yasa
import numpy as np
import pandas as pd
import pingouin as pg

import seaborn as sns
import matplotlib.pyplot as plt


from tensorpac import Pac, EventRelatedPac, PreferredPhase
from tensorpac.utils import PeakLockedTF, PSD, ITC, BinAmplitude

import os
import urllib

import numpy as np
from scipy.io import loadmat

from tensorpac import Pac, EventRelatedPac, PreferredPhase
from tensorpac.utils import PeakLockedTF, PSD, ITC, BinAmplitude

import matplotlib.pyplot as plt




subjects = ['OL_01' , 'OL_02', 'OL_03', 'OL_04' , 'OL_05' , 'OL_06' , 'OL_07', 'OL_08', 'OL_09', 'OL_10', 'OL_11', 'OL_12',  'OL_13', 'OL_14',
            'OL_15','OL_16',  'OL_17', 'OL_18', 'OL_19' ,'OL_20','OL_21','OL_22' ,'OL_23' ,'OL_24'] 
channels = np.array(['all'])

data_avg = {}

for sub in subjects:
    print('Loading data for subject {}  \n'.format(sub))

    f = np.loadtxt('D:\\Documents\\Research\\TMR\\openLoop\\bimanual_open_loop\\data\\{}\\exp\{}_withRest_yasa_avgOverChan.txt'.format(sub,sub),delimiter = ',')
    data_avg.update({sub: [f[:-1,-1].T,f[:-1,1].T,f[:-1,2].T,f[-1,0]]})
    print('Data loaded for subject {}  \n'.format(sub))



data_ERSO ={}

#detection on avg
for sub in subjects:
    print('detecting SW of subject {}  \n'.format(sub))

    sw = yasa.sw_detect(data_avg[sub][0], data_avg[sub][3], hypno=data_avg[sub][2], 
                        include=(0,1,2), ch_names=channels)
    if sw is not None:
      
        sync = sw.get_sync_events(center="NegPeak", time_before=3,
                                       time_after=3, filt=(None, None))
        
        tmp = sync['Amplitude'].values.reshape(int(len(sync['Amplitude'])/len(sync['Amplitude'][sync['Event']==0])),int(len(sync['Amplitude'][sync['Event']==0])))
        
        data_ERSO.update({sub: [tmp[np.unique(sync['Event'][sync['Stage']==0]).tolist()],tmp[np.unique(sync['Event'][sync['Stage']==1]).tolist()],tmp[np.unique(sync['Event'][sync['Stage']==2]).tolist()]]})
        


times = np.arange(-3,3.001,1/500)
sf = 500
#detection on Fz
data_ERSO ={}

for sub in subjects:
    print('detecting SW of subject {}  \n'.format(sub))
    sw = yasa.sw_detect(data_avg[sub][0], data_avg[sub][3], hypno=data_avg[sub][2], freq_sw=(0.5, 2),
                        include=(0,1,2), ch_names=np.array(['Fz']))

    tmpirrel = []
    tmprel = []
    tmprest = []
    if len(sw._events['NegPeakSample'][sw._events['Stage']==0])>0:
        for idx_SW in sw._events['NegPeakSample'][sw._events['Stage']==0]:
            if idx_SW+3*sf< len(data_avg[sub][0]) and idx_SW-3*sf>0:
                tmpirrel.append( data_avg[sub][0][int(idx_SW-3*sf):int(idx_SW+3*sf)])
    if len(sw._events['NegPeakSample'][sw._events['Stage']==1])>0:
        for idx_SW in sw._events['NegPeakSample'][sw._events['Stage']==1]:
            if idx_SW+3*sf< len(data_avg[sub][0]) and idx_SW-3*sf>0:
                tmprel.append( data_avg[sub][0][int(idx_SW-3*sf):int(idx_SW+3*sf)])
    if len(sw._events['NegPeakSample'][sw._events['Stage']==1])>0:
        for idx_SW in sw._events['NegPeakSample'][sw._events['Stage']==2]:
            if idx_SW+3*sf< len(data_avg[sub][0]) and idx_SW-3*sf>0:
                tmprest.append( data_avg[sub][0][int(idx_SW-3*sf):int(idx_SW+3*sf)])
        tmpirrel=np.dstack(tmpirrel)
        tmprel=np.dstack(tmprel)
        tmprest=np.dstack(tmprest)
        data_ERSO.update({sub: [tmpirrel, tmprel,tmprest]})
    
    
###############################################################################
# Compute and plot the SO-Related PAC
###############################################################################

rp_obj = EventRelatedPac(f_pha=[0.5,2], f_amp=np.arange(7, 30, 0.5))


df_ERSOpac_rel = []
df_ERSOpac_irrel = []
df_ERSOpac_rest = []

for sub   in subjects:
    sf=500
     
    if  sub in data_ERSO.keys() and data_ERSO[sub][0].shape[2] > 4 and data_ERSO[sub][2].shape[2] > 4 and data_ERSO[sub][2].shape[2] > 4 :
        df_ERSOcpac = []
        ERSOpac = rp_obj.filterfit( sf, data_ERSO[sub][1].squeeze().T, method='gc', smooth=100)
        df_ERSOcpac = pd.DataFrame(ERSOpac.squeeze())
        df_ERSOpac_rel.append(df_ERSOcpac)
        print('\nRelevant computed for subject {} \n'.format(sub))
        np.savetxt('D:\\Documents\\Research\\TMR\\openLoop\\bimanual_open_loop\\data\\{}\\exp\{}_pacERSO_rel_avgOverCentralChan_detectionFz.txt'.format(sub,sub), ((ERSOpac.squeeze())),delimiter = ',')
         
        df_ERSOcpac = []
        ERSOpac = rp_obj.filterfit( sf, data_ERSO[sub][0].squeeze().T, method='gc', smooth=100)
        df_ERSOcpac = pd.DataFrame(ERSOpac.squeeze())
        df_ERSOpac_irrel.append(df_ERSOcpac)
        print('\nIrrelevant computed for subject {} \n'.format(sub))
        np.savetxt('D:\\Documents\\Research\\TMR\\openLoop\\bimanual_open_loop\\data\\{}\\exp\{}_pacERSO_irrel_avgOverCentralChan_detectionFz.txt'.format(sub,sub), ERSOpac.squeeze(),delimiter = ',')
         
         
        df_ERSOcpac = []
        ERSOpac = rp_obj.filterfit( sf, data_ERSO[sub][2].squeeze().T, method='gc', smooth=100)
        df_ERSOcpac = pd.DataFrame(ERSOpac.squeeze())
        df_ERSOpac_rest.append(df_ERSOcpac)
        print('\nRest computed for subject {} \n'.format(sub))
        np.savetxt('D:\\Documents\\Research\\TMR\\openLoop\\bimanual_open_loop\\data\\{}\\exp\{}_pacERSO_rest_avgOverCentralChan_detectionFz.txt'.format(sub,sub), ERSOpac.squeeze(),delimiter = ',')
    





###############################################################################
# Identify the preferred phase
###############################################################################


df_ERSOPP_rel = []
df_ERSOPP_irrel = []
df_ERSOPP_rest = []
times = np.arange(-3,3.00,1/500)


# define the preferred phase object
# only extract the SO phase
pp_obj = PreferredPhase(f_pha=[0.5, 2])
p_obj = Pac(idpac=(6, 2, 0), f_pha=np.arange(0.3,1.8, 0.5), f_amp=np.arange(12,18, 1))
n_bins = 72

for sub   in subjects:
    
    sf=500

    
    if  data_ERSO[sub][0].shape[0] > 4 and data_ERSO[sub][1].shape[0] > 4 and data_ERSO[sub][2].shape[0] > 4 :
    
    
        print('Processing subject {} \n'.format(sub))
    
        
        df_ampBin = []
        pp_pha = pp_obj.filter(sf,data_ERSO[sub][1][:,(times>-1) & (times<2)], ftype='phase')
        amp = p_obj.filter(sf,data_ERSO[sub][1][:,(times>-1) & (times<2)], ftype='amplitude')
        ampbin, _, vecbin = pp_obj.fit(pp_pha, amp, n_bins=n_bins)
        df_ampBin = pd.DataFrame(np.squeeze(ampbin).mean(-1).T)
    
        df_ERSOPP_rel.append(df_ampBin)  
        
        print('Relevant condition computed for subject {}  \n'.format(sub))
        
        df_ampBin = []
        pp_pha = pp_obj.filter(sf,data_ERSO[sub][0][:,(times>-1) & (times<2)], ftype='phase')
        amp = p_obj.filter(sf,data_ERSO[sub][0][:,(times>-1) & (times<2)], ftype='amplitude')
        ampbin, _, vecbin = pp_obj.fit(pp_pha, amp, n_bins=n_bins)
        df_ampBin = pd.DataFrame(np.squeeze(ampbin).mean(-1).T)
    
        df_ERSOPP_irrel.append(df_ampBin)  
        
        print('Irrelevant condition computed for subject {} \n'.format(sub))
    
            
        df_ampBin = []
        pp_pha = pp_obj.filter(sf,data_ERSO[sub][2][:,(times>-1) & (times<2)], ftype='phase')
        amp = p_obj.filter(sf,data_ERSO[sub][2][:,(times>-1) & (times<2)], ftype='amplitude')
        ampbin, _, vecbin = pp_obj.fit(pp_pha, amp, n_bins=n_bins)
        df_ampBin = pd.DataFrame(np.squeeze(ampbin).mean(-1).T)
    
        df_ERSOPP_rest.append(df_ampBin)  
        
        print('Rest condition computed for subject {} \n'.format(sub))

    
        
df_ERSOPP_rel = pd.concat(df_ERSOPP_rel)
df_ERSOPP_irrel = pd.concat(df_ERSOPP_irrel)
df_ERSOPP_rest = pd.concat(df_ERSOPP_rest)

df_ERSOPP_rel.index.name  = 'FreqAmplitude'
df_ERSOPP_irrel.index.name  = 'FreqAmplitude'
df_ERSOPP_rest.index.name  = 'FreqAmplitude'



PP_rel = vecbin[np.argmax(df_ERSOPP_rel.values.reshape(len(subjects)-2,len(p_obj.yvec),n_bins).mean(1),1)]
PP_irrel = vecbin[np.argmax(df_ERSOPP_irrel.values.reshape(len(subjects)-2,len(p_obj.yvec),n_bins).mean(1),1)]
PP_rest = vecbin[np.argmax(df_ERSOPP_rest.values.reshape(len(subjects)-2,len(p_obj.yvec),n_bins).mean(1),1)]


