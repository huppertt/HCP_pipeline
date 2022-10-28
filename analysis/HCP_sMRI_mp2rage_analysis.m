function tbl=HCP_sMRI_mp2rage_analysis(subjid,outfolder,force)

HCProot='/disk/HCP';
if(nargin<2)
    outfolder=fullfile(HCProot,'analyzed');
end

if(nargin<3)
    force=false;
end

HCP_matlab_setenv;  % Sets the FSL, Freesurfer, etc folders 

if(force)
    system(['rm -rf ' fullfile(outfolder,subjid,'T1w',subjid)]);
end

% This runs all the sMRI/Freesurfer parts of the code
system(['source ' HCProot '/pipeline/projects/Pipelines/Examples/Scripts/PreFreeSurferMP2RAGEPipelineBatch.sh --runlocal --StudyFolder=' outfolder ' --Subjlist="' subjid '"'])
system(['source ' HCProot '/pipeline/projects/Pipelines/Examples/Scripts/FreeSurferPipelineBatch.sh --runlocal --StudyFolder=' outfolder ' --Subjlist="' subjid '"'])
system(['source ' HCProot '/pipeline/projects/Pipelines/Examples/Scripts/PostFreeSurferPipelineBatch.sh --runlocal --StudyFolder=' outfolder ' --Subjlist="' subjid '"'])


%system([fullfile(HCProot,'pipeline','projects','Pipelines','StructuralQC','GenerateStructuralScenes.sh') ' --StudyFolder=' outfolder ' --Subjlist=' subjid])

system(['mkdir ' fullfile(outfolder,subjid,'stats')]);
system(['cp ' fullfile(outfolder,subjid,'T1w',subjid,'stats','*') ' '  fullfile(outfolder,subjid,'stats')]);

system(['rm -rf ' fullfile(outfolder,subjid,'T1w',subjid,'bem','*.fif')]);

HCP_add_BEM_models(subjid,outfolder);
% HCP_compute_scalp_distance(subjid,outfolder);
% HCP_makeIso2Mesh(subjid,outfolder);
% HCP_Label_1020(subjid,outfolder);

HCP_sMRI_QC(subjid,outfolder);

tbl = HCP_report_file_integrity(fullfile(outfolder,subjid),'sMRI');