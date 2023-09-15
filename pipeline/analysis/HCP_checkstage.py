#!/usr/bin/env python3
"""

"""

import os.path as op
import sys
import glob

ddir = '/disk/HCP/analyzed'
def check(subjid,outf=ddir):
    "checks completion of HCP pipelines"    
    stage = {'stage 0':[op.join(outf,subjid,'unprocessed','3T','T1w_MPR1',subjid+'_3T_T1w_MPR1.nii.gz'),
                        ],
             'stage 1': [op.join(outf,subjid,'MNINonLinear',subjid+'.164k_fs_LR.wb.spec'),],
             'stage 2': [op.join(outf,subjid,'T1w',subjid,'dpath','merged_avg33_mni_bbr.mgz')],
             'stage 3': glob.glob(op.join(outf,subjid,'MNINonLinear','Results') +'/BOLD*/*Atlas.dtseries.nii'),
             'stage 4': [op.join(outf,subjid,'MNINonLinear','Results','BOLD_MSMconcat','BOLD_MSMconcat_Atlas_MSMSulc_prepared_nobias_vn.dtseries.nii')],
             'stage 5': [op.join(outf,subjid,'ASL','ASL_nonlin_norm.nii.gz')],
             'stage 6': glob.glob(op.join(outf,subjid,'MNINonLinear','Results')+'/BOLD*/BOLD*.feat/*level2_AVG_*.nii')}

    for key in sorted(stage):
        print('checking ' + key)
        if not stage[key]:
            print('no files found, ' + key + ' failed!')
        else:    
            for fn in stage[key]:
                f = op.relpath(fn,op.join(outf,subjid))
                if not op.isfile(fn):
                    print(f + ' not found, ' + key + ' failed!')
                    break
                elif op.getsize(fn) == 0:
                    print(f + ' is 0 bytes, ' + key + ' failed!')
                    break
                else:
                    print(f + ' is ' + str(op.getsize(fn)) + ' bytes')     
            else:
                print(key + ' complete, congratulations!')

if __name__ == "__main__":
    try:
        check(sys.argv[1:])
    except:
        print('Some unexpected exception')
        sys.exit()
