#!/disk/HCP/pipeline/external/Python-3.5.2/bin/bin/python3.5

"""
Created on Fri Sep 23 13:34:01 2016

@author: huppert
"""
import mne
import mne.minimum_norm
import scipy.io
import sys

def main(argv):
    method="MNE" 
    pick_ori=None
    lambda2=1. / 9
    file = "none"
    print("Converting model to matlab")
    
    file=argv[0]
    if(len(argv)>1):
        method=argv[1]
    if(len(argv)>2):
        lambda2=argv[2]    
            
    
    #file='HCPtest1-MEG_REST1-inv.fif.gz'
    print("File=" + file)
    index_of_dot = file.index('.')
    fileout = file[:index_of_dot]

    inverse_operator=mne.minimum_norm.read_inverse_operator(file)

    prepared=False
    label=None
    nave=1
                      
    if not prepared:
        inv = mne.minimum_norm.prepare_inverse_operator(inverse_operator, nave, lambda2, method)
    else:
        inv = inverse_operator
    
    ch_names=inv['noise_cov'].ch_names
    mne.minimum_norm.inverse._pick_channels_inverse_operator(ch_names, inv)
               
    K, noise_norm, vertno = mne.minimum_norm.inverse._assemble_kernel(inv, label, method, pick_ori)
    mdict=dict([('K',K),('ch_names',ch_names),('method',method),('vertno',vertno)])
    scipy.io.savemat(fileout,mdict)


if __name__ == "__main__":
   main(sys.argv[1:])