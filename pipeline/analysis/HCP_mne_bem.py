#!/Users/huppert/anaconda/bin/python

"""
This script will run the MNE setup for generating the BEM models
used by the NIRS and MEEG pipelines
"""

import sys
import mne
import os
import shutil
      
spaceres='ico4'
          
try:
    subjdir = os.environ['SUBJECTS_DIR']
except:
    print("MNE SUBJECTS_DIR not set")
    sys.exit(1)

try:
    subjid = os.environ['SUBJECT']
except:
    print("MNE SUBJECT not set")
    sys.exit(1)
    
if isinstance(subjid,int):    
    subjid=str(subjid)

mne.set_config('SUBJECTS_DIR',subjdir)


os.chdir(subjdir)
os.chdir(subjid)
os.chdir('bem')    


if(os.path.isfile(subjid+'-'+spaceres+'-src.fif')):
    os.remove(subjid+'-'+spaceres+'-src.fif')

src = mne.setup_source_space(subjid,spacing=spaceres)
mne.write_source_spaces(subjid+'-'+spaceres+'-src.fif',src)         


file=subjid+'-'+spaceres
mne.surface.write_surface(file + 'L.surf',src[0]['rr'],src[0]['tris'])
mne.surface.write_surface(file + 'R.surf',src[1]['rr'],src[1]['tris'])
      
      
    
   
fixed = False
   
while (not fixed):
    try:      
        model = mne.make_bem_model(subjid)
        fixed = True
    except:
        print("Inner skull error: moving surface")
        pts,tris = mne.read_surface('inner_skull.surf')
        pts *=.98 
        mne.write_surface('inner_skull.surf',pts,tris);               


if(os.path.isfile(subjid+'-bem.fif')):
    os.remove(subjid+'-bem.fif')
    
mne.write_bem_surfaces(subjid+'-bem.fif',model)

if(os.path.isfile(subjid+'-bem-sol.fif')):
    os.remove(subjid+'-bem-sol.fif')
      
bem_sol = mne.make_bem_solution(model)
mne.write_bem_solution(subjid+'-bem-sol.fif',bem_sol)

 

    

