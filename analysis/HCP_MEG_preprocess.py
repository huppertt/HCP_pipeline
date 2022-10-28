#!/usr/bin/env python

"""
Created on Fri Sep  2 12:17:30 2016

@author: huppert
"""

import sys
import mne
import os
#import matplotlib.pyplot as plt
import numpy as np


try:
    subjid = os.environ['SUBJECT']
except:
    print("MNE SUBJECT not set")
    sys.exit(1)
    
if isinstance(subjid,int):    
    subjid=str(subjid)


fileList=['MEG_MOTOR1' ,'MEG_MOTOR2' ,'MEG_MOTOR3','MEG_REST1' ,'MEG_REST2','MEG_REST3',
          'MEG_WM1' ',MEG_WM2' ,'MEG_WM3',
          'MEG_LANGUAGE1' ,'MEG_LANGUAGE2' ,'MEG_LANGUAGE3']
         
HCProot='/disk/HCP'
#subjid = 'HCPtest1'

# filtering and resample
fmin, fmax = 1, 100
fs=250

# ICA param
n_components = 20
method = 'fastica'
decim = 3

ncpu=2

bads=['MEG1212','MEG1421'] 

reject = dict(mag=5e-12, # T magnetometers
              grad=4000e-13, # T/m gradiometers
              )

bem = HCProot + '/analyzed/' + subjid + '/T1w/' + subjid + '/bem/' + subjid + '-bem-sol.fif'
src = HCProot + '/analyzed/' + subjid + '/T1w/' + subjid + '/bem/' + subjid + '-ico4-src.fif'


#raw_empty = mne.io.read_raw_fif(os.path.join(sample.data_path(),'MEG','sample','ernoise_raw.fif'))
#noise_cov = mne.compute_raw_covariance(raw_empty, tmin=0, tmax=None)
 
        
for fI in fileList:
     
    rawf = HCProot + '/analyzed/' + subjid + '/' + fI + '/' + subjid + '-' + fI + '-raw.fif'
    sssf = HCProot + '/analyzed/' + subjid + '/' + fI + '/' + subjid + '-' + fI + '-raw_sss.fif.gz'
    print(rawf)
    trans = HCProot + '/analyzed/' + subjid + '/' + fI + '/' + subjid + '-' + fI + '--test-trans.fif'
    
    if (os.path.isfile(rawf) & os.path.isfile(trans)): 
        print('Processing ' + fI)
        fwdfile = HCProot + '/analyzed/' + subjid + '/' + fI + '/' + subjid + '-' + fI + '-test-fwd.fif.gz'
        invfile = HCProot + '/analyzed/' + subjid + '/' + fI + '/' + subjid + '-' + fI +'test-inv.fif.gz'

        raw = mne.io.read_raw_fif(rawf, preload=True)
        raw.info['bads']=bads  

        picks = mne.pick_types(raw.info, meg=True, eeg=False, eog=False, stim=False, 
                       exclude='bads')

        
        # Preprocess the MEG        
        raw.filter(fmin, fmax, picks=picks, n_jobs=ncpu)
        raw.notch_filter(np.arange(60,fmax+1,60))
        raw.resample(fs, npad='auto')
        
        eog_epochs = mne.preprocessing.create_eog_epochs(raw, reject=reject)
        eog_avg = eog_epochs.average()
    
        ecg_epochs = mne.preprocessing.create_ecg_epochs(raw,reject=reject)
        ecg_avg = ecg_epochs.average()
            
        
        #%% ICA
        raw_ica=raw.copy()
        ica = mne.preprocessing.ICA(n_components=n_components, method=method)
        ica = ica.fit(raw_ica, picks=picks, decim=decim, reject=reject)
        
        eog_inds, scores = ica.find_bads_eog(eog_epochs)
    
        ecg_inds, scores = ica.find_bads_ecg(ecg_epochs)
    
        # remove EOG and ECG components 
        ica.exclude.extend(eog_inds + ecg_inds)     
        ica.apply(raw_ica)   
                
        #%% Maxwell filter
        raw_sss = mne.preprocessing.maxwell_filter(raw_ica)
    
        #%% SSP
        raw_sss_ssp=raw_sss.copy()        
    #    projs, events = mne.preprocessing.compute_proj_ecg(raw_sss_ssp, n_grad=1, n_mag=1, n_eeg=0, bads=raw_sss.info['bads'], average=True)  
    #    ecg_projs = projs[-2:]
        
        projs, events = mne.preprocessing.compute_proj_eog(raw_sss_ssp, n_grad=2, n_mag=2, n_eeg=0, bads=raw_sss.info['bads'], average=True)
        print(projs)
    
        eog_projs = projs[-2:]
        raw_sss_ssp = raw_sss_ssp.apply_proj() 
        
        raw_sss_ssp.save(sssf,overwrite=True)
        
        noise_cov = mne.compute_raw_covariance(raw_sss_ssp, tmin=0, tmax=None)
        
        if (os.path.isfile(fwdfile)):
            os.remove(fwdfile)
        if (os.path.isfile(invfile)):
            os.remove(invfile)
        fwd = mne.make_forward_solution(raw.info, trans=trans, src=src, bem=bem, fname=fwdfile, 
                                    meg=True, eeg=False, mindist=5.0, n_jobs=ncpu)     
    
        inv = mne.minimum_norm.make_inverse_operator(raw.info, fwd, noise_cov, loose=0.2, depth=0.8)
        mne.minimum_norm.write_inverse_operator(invfile,inv)
    