function tbl=HCP_LPA_WMH_stats(subjid,outfolder);

wmparc=load_nii([outfolder filesep subjid '/T2FLAIR/wmparc_acpc.nii.gz']);
% 7   Left-Cerebellum-White-Matter            220 248 164 0
% 46  Right-Cerebellum-White-Matter           220 248 164 0
lstCERWM=find(ismember(wmparc.img,[7 46]));
% 
% 3   Left-Cerebral-Cortex                    205 62  78  0
% 4   Left-Lateral-Ventricle                  120 18  134 0
% 5   Left-Inf-Lat-Vent                       196 58  250 0
% 14  3rd-Ventricle                           204 182 142 0
% 15  4th-Ventricle                           42  204 164 0
% 24  CSF                                     60  60  60  0
% 25  Left-Lesion                             255 165 0   0
% 30  Left-vessel                             160 32  240 0
% 42  Right-Cerebral-Cortex                   205 62  78  0
% 43  Right-Lateral-Ventricle                 120 18  134 0
% 44  Right-Inf-Lat-Vent                      196 58  250 0
% 57  Right-Lesion                            255 165 0   0
% 62  Right-vessel                            160 32  240 0
% 72  5th-Ventricle                           120 190 150 0
% 1000's - left cortex
% 2000's - right cortex

lstWM = find(~ismember(wmparc.img,[0 3 4 5 6 7 8 14 15 24 25 30 42 43 44 45 46 47 57 62 72 1000:2999]));
mask=wmparc;
mask.img(:)=0;
mask.img(lstWM)=1;
% mask.img(lstCERWM)=2;

wmparc=load_nii([outfolder filesep subjid '/T2FLAIR/wmparc_acpc.nii.gz']);




% 7   Left-Cerebellum-White-Matter            220 248 164 0
% 46  Right-Cerebellum-White-Matter           220 248 164 0
lstCERWM=find(ismember(wmparc.img,[7 46]));

% 
% 3   Left-Cerebral-Cortex                    205 62  78  0
% 4   Left-Lateral-Ventricle                  120 18  134 0
% 5   Left-Inf-Lat-Vent                       196 58  250 0
% 14  3rd-Ventricle                           204 182 142 0
% 15  4th-Ventricle                           42  204 164 0
% 24  CSF                                     60  60  60  0
% 25  Left-Lesion                             255 165 0   0
% 30  Left-vessel                             160 32  240 0
% 42  Right-Cerebral-Cortex                   205 62  78  0
% 43  Right-Lateral-Ventricle                 120 18  134 0
% 44  Right-Inf-Lat-Vent                      196 58  250 0
% 57  Right-Lesion                            255 165 0   0
% 62  Right-vessel                            160 32  240 0
% 72  5th-Ventricle                           120 190 150 0
% 1000's - left cortex
% 2000's - right cortex

lstWM = find(~ismember(wmparc.img,[0 3 4 5 6 7 8 14 15 24 25 30 42 43 44 45 46 47 57 62 72 1000:2999]));
mask=wmparc;
mask.img(:)=0;
mask.img(lstWM)=1;
% mask.img(lstCERWM)=2;

maskout=[outfolder filesep subjid '/T1w/WMH/wmparc_mask_acpc.nii.gz']
save_nii(mask,maskout);

statsOut=[outfolder filesep subjid '/T1w/WMH/' subjid '_WMH_acpc_stats.dat'];
disp(['Running stats: ' statsOut]);

lpa_file=[outfolder filesep subjid '/T1w/WMH/ples_lpa_m' subjid '_3T_T2FLAIR_acpc.nii'];
maskname=[outfolder filesep subjid '/T1w/WMH/' subjid '_WMH_acpc.nii.gz'];

system(['fslmaths ' lpa_file ' -nan ' lpa_file]);
system(['fslmaths ' lpa_file ' -nan -mas ' maskout ' ' maskname]);

system(['mri_segstats --i ' lpa_file ...
    ' --mask ' maskname ...
    ' --seg ' outfolder filesep subjid '/T2FLAIR/wmparc_acpc.nii.gz --excludeid 0'...
    ' --ctab $FREESURFER_HOME/FreeSurferColorLUT.txt --sum ' statsOut]);

tbl= HCP_stats2table(statsOut);