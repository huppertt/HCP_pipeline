function HCP_GroupLevel(outfolder);

HCProot='/disk/HCP';
if(nargin<1)
    outfolder=fullfile(HCProot,'analyzed');
end

HCP_matlab_setenv;  % Sets the FSL, Freesurfer, etc folders 



studypath = outfolder;

s = rdir(fullfile(outfolder,'*','MNINonLinear'));
subj={};
for i=1:length(s);
    subj{i}=s(i).name(length(outfolder)+2:end);
    subj{i}=subj{i}(1:min(strfind(subj{i},filesep))-1);
end
subj=unique(subj);

RM={'HCP444','HCPTEST1','s1200','HCPYC001','HCPYC002','HCPYC003'};
 subj=[subj(~ismember(subj,RM))]    ;

subjlist='';
for i=1:length(subj)
    if(     exist(fullfile(outfolder,subj{i},'MNINonLinear',[subj{i} '.R.sphere.164k_fs_LR.surf.gii']))==2 & ...
            exist(fullfile(outfolder,subj{i},'MNINonLinear','Native',[subj{i} '.R.sphere.reg.native.surf.gii']))==2 & ...
            exist(fullfile(outfolder,subj{i},'MNINonLinear','Native',[subj{i} '.R.sphere.MSMSulc.native.surf.gii']))==2)
    subjlist=[subjlist '@' subj{i}];
    end
end
% subjlist(1)=[];

groupname = 'Group';
commonfolder = fullfile(outfolder,groupname);


%commonfolder = '/disk/sulcus/WPC-7055/GroupAnat';
regname='MSMSulc';
inregname='reg';
tarregname='MSMSulc';
high_res_mesh='164';
low_res_mesh='32';
system([ HCProot '/pipeline/projects/Pipelines/MSMRemoveGroupDrift/MSMRemoveGroupDrift.sh'...
    ' --path=' studypath ' --subject-list=' subjlist ' --common-folder=' commonfolder ...
    ' --group-average-name=' groupname ' --input-registration-name=' inregname ...
    ' --target-registration-name=' tarregname ' --registration-name=' regname ...
    ' --high-res-mesh=' high_res_mesh ' --low-res-mesh=' low_res_mesh]);

regname='reg.reg_LR'
inregname='reg';
tarregname='reg.reg_LR';
system([ HCProot '/pipeline/projects/Pipelines/MSMRemoveGroupDrift/MSMRemoveGroupDrift.sh'...
    ' --path=' studypath ' --subject-list=' subjlist ' --common-folder=' commonfolder ...
    ' --group-average-name=' groupname ' --input-registration-name=' inregname ...
    ' --target-registration-name=' tarregname ' --registration-name=' regname ...
    ' --high-res-mesh=' high_res_mesh ' --low-res-mesh=' low_res_mesh]);


%%  MSMAll
regname='MSMAll'
inregname='reg';
tarregname='MSMSulc';
system([ HCProot '/pipeline/projects/Pipelines/MSMRemoveGroupDrift/MSMRemoveGroupDrift.sh'...
    ' --path=' studypath ' --subject-list=' subjlist ' --common-folder=' commonfolder ...
    ' --group-average-name=' groupname ' --input-registration-name=' inregname ...
    ' --target-registration-name=' tarregname ' --registration-name=' regname ...
    ' --high-res-mesh=' high_res_mesh ' --low-res-mesh=' low_res_mesh]);



StudyFolder=outfolder;
% GroupAverageName='COBRA_Group';
GroupAverageName='Group';
SurfaceAtlasDIR='/disk/HCP/pipeline/projects/Pipelines/global/templates/standard_mesh_atlases' ;
GrayordinatesSpaceDIR='/disk/HCP/pipeline/projects/Pipelines/global/templates/91282_Greyordinates' ;
HighResMesh='164';
LowResMesh='32';
FreeSurferLabels='/disk/HCP/pipeline/projects/Pipelines/global/config/FreeSurferAllLut.txt';
Caret7_Command='wb_command';
Sigma='1'; %Pregradient Smoothing
RegName='NONE';
VideenMaps='corrThickness@thickness@MyelinMap_BC@SmoothedMyelinMap_BC';
GreyScaleMaps='sulc@curvature';
DistortionMaps='SphericalDistortion'; % Don't Include ArealDistortion or EdgeDistortion with RegName NONE
GradientMaps='MyelinMap_BC@SmoothedMyelinMap_BC@corrThickness';
MultiMaps='NONE'; % #I.e. contain multiple columns
STDMaps='sulc@curvature@corrThickness@thickness@MyelinMap_BC';

system(['/disk/HCP/pipeline/projects/Pipelines/Supplemental/MakeAverageDataset/MakeAverageDataset.sh '...
    ' --subject-list=' subjlist ' --study-folder=' StudyFolder ' --group-average-name=' GroupAverageName ' --surface-atlas-dir=' SurfaceAtlasDIR ...
    ' --grayordinates-space-dir=' GrayordinatesSpaceDIR ' --high-res-mesh=' HighResMesh ' --low-res-meshes=' LowResMesh ...
    ' --freesurfer-labels=' FreeSurferLabels ' --sigma=' Sigma ...
    ' --reg-name=' RegName ' --videen-maps=' VideenMaps ' --greyscale-maps=' GreyScaleMaps ' --distortion-maps=' DistortionMaps...
    ' --gradient-maps=' GradientMaps ' --std-maps=' STDMaps ' --multi-maps=' MultiMaps]);