function tbl=HCP_DTI_analysis(subjid,outfolder)

HCProot='/disk/HCP';
if(nargin<2)
    outfolder=fullfile(HCProot,'analyzed');
end

HCP_matlab_setenv;  % Sets the FSL, Freesurfer, etc folders


if(~exist(fullfile(outfolder,subjid,'T1w',subjid,'dmri','dtifit_V3.nii.gz')) | ...
        ~exist(fullfile(outfolder,subjid,'T1w','Diffusion','data.nii.gz')))
    
    if(~exist(fullfile(outfolder,subjid,'T1w','Diffusion','data.nii.gz')))
        system(['source ' HCProot '/pipeline/projects/Pipelines/Examples/Scripts/DiffusionPreprocessingBatch.sh --runlocal --StudyFolder=' outfolder ' --Subjlist="' subjid '"'])
    end
    % RUn Tracula pre-processing
    
    HCP_matlab_setenv
    
    if(~exist(fullfile(outfolder,subjid,'T1w',subjid,'dmri')))
        mkdir(fullfile(outfolder,subjid,'T1w',subjid,'dmri'));
    end
    
    system(['cp ' fullfile(outfolder,subjid,'T1w','Diffusion','data.nii.gz') ' ' fullfile(outfolder,subjid,'T1w',subjid,'dmri','dwi.nii.gz')]);
    system(['cp ' fullfile(outfolder,subjid,'T1w','Diffusion','bvecs') ' ' fullfile(outfolder,subjid,'T1w',subjid,'dmri','bvecs')]);
    system(['cp ' fullfile(outfolder,subjid,'T1w','Diffusion','bvals') ' ' fullfile(outfolder,subjid,'T1w',subjid,'dmri','bvals')]);
    
    
    d=dlmread(fullfile(outfolder,subjid,'T1w',subjid,'dmri','bvecs'));
    dlmwrite(fullfile(outfolder,subjid,'T1w',subjid,'dmri','bvecs'),d',' ');
    
    d=dlmread(fullfile(outfolder,subjid,'T1w',subjid,'dmri','bvals'));
    dlmwrite(fullfile(outfolder,subjid,'T1w',subjid,'dmri','bvals'),d',' ');
    
    
    cd(fullfile(outfolder,subjid,'T1w',subjid,'dmri'));
    
    setenv('SUBJECTS_DIR', fullfile(outfolder,subjid,'T1w'));
    system(['trac-all  -no-isrunning -s ' subjid ' -i ' fullfile(outfolder,subjid,'T1w',subjid,'dmri','dwi.nii.gz') ' -prep'])
    
else
    system(['cp ' fullfile(outfolder,subjid,'T1w','Diffusion','data.nii.gz') ' ' fullfile(outfolder,subjid,'T1w',subjid,'dmri','dwi.nii.gz')]);
    system(['cp ' fullfile(outfolder,subjid,'T1w','Diffusion','bvecs') ' ' fullfile(outfolder,subjid,'T1w',subjid,'dmri','bvecs')]);
    system(['cp ' fullfile(outfolder,subjid,'T1w','Diffusion','bvals') ' ' fullfile(outfolder,subjid,'T1w',subjid,'dmri','bvals')]);
    
    
    d=dlmread(fullfile(outfolder,subjid,'T1w',subjid,'dmri','bvecs'));
    dlmwrite(fullfile(outfolder,subjid,'T1w',subjid,'dmri','bvecs'),d',' ');
    
    d=dlmread(fullfile(outfolder,subjid,'T1w',subjid,'dmri','bvals'));
    dlmwrite(fullfile(outfolder,subjid,'T1w',subjid,'dmri','bvals'),d',' ');
  
    cd(fullfile(outfolder,subjid,'T1w',subjid,'dmri'));
    
    setenv('SUBJECTS_DIR', fullfile(outfolder,subjid,'T1w'));
    
    
    
end

if(exist(fullfile(outfolder,subjid,'T1w',subjid,'dpath','rh.slft_PP_avg33_mni_bbr'))~=2)
system(['trac-all  -no-isrunning -s ' subjid ' -i ' fullfile(outfolder,subjid,'T1w',subjid,'dmri','dwi.nii.gz') ' -bedp'])

system(['${FSLDIR}/bin/bedpostx_postproc.sh ' outfolder '/' subjid '/T1w/' subjid '/dmri'])


system(['trac-all  -no-isrunning -s ' subjid ' -i ' fullfile(outfolder,subjid,'T1w',subjid,'dmri','dwi.nii.gz') ' -path'])
 



%tbl = HCP_report_file_integrity(fullfile(outfolder,subjid),'DTI');
else
    disp([subjid ' already completed']);
end


% 
% dtifit_FA.nii.gz - Fractional Anisotropy 
% dtifit_MD.nii.gz - Mean Diffusivity 
% dtifit_MO.nii.gz - Mode of the Anisotropy 
% dtifit_S0.nii.gz - Non-Diffusion weighted image 
% dtifit_L1.nii.gz - Primary Eigenvalue 
% dtifit_L2.nii.gz - Secondary Eigenvalue 
% dtifit_L3.nii.gz - Tertiary Eigenvalue 
% dtifit_V1.nii.gz - Primary Eigenvector 
% dtifit_V2.nii.gz - Secondary Eigenvector 
% dtifit_V3.nii.gz - Tertiary Eigenvector 
% 
% lh.cst_AS: Left corticospinal tract 
% rh.cst_AS: Right corticospinal tract 
% lh.ilf_AS: Left inferior longitudinal fasciculus 
% rh.ilf_AS: Right inferior longitudinal fasciculus 
% lh.unc_AS: Left uncinate fasciculus 
% rh.unc_AS: Right uncinate fasciculus 
% fmajor_PP: Corpus callosum - forceps major 
% fminor_PP: Corpus callosum - forceps minor 
% lh.atr_PP: Left anterior thalamic radiations 
% rh.atr_PP: Right anterior thalamic radiations 
% lh.ccg_PP: Left cingulum - cingulate gyrus endings 
% rh.ccg_PP: Right cingulum - cingulate gyrus endings 
% lh.cab_PP: Left cingulum - angular bundle 
% rh.cab_PP: Right cingulum - angular bundle 
% lh.slfp_PP: Left superior longitudinal fasciculus - parietal endings 
% rh.slfp_PP: Right superior longitudinal fasciculus - parietal endings 
% lh.slft_PP: Left superior longitudinal fasciculus - temporal endings 
% rh.slft_PP: Right superior longitudinal fasciculus - temporal endings 