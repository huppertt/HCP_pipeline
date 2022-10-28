function roiAverage_dtseries(subjid)


a={'BA','aparc','aparc.a2009s'};

files=rdir(['/disk/sulcus1/COBRA/' subjid '/MNINonLinear/Results/*/*_Atlas_MSMSulc_prepared.dtseries.nii']);

for iA=1:length(a)
    atlas=['/disk/sulcus1/COBRA/' subjid '/MNINonLinear/fsaverage_LR32k/' subjid '.' a{iA} '.32k_fs_LR.dlabel.nii'];
    
    adata=ft_read_cifti(atlas);
    for fI=1:length(files)
        if(~exist([strtok(files(fI).name,'.') '.' a{iA} '.ROI.dconn_nonAR.mat']))
        
        data=ft_read_cifti(files(fI).name);
        
        fld=[lower(subjid) '_' lower(a{iA})];
        fld(strfind(fld,'.'))='_';
        
        uL=unique(adata.(fld)(~isnan(adata.(fld))));
        ROI=[];
        for j=1:length(uL)
            lst=find(adata.(fld)==uL(j));
            if(length(lst)>0)
                ROI(j,:)=mean(data.dtseries(lst,:));
            else
                ROI(j,:)=nan(size(data.time));
            end
        end
        save([strtok(files(fI).name,'.') '.' a{iA} '.ROI.mat'],'ROI','-MAT')
        ROI(:,1:19)=[];
        [dConn.r,dConn.p]=nirs.sFC.ar_corr(ROI',30,true);
        dConn.dfe=size(ROI,2)-2;
        save([strtok(files(fI).name,'.') '.' a{iA} '.ROI.dconn.mat'],'dConn','-MAT')
        
        [dConn.r,dConn.p]=corrcoef(ROI');
        dConn.dfe=size(ROI,2)-2;
        save([strtok(files(fI).name,'.') '.' a{iA} '.ROI.dconn_nonAR.mat'],'dConn','-MAT')
        end
    end
end



