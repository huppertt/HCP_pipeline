function HCP_WMH_GPNnew(subjid,outfolder,force)

if(nargin<2)
    outfolder='/disk/HCP/analyzed';
end
if(nargin<3)
    force=false;
end
tic;
HCP_matlab_setenv;

FLAIR=fullfile(outfolder,subjid,'T2FLAIR',[subjid '_3T_T2FLAIR_acpc.nii.gz']);

HiRES=fullfile(outfolder,subjid,'T1w','T1w_acpc.nii.gz');
WMH=fullfile(outfolder,subjid,'T2FLAIR',[subjid '_3T_WMH_kmeans_acpc.nii.gz']);
WMH2=fullfile(outfolder,subjid,'T2FLAIR',[subjid '_3T_WMH_fuzzy_acpc.nii.gz']);
Znorm=fullfile(outfolder,subjid,'T2FLAIR',[subjid '_3T_T2FLAIR_acpc_N4_Znorm.nii.gz']);

if(exist(WMH2)==2 && ~force)
    disp(['skipping ' subjid]);
    return
end


setenv('SUBJECTS_DIR',fullfile(outfolder,subjid,'T1w'));
setenv('PATH',[getenv('PATH') ':' getenv('FREESURFER_HOME') filesep 'fsfast' filesep 'bin']);
setenv('PATH',[getenv('PATH') ':' getenv('FREESURFER_HOME') filesep 'mni' filesep 'bin']);

fileOut={};

if(exist(FLAIR)~=2)
    warning([subjid ' is missing FLAIR']);
    return
end


if(~(exist(Znorm)==2 && ~force))
        
FLAIRN4=HCP_N4filter(FLAIR);

% STEP 1 
% #1. creates WMHv3 folder which will contain processed data for each scan
% #2. copies required files into "destination": to_copy_subj (subject-specific)
% #3. registers mask_ICV_auto to FLAIR space (for N4 correction)
% #4. creates required masks from Freesurfer segmentation & registers them to FLAIR space:
% #WM mask for whole brain (step03_extract_wmh.m will look for WMH only within this mask)
% #(WM mask excludes CER & Brainstem, and includes subcortical regions to help capture WMH around ventricles)
% #cerebellar WM mask (used to normalize intensity of WM in rest of brain, as CER is known to have few WMH)


%  #get WM+Vents mask from FS seg --> into fs_dir
%     get_fs_mask(wm_vents_mask_withcer, subjID, scanID)
fs_seg= fullfile(outfolder,subjid,'T1w',subjid,'mri','aseg.mgz');
mask= fullfile(outfolder,subjid,'T2FLAIR','WM+Vents+Subcort_mask_withcer+brainstem');
system(['mri_binarize --i ' fs_seg ' --ctx-wm --ventricles --subcort-gm --o ' mask '.mgz']);
system(['mri_convert -i ' mask '.mgz -rl ' FLAIRN4 ' -rt nearest -o ' mask '.nii']);

%     get_fs_mask(cer_and_brainstem_mask, subjID, scanID)  #get_fs_mask(whole_cerebellum_mask, subjID, scanID)
mask= fullfile(outfolder,subjid,'T2FLAIR','Cerebellum_mask');
system(['mri_binarize --i ' fs_seg ' --match 6 7 8 45 46 47 --o ' mask '.mgz']);
system(['mri_convert -i ' mask '.mgz -rl ' FLAIRN4 ' -rt nearest -o ' mask '.nii']);

%     remove_cer_and_brainstem_from_mask(wm_vents_mask_withcer, wm_vents_mask, subjID, scanID)     #remove_cer_from_wm_vents_mask(subjID, scanID)
mask1= fullfile(outfolder,subjid,'T2FLAIR','WM+Vents+Subcort_mask_withcer+brainstem.nii');
mask2= fullfile(outfolder,subjid,'T2FLAIR','Cerebellum_mask.nii');
mask3= fullfile(outfolder,subjid,'T2FLAIR','WM+Vents+Subcort_mask_nocer_nobrainstem.nii');
system(['fslmaths ' mask1 ' -sub ' mask2 ' -thr 1 -bin ' mask3]);


%     get_fs_mask(cerebellar_wm_mask, subjID, scanID)
mask4= fullfile(outfolder,subjid,'T2FLAIR','CerebellarWM_mask');
system(['mri_binarize --i ' fs_seg ' --match 7 46 --o ' mask4 '.mgz']);
system(['mri_convert -i ' mask4 '.mgz -rl ' FLAIRN4 ' -rt nearest -o ' mask4 '.nii']);


%     #register mask from FS space to FLAIR space --> into wmh_dir

mask3=[mask3 '.gz'];
mask4=[mask4 '.nii'];


thr=1:.5:4;
GPN_SeedSelector_singlesub(FLAIRN4,mask4,mask4,mask3,thr);
for tI=1:length(thr)
    fileOut{end+1}=fullfile(outfolder,subjid,'T2FLAIR',[subjid '_3T_T2FLAIR_acpc_N4_std' num2str(thr(tI)) '_Znorm_th.nii.gz']);
end
end



disp('Running K-means WMH estimate');
FLAIRZ=load_nii(Znorm);

nclust=2;
[IDX,centroids]=imsegkmeans3(int16(FLAIRZ.img.*(FLAIRZ.img>1)),3);

mask2=zeros(size(FLAIRZ.img));
[~,idx]=max(centroids);
mask2(find(IDX==idx))=1;

CC = bwconncomp(mask2>0);
for idx = 1:length(CC.PixelIdxList)
    if length(CC.PixelIdxList{idx}) < 2
        mask2(CC.PixelIdxList{idx}) = 0;
    end
end

FLAIRZ.img=FLAIRZ.img.*mask2;
disp(['saving WMH file: ' WMH]);
save_nii(FLAIRZ,WMH);
fileOut{end+1}=WMH;


disp('Running FCM WMH estimate');
FLAIRZ=load_nii(Znorm);
C = FCM3(FLAIRZ.img,FLAIRZ.img>1,2);
FLAIRZ.img=C(:,:,:,2);
disp(['saving WMH file: ' WMH2]);
save_nii(FLAIRZ,WMH2);
fileOut{end+1}=WMH2;


system(['mri_convert -i ' outfolder '/' subjid '/T1w/' subjid '/mri/wmparc.mgz '...
    '-rl ' FLAIRN4 ' -rt nearest -o ' outfolder filesep subjid '/T2FLAIR/wmparc_acpc.nii.gz']);


system(['mri_convert -i ' outfolder '/' subjid '/T1w/' subjid '/mri/aseg.mgz '...
    '-rl ' FLAIRN4 ' -rt nearest -o ' outfolder filesep subjid '/T2FLAIR/aseg_acpc.nii.gz']);



for i=1:length(fileOut)
    maskOut=strrep(fileOut{i},'.nii.gz','_mask.nii.gz');
    system(['fslmaths ' fileOut{i} ' -bin ' maskOut ]);
    
    statsOut=strrep(fileOut{i},'.nii.gz','_stats.dat');
    disp(['Running stats: ' statsOut]);
    system(['mri_segstats --i ' fileOut{i} ...
        ' --mask ' maskOut ...
        ' --seg ' outfolder filesep subjid '/T2FLAIR/wmparc_acpc.nii.gz --excludeid 0'...
        ' --ctab $FREESURFER_HOME/FreeSurferColorLUT.txt --sum ' statsOut]);
end

disp(['DONE: time elapsed ' num2str(toc) 's']);
