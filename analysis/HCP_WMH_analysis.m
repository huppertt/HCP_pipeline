function HCP_WMH_analysis(subjid,outfolder)
% This function uses LST-LPA to identify white matter hyperintensities in
% T2FLAIR images (https://www.applied-statistics.de/lst.html).

% Set env for FSL
HCP_matlab_setenv

if(exist(fullfile(outfolder,subjid,'MNINonLinear','WMH.nii.gz'))~=0)
    disp(['skipping : ' subjid]);
    return;
end

if exist(fullfile(outfolder,subjid,'T2FLAIR'),'dir')
    
    % Add SPM to path
    spmdir = '/home/huppert/spm12';
    addpath(spmdir)
    
    % Run noninteractive SPM session
    spm('defaults','fmri');
    spm_jobman('initcfg');
    spm_get_defaults('cmdline',true);
    
    % Create WMH directory and copy ACPC-aligned T1 and T2FLAIR image to it
    mkdir(fullfile(outfolder,subjid,'T1w','WMH'));
    cd(fullfile(outfolder,subjid,'T1w','WMH'))
    copyfile(fullfile(outfolder,subjid,'T2FLAIR',[subjid '_3T_T2FLAIR_acpc.nii.gz']),...
        fullfile(outfolder,subjid,'T1w','WMH',[subjid '_3T_T2FLAIR_acpc.nii.gz']));
    copyfile(fullfile(outfolder,subjid,'T1w','T1w_acpc_dc_restore_brain.nii.gz'),...
        fullfile(outfolder,subjid,'T1w','WMH', 'T1w_acpc_dc_restore_brain.nii.gz'));
    
    % Unzip nii.gzs (SPM only handles unzipped Nifti files)
    system(['gunzip -f '  fullfile(outfolder,subjid,'T1w','WMH',[subjid '_3T_T2FLAIR_acpc.nii.gz']) ] )
    system(['gunzip -f '  fullfile(outfolder,subjid,'T1w','WMH','T1w_acpc_dc_restore_brain.nii.gz' ) ] )
    
    % Call LST - Lesion Prediction Algorithm from SPM toolbox
    ps_LST_lpa( [fullfile(outfolder,subjid,'T1w','WMH',[subjid '_3T_T2FLAIR_acpc.nii']) ', 1'] )
    
    % Call LST - Lesion Growth Algorithm from SPM toolbox
    % ps_LST_lga([fullfile(outfolder,subjid,'T1w','WMH','T1w_acpc_dc_restore_brain.nii') ', 1'],...
    %    [fullfile(outfolder,subjid,'T1w','WMH',[subjid '_3T_T2FLAIR_acpc.nii']) ', 1'],0.1)
    
    % Exit SPM session
    spm('Quit')
    
    % Threshold/binarize lesion probability map (0.5) to get WMH map and save as
    % subjid_WMH_acpc.nii.gz
    system(['fslmaths '...
        fullfile(outfolder,subjid,'T1w','WMH',['ples_lpa_m' subjid '_3T_T2FLAIR_acpc.nii'])...
        ' -thr 0.5 -bin '...
        fullfile(outfolder,subjid,'T1w','WMH',[subjid '_WMH_acpc.nii.gz'])...
        ])
    
    % Apply ACPC-to-MNINonLinear warp
    system(['applywarp  --rel --interp=nn ' ...
        ' -i ' fullfile(outfolder,subjid,'T1w','WMH',[subjid '_WMH_acpc.nii.gz'])...
        ' -r ' fullfile(outfolder,subjid,'MNINonLinear','T1w_restore.nii.gz') ...
        ' -w ' fullfile(outfolder,subjid,'MNINonLinear','xfms','acpc_dc2standard.nii.gz') ...
        ' -o ' fullfile(outfolder,subjid,'MNINonLinear','WMH.nii.gz')  ]);
    
    % Add to wb spec file for subject
    % spec=fullfile(outfolder,subjid,'MNINonLinear',[ subjid '.164k_fs_LR.wb.spec']);
    % system(['${CARET7DIR}/wb_command -add-to-spec-file '...                                                % Add to spec file
    %        spec ' INVALID ' fullfile(outfolder,subjid,'MNINonLinear','WMH.nii.gz') ])
    
else
    disp('No T2FLAIR directory found.')
end