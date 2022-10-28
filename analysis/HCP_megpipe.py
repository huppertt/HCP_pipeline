#!disk/HCP/pipeline/external/Python-3.5.2/bin/bin/python3.5
"""
Created on Wed Nov  9 10:29:39 2016

@author: Daniel
"""
import mne
import numpy as np
import os
#import matplotlib.pyplot as plt
import sys
import fnmatch
from subprocess import call

import warnings
warnings.filterwarnings("ignore", category=DeprecationWarning) 


mne.set_config('MNE_STIM_CHANNEL', 'STI101')

def prep(file,fileo): 

    fmin, fmax = 1, 55
    fs = 150
    reject = dict(mag=5e-11, # T magnetometers
                  grad=4e-9, # T/m gradiometers
                  )

    n_components = 20
    decim = 3

    if os.path.isfile(file):
                
        if not fnmatch.fnmatch(file, '*tsss*'):
            print('trying maxfilter')
            call('/neuro/bin/util/maxfilter -f $file -st -force -v') #runs elekta maxfilter tsss, works on cerebro
            file = file.split('.')[0]+'_tsss.fif'
        
        raw = mne.io.read_raw_fif(file, preload=True)
        info = mne.io.read_info(file);

        sfreq=info.get('sfreq')
        if(fmax<sfreq/2):
            #raw = mne.chpi.filter_chpi(raw,include_line=False)
            raw.notch_filter(np.arange(60,sfreq/2+1,60))    
            raw.filter(fmin, fmax, n_jobs=2)
            

        raw.resample(fs, npad='auto')
        
  
        #raw.plot(order='selection')
        #print('Select bad channels to exclude, press any key to continue')
        #while not plt.waitforbuttonpress(): pass
        #plt.close('all')

        picks = mne.pick_types(raw.info, meg=True, eeg=False, eog=False, stim=False, exclude='bads')
        
        eog_epochs = mne.preprocessing.create_eog_epochs(raw)
#        eog_avg = eog_epochs.average()
        ecg_epochs = mne.preprocessing.create_ecg_epochs(raw)
#        ecg_avg = ecg_epochs.average()
    
        ica = mne.preprocessing.ICA(n_components=n_components, method='fastica')
        ica.fit(raw, picks=picks, decim=decim, reject=reject) 
        eog_inds, scores = ica.find_bads_eog(eog_epochs)
        ecg_inds, scores = ica.find_bads_ecg(ecg_epochs)
        ica.exclude.extend(eog_inds + ecg_inds)
              
      #  ica.plot_sources(raw)
      #  print('Select components to exclude, press any key to continue')
      #  while not plt.waitforbuttonpress(): pass 
      #  plt.close('all')
              
        ica.apply(raw)
        
        projs, events = mne.preprocessing.compute_proj_ecg(raw, n_grad=2, n_mag=2, n_eeg=0, bads=raw.info['bads'], reject=reject, average=True)
        ecg_projs = projs[-2:]
        projs, events = mne.preprocessing.compute_proj_eog(raw, n_grad=2, n_mag=2, n_eeg=0, bads=raw.info['bads'], reject=reject, average=True)
        eog_projs = projs[-2:]
        raw.info['projs'] += ecg_projs + eog_projs
        raw.apply_proj() 
              
        raw.save(fileo,overwrite=True)


#def source(file, subj_dir, trans, subj=None, src=None, fwd=None, inv=None, empty=None):
#    "uses inverse model, forward operator, or source space in that order if provided. trans file necessary. subj_dir should contain bem folder"
#    snr = 3
#    lambda2 = 1/snr**2
#    conductivity = (0.3,)
#    method = 'MNE'
#
#    raw = mne.io.read_raw_fif(file, preload=True)
#    if not subj:                    # subj set to 3rd directory back; expects filepath to be HCP file structure
#        subj = file.split('/')[-3]  # e.g. ../HCP201/MEG_REST1/HCP201_MEG_REST1-raw_preproc.fif --> will set subj='HCP201'
#    
#    if(subj=='None'):
#        subj=None
#    if(src=='None'):
#        src=None
#    if(fwd=='None'):
#        fwd=None
#    if(inv=='None'):
#        inv=None
#    if(empty=='None'):
#        empty=None
#
#    if not inv:
#        if not fwd:
#            if not src: 
#                # generate and save native and fsavg morphed source spaces. uses morphed src
#                src = mne.setup_source_space(subj, spacing='ico4', subjects_dir=subj_dir, add_dist=False, overwrite=True)
#                mne.write_source_spaces(file.split('.')[0].rsplit('-',0)[0]+'-src.fif.gz',src)
#                src_morph = mne.morph_source_spaces(src,'fsaverage',subjects_dir=subj_dir)
#                mne.write_source_spaces(file.split('.')[0].rsplit('-',0)[0]+'-fsavg_src.fif.gz',src_morph)
#            else:
#                src = mne.read_source_spaces(src)
#            
#            model = mne.make_bem_model(subject=subj, ico=4, conductivity=conductivity, subjects_dir=subj_dir)
#            bem = mne.make_bem_solution(model)
#            fwd = mne.make_forward_solution(raw.info, trans=trans, src=src, bem=bem, fname=None, meg=True, eeg=False, mindist=0.0, n_jobs=2)
#            fwd = mne.pick_types_forward(fwd, meg=True, eeg=False)
#            mne.write_forward_solution(file.split('.')[0].rsplit('-',0)[0]+'-fwd.fif.gz', fwd, overwrite=True)
#            try:
#                fwd_morph = mne.make_forward_solution(raw.info, trans=trans, src=src_morph, bem=bem, fname=None, meg=True, eeg=False, mindist=0.0, n_jobs=2)
#                fwd_morph = mne.pick_types_forward(fwd_morph, meg=True, eeg=False)
#                mne.write_forward_solution(file.split('.')[0].rsplit('-',0)[0]+'-morph_fwd.fif.gz', fwd_morph, overwrite=True)
#            except NameError:
#                print('No morphed source space found... skipping forward morph')
#
#        else:
#            fwd = mne.read_forward_solution(fwd)
#
#        if not empty:
#            cov = mne.compute_raw_covariance(raw, tmin=0, tmax=30)
#        else:
#            craw = mne.io.read_raw_fif(empty, preload=True)
#            cov = mne.compute_raw_covariance(craw)
#        
#        inv = mne.minimum_norm.make_inverse_operator(raw.info, fwd, cov, fixed=True, depth=None)
#        mne.minimum_norm.write_inverse_operator(file.split('.')[0].rsplit('-',0)[0]+'-inv.fif.gz',inv)
#        try:
#            inv_morph = mne.minimum_norm.make_inverse_operator(raw.info, fwd_morph, cov, fixed=True, depth=None)
#            mne.minimum_norm.write_inverse_operator(file.split('.')[0].rsplit('-',0)[0]+'-morph_inv.fif.gz',inv_morph)
#        except NameError:
#            print('No morphed forward operator found... skipping inverse morph')
#    
#    else:
#        inv = mne.minimum_norm.read_inverse_operator(inv)
#
#    stc = mne.minimum_norm.apply_inverse_raw(raw, inv, lambda2, method, buffer_size=25000)
#    stc.save(file.split('.')[0]+'-native',ftype='stc')
#    try:
#        stc_morph = mne.minimum_norm.apply_inverse_raw(raw, inv_morph, lambda2, method, buffer_size=25000)
#        stc_morph.save(file.split('.')[0]+'-morph',ftype='stc')
#    except NameError:
#        print('No morphed inverse operator found... skipping source estimate morph')
   
def source(file, subj_dir, trans, subj=None, src=None, fwd=None, inv=None, empty=None):
    
    snr = 3
    lambda2 = 1/snr**2
    conductivity = (0.3,)
    method = 'MNE'
        
    raw = mne.io.read_raw_fif(file, preload=True)
    if not subj:                    # subj set to 3rd directory back; expects filepath to be HCP file structure
        subj = file.split('/')[-3]  # e.g. ../HCP201/MEG_REST1/HCP201_MEG_REST1-raw_preproc.fif --> will set subj='HCP201'
    
    if(subj=='None'):
        subj=None
    if(src=='None'):
        src=None
    if(fwd=='None'):
        fwd=None
    if(inv=='None'):
        inv=None
    if(empty=='None'):
        empty=None
    
    if not inv:
        if not fwd:
            if not src: 
                # generate and save native and fsavg morphed source spaces. uses morphed src
                src = mne.setup_source_space(subj, spacing='ico4', subjects_dir=subj_dir, add_dist=False, overwrite=True)
                mne.write_source_spaces(file.split('.')[0]+'-src.fif.gz',src,overwrite=True)
                src_morph = mne.morph_source_spaces(src,'fsaverage',subjects_dir=subj_dir)
                mne.write_source_spaces(file.split('.')[0]+'-fsavg_src.fif.gz',src_morph,overwrite=True)
            else:
                src = mne.read_source_spaces(src)
            
            model = mne.make_bem_model(subject=subj, ico=4, conductivity=conductivity, subjects_dir=subj_dir)
            bem = mne.make_bem_solution(model)
            fwd = mne.make_forward_solution(raw.info, trans=trans, src=src, bem=bem, fname=None, meg=True, eeg=False, mindist=0.0, n_jobs=2)
            fwd = mne.pick_types_forward(fwd, meg=True, eeg=False)
            mne.write_forward_solution(file.split('.')[0]+'-fwd.fif.gz', fwd, overwrite=True)
            try:
                fwd_morph = mne.make_forward_solution(raw.info, trans=trans, src=src_morph, bem=bem, fname=None, meg=True, eeg=False, mindist=0.0, n_jobs=2)
                fwd_morph = mne.pick_types_forward(fwd_morph, meg=True, eeg=False)
                mne.write_forward_solution(file.split('.')[0]+'-morph_fwd.fif.gz', fwd_morph, overwrite=True)
            except NameError:
                print('No morphed source space found... skipping forward morph')

        else:
            fwd = mne.read_forward_solution(fwd)

        if not empty:
            cov = mne.compute_raw_covariance(raw, tmin=0, tmax=30)
        else:
            craw = mne.io.read_raw_fif(empty, preload=True)
            cov = mne.compute_raw_covariance(craw)
        
        inv = mne.minimum_norm.make_inverse_operator(raw.info, fwd, cov, loose=0.2, depth=0.8)
        mne.minimum_norm.write_inverse_operator(file.split('.')[0]+'-inv.fif.gz',inv)
        try:
            inv_morph = mne.minimum_norm.make_inverse_operator(raw.info, fwd_morph, cov, loose=0.2, depth=0.8)
            mne.minimum_norm.write_inverse_operator(file.split('.')[0]+'-morph_inv.fif.gz',inv_morph)
        except NameError:
            print('No morphed forward operator found... skipping inverse morph')
    
    else:
        inv = mne.minimum_norm.read_inverse_operator(inv)

    raw.pick_types(meg=True, eeg=False)

    stc = mne.minimum_norm.apply_inverse_raw(raw, inv, lambda2, method, buffer_size=25000)
    stc.save(file.split('.')[0]+'-native',ftype='stc')
    try:
        stc_morph = mne.minimum_norm.apply_inverse_raw(raw, inv_morph, lambda2, method, buffer_size=25000)
        stc_morph.save(file.split('.')[0]+'-morph',ftype='stc')
    except NameError:
        print('No morphed inverse operator found... skipping source estimate morph')
             

def task(file, tasktype, fwd=None):
    "tasktype can be 'motor', 'wm', 'language', or 'mn'"
    
    reject = dict(mag=5e-11, 
                  grad=4000e-12,
                  )
    snr = 3
    lambda2 = 1/snr**2

    tmin, tmax = -0.3, 0.6
    baseline = (None, 0)

    method = 'MNE' # method can be MNE, dSPM, sLORETA
    
    fileo = file[:-4] + '_'   
    
    raw = mne.io.read_raw_fif(file, preload=True)

    picks = mne.pick_types(raw.info, meg=True, eeg=False, eog=False, stim=False, 
                           exclude='bads')
       
    events = mne.find_events(raw,uint_cast=True,shortest_event=1)                       
    if tasktype == 'motor':
        print('Motor Task')
        event_id = {'LHand':22, 'RHand':70, 'LFoot':38, 'RFoot':134}
    elif tasktype == 'wm':
        print('Working Memory Task')
        event_id = {'0-Bk Face NonTarget':10, '0-Bk Face Lure':12, '0-Bk Face Target':14, 
                '0-Bk Tool NonTarget':42, '0-Bk Tool Lure':44, '0-Bk Tool Target':46, 
                '2-Bk Face NonTarget':74, '2-Bk Face Lure':76, '2-Bk Face Target':78,
                '2-Bk Tool NonTarget':106, '2-Bk Tool Lure':108, '2-Bk Tool Target':110}
    elif tasktype == 'language':
        print('Story/Math Task')
        event_id = {'StoryOnset':56, 'StoryQOnset':46, 'StoryCorrOpt':44, 'StoryIncOpt':42,
                'StoryResp':34, 'MathInst':88, 'MathQ2nd':76}
    elif tasktype == 'mn':
        print('Median Nerve Stimulation')
        tmin, tmax = -0.1, 0.3
        event_id = {'Stim':2048}
    else:
        raise Exception('Please select type of task')
        
    if not fwd:
        try:    
            fwd = mne.read_forward_solution(file[:-15] + 'fwd.fif.gz')
        except:
            raise Exception('Forward solution file not found')
    else:
        fwd = mne.read_forward_solution(fwd)
    
    for key in event_id:                  
        epochs = mne.Epochs(raw, events=events, event_id=event_id[key], tmin=tmin, tmax=tmax, 
                        baseline=baseline, reject=reject, picks=picks)
                        
        evoked=epochs.average()
        gfig, mfig = evoked.plot_joint(times='auto',show=False,title=key)
        gfig.savefig(fileo + key + '_evoked_jointplot_grad', transparent=True)
        mfig.savefig(fileo + key + '_evoked_jointplot_mag', transparent=True)            
        plt.close('all')
                 
        cov = mne.compute_covariance(epochs, tmax=0, method=['shrunk','empirical'])
        inv = mne.minimum_norm.make_inverse_operator(evoked.info, fwd, cov, loose=0.2, depth=0.8)
        # mne.minimum_norm.write_inverse_operator(fileo + '-inv.fif', inv)

        stc = mne.minimum_norm.apply_inverse(evoked, inv, lambda2, method)            
        stc.save(fileo + 'source', ftype='stc',verbose=True)

        stc_epochs = mne.minimum_norm.apply_inverse_epochs(epochs, inv, lambda2, method)    
            
        intercept = np.ones(len(stc_epochs), dtype=np.float)
        design_matrix = np.column_stack([intercept, np.linspace(0,1,len(intercept))-.5])

        lm = mne.stats.linear_regression(stc_epochs, design_matrix)
        for k in lm:
            lm[k].beta.save(fileo + key + '_' + k + '_beta', ftype='stc', verbose=True)
            lm[k].stderr.save(fileo + key + '_' + k + '_stderr', ftype='stc', verbose=True)
            lm[k].t_val.save(fileo + key + '_' + k + '_t-val', ftype='stc', verbose=True)
            lm[k].p_val.save(fileo + key + '_' + k + '_p-val', ftype='stc', verbose=True)

def sort(mdir):
    "takes absolute pathname mdir and sorts meg files inside into raw, proc, stc, models, and png subdirectories"
    os.makedirs(os.path.join(mdir,'proc'),exist_ok=True)
    os.makedirs(os.path.join(mdir,'stc'),exist_ok=True)
    os.makedirs(os.path.join(mdir,'png'),exist_ok=True)
    os.makedirs(os.path.join(mdir,'models'),exist_ok=True)
    os.makedirs(os.path.join(mdir,'task'),exist_ok=True)
    
    for f in os.listdir(mdir):
        if fnmatch.fnmatch(f,'*.png'):
            os.rename(os.path.join(mdir,f), os.path.join(mdir,'png',f))
        elif fnmatch.fnmatch(f,'*x0*') or fnmatch.fnmatch(f,'*x1*'):
            os.rename(os.path.join(mdir,f), os.path.join(mdir,'task',f))
        elif fnmatch.fnmatch(f,'*.stc'):
            os.rename(os.path.join(mdir,f), os.path.join(mdir,'stc',f))        
        elif fnmatch.fnmatch(f,'*fwd.fif*') or fnmatch.fnmatch(f,'*inv.fif*') or fnmatch.fnmatch(f,'*src.fif*'):
            os.rename(os.path.join(mdir,f), os.path.join(mdir,'models',f))        
        elif fnmatch.fnmatch(f,'*preproc.fif'):
            os.rename(os.path.join(mdir,f), os.path.join(mdir,'proc',f))        

    os.system('chmod -R 777 ' + mdir)

def anom(file):
    raw = mne.io.read_raw_fif(file, preload=True)
    raw=raw.anonymize()
    raw.save('temp.fif',overwrite=True)
    os.remove(file)
    os.rename('temp.fif',file)

if __name__ == "__main__":
    try:
        ins = sys.argv[1:]
        
        if ins[0] == 'prep':
            print('running prep')
            prep(ins[1],ins[2])
        elif ins[0] == 'source':
            source(ins[1],ins[2],ins[3],ins[4],ins[5],ins[6],ins[7],ins[8])
        elif ins[0] == 'task':
            task(ins[1],ins[2],ins[3])
        elif ins[0] == 'anom':
            anom(ins[1])

    except:
        print('Some unexpected exception')
        sys.exit()
