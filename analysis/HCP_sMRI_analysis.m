function tbl=HCP_sMRI_analysis(subjid,outfolder,force,infant)

HCProot='/disk/HCP';
if(nargin<2)
    outfolder=fullfile(HCProot,'analyzed');
end

if(nargin<3)
    force=false;
end

if(nargin<4)
    infant=false;
end

HCP_matlab_setenv;  % Sets the FSL, Freesurfer, etc folders


if(force)
    system(['rm -rf ' fullfile(outfolder,subjid,'T1w')]);
end



f=rdir(fullfile(outfolder,subjid,'unprocessed','3T','T1w_MPR1',[subjid '_3T_T1w_MPR1.nii.gz']));

try
    n=load_untouch_nii(f(1).name);
    if(size(n.img,4)>1)
        warning('T1w has more than one volume- averaging');
        system(['fslmaths ' f(1).name ' -Tmean ' f(1).name]);
    end
end

if(force | exist(fullfile(outfolder,subjid,'T1w','T1w_acpc_dc_restore.nii.gz'))~=2)
    % This runs all the sMRI/Freesurfer parts of the code
    system(['source ' HCProot '/pipeline/projects/Pipelines/Examples/Scripts/PreFreeSurferPipelineBatch.sh --runlocal --StudyFolder=' outfolder ' --Subjlist="' subjid '"'])
end


try
    f={fullfile(outfolder,subjid,'T1w','T1w_acpc_dc_restore.nii.gz'),...
        fullfile(outfolder,subjid,'T1w','T2w_acpc_dc_restore.nii.gz'),...
        fullfile(outfolder,subjid,'T1w','T1w_acpc_dc_restore_brain.nii.gz')};
    for i=1:length(f)
        
        n=load_untouch_nii(f{i});
        if(size(n.img,4)>1)
            warning('T1w has more than one volume- averaging');
            system(['fslmaths ' f{i} ' -Tmean ' f{i}]);
        end
    end
end

if(exist(fullfile(outfolder,subjid,'T1w',subjid,'surf','lh.sphere'))~=2)
    if(infant)
        system(['source ' HCProot '/pipeline/projects/Pipelines/Examples/Scripts/FreeSurferPipelineBatch.sh --runlocal --StudyFolder=' outfolder ' --Subjlist="' subjid '" --flags=@-noaseg'])
    else
        system(['rm -rf ' fullfile(outfolder,subjid,'T1w',subjid)])
        system(['source ' HCProot '/pipeline/projects/Pipelines/Examples/Scripts/FreeSurferPipelineBatch.sh --runlocal --StudyFolder=' outfolder ' --Subjlist="' subjid '"'])
    end
end
system(['source ' HCProot '/pipeline/projects/Pipelines/Examples/Scripts/PostFreeSurferPipelineBatch.sh --runlocal --StudyFolder=' outfolder ' --Subjlist="' subjid '"'])


%system([fullfile(HCProot,'pipeline','projects','Pipelines','StructuralQC','GenerateStructuralScenes.sh') ' --StudyFolder=' outfolder ' --Subjlist=' subjid])

system(['mkdir ' fullfile(outfolder,subjid,'stats')]);
system(['cp ' fullfile(outfolder,subjid,'T1w',subjid,'stats','*') ' '  fullfile(outfolder,subjid,'stats')]);

system(['rm -rf ' fullfile(outfolder,subjid,'T1w',subjid,'bem','*.fif')]);

HCP_add_BEM_models(subjid,outfolder);
HCP_compute_scalp_distance(subjid,outfolder);
HCP_makeIso2Mesh(subjid,outfolder);
HCP_Label_1020(subjid,outfolder);

HCP_sMRI_QC(subjid,outfolder);

tbl = HCP_report_file_integrity(fullfile(outfolder,subjid),'sMRI');