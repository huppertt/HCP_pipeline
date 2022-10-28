#!/usr/bin/env python

"""
Created on Tue Sep  6 10:54:49 2016

@author: huppert
"""

import sys
import mne
import os
import numpy as np
#import matplotlib.pyplot as plt
#import nibabel

import warnings
warnings.filterwarnings("ignore", category=DeprecationWarning) 


HCProot='/disk/HCP'
bads=[] #'MEG1212','MEG1421']   
reject = dict(mag=5e-11, grad=4000e-12)
mne.set_config('MNE_STIM_CHANNEL', 'STI101')

snr = 3
lambda2 = 1/snr**2

tmin, tmax = -0.2, 0.5
baseline = (None, 0)

method = 'MNE' # method can be MNE, dSPM, sLORETA

try:
    subj = os.environ['SUBJECT']
except:
    print("MNE SUBJECT not set")
    sys.exit(1)
    
if isinstance(subj,int):    
    subj=str(subj)
    
    
fileList=['MEG_MOTOR1','MEG_MOTOR2','MEG_MOTOR3',
          'MEG_WM1', 'MEG_WM2','MEG_WM3']
         # 'MEG_LANGUAGE1','MEG_LANGUAGE2','MEG_LANGUAGE3']
          

for fI in fileList:
    sssf = HCProot + '/analyzed/' + subj + '/' + fI + '/' + subj + '-' + fI + '-prep.fif'

    if (os.path.isfile(sssf)): 

        megdir = HCProot + '/analyzed/' + subj + '/' + fI
        os.makedirs(megdir + '/megstats', exist_ok=True)
                    
        filen = HCProot + '/analyzed/' + subj + '/' + fI + '/' + subj + '-' + fI

        fwdfile = filen + '-prep-fwd.fif.gz'

        raw = mne.io.read_raw_fif(sssf, preload=True)
        raw.info['bads']=bads 

        picks = mne.pick_types(raw.info, meg=True, eeg=False, eog=False, stim=False, 
                       exclude='bads')
        
        #fwd = mne.read_forward_solution(fwdfile)
        inv = mne.minimum_norm.read_inverse_operator(filen + '-prep-inv.fif.gz')                
        
                         
        events = mne.find_events(raw,uint_cast=True)                       
        if fI in ['MEG_MOTOR1' ,'MEG_MOTOR2' ,'MEG_MOTOR3']:
            print('Motor')
            event_id = {'LHand':22, 'RHand':70, 'LFoot':38, 'RFoot':134}
        elif fI in ['MEG_WM1', 'MEG_WM2' ,'MEG_WM3']:
            print('Working Memory')    
            event_id = {'0-Bk Face NonTarget':10, '0-Bk Face Lure':12, '0-Bk Face Target':14, 
                '0-Bk Tool NonTarget':42, '0-Bk Tool Lure':44, '0-Bk Tool Target':46, 
                '2-Bk Face NonTarget':74, '2-Bk Face Lure':76, '2-Bk Face Target':78,
                '2-Bk Tool NonTarget':106, '2-Bk Tool Lure':108, '2-Bk Tool Target':110}
        elif fI in ['MEG_LANGUAGE1' ,'MEG_LANGUAGE2' ,'MEG_LANGUAGE3']:
            print('Story/Math')
            event_id = {'StoryOnset':56, 'StoryQOnset':46, 'StoryCorrOpt':44, 'StoryIncOpt':42,
                'StoryResp':34, 'MathInst':88, 'MathQ1st':74, 'MathQ2nd':76}

        for key in event_id:                  
            fileo = megdir +'/megstats/' + subj + '-' + key            
            epochs = mne.Epochs(raw, events=events, event_id=event_id[key], tmin=tmin, tmax=tmax, 
                        baseline=baseline, reject=reject, picks=picks)
            epochs.save(fileo + '-epo.fif');
     
            evoked=epochs.average()
            evoked.save(fileo + '-ave.fif')
            #mfig, gfig = evoked.plot_joint(times='auto',show=False,title=key)
            #gfig.savefig(fileo + 'evoked_jointplot_grad', transparent=True)
            #mfig.savefig(fileo + 'evoked_jointplot_mag', transparent=True)            
            #plt.close('all')
                 
            #cov = mne.compute_covariance(epochs, tmax=0, method=['shrunk','empirical'])
            #inv = mne.minimum_norm.make_inverse_operator(evoked.info, fwd, cov, loose=0.2, depth=0.8)
            #mne.minimum_norm.write_inverse_operator(fileo + '-inv.fif', inv)

            

            stc = mne.minimum_norm.apply_inverse(evoked, inv, lambda2, method)            
            stc.save(fileo, ftype='stc',verbose=True)
    
#            vertno_max, time_idx = stc.get_peak(time_as_index=True)
     
            stc_epochs = mne.minimum_norm.apply_inverse_epochs(epochs, inv, lambda2, method)    
            
            intercept = np.ones(len(stc_epochs), dtype=np.float)
            design_matrix = np.column_stack([intercept, np.linspace(0,1,len(intercept))-.5])

            # lm = mne.stats.linear_regression(stc_epochs, design_matrix)
            lm = mne.stats.linear_regression(stc_epochs, design_matrix)
            for k in lm:
                lm[k].beta.save(fileo + k +'_beta', ftype='stc', verbose=True)
                lm[k].stderr.save(fileo + k + '_stderr', ftype='stc', verbose=True)
                lm[k].t_val.save(fileo + k + '_t-val', ftype='stc', verbose=True)
                lm[k].p_val.save(fileo + k +'_p-val', ftype='stc', verbose=True)


            # beta = np.zeros(stc_epochs[0].data.shape)
            # MSE = np.zeros(stc_epochs[0].data.shape)
    
            # for i in range(0,len(stc_epochs)):
            #     beta=beta+stc_epochs[i].data[:][:]/len(stc_epochs)

            # for i in range(0,len(stc_epochs)):
            #     MSE=MSE+np.square(stc_epochs[i].data-beta)/len(stc_epochs)
    
            # T = beta/np.sqrt(MSE)
            # d=stc.data     
            # d=MSE
            # stc.data.data=d.data  # memory copy
            # stc.save(filen + '-MSE' ,ftype='stc',verbose=True)
    
            # d=T
            # stc.data.data=d.data  # memory copy
            # stc.save(filen + '-tstat' ,ftype='stc',verbose=True)
    

       