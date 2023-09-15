function tbl=HCP_ASL_analysis(subjid,outfolder,runslurm,str)

HCProot='/disk/HCP';
if(nargin<2)
    outfolder=fullfile(HCProot,'analyzed');
end

if(nargin<3)
    runslurm=false;
end

if(~isstruct(subjid))
    subjid2.name=subjid;
    clear subjid;
    subjid=subjid2;
end

if(exist(fullfile(outfolder,subjid.name,'MNINonLinear','ASL_flow_nonlin_brain_1mm.nii.gz'))~=0)
    disp(['ASL done skipping: ' subjid.name]);
    return;
end

HCP_matlab_setenv;  % Sets the FSL, Freesurfer, etc folders

if(nargin<4)
    str={'EP2D_PERF_P2','EP2D_PERF_P2_2','Perfusion','Perfusion_2','3DASL','3DASL_2','ASL','ASL2','ASL_HypercapniaOff','ASL_HypercapniaOn','HypercapniaOn','HypercapniaOff',...
        'ASL_AIR1','ASL_AIR2','ASL_AIR3','ASL_CO21','ASL_CO22','ASL_REST1','ASL_REST2',...
        'ASL_MEDAIR1','ASL_MEDAIR2','ASL_MEDAIR3','ASL_CO2_1','ASL_CO2_2','ASL_1','ASL_2','ASL_3','ASL_4','ASL_5'};
    
end

if(~iscell(str))
    str={str};
end

%This does the fMRI pre-processing
if(length(str)>1)
    jobs={}; cnt=1;
    for i=1:length(subjid)
        for idx=1:length(str)
            if(exist(fullfile(outfolder,subjid(i).name,'unprocessed','3T',str{idx}))==7)
            if(runslurm)
                jobs{cnt}=['HCP_ASL_analysis(''' subjid(i).name ''',''' outfolder ''',false,''' str{idx} ''');'];
                cnt=cnt+1;
            else
                try
                    HCP_ASL_analysis(subjid(i).name,outfolder,runslurm,str{idx})
                end
            end
        end
        end
    end
    if(runslurm)
        matlab2slurm(jobs);
    end
    return;
end

% If you got here, then we are looking only at one file at a time
str=str{1};
subjid=subjid(1).name;

if(exist(fullfile(outfolder,subjid,'unprocessed','3T',str))~=7)
    return
end
   
if(~isempty(strfind(str,'RL')));
    direction='x';
elseif(~isempty(strfind(str,'LR')));
    direction='x-';
elseif(~isempty(strfind(str,'PA')));
    direction='y';
elseif(~isempty(strfind(str,'AP')));
    direction='y-';
else
    direction='y';
end;

system(['source ' HCProot '/pipeline/projects/Pipelines/Examples/Scripts/ASLVolumeProcessingPipelineBatch.sh --runlocal --StudyFolder=' ...
     outfolder ' --Subjlist="' subjid '" --Tasklist=' str ' --Phaselist=' direction]);


file = [outfolder filesep subjid filesep str filesep str '_nonlin_norm.nii.gz'];
fout1 = [outfolder filesep subjid filesep str filesep str '_flow_nonlin.nii.gz'];
fout2 = [outfolder filesep subjid filesep str filesep str '_mean_nonlin.nii.gz'];

system(['asl_file --data=' file ' --ntis=1 --iaf=ct --diff --out=' fout1 ' --mean=' fout2]);

%The asl code screws up the header info (not my fault).

system(['${FSLDIR}/bin/applywarp --interp=nn -i ' fout1 ...
    ' -r ' file ' -o ' fout1 ' --premat=${FSLDIR}/etc/flirtsch/ident.mat']);

system(['${FSLDIR}/bin/applywarp --interp=nn -i ' fout2 ...
    ' -r ' file ' -o ' fout2 ' --premat=${FSLDIR}/etc/flirtsch/ident.mat']);



AtlasSpaceFolder=fullfile(outfolder,subjid,'MNINonLinear');
AtlasTransform=fullfile(AtlasSpaceFolder,'xfms','acpc_dc2standard.nii.gz');
AtlasT1 = fullfile(outfolder,subjid,'MNINonLinear','T1w_restore.nii.gz');
T1 =fullfile(outfolder,subjid,'T1w','T1w_acpc_dc_restore_1mm.nii.gz');
T1brain =fullfile(outfolder,subjid,'T1w','T1w_acpc_dc_restore_brain_1mm.nii.gz');

system(['applywarp --rel --interp=nn -i ' fout1 ' -r ' AtlasT1 ' -w ' AtlasTransform ' -o ' AtlasSpaceFolder '/ASL_flow_nonlin_brain_1mm.nii.gz']);
system(['applywarp --rel --interp=nn -i ' fout2 ' -r ' AtlasT1 ' -w ' AtlasTransform ' -o ' AtlasSpaceFolder '/ASL_mean_nonlin_brain_1mm.nii.gz']);

system(['${CARET7DIR}/wb_command -add-to-spec-file ' AtlasSpaceFolder '/' subjid '.164k_fs_LR.wb.spec INVALID ' AtlasSpaceFolder '/ASL_mean_nonlin_brain_1mm.nii.gz']);



