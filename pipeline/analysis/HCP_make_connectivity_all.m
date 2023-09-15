function HCP_make_connectivity_all(subjid,outfolder)




BOLDfiles=rdir(fullfile(outfolder,subjid,'MNINonLinear','Results','*','*_Atlas*.dtseries.nii'));

ROIs=rdir(fullfile(outfolder,subjid,'MNINonLinear','fsaverage_LR32k','*.32k_fs_LR.dlabel.nii'));
lst=[];
for i=1:length(ROIs)
    if(~isempty([strfind(ROIs(i).name,'.R.') strfind(ROIs(i).name,'.L.')]))
        lst=[lst i];
        end
end
ROIs(lst)=[];

for i=1:length(BOLDfiles)
    [~,ff,~]=fileparts(BOLDfiles(i).name);
    [~,ff,~]=fileparts(ff);
    ff=[ff '_*.mat'];
    if(length(dir(fullfile(outfolder,subjid,'MNINonLinear','Results',ff)))==length(ROIs));
        disp(['skipping ' BOLDfiles(i).name]);
        continue;
    end
   
    c=ft_read_cifti(BOLDfiles(i).name);
    for j=1:length(ROIs)
        l=ft_read_cifti(ROIs(j).name);
        L={}; B=[]; cnt=1;
        
        flds=fields(l);
        name={};
        for k=1:length(flds)
            if(~isempty([strfind(flds{k},['x' ]) strfind(flds{k},[lower(subjid(1:3))])]))
                name=flds{k};
            end
        end
        if(~isempty(name))
         
        for k=1:length(c.brainstructurelabel)
           if(~ismember(c.brainstructurelabel{k},l.brainstructurelabel))
               lst=find(c.brainstructure==k);
               B(:,cnt)=nanmedian(c.dtseries(lst,:),1);
               L{cnt,1}=c.brainstructurelabel{k};
               cnt=cnt+1;
           else
                lst=find(c.brainstructure==k);
                lst2=find(l.brainstructure==find(ismember(c.brainstructurelabel{k},l.brainstructurelabel)));
                ul=unique(l.(name)(lst2));
                ul(isnan(ul))=[];
                ul(ul==0)=[];
                for kk=1:length(ul)
                    lst3=lst(find(l.(name)(lst2)==ul(kk)));
                    B(:,cnt)=nanmedian(c.dtseries(lst3,:),1);
                    L{cnt,1}=[c.brainstructurelabel{k} '_' name '_' num2str(ul(kk))];
                    cnt=cnt+1;
               
                end
                
           end
        end
        data.BOLD=B;
        data.Labels=L;
        B=B-ones(size(B,1),1)*nanmean(B,1);
        B=B-ones(size(B,1),1)*nanmean(B,1);
        ll=find(all(~isnan(B),1));
        inn=nirs.math.innovations(B(:,ll),15);
        data.dconn=nan(size(B,2),size(B,2));
        data.dconn(ll,ll)=nirs.math.robust_corrcoef2(inn);
        data.dfe=length(inn)-2;
        
        [~,ff,~]=fileparts(BOLDfiles(i).name);
    [~,ff,~]=fileparts(ff);
    ff=[ff '_' name '.mat'];
    filename=fullfile(outfolder,subjid,'MNINonLinear','Results',ff);
        disp(['saving ' filename]);
        save(filename,'data');
        end
    end
end