import mne 
import yasa
import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
from matplotlib.widgets import Slider, Button, RadioButtons
from mne.filter import resample, filter_data
import pingouin as pg
from copy import deepcopy
from scipy.stats import skewnorm
from scipy.linalg import eigh
from scipy.interpolate import RectBivariateSpline
from scipy.signal import find_peaks, welch, detrend,hilbert
import math
import seaborn as sns
import collections 


subjects = ['OL_01' , 'OL_02', 'OL_03', 'OL_04' , 'OL_05' , 'OL_06' , 'OL_07', 'OL_08', 'OL_09', 'OL_10', 'OL_11', 'OL_12',  'OL_13', 'OL_14',
            'OL_15','OL_16',  'OL_17', 'OL_18', 'OL_19' ,'OL_20','OL_21','OL_22' ,'OL_23' ,'OL_24'] 
channels = np.array(['Fz','Cz','Pz','Oz','C3','C4'])
# channels = np.array(['all'])

data_all = {}

for sub in subjects:
    print('Loading data for subject {}  \n'.format(sub))

    f = np.loadtxt('D:\\Documents\\Research\\TMR\\openLoop\\bimanual_open_loop\\data\\{}\\exp\{}_withRest_yasa.txt'.format(sub,sub),delimiter = ',')
    data_all.update({sub: [np.nan_to_num(f[:,4:10].T),f[:,1].T,f[:,2].T,f[-1,0]]})
    
    print('Data loaded for subject {}  \n'.format(sub))






df_sp = []
df_sp_sync = []

for sub in subjects:
    print('Detecting spindles for subject {}  \n'.format(sub))

    sp = yasa.spindles_detect(data = data_all[sub][0], sf = data_all[sub][3], hypno=data_all[sub][2], include=(0,1,2), ch_names=channels, 
                              freq_sp=(12,16),duration=(0.5, 3),
                              coupling = False, freq_sw=(0.3,2))
    if sp is not None:
        spSummary = sp.summary(grp_stage=True,grp_chan=True)
        spSummary['Sub'] = sub
        df_sp.append(spSummary)
        data_all[sub].append(sp.get_mask())
        
                
        sync = sp.get_sync_events(center="Peak", time_before=1,
                                       time_after=1, filt=(None, None))
        sync['Sub'] = sub

        df_sp_sync.append(sync)

        
df_sp = pd.concat(df_sp)
df_sp = df_sp.reset_index()
df_sp.to_csv('D:\\Documents\\Research\\TMR\\openLoop\\bimanual_open_loop\\data\\group\\ol\\Spindles_withRest.csv')

df_sw = []
df_sw_sync = []

for sub in subjects:
    
    sw = yasa.sw_detect(data_all[sub][0], data_all[sub][3], hypno=data_all[sub][2], 
                        include=(0,1,2), ch_names=channels,   
                        coupling=True,freq_sp=(12,16))
    if sw is not None:
        swSummary = sw.summary(grp_stage=True,grp_chan=True)
        swSummary['Sub'] = sub
        df_sw.append(swSummary)
        data_all[sub].append(sw.get_mask())
        
        sync = sw.get_sync_events(center="NegPeak", time_before=1,
                                        time_after=2, filt=(None, None))
        sync['Sub'] = sub

        df_sw_sync.append(sync)
        
        
        

df_sw = pd.concat(df_sw)
df_sw = df_sw.reset_index()
df_sw_sync = pd.concat(df_sw_sync)
df_sw = df_sw.reset_index()
df_sw.to_csv('D:\\Documents\\Research\\TMR\\openLoop\bimanual_open_loop\\data\\group\\OL\\allswto2_withRest.csv')
df_sw.to_csv('D:\\Documents\\Research\\TMR\\openLoop\\bimanual_open_loop\\data\\group\\OL\\df_sw.npy')
