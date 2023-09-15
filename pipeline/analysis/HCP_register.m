function HCP_register(subjid,outfolder,InImage,OutImage)
%InImage = 'Scout_gdc';
%OutImage = 'Scout_nonlin';


T1wImage=fullfile(outfolder,subjid,'T1w','T1w_restore.nii.gz');
BrainMask=fullfile(outfolder,subjid,'T1w','T1w_acpc_dc_restore_brain.nii.gz');
BiasField=fullfile(outfolder,subjid,'T1w','BiasField_acpc_dc.nii.gz');

RegFile =[InImage '_reg'];

system(['${FSLDIR}/bin/flirt -in ' InImage '.nii.gz -ref ' T1wImage ' -omat reg.mat']);
system('${FSLDIR}/bin/convert_xfm -omat ireg.mat -inverse reg.mat');
system(['${FSLDIR}/bin/applywarp -i ' BrainMask ' -o ' InImage '_mask.nii.gz -r ' InImage ' --rel --premat=ireg.mat --interp=nn']);
system(['${FSLDIR}/bin/fslmaths ' InImage '_mask.nii.gz -mas ' InImage '_mask.nii.gz ' InImage '_mask.nii.gz']);
system(['${FSLDIR}/bin/fslmaths ' InImage ' -mas ' InImage '_mask.nii.gz ' InImage '_brain.nii.gz']);

system(['${FREESURFER_HOME}/bin/bbregister --s ' subjid ' --mov Scout_gdc_brain.nii.gz --reg ' RegFile '.dat --init-fsl --bold --lta ' RegFile '.lta']);
system(['${FREESURFER_HOME}/bin/mri_convert -at ' RegFile '.lta -rl ' BiasField ' -i ' InImage '.nii.gz -o ' OutImage '.nii.gz']);
system(['${FREESURFER_HOME}/bin/mri_convert -at ' RegFile '.lta -rl ' BiasField ' -i ' InImage '_brain.nii.gz -o ' OutImage '_brain.nii.gz']);

% BiasFIeld Correction
system(['${FSLDIR}/bin/fslmaths ' OutImage '_brain.nii.gz -div ' BiasField ' ' OutImage '_brain.nii.gz']);
system(['${FSLDIR}/bin/fslmaths ' OutImage '.nii.gz -div ' BiasField ' ' OutImage '.nii.gz']);


AtlasSpaceFolder=fullfile(outfolder,subjid,'MNINonLinear');
AtlasTransform=fullfile(AtlasSpaceFolder,'xfms','acpc_dc2standard.nii.gz');
AtlasT1 = fullfile(outfolder,subjid,'MNINonLinear','T1w_restore.nii.gz');

T1 =fullfile(outfolder,subjid,'T1w','T1w_acpc_dc_restore_1mm.nii.gz');

system(['mri_convert -rt nearest -rl ' T1 ' ' OutImage '.nii.gz ' OutImage '_1mm.nii.gz']);
system(['mri_convert -rt nearest -rl ' T1 ' ' OutImage '_brain.nii.gz ' OutImage 'brain_1mm.nii.gz']);

system(['applywarp --rel --interp=nn -i ' OutImage '_brain.nii.gz -r ' AtlasT1 ' -w ' AtlasTransform ' -o ' AtlasSpaceFolder '/' OutImage '_brain.nii.gz']);
system(['applywarp --rel --interp=nn -i ' OutImage '.nii.gz -r ' AtlasT1 ' -w ' AtlasTransform ' -o ' AtlasSpaceFolder '/' OutImage '.nii.gz']);
    
    
system(['${CARET7DIR}/wb_command -add-to-spec-file ' AtlasSpaceFolder '/' subjid '.164k_fs_LR.wb.spec INVALID ' AtlasSpaceFolder '/' OutImage '_brain.nii.gz']);