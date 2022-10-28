function HCP_MSM(subjid,outfolder)


HCProot='/disk/HCP';
if(nargin<2)
    outfolder=fullfile(HCProot,'analyzed');
end

HCP_matlab_setenv;  % Sets the FSL, Freesurfer, etc folders 

LUT='/disk/HCP/pipeline/projects/Pipelines/global/config/FreeSurferAllLut.txt';
high_res_mesh='164';
low_res_mesh='32';

if(length(rdir(fullfile(outfolder,subjid,'MNINonLinear','fsaverage_LR32k','*MSMAll*')))>50)
    disp(['Skipping MSMall ' subjid]);
    return;
end



%% DeDriftAndResample
highpass='2000';
regname='MSMSulc';

fmrires='2.0';
dlabel='NONE';
output_proc_string='_prepared';
smoothing_fwhm='4';
brain_ordinates_res=fmrires;

files=getall_BOLDfiles(fullfile(outfolder,subjid,'MNINonLinear','Results'));

highpass='2000';
smoothing_fwhm='4';
conregname='MSMSulc';
maps=['ArealDistortion_FS@curvature@sulc@thickness'];
  
mmaps=['MyelinMap@SmoothedMyelinMap'];
    

% This needs to exist (and comes from the group level code)
dedrift=[outfolder '/Group/MNINonLinear/Group.L.sphere.MSMSulc.164k_fs_LR.surf.gii@'...
         outfolder '/Group/MNINonLinear/Group.R.sphere.MSMSulc.164k_fs_LR.surf.gii	'];
         
f=getall_BOLDfiles(fullfile(outfolder,subjid));
rfmri='';
found=[];
for i=1:length(f)
    if(isempty(strfind(f(i).name,'MOCO')))
    rfmri=[rfmri '@' f(i).name];
    if(exist(fullfile(outfolder,subjid,'MNINonLinear','Results',f(i).name,...
            [f(i).name '_Atlas_MSMAll_prepared.dtseries.nii'])))
    found(end+1)=1;
    else
        found(end+1)=0;
    end
    
    end
end
rfmri(1)=[];
f2=getall_BOLDfiles(fullfile(outfolder,subjid));
f2(ismember({f2.name},{f.name}))=[];
tfmri='';
for i=1:length(f2)
    if(~isempty(dir(fullfile(outfolder,subjid,f2(i).name,[f2(i).name '_nonlin.nii.gz']))))
        tfmri=[tfmri '@' f2(i).name];
        if(exist(fullfile(outfolder,subjid,'MNINonLinear','Results',f2(i).name,...
                [f2(i).name '_Atlas_MSMAll_prepared.dtseries.nii'])))
            found(end+1)=1;
        else
            found(end+1)=0;
        end
    end
end
if(length(tfmri)>0)
    tfmri(1)=[];
end

if(isempty(tfmri))
    tfmri='NONE';
end

if(all(found==1))
    disp(['MSMAll complete skipping: ' subjid]);
    return;
end


rois=dir(fullfile(outfolder,subjid,'MNINonLinear','ROIs','*.2.nii.gz'));
for i=1:length(rois)  
    fileIn=(fullfile(outfolder,subjid,'MNINonLinear','ROIs',rois(i).name));
    fileOut=[fileIn(1:strfind(fileIn,'.2.nii.gz')) '2.0.nii.gz'];
    system(['${CARET7DIR}/wb_command -volume-label-import ' fileIn ' ' LUT ' ' fileOut ' -discard-others']); 
end


system(['/disk/HCP/pipeline/projects/Pipelines/DeDriftAndResample/DeDriftAndResamplePipeline.sh'...
    ' --path=' outfolder ' --subject=' subjid ' --high-res-mesh=' high_res_mesh ' --low-res-meshes=' low_res_mesh...
    ' --registration-name=' regname ' --dedrift-reg-files=' dedrift ...
    ' --concat-reg-name=' conregname ' --maps=' maps ' --myelin-maps=' mmaps ...
    ' --rfmri-names=' rfmri ' --tfmri-names=' tfmri ' --smoothing-fwhm=' smoothing_fwhm...
    ' --highpass=' highpass]);

if(~exist(fullfile(outfolder,subjid,'scripts')))
    mkdir(fullfile(outfolder,subjid,'scripts'))  
end
system(['mv -v ' outfolder filesep subjid '*.matlab.log ' outfolder filesep subjid filesep 'scripts']);


%% RestingStateStats
regname = 'MSMSulc';
for i=1:length(files)
    fmriname = files(i).name;
    
    system([HCProot '/pipeline/projects/Pipelines/RestingStateStats/RestingStateStats.sh' ...
            ' --study-folder=' outfolder ...
            ' --subject=' subjid ...
            ' --fmri-name=' fmriname ...
            ' --high-pass=' highpass ...
            ' --reg-name=' regname ...
            ' --low-res-mesh=' low_res_mesh ...
            ' --final-fmri-res=' fmrires ...
            ' --dlabel-file=' dlabel ...
            ' --output-proc-string=' output_proc_string ...
            ' --smoothing-fwhm=' smoothing_fwhm ...
            ' --brain-ordinates-res=' brain_ordinates_res...
            ' --bc-mode=NONE'...
            ]);
end
system(['mv -v ' outfolder filesep subjid '*.matlab.log ' outfolder filesep subjid filesep 'scripts']);


MSMpath=fullfile(HCProot,'/pipeline/projects/Pipelines/global/templates/MSMAll');
fmrinames=[];

for i=1:length(files)
    if(exist(fullfile(outfolder,subjid,'MNINonLinear','Results',files(i).name))==7)
    fIn=rdir(fullfile(outfolder,subjid,'MNINonLinear','Results',files(i).name,[files(i).name '_Atlas_MSMSulc.dtseries.nii'] ));
    if(~isempty(fIn))
        fIn=fIn(1).name;
        fOut=[fIn(1:strfind(fIn,'.dtseries')-1) '_prepared.dtseries.nii'];
        system(['cp -v ' fIn ' ' fOut]);
        fmrinames=[fmrinames '@' files(i).name];
    end
    end
end
fmrinames(1)=[];

fmri_proc_string='_Atlas_MSMSulc_prepared';
output_registration_name='MSMAll';
high_res_mesh='164';

output_fmri_name='BOLD_MSMconcat';
input_registration_name='MSMSulc';

setenv('MSMBin','/disk/HCP/pipeline/external/MSM_HOCR_v1/Centos/');

system([HCProot '/pipeline/projects/Pipelines/MSMAll/MSMAllPipeline.sh' ...
            ' --study-folder=' outfolder ...
            ' --subject=' subjid ...
            ' --fmri-names-list=' fmrinames ...
            ' --msm-all-templates=' MSMpath ...
            ' --output-fmri-name=' output_fmri_name ...
            ' --fmri-proc-string=' fmri_proc_string ...
            ' --output-registration-name=' output_registration_name ...
            ' --high-res-mesh=' high_res_mesh ...
            ' --low-res-mesh=' low_res_mesh ...
            ' --input-registration-name=' input_registration_name ...
            ]);
 
        

% 
HCP_MSMall_makespec(subjid,outfolder);
