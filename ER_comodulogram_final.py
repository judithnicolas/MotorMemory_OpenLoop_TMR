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



subjects = ['OL_01', 'OL_02', 'OL_03', 'OL_04' , 'OL_05' , 'OL_06' , 'OL_07', 'OL_08', 'OL_09', 'OL_10', 'OL_11', 'OL_12',  'OL_13', 'OL_14',
            'OL_15','OL_16',  'OL_17', 'OL_18', 'OL_19' ,'OL_20','OL_21','OL_22' ,'OL_23' ,'OL_24'] 

data_ER= {}

for sub   in subjects:
    data = np.loadtxt('D:\\Documents\\Research\\TMR\\openLoop\\bimanual_open_loop\\data\\{}\\exp\{}_ERpac_avgOverChan_corrected.txt'.format(sub,sub),delimiter = ',')
    
    sf = 500
    data_ER.update({sub:  [data[data[:,-3]==1][:,0:-3],data[data[:,-3]==0][:,0:-3],np.arange(-1,3.001,1/sf),sf]})


        



###############################################################################
# Compute and plot the Event-Related PAC
###############################################################################

rp_obj = EventRelatedPac(f_pha=[0.5,2], f_amp=np.arange(7, 30, 0.5))


df_erpac_rel = []
df_erpac_irrel = []

for sub   in subjects:

    df_ercpac = []
    erpac = rp_obj.filterfit( data_ER[sub][3], data_ER[sub][0], method='gc', smooth=100)
    df_ercpac = pd.DataFrame(erpac.squeeze())
    df_erpac_rel.append(df_ercpac)
    print('\nRelevant computed for subject {} \n'.format(sub))
    np.savetxt('D:\\Documents\\Research\\TMR\\openLoop\\bimanual_open_loop\\data\\{}\\exp\{}_pacER_rel_avgOverChan_corrected.txt'.format(sub,sub), erpac.squeeze(),delimiter = ',')

    
    df_ercpac = []
    erpac = rp_obj.filterfit( data_ER[sub][3], data_ER[sub][1], method='gc', smooth=100)
    df_ercpac = pd.DataFrame(erpac.squeeze())
    df_erpac_irrel.append(df_ercpac)
    print('\nIrrelevant computed for subject {} \n'.format(sub))
    np.savetxt('D:\\Documents\\Research\\TMR\\openLoop\\bimanual_open_loop\\data\\{}\\exp\{}_pacER_irrel_avgOverChan_corrected.txt'.format(sub,sub), erpac.squeeze(),delimiter = ',')



###############################################################################
# Identify the preferred phase
###############################################################################


df_ERPP_rel = []
df_ERPP_irrel = []


# define the preferred phase object
# only extract the SO phase
pp_obj = PreferredPhase(f_pha=[0.5, 2])
p_obj = Pac(idpac=(6, 2, 0), f_pha=np.arange(0.3,1.8, 0.5), f_amp=np.arange(10,19, 1))
n_bins = 72

for sub   in subjects:

    print('Processing subject {} \n'.format(sub))

    
    df_ampBin = []
    pp_pha = pp_obj.filter(data_ER[sub][3],data_ER[sub][0], ftype='phase')
    amp = p_obj.filter(data_ER[sub][3],data_ER[sub][0], ftype='amplitude')
    ampbin, _, vecbin = pp_obj.fit(pp_pha, amp, n_bins=n_bins)
    df_ampBin = pd.DataFrame(np.squeeze(ampbin).mean(-1).T)

    df_ERPP_rel.append(df_ampBin)  
    
    print('Relevant condition computed for subject {}  \n'.format(sub))
    
    df_ampBin = []
    pp_pha = pp_obj.filter(data_ER[sub][3],data_ER[sub][1], ftype='phase')
    amp = p_obj.filter(data_ER[sub][3],data_ER[sub][1], ftype='amplitude')
    ampbin, _, vecbin = pp_obj.fit(pp_pha, amp, n_bins=n_bins)
    df_ampBin = pd.DataFrame(np.squeeze(ampbin).mean(-1).T)

    df_ERPP_irrel.append(df_ampBin)  
    
    print('Irrelevant condition computed for subject {} \n'.format(sub))

    
        
df_ERPP_rel = pd.concat(df_ERPP_rel)
df_ERPP_irrel = pd.concat(df_ERPP_irrel)

df_ERPP_rel.index.name  = 'FreqAmplitude'
df_ERPP_irrel.index.name  = 'FreqAmplitude'




PP_rel = vecbin[np.argmax(df_ERPP_rel.values.reshape(len(subjects),len(p_obj.yvec),n_bins).mean(1),1)]
PP_irrel = vecbin[np.argmax(df_ERPP_irrel.values.reshape(len(subjects),len(p_obj.yvec),n_bins).mean(1),1)]

np.savetxt('D:\\Documents\\Research\\TMR\\openLoop\\bimanual_open_loop\\data\\group\\OL\\PP_rel_avgOverChan_corrected.txt'.format(sub,sub), PP_rel,delimiter = ',')
np.savetxt('D:\\Documents\\Research\\TMR\\openLoop\\bimanual_open_loop\\data\\group\\OL\\PP_irrel_avgOverChan_corrected.txt'.format(sub,sub), PP_irrel,delimiter = ',')











