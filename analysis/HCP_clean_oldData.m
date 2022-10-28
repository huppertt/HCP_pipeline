function HCP_clean_oldData(subjid,outfolder)

if(nargin<2)
    outfolder='/disk/HCP/analyzed';
end


f=rdir(fullfile(outfolder,subjid,'MNINonLinear','Results','*','*_Atlas.dtseries.nii'));

BOLDDone={};
for i=1:length(f)
    [~,BOLDDone{i,1}]=fileparts(f(i).name);
    BOLDDone{i}=BOLDDone{i}(1:strfind(BOLDDone{i},'_Atlas')-1);
    if(strcmp(BOLDDone{i}(end),'_')); BOLDDone{i}(end)=[]; end;
end
BOLDDone=unique(BOLDDone);

rm={'DistortionCorrectionAndEPIToT1wReg_FLIRTBBRAndFreeSurferBBRbased'
    'MotionCorrection_FLIRTbased'
    'MotionMatrices'
    'OneStepResampling'
    'Scout_GradientDistortionUnwarp'};

for i=1:length(BOLDDone)
    for j=1:length(rm)
        system(['rm -rfv ' fullfile(outfolder,subjid,BOLDDone{i},rm{j})]);
    end
    system(['rm -rfv ' fullfile(outfolder,subjid,'MNINonLinear','Results',BOLDDone{i},'RibbonVolumeToSurfaceMapping')]);
   % system(['rm -rfv ' fullfile(outfolder,subjid,'MNINonLinear','Results',BOLDDone{i},'*.ica')]);
    
    
    system(['rm -rfv ' fullfile(outfolder,subjid,BOLDDone{i},'afni','*_AA*')]);
    system(['rm -rfv ' fullfile(outfolder,subjid,BOLDDone{i},'afni','*_AB*')]);
    system(['rm -rfv ' fullfile(outfolder,subjid,BOLDDone{i},'afni','*_AC*')]);
    system(['rm -rfv ' fullfile(outfolder,subjid,BOLDDone{i},'afni','*_AD*')]);
   
end


