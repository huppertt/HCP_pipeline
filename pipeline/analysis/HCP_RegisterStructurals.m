function HCP_RegisterStructurals(subjid,outfolder,type)


HCProot='/disk/HCP';
if(nargin<2 || isempty(outfolder))
    outfolder=fullfile(HCProot,'analyzed');
end

if(nargin<3)
    type = {'SWI','FLAIR'};
end

if(iscell(type))
    for i=1:length(type)
        HCP_RegisterStructurals(subjid,outfolder,type{i});
    end
    return
end

HCP_matlab_setenv;  % Sets the FSL, Freesurfer, etc folders 



AtlasSpaceFolder=fullfile(outfolder,subjid,'MNINonLinear');
AtlasTransform=fullfile(AtlasSpaceFolder,'xfms','acpc_dc2standard.nii.gz');
AtlasT1 = fullfile(outfolder,subjid,'MNINonLinear','T1w_restore.nii.gz');


if(exist(fullfile(outfolder,subjid,'unprocessed','3T','SWI')))
    system(['source ' HCProot '/pipeline/projects/Pipelines/Examples/Scripts/GenericRegistrationPipelineBatch.sh --runlocal --StudyFolder='...
        outfolder ' --Subjlist="' subjid '" --Modlist="SWI"'])
    fout1=fullfile(outfolder,subjid,'T1w','SWI_acpc_dc_brain.nii.gz');
    system(['applywarp --rel --interp=nn -i ' fout1 ' -r ' AtlasT1 ' -w ' AtlasTransform ' -o ' AtlasSpaceFolder '/SWI_nonlin_brain_1mm.nii.gz']);
    system(['${CARET7DIR}/wb_command -add-to-spec-file ' AtlasSpaceFolder '/' subjid '.164k_fs_LR.wb.spec INVALID ' AtlasSpaceFolder '/SWI_nonlin_brain_1mm.nii.gz']);
end

if(exist(fullfile(outfolder,subjid,'unprocessed','3T','T2FLAIR')))
    
    system(['source ' HCProot '/pipeline/projects/Pipelines/Examples/Scripts/GenericRegistrationPipelineBatch.sh --runlocal --StudyFolder='...
        outfolder ' --Subjlist="' subjid '" --Modlist="T2FLAIR"'])
    fout2=fullfile(outfolder,subjid,'T1w','T2FLAIR_acpc_dc_brain.nii.gz');
    system(['applywarp --rel --interp=nn -i ' fout2 ' -r ' AtlasT1 ' -w ' AtlasTransform ' -o ' AtlasSpaceFolder '/T2wFLAIR_nonlin_brain_1mm.nii.gz']);
    
    system(['${CARET7DIR}/wb_command -add-to-spec-file ' AtlasSpaceFolder '/' subjid '.164k_fs_LR.wb.spec INVALID ' AtlasSpaceFolder '/T2wFLAIR_nonlin_brain_1mm.nii.gz']);
    
    
end