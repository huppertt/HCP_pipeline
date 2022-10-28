function HCP_MSM_resample_MEG(subjid,force);

if(nargin<2)
    force=false;
end


outfolder='/disk/HCP/analyzed';

InL=fullfile(outfolder,subjid,'MNINonLinear','fsaverage_LR32k',[subjid '.L.sphere.MSMAll_2_d40_WRN.32k_fs_LR.surf.gii']);
InR=fullfile(outfolder,subjid,'MNINonLinear','fsaverage_LR32k',[subjid '.R.sphere.MSMAll_2_d40_WRN.32k_fs_LR.surf.gii']);

OutL=fullfile(outfolder,subjid,'MNINonLinear','waveletJ5',[subjid '.L.sphere.surf.gii']);
OutR=fullfile(outfolder,subjid,'MNINonLinear','waveletJ5',[subjid '.R.sphere.surf.gii']);

IL=gifti(InL);
OL=gifti(OutL);
kL=dsearchn(IL.vertices,OL.vertices);

IR=gifti(InR);
OR=gifti(OutR);
kR=dsearchn(IR.vertices,OR.vertices);

file='/disk/HCP/pipeline/templates/HCP_S900_GroupAvg_v1/Gordon333.32k_fs_LR.dlabel.nii';
c=ft_read_cifti(file);
lstL=find(c.brainstructure==1);
lstR=find(c.brainstructure==2);

labels = c.x333cort([lstL(kL); lstR(kR)]);



files=rdir(fullfile(outfolder,subjid,'MEG*','*-real.dtseries.nii'));
for ii=1:length(files)
    f=files(ii).name(1:strfind(files(ii).name,'-real.dtseries.nii')-1);
     fileOut=[f '_Gordon333_dconn.mat'];
     if(exist(fileOut))
         tmp=load(fileOut);
         if(sum(tmp.ROI.PLV(:))==0)
             delete(fileOut);
             disp(['redoing ' fileOut]);
         end
         
     end
     if(exist(fileOut) & ~force)
         continue; 
     end
    ccI=ft_read_cifti([f '-imag.dtseries.nii']);
    ccR=ft_read_cifti([f '-real.dtseries.nii']);
    y=[];
    for j=1:333
        lst=find(labels==j);
        re=nanmean(ccR.dtseries(lst,:),1);
        im=nanmean(ccI.dtseries(lst,:),1);
        
        y(j,:)=angle(re+(1i)*im);
    end
    
    PLV=zeros(size(y,1));
    for i=1:size(y,1)
        for j=i+1:size(y,1)
            PLV(i,j)=abs(sum(exp(1i*(y(i,:)-y(j,:)))))/size(y,1);
            PLV(j,i)=PLV(i,j);
        end
    end
    
    ROI.PLV=PLV;
    ROI.labels=readtable('/disk/HCP/pipeline/templates/HCP_S900_GroupAvg_v1/Gordon333_Key.txt','Delimiter','\t');
    
   
    save(fileOut,'ROI');
    disp(fileOut);
end
