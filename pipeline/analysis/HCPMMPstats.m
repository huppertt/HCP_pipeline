function tbl = HCPMMPstats(subjid,outfolder);

if(nargin<2)
    outfolder='/disk/HCP/analyzed';
end

try
labelR=ft_read_cifti(fullfile(outfolder,'HCP201','MNINonLinear','fsaverage_LR32k',...
    ['HCP201.R.CorticalAreas_dil_Final_Final_Areas_Group.32k_fs_LR.dlabel.nii']),...
    'readsurface',false);

labelL=ft_read_cifti(fullfile(outfolder,'HCP201','MNINonLinear','fsaverage_LR32k',...
    ['HCP201.L.CorticalAreas_dil_Final_Final_Areas_Group.32k_fs_LR.dlabel.nii']),...
    'readsurface',false);

R=gifti(fullfile(outfolder,subjid,'MNINonLinear','fsaverage_LR32k',...
    [subjid '.R.midthickness.32k_fs_LR.surf.gii']));
L=gifti(fullfile(outfolder,subjid,'MNINonLinear','fsaverage_LR32k',...
    [subjid '.L.midthickness.32k_fs_LR.surf.gii']));

v1=R.vertices(R.faces(:,1),:);
v2=R.vertices(R.faces(:,2),:);
v3=R.vertices(R.faces(:,3),:);
vec1=v2-v1;
vec2=v3-v1;
cr=cross(vec1,vec2,2);
surfaceR =sqrt(sum(cr.^2,2))/2; 

v1=L.vertices(L.faces(:,1),:);
v2=L.vertices(L.faces(:,2),:);
v3=L.vertices(L.faces(:,3),:);
vec1=v2-v1;
vec2=v3-v1;
cr=cross(vec1,vec2,2);
surfaceL =sqrt(sum(cr.^2,2))/2;

MyR=gifti(fullfile(outfolder,subjid,'MNINonLinear','fsaverage_LR32k',...
    [subjid '.R.SmoothedMyelinMap.32k_fs_LR.func.gii']));
MyL=gifti(fullfile(outfolder,subjid,'MNINonLinear','fsaverage_LR32k',...
    [subjid '.L.SmoothedMyelinMap.32k_fs_LR.func.gii']));

ThR=gifti(fullfile(outfolder,subjid,'MNINonLinear','fsaverage_LR32k',...
    [subjid '.R.thickness.32k_fs_LR.shape.gii']));
ThL=gifti(fullfile(outfolder,subjid,'MNINonLinear','fsaverage_LR32k',...
    [subjid '.L.thickness.32k_fs_LR.shape.gii']));

 tbl=readtable('/disk/HCP/pipeline/templates/HCP-MMP.txt','delimiter',' ','ReadVariableNames',false);

s=struct;

lab=unique(labelL.indexmax(~isnan(labelL.indexmax)));
for i=1:length(lab)
    s.Hemi{i,1}='L';
    s.Index(i,1)=lab(i);
    s.Label{i,1}=tbl.Var2{i};
    lst=find(labelL.indexmax==lab(i));
     lst2=find(all(ismember(L.faces,lst),2));
    s.thickness(i,1)=mean(ThL.cdata(lst));
    s.area(i,1)=sum(surfaceL(lst2));
    s.volume(i,1)=s.thickness(i,1)*s.area(i,1);
    s.myelin(i,1)=mean(MyL.cdata(lst));
end
cnt=i;
lab=unique(labelR.indexmax(~isnan(labelR.indexmax)));
for i=1:length(lab)
    s.Hemi{cnt+i,1}='R';
    s.Index(cnt+i,1)=lab(i)+cnt;
      s.Label{i+cnt,1}=tbl.Var2{i+cnt};
    lst=find(labelR.indexmax==lab(i));
    lst2=find(all(ismember(R.faces,lst),2));
    s.thickness(cnt+i,1)=mean(ThR.cdata(lst));
    s.area(cnt+i,1)=sum(surfaceR(lst2));
    s.volume(cnt+i,1)=s.thickness(cnt+i)*s.area(cnt+i,1);
    s.myelin(cnt+i,1)=mean(MyR.cdata(lst));
end

tbl=struct2table(s);
nirs.util.write_xls(fullfile(outfolder,subjid,'stats','HCP-MMPstats.xls'),tbl);
catch
    tbl=[];
end