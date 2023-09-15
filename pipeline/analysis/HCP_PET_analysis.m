
function HCP_PET_analysis(subjid,outfolder,force)
% This function analyzes the PET-PIB data and adds the files to the spec
% xlm file

if(nargin<3)
    force=false;
end

curdir=pwd;

HCProot='/disk/HCP';
if(nargin<2)
    outfolder=fullfile(HCProot,'analyzed');
end

HCP_matlab_setenv;  % Sets the FSL, Freesurfer, etc folders 
setenv('SUBJECTS_DIR',fullfile(outfolder,subjid,'T1w'));
PEToutfolder=fullfile(outfolder,subjid,'PET');


if(exist(fullfile(PEToutfolder,'nongtm.output','gtm.stats.dat'))~=2)
    
setenv('FREESURFER_HOME','/disk/HCP/pipeline/external/freesurfer-beta');
system(['source ' getenv('FREESURFER_HOME') filesep 'SetUpFreeSurfer.sh']);
setenv('PATH',[getenv('PATH') ':' getenv('FREESURFER_HOME') filesep 'bin']);
setenv('PATH',[getenv('PATH') ':' getenv('FREESURFER_HOME') filesep 'fsfast' filesep 'bin']);
setenv('PATH',[getenv('PATH') ':' getenv('FREESURFER_HOME') filesep 'mni' filesep 'bin']);

setenv('SUBJECTS_DIR',fullfile(outfolder,subjid,'T1w'))
setenv('SUBJECT',subjid);
if(~exist(fullfile(outfolder,subjid,'T1w',subjid,'mri','gtmseg.mgz')) || force)
    system(['gtmseg --s ' subjid ' --xcerseg']);
end

PiBavg = [rdir(fullfile(outfolder,subjid,'unprocessed','PET',strcat(subjid,'*AVG*.nii')));...
            rdir(fullfile(outfolder,subjid,'unprocessed','PET',strcat(subjid,'*Avg*.nii')));...
            rdir(fullfile(outfolder,subjid,'unprocessed','PET',strcat(subjid,'*.nii')))];
PiBavg=PiBavg(1).name;

mkdir(fullfile(outfolder,subjid,'PET'));
copyfile(PiBavg,fullfile(outfolder,subjid,'PET','PiB-AVG.nii'));

PEToutfolder=fullfile(outfolder,subjid,'PET');
PETnii=fullfile(outfolder,subjid,'PET','PiB-AVG.nii');

cd(PEToutfolder)
delete('PiB-AVG.reg.lta');

system(['flirt -v -cost mutualinfo -searchrx -180 180 -searchry -180 180 -searchrz -180 180 -dof 6 ' ... 
     '-in PiB-AVG.nii -ref  /disk/HCP/pipeline/templates/PET_Group.nii.gz '...  
     '-omat initial_xfm.mat -out PiB-native.nii']);

 system(['flirt -v -cost mutualinfo -searchrx -30 30 -searchry -30 30 -searchrz -30 30 -dof 6 ' ... 
      '-in PiB-native.nii -ref ' fullfile(outfolder,subjid,'T1w','T1w_acpc_dc_brain.nii.gz') ' '...  
      '-omat initial_xfm2.mat -out PiB-native.nii']);


setenv('FREESURFER_HOME','/disk/HCP/pipeline/external/freesurfer-beta');
system(['source ' getenv('FREESURFER_HOME') filesep 'SetUpFreeSurfer.sh']);
setenv('PATH',[getenv('PATH') ':' getenv('FREESURFER_HOME') filesep 'bin']);
setenv('PATH',[getenv('PATH') ':' getenv('FREESURFER_HOME') filesep 'fsfast' filesep 'bin']);
setenv('PATH',[getenv('PATH') ':' getenv('FREESURFER_HOME') filesep 'mni' filesep 'bin']);
setenv('FS_LICENSE',[getenv('FREESURFER_HOME') '/license.txt']);
 

system(['mri_coreg --s ' subjid ' --mov PiB-native.nii.gz --ref ' fullfile(outfolder,subjid,'T1w',subjid,'mri/T1.mgz')...
    ' --reg PiB-AVG.reg.lta']);

%  system(['tkregisterfv --mov PiB-native.nii.gz --targ /disk/HCP/analyzed/'...
%           subjid '/T1w/' subjid '/mri/T1.mgz --reg PiB-AVG.reg.lta --s ' subjid ' --surfs']);



system(['mri_gtmpvc --i PiB-native.nii.gz --reg PiB-AVG.reg.lta --psf 6 --seg ' fullfile(outfolder,subjid,'T1w',subjid,'mri','gtmseg.mgz') ...
' --default-seg-merge --auto-mask PSF .01 --mgx .01 --o gtmpvc.output --rescale 8 47 --no-reduce-fov --max-threads -'])

system(['mri_gtmpvc --i PiB-native.nii.gz --reg PiB-AVG.reg.lta --psf 0 --seg gtmseg.mgz' ...
' --default-seg-merge --auto-mask PSF .01 --mgx .01 --o gtmpvc_noPSF.output --rescale 8 47 --no-reduce-fov --max-threads'])


tbl1=HCP_stats2table('gtmpvc.output/gtm.stats.dat');

system('mkdir -p gtm_noPVC.output')
system(['mri_convert PiB-native.nii.gz --apply_transform PiB-AVG.reg.lta'...
' --like ${SUBJECTS_DIR}/' subjid '/mri/gtmseg.mgz PiB-native-gtm.nii.gz']);
system(['mri_segstats --i PiB-native-gtm.nii.gz --seg ${SUBJECTS_DIR}/' subjid '/mri/gtmseg.mgz --excludeid 0 --ctab ${SUBJECTS_DIR}/' subjid '/mri/gtmseg.ctab --sum gtm_noPVC.output/stats.dat'])
cd('gtm_noPVC.output');
tbl=HCP_stats2table('stats.dat');

ROI_name=tbl.StructName;
row=tbl.Index;
ROI_idx=tbl.SegId;
Number_PET_Voxels = tbl.Volume_mm3;

lst=ismember(ROI_name,{'Right-Cerebellum-Cortex','Left-Cerebellum-Cortex'});
n=sum(tbl.Mean(lst).*tbl.Volume_mm3(lst))./sum(tbl.Volume_mm3(lst));
PVC_uptake_wrt_Cerebellum = tbl.Mean/n;

Tissue_class=repmat({'?'},size(PVC_uptake_wrt_Cerebellum));
variance_reduction_factor=nan(size(PVC_uptake_wrt_Cerebellum));
resdiual_varaince=nan(size(PVC_uptake_wrt_Cerebellum));

tbl2=table(row,ROI_idx,ROI_name,Number_PET_Voxels,PVC_uptake_wrt_Cerebellum,Tissue_class,variance_reduction_factor,resdiual_varaince);
[a,b]=ismember(tbl1.ROI_name,tbl2.ROI_name);
lst=find(b==0);
b(lst)=1;
tbl2=tbl2(b,:);
tbl2.ROI_idx(lst)=NaN; tbl2.Number_PET_Voxels(lst)=NaN; tbl2.PVC_uptake_wrt_Cerebellum(lst)=NaN; tbl2.row(lst)=NaN;
for ii=1:length(lst); tbl2.ROI_name{lst(ii)}=''; end;
writetable(tbl2,'gtm.stats.dat','FileType','text','Delimiter','\t');
cd('..');


system('mkdir -p nongtm.output')
system(['mri_convert PiB-native.nii.gz --apply_transform PiB-AVG.reg.lta'...
' --like ${SUBJECTS_DIR}/' subjid '/mri/aparc+aseg.mgz PiB-aseg.nii.gz']);
system(['mri_segstats --i PiB-aseg.nii.gz --seg ${SUBJECTS_DIR}/' subjid '/mri/aparc+aseg.mgz --excludeid 0 --ctab $FREESURFER_HOME/FreeSurferColorLUT.txt --sum nongtm.output/stats.dat'])

cd('nongtm.output');
tbl=HCP_stats2table('stats.dat');

ROI_name=tbl.StructName;
row=tbl.Index;
ROI_idx=tbl.SegId;
Number_PET_Voxels = tbl.Volume_mm3;

lst=ismember(ROI_name,{'Right-Cerebellum-Cortex','Left-Cerebellum-Cortex'});
n=sum(tbl.Mean(lst).*tbl.Volume_mm3(lst))./sum(tbl.Volume_mm3(lst));
PVC_uptake_wrt_Cerebellum = tbl.Mean/n;

Tissue_class=repmat({'?'},size(PVC_uptake_wrt_Cerebellum));
variance_reduction_factor=nan(size(PVC_uptake_wrt_Cerebellum));
resdiual_varaince=nan(size(PVC_uptake_wrt_Cerebellum));

tbl2=table(row,ROI_idx,ROI_name,Number_PET_Voxels,PVC_uptake_wrt_Cerebellum,Tissue_class,variance_reduction_factor,resdiual_varaince);
[a,b]=ismember(tbl1.ROI_name,tbl2.ROI_name);

lst=find(b==0);
b(lst)=1;
tbl2=tbl2(b,:);
tbl2.ROI_idx(lst)=NaN; tbl2.Number_PET_Voxels(lst)=NaN; tbl2.PVC_uptake_wrt_Cerebellum(lst)=NaN; tbl2.row(lst)=NaN;
for ii=1:length(lst); tbl2.ROI_name{lst(ii)}=''; end;

writetable(tbl2,'gtm.stats.dat','FileType','text','Delimiter','\t');
cd('..');

end

if(exist(fullfile(PEToutfolder,'PiB_acpc_restore.nii.gz'))~=2)
    

cd(PEToutfolder)
system('cp gtmpvc.output/gtm.stats.dat PiB_SUV.stats');

system(['cp PiB_SUV.stats ' fullfile(outfolder,subjid,'stats','PiB_SUV.stats')]);

system('cp gtmpvc.output/mgx.gm.nii.gz PiB_SUV_GM_PVC_acpc.nii.gz');
system('cp gtmpvc.output/mgx.ctxgm.nii.gz PiB_SUV_CTXGM_PVC_acpc.nii.gz');
system('cp gtmpvc.output/mgx.subctxgm.nii.gz PiB_SUV_SubCtxGM_acpc.nii.gz');

AtlasSpaceT1wImage=fullfile(outfolder,subjid,'MNINonLinear','T1w_restore.nii.gz');
T1wImageBrain1mm=fullfile(outfolder,subjid,'T1w','T1w_acpc_dc_restore_1mm.nii.gz');
T1wImageBrain=fullfile(outfolder,subjid,'T1w','T1w_acpc_dc_restore.nii.gz');
AtlasTransform=fullfile(outfolder,subjid,'MNINonLinear','xfms','acpc_dc2standard.nii.gz');
AtlasFolder=fullfile(outfolder,subjid,'MNINonLinear');
fsldir=getenv('FSLDIR');

if(exist('PiB_acpc.nii.gz')~=2)
    system(['mri_convert -rt nearest -rl ' T1wImageBrain ' PiB-native.nii.gz --apply_transform PiB-AVG.reg.lta PiB_acpc.nii.gz']);
end

files={'PiB_SUV_GM_PVC_acpc' 'PiB_SUV_CTXGM_PVC_acpc' 'PiB_SUV_SubCtxGM_acpc' 'PiB_acpc'};
for i=1:length(files)
    disp(files{i});
    if(exist(fullfile(AtlasFolder,[files{i} '_restore.nii.gz']))~=2)
    system(['mri_convert -rt nearest -rl ' T1wImageBrain1mm ' ' files{i} '.nii.gz ' files{i} '_1mm.nii.gz']);
    system(['applywarp --rel --interp=nn -i ' files{i} '_1mm.nii.gz -r ' AtlasSpaceT1wImage ' --premat=' fsldir '/etc/flirtsch/ident.mat -o ' files{i} '_restore.nii.gz']);
    system(['applywarp --rel --interp=nn -i ' files{i} '_1mm.nii.gz -r ' AtlasSpaceT1wImage ' -w ' AtlasTransform ' -o ' AtlasFolder filesep files{i} '_restore.nii.gz']);
    end
    
    system(['${CARET7DIR}/wb_command -volume-to-surface-mapping ' ...
        AtlasFolder filesep files{i} '_restore.nii.gz ' fullfile(AtlasFolder,[subjid '.L.midthickness.164k_fs_LR.surf.gii ' AtlasFolder filesep files{i} '.L.164k_fs.func.gii -cubic'])]);
    system(['${CARET7DIR}/wb_command -volume-to-surface-mapping ' ...
        AtlasFolder filesep files{i} '_restore.nii.gz ' fullfile(AtlasFolder,[subjid '.R.midthickness.164k_fs_LR.surf.gii ' AtlasFolder filesep files{i} '.R.164k_fs.func.gii -cubic'])]);
    
end

cd(AtlasFolder) 
for i=1:length(files)
    disp(files{i});
    system(['${CARET7DIR}/wb_command -cifti-create-dense-scalar ' files{i} '.164k_fs_LR.dscalar.nii -left-metric ' files{i} '.L.164k_fs.func.gii -right-metric ' files{i} '.R.164k_fs.func.gii']);
    system(['${CARET7DIR}/wb_command -add-to-spec-file ' subjid '.164k_fs_LR.wb.spec INVALID ' files{1} '.164k_fs_LR.dscalar.nii']);
    system(['${CARET7DIR}/wb_command -add-to-spec-file ' subjid '.164k_fs_LR.wb.spec INVALID ' files{i} '_restore.nii.gz']);
end

end
cd(curdir)