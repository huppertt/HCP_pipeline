#!/disk/HCP/pipeline/external/Python-3.5.2/bin/bin/
# -*- coding: utf-8 -*-
"""
Created on Thu Dec  1 10:40:18 2016

@author: Daniel
"""
import sys
import os
import fnmatch
import HCP_megpipe as megpipe
import mne

mne.set_config('MNE_STIM_CHANNEL','STI101')

mdir = '/disk/NIRS/MRI_Studies/MEEG-MRI-NIRS/analyzed/'
# subjects = ['HCP214','HCP215']
tasktypes = ['MOTOR', 'WM', 'LANGUAGE']

def process(subjects):
    "parses HCP MEG file structure, runs megpipe.sort, megpipe.preproc, megpipe.source, megpipe.task"
    for subj in subjects:
        fpath = os.path.join(mdir,subj)
        subj_dir = os.path.join(fpath,'T1w')

        megdirs = fnmatch.filter(os.listdir(fpath),'MEG*')

        for megdir in megdirs:
            fns = os.listdir(os.path.join(fpath,megdir))
            
            megpipe.sort(os.path.join(fpath,megdir))

            models = os.listdir(os.path.join(fpath,megdir,'models'))
            stcs = os.listdir(os.path.join(fpath,megdir,'stc'))
            procs = os.listdir(os.path.join(fpath,megdir,'proc'))
            
            rawf = ''.join(fnmatch.filter(fns,'*tsss.fif')[:1])
            if not rawf:
                rawf = ''.join(fnmatch.filter(fns,'*raw.fif')[:1])
                try: 
                    #/neuro/bin/util/maxfilter -f $rawf -st -force -v #runs elekta maxfilter tsss, works on cerebro
                    rawf = rawf.split('.')[0]+'_tsss.fif'
                except:
                    print('No raw file ending in raw.fif found in ' + megdir) ' or MaxFilter is not working'
            if procs:
                os.rename(os.path.join(fpath,megdir,'proc',rawf[:-4]+'_preproc'+rawf[-4:]),
                            os.path.join(fpath,megdir,rawf[:-4]+'_preproc'+rawf[-4:]))
            rawpp = os.path.join(fpath,megdir,rawf[:-4]+'_preproc'+rawf[-4:])

            if not os.path.isfile(rawpp):
                # megpipe.prep(os.path.join(fpath,megdir,rawf),rawpp)
                print('do preprocessing on system with working python tkinter')

            empty = ''.join(fnmatch.filter(fns,'*empty*')[:1])
            if empty:
                empty = os.path.join(fpath,megdir,empty)

            trans = ''.join(fnmatch.filter(fns,'*trans.fif')[:1])
            if not trans: 
                print('No trans file ending in trans.fif found in ' + megdir + ', please create one')
            else:
                fwd = ''.join(fnmatch.filter(models,'*fwd.fif*')[:1])
                if fwd:
                    fwd = os.path.join(fpath,megdir,'models',fwd)

                if not fnmatch.filter(stcs,'*-morph-lh.stc') and not fnmatch.filter(stcs,'*-morph-rh.stc'):
                    inv = ''.join(fnmatch.filter(models,'*inv.fif*')[:1])
                    if inv:
                        inv = os.path.join(fpath,megdir,'models',inv)
                    src = ''.join(fnmatch.filter(models,'*src_fsavg.fif*')[:1])
                    if not src:
                        src = ''.join(fnmatch.filter(models,'*src.fif*')[:1])
                    if src:
                        src = os.path.join(fpath,megdir,'models',src)

                    megpipe.source(rawpp,subj_dir,os.path.join(fpath,megdir,trans),subj=subj,src=src,fwd=fwd,inv=inv,empty=empty)
                    # print('let''s do this source space stuff on cerebro!')

                if not fnmatch.filter(stcs,'*beta-lh.stc') and not fnmatch.filter(stcs,'*beta-rh.stc'):
                    for t in tasktypes:
                        if fnmatch.fnmatch(megdir,'*'+ t +'*'):
                            # megpipe.task(rawpp,t.lower(),fwd=fwd)
                            print('let''s do this task stuff later!')

            megpipe.sort(os.path.join(fpath,megdir))

if __name__ == "__main__":
    try:
        process(sys.argv[1:])
    except:
        print('Some unexpected exception')
        sys.exit()
