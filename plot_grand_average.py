# -*- coding: utf-8 -*-
"""
Created on Fri Oct 16 10:56:26 2020

@author: u0129763
"""

df_sw = np.load('D:\\Documents\\Research\\TMR\\openLoop\\bimanual_open_loop\\data\\group\\df_sw.npy',allow_pickle='TRUE')
#computed from SO_spindles analysis


df_sw_sync.groupby(['Sub','Stage']).mean()


tmpSub = df_sw_sync.groupby(['Sub','Stage','Time']).mean()
tmpSub = tmpSub.reset_index()

times = np.arange(-1,2.001,1/500)
stages = np.arange(0,2.001,1)

tmp= np.zeros((4503,4))
counter = 0
for s   in stages :
    for i   in times :
        print('computing time {} of stage {}  \n'.format(i,s))

        tmp[counter,0] = s 
        tmp[counter,1] = i
        tmp[counter,2] = df_sw_sync['Amplitude'][(df_sw_sync['Stage']==s) & (df_sw_sync['Time']==round(i,3))].mean()
        tmp[counter,3] = (np.std(df_sw_sync['Amplitude'][ (df_sw_sync['Stage']==s) & (df_sw_sync['Time']==round(i,3))],ddof = 1)) /np.sqrt(np.size(df_sw_sync['Amplitude'][ (df_sw_sync['Stage']==s) & (df_sw_sync['Time']==round(i,3))]))
        
        counter = counter +1
        
        


df_sw_sync.mean()



tmp = df_sw_sync.groupby(['Stage','Time']).mean()
tmp = tmp.reset_index()
tmp['SE']= tmpSE['Amplitude'].values

tmp.to_csv("D:\\Documents\\Research\\TMR\\openLoop\\bimanual_open_loop\\data\\group\\OL\\gdAvg_SO.csv")
