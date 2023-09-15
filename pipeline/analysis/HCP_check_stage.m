function flag=HCP_check_stage(subjid,outfolder,stage)

flag=false;

switch(stage)
    case 0
        flag= ~isempty(dir(fullfile(outfolder,subjid,'unprocessed','3T','T1w_MPR1',[subjid '_3T_T1w_MPR1.nii.gz'])));
    case 1
        flag=~isempty(dir(fullfile(outfolder,subjid,'MNINonLinear',[subjid '.164k_fs_LR.wb.spec']))) &...
                ~isempty(dir(fullfile(outfolder,subjid,'stats','aseg.stats')));
    case 2
        flag=~isempty(dir(fullfile(outfolder,subjid,'T1w',subjid,'dpath','merged_avg33_mni_bbr.mgz')));
    case 3
        flag=(~isempty(rdir(fullfile(outfolder,subjid,'BOLD*','*nonlin.nii.gz')))  | ~isempty(rdir(fullfile(outfolder,subjid,'*REST*','*nonlin.nii.gz'))));
    case 4
        flag=~isempty(dir(fullfile(outfolder,subjid,'MNINonLinear','Results','*_MSMconcat','*_MSMconcat_Atlas_MSMSulc_prepared_nobias_vn.dtseries.nii')));
    case 5
        flag= ~isempty(rdir(fullfile(outfolder,subjid,'ASL*','*_nonlin_norm.nii.gz')));
    case 6
        flag=~isempty(rdir(fullfile(outfolder,subjid,'MNINonLinear','Results','/BOLD*/BOLD*.feat/*dscalar.nii')));
    case 7
        flag=~isempty(rdir(fullfile(outfolder,subjid,'PET','gtmpvc.output','gtm.stats.dat')));
end

