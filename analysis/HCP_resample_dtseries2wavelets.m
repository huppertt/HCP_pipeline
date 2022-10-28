function HCP_resample_dtseries2wavelets(subjid,J,outfolder)

HCProot='/disk/HCP';
if(nargin<3)
    outfolder=fullfile(HCProot,'analyzed');
end

if(nargin<2 || isempty(J))
    J=5;
end


HCP_matlab_setenv;


p=fullfile(outfolder,subjid,'MNINonLinear',['waveletJ' num2str(J)]);
if(exist(p)~=7)
    disp(['Wavelet folder does not exist: CREATING']);
    disp(p);
    HCP_makeMNIsourcespace(subjid,J,outfolder);
end


direction='COLUMN';
cifti_template=fullfile(p,[subjid '.LR.pial.dscalar.nii']);

template_direction='COLUMN';
surface_method = 'BARYCENTRIC';
volume_method = 'TRILINEAR';

left_spheres1=  fullfile(outfolder,subjid,'MNINonLinear','fsaverage_LR32k',[subjid '.L.sphere.MSMSulc.32k_fs_LR.surf.gii']);
left_spheres2=  fullfile(p,[subjid '.L.sphere.surf.gii']);
left_pial=  fullfile(p,[subjid '.L.pial.surf.gii']);

right_spheres1=  fullfile(outfolder,subjid,'MNINonLinear','fsaverage_LR32k',[subjid '.R.sphere.MSMSulc.32k_fs_LR.surf.gii']);
right_spheres2=  fullfile(p,[subjid '.R.sphere.surf.gii']);
right_pial=  fullfile(p,[subjid '.R.pial.surf.gii']);

f=rdir(fullfile(outfolder,subjid,'MNINonLinear','Results','*','*_Atlas_MSMSulc.dtseries.nii'));

system(['mkdir -p ' fullfile(p,'Results')]);
for i=1:length(f)
    cifti_in=f(i).name;
    
    [~,a,e]=fileparts(f(i).name);
    
    cifti_out=fullfile(p,'Results',[a e]);
    
    
    if(~exist(cifti_out,'file'))
        disp([cifti_in ' >> ' cifti_out]);
        system(['${CARET7DIR}/wb_command -cifti-resample '...
            cifti_in ' ' direction ' ' cifti_template ' ' template_direction ' ' ...
            surface_method ' ' volume_method ' ' cifti_out ' '...
            '-left-spheres ' left_spheres1 ' ' left_spheres2 ' ' ...
            '-right-spheres ' right_spheres1 ' ' right_spheres2]);
    else
        disp(['Skipping ' f(i).name]);
    end
end

if(~exist(fullfile(p,'Results',[subjid '.CORTEX_RIGHT.surf.gii']),'file'))
    system(['cp -v ' left_pial ' ' fullfile(p,'Results',[subjid '.CORTEX_LEFT.surf.gii'])]);
    system(['cp -v ' right_pial ' ' fullfile(p,'Results',[subjid '.CORTEX_RIGHT.surf.gii'])]);
end

% COPY any MEG data
f=rdir(fullfile(outfolder,subjid,'MEG*','*dtseries.nii'));
for i=1:length(f)
    [~,pp,e]=fileparts(f(i).name);
    
    f0=fullfile(p,'Results',[pp e]);
    system(['ln -sv ' f(i).name ' ' f0]);
end
 
f=rdir(fullfile(outfolder,subjid,'NIRS*','*dtseries.nii'));
for i=1:length(f)
    [~,pp,e]=fileparts(f(i).name);
    
    f0=fullfile(p,'Results',[pp e]);
    system(['ln -sv ' f(i).name ' ' f0]);
end
 


