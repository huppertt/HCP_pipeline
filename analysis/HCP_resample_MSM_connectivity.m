function HCP_resample_MSM_connectivity(subjid,outfolder)

if(nargin<2)
outfolder='/disk/HCP/analyzed';
end

atlasR=fullfile(outfolder,subjid,'MNINonLinear','fsaverage_LR32k',[subjid '.R.CorticalAreas_dil_Final_Final_Areas_Group.32k_fs_LR.dlabel.nii']);
atlasL=fullfile(outfolder,subjid,'MNINonLinear','fsaverage_LR32k',[subjid '.R.CorticalAreas_dil_Final_Final_Areas_Group.32k_fs_LR.dlabel.nii']);


files=rdir(fullfile(outfolder,subjid,'MNINonLinear','Results','BOLD_*','*_Atlas_MSMSulc_prepared.dtseries.nii'));
%files=[files; rdir(fullfile(outfolder,subjid,'MEG*','*-prep.dtseries.nii'))];

% make the time courses in MSMall space

OutL=fullfile(outfolder,subjid,'MNINonLinear','fsaverage_LR32k',[subjid '.L.sphere.MSMAll_1_d40_WRN.32k_fs_LR.surf.gii']);
OutR=fullfile(outfolder,subjid,'MNINonLinear','fsaverage_LR32k',[subjid '.R.sphere.MSMAll_1_d40_WRN.32k_fs_LR.surf.gii']);
InL=fullfile(outfolder,subjid,'MNINonLinear','fsaverage_LR32k',[subjid '.L.sphere.32k_fs_LR.surf.gii']);
InR=fullfile(outfolder,subjid,'MNINonLinear','fsaverage_LR32k',[subjid '.R.sphere.32k_fs_LR.surf.gii']);


OutLa=fullfile(outfolder,subjid,'MNINonLinear','fsaverage_LR32k',[subjid '.L.midthickness_MSMAll_1_d40_WRN.32k_fs_LR.surf.gii']);
OutRa=fullfile(outfolder,subjid,'MNINonLinear','fsaverage_LR32k',[subjid '.R.midthickness_MSMAll_1_d40_WRN.32k_fs_LR.surf.gii']);

InLa=fullfile(outfolder,subjid,'MNINonLinear','fsaverage_LR32k',[subjid '.L.midthickness_MSMSulc.32k_fs_LR.surf.gii']);
InRa=fullfile(outfolder,subjid,'MNINonLinear','fsaverage_LR32k',[subjid '.R.midthickness_MSMSulc.32k_fs_LR.surf.gii']);

atlas333=ft_read_cifti('/disk/HCP/pipeline/templates/HCP_S900_GroupAvg_v1/Gordon333.32k_fs_LR.dlabel.nii');

for i=1:length(files)
   
    fileOut=files(i).name;
    fileOut=[fileOut(1:strfind(fileOut,'_Atlas_MSMSulc')) 'Atlas_MSMAll_prepared.dtseries.nii'];
     
    fileOut2=files(i).name;
   fileOut2=[fileOut2(1:strfind(fileOut2,'_Atlas_MSMSulc')) 'Gordon333_ROI.mat'];
   
   if(exist(fileOut2))
       disp(['skipping: ' fileOut2]);
       continue;
   else
       disp(fileOut2);
   end
    if(~isempty(strfind(files(i).name,'.label.')))
        METHOD='ENCLOSING_VOXEL'; %use for dlabel
    else
        METHOD='CUBIC';
    end
    
    template='/disk/HCP/pipeline/templates/HCP_S900_GroupAvg_v1/S900.midthickness_MSMAll_va.32k_fs_LR.dscalar.nii';
      

    
    cmd=['${CARET7DIR}/wb_command -cifti-resample ' ...
        files(i).name ' COLUMN ' template ' COLUMN'...
        ' ADAP_BARY_AREA ' METHOD ' ' fileOut ...
        ' -left-spheres ' InL ' ' OutL ...
        ' -left-area-surfs '  InLa ' ' OutLa ...
        ' -right-spheres ' InR ' ' OutR ...
        ' -right-area-surfs '  InRa ' ' OutRa];
    if(~exist(fileOut))
        system(cmd);
    end
    c=ft_read_cifti(fileOut);
    ROI.data=zeros(333,size(c.dtseries,2));
    for j=1:333
        lst=find(atlas333.x333cort==j);
        ROI.data(j,:)=nanmean(c.dtseries(lst,:),1);
    end
   ROI.labels=readtable('/disk/HCP/pipeline/templates/HCP_S900_GroupAvg_v1/Gordon333_Key.txt','Delimiter','\t');
   
  
   save(fileOut2,'ROI');
   
end






