function HCP_MSMall_makespec(subjid,outfolder)


HCProot='/disk/HCP';
if(nargin<2)
    outfolder=fullfile(HCProot,'analyzed');
end

HCP_matlab_setenv;  % Sets the FSL, Freesurfer, etc folders 

 MSMallfiles = rdir(fullfile(outfolder,subjid,'MNINonLinear','fsaverage_LR32k','*MSMAll*.nii'));

if(isempty(MSMallfiles))
    warning('no files');
    return
end

Lsphere = fullfile(outfolder,subjid,'MNINonLinear','fsaverage_LR32k',[subjid '.L.sphere.MSMAll_1_d40_WRN.32k_fs_LR.surf.gii']);
Rsphere = fullfile(outfolder,subjid,'MNINonLinear','fsaverage_LR32k',[subjid '.R.sphere.MSMAll_1_d40_WRN.32k_fs_LR.surf.gii']);
Lsphere2 = fullfile(outfolder,subjid,'MNINonLinear','fsaverage_LR32k',[subjid '.L.sphere.MSMAll_2_d40_WRN.32k_fs_LR.surf.gii']);
Rsphere2 = fullfile(outfolder,subjid,'MNINonLinear','fsaverage_LR32k',[subjid '.R.sphere.MSMAll_2_d40_WRN.32k_fs_LR.surf.gii']);

f{1}='pial';
f{2}='very_inflated';
f{3}='midthickness';
f{4}='flat';
f{5}='inflated';
f{6}='white';

LsphereOrig=fullfile(outfolder,subjid,'MNINonLinear',[subjid '.L.sphere.164k_fs_LR.surf.gii']);
RsphereOrig=fullfile(outfolder,subjid,'MNINonLinear',[subjid '.R.sphere.164k_fs_LR.surf.gii']);

% first let's make the surface files

for i=1:length(f)

fileInL=fullfile(outfolder,subjid,'MNINonLinear',[subjid '.L.' f{i} '.164k_fs_LR.surf.gii']);
fileInR=fullfile(outfolder,subjid,'MNINonLinear',[subjid '.R.' f{i} '.164k_fs_LR.surf.gii']);

fileOutL=fullfile(outfolder,subjid,'MNINonLinear','fsaverage_LR32k',[subjid '.L.' f{i} '_MSMAll_1_d40_WRN.32k_fs_LR.surf.gii']);
fileOutR=fullfile(outfolder,subjid,'MNINonLinear','fsaverage_LR32k',[subjid '.R.' f{i} '_MSMAll_1_d40_WRN.32k_fs_LR.surf.gii']);

    
system(['${CARET7DIR}/wb_command -surface-resample ' fileInL ' ' LsphereOrig ' ' Lsphere ' BARYCENTRIC ' fileOutL]);
system(['${CARET7DIR}/wb_command -surface-resample ' fileInR ' ' RsphereOrig ' ' Rsphere ' BARYCENTRIC ' fileOutR]);


fileOutL=fullfile(outfolder,subjid,'MNINonLinear','fsaverage_LR32k',[subjid '.L.' f{i} '_MSMAll_2_d40_WRN.32k_fs_LR.surf.gii']);
fileOutR=fullfile(outfolder,subjid,'MNINonLinear','fsaverage_LR32k',[subjid '.R.' f{i} '_MSMAll_2_d40_WRN.32k_fs_LR.surf.gii']);

    
system(['${CARET7DIR}/wb_command -surface-resample ' fileInL ' ' LsphereOrig ' ' Lsphere2 ' BARYCENTRIC ' fileOutL]);
system(['${CARET7DIR}/wb_command -surface-resample ' fileInR ' ' RsphereOrig ' ' Rsphere2 ' BARYCENTRIC ' fileOutR]);


end


% now create the SPEC file
specfile =  fullfile(outfolder,subjid,'MNINonLinear','fsaverage_LR32k',[subjid '.MSMAll_2_d40_WRN.32k_fs_LR.wb.spec']);

Lsphere = fullfile(outfolder,subjid,'MNINonLinear','fsaverage_LR32k',[subjid '.L.sphere.MSMAll_2_d40_WRN.32k_fs_LR.surf.gii']);
Rsphere = fullfile(outfolder,subjid,'MNINonLinear','fsaverage_LR32k',[subjid '.R.sphere.MSMAll_2_d40_WRN.32k_fs_LR.surf.gii']);


giifilesL=rdir(fullfile(outfolder,subjid,'MNINonLinear','fsaverage_LR32k',[subjid '.L.*.MSMAll*.surf.gii']));
giifilesR=rdir(fullfile(outfolder,subjid,'MNINonLinear','fsaverage_LR32k',[subjid '.R.*.MSMAll*.surf.gii']));

for i=1:length(giifilesL)
    system(['${CARET7DIR}/wb_command -add-to-spec-file ' specfile ' CORTEX_LEFT ' giifilesL(i).name]);
end
for i=1:length(giifilesR)
    system(['${CARET7DIR}/wb_command -add-to-spec-file ' specfile ' CORTEX_RIGHT ' giifilesR(i).name]);
end

MSMallfiles = rdir(fullfile(outfolder,subjid,'MNINonLinear','fsaverage_LR32k','*_MSMAll_2_d40_WRN*.nii'));

for i=1:length(MSMallfiles)
     system(['${CARET7DIR}/wb_command -add-to-spec-file ' specfile ' CORTEX ' MSMallfiles(i).name]);
end




%/disk/sulcus/analyzed/HCP_Atlas/Glasser_et_al_2016_HCP_MMP1.0_RVVG' 2'/HCP_PhaseTwo/Q1-Q6_RelatedParcellation210/MNINonLinear/fsaverage_LR32k/

f=rdir('/disk/sulcus/HCP_Atlas/Glasser_et_al_2016_HCP_MMP1.0_RVVG 2/HCP_PhaseTwo/Q1-Q6_RelatedParcellation210/MNINonLinear/fsaverage_LR32k/Q*.border')
for i=1:length(f)
   [~,fi,ext]=fileparts(f(i).name);
   [~,fi]=strtok(fi,'.');
   fi=fullfile(outfolder,subjid,'MNINonLinear','fsaverage_LR32k',[subjid fi ext]);
   disp(fi)
   copyfile(f(i).name,fi);  
end


f=rdir('/disk/sulcus/HCP_Atlas/Glasser_et_al_2016_HCP_MMP1.0_RVVG 2/HCP_PhaseTwo/Q1-Q6_RelatedParcellation210/MNINonLinear/fsaverage_LR32k/*.dlabel.nii')
for i=1:length(f)
   [~,fi,ext]=fileparts(f(i).name);
   [~,fi]=strtok(fi,'.');
   fi=fullfile(outfolder,subjid,'MNINonLinear','fsaverage_LR32k',[subjid fi ext]);
   disp(fi)
   copyfile(f(i).name,fi);  
end

scene='/disk/sulcus1/HCP_Atlas/Glasser_et_al_2016_HCP_MMP1.0_RVVG 2/HCP_PhaseTwo/Glasser_et_al_2016_HCP_MMP1.0_StudyData/Glasser_et_al_2016_HCP_MMP1.0_6_AllAreasMap.scene';
sceneOut=fullfile(outfolder,subjid,'MNINonLinear','fsaverage_LR32k',[subjid '.MSMAll_AllAreasMap.scene']);

copyfile(scene,sceneOut);

% MISSING DeDrift files from folder


s1='../Q1-Q6_RelatedParcellation210/MNINonLinear/fsaverage_LR32k/Q1-Q6_RelatedParcellation210';

system(['sed ''s/Q1-Q6_RelatedParcellation210/' subjid '/g'' ' sceneOut ' > test.scene' ]);
system(['sed ''s/Q1-Q6_RelatedValidation210/' subjid '/g'' test.scene > test2.scene']);
system(['sed ''s/..\/' subjid '\/MNINonLinear\/fsaverage_LR32k/./g'' test2.scene > test3.scene']);
system(['sed ''s/d41_WRN_DeDrift/d40_WRN/g'' test3.scene > ' sceneOut]);
 
system('rm test*.scene');


if(~exist(fullfile(outfolder,subjid,'scripts')))
    mkdir(fullfile(outfolder,subjid,'scripts'))  
end
system(['mv -v ' outfolder filesep subjid '*.log ' outfolder filesep subjid filesep 'scripts']);

