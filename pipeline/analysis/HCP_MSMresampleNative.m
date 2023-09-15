function HCP_MSMresampleNative(subjid,outfolder)


HCProot='/disk/HCP';
if(nargin<2)
    outfolder=fullfile(HCProot,'analyzed');
end

HCP_matlab_setenv;

rootfolder=fullfile(outfolder,subjid,'MNINonLinear','Native');
outf=fullfile(outfolder,subjid,'MNINonLinear','MSMsulc');
files=dir(fullfile(rootfolder,'*.gii'));

mkdir(outf);


oldsphereL=[rootfolder filesep subjid '.L.sphere.reg.native.surf.gii'];
newsphereL='/disk/HCP/pipeline/templates/HCP_S900_GroupAvg_v1/S900.L.sphere.32k_fs_LR.surf.gii';
oldsphereareaL=[rootfolder filesep subjid '.L.midthickness.native.surf.gii'];
newsphereareaL='/disk/HCP/pipeline/templates/HCP_S900_GroupAvg_v1/S900.L.midthickness_MSMAll.32k_fs_LR.surf.gii';

oldsphereR=[rootfolder filesep subjid '.R.sphere.reg.native.surf.gii'];
newsphereR='/disk/HCP/pipeline/templates/HCP_S900_GroupAvg_v1/S900.R.sphere.32k_fs_LR.surf.gii';
oldsphereareaR=[rootfolder filesep subjid '.R.midthickness.native.surf.gii'];
newsphereareaR='/disk/HCP/pipeline/templates/HCP_S900_GroupAvg_v1/S900.R.midthickness_MSMAll.32k_fs_LR.surf.gii';

for i=1:length(files)
    fileIn=fullfile(rootfolder,files(i).name);
    fileOut=fullfile(outf,files(i).name);
    
    if(~isempty(strfind(files(i).name,'.label.')))
        METHOD='ENCLOSING_VOXEL'; %use for dlabel
    else
        METHOD='CUBIC';
    end
    
    if    (~isempty(strfind(files(i).name,'.L.')))
        continue;
    elseif(~isempty(strfind(files(i).name,'.R.')))
        continue;
    else
        template='/disk/HCP/pipeline/templates/HCP_S900_GroupAvg_v1/S900.midthickness_MSMAll_va.32k_fs_LR.dscalar.nii'
    end
    

    
    cmd=['${CARET7DIR}/wb_command -cifti-resample ' ...
        fileIn ' COLUMN ' template ' COLUMN'...
        ' ADAP_BARY_AREA ' METHOD ' ' fileOut ...
        ' -left-spheres ' oldsphereL ' ' newsphereL ...
        ' -left-area-surfs '  oldsphereareaL ' ' newsphereareaL ...
        ' -right-spheres ' oldsphereR ' ' newsphereR ...
        ' -right-area-surfs '  oldsphereareaR ' ' newsphereareaR];
    
end




