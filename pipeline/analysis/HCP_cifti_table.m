function varargout=HCP_cifti_table(cifti,dlabel,fileout)
% This function extracts the ROI information from a cifti file and stores
% as a stats table

labl=ft_read_cifti(dlabel,'readsurface',false);
data=ft_read_cifti(cifti,'readsurface',false);

fldsO={'dimord' 'hdr' 'unit' 'brainstructure' 'brainstructurelabel' 'pos' 'tri'};
flds=fields(labl);
fld=flds{find(~ismember(flds,fldsO))};
labIdx=unique(labl.(fld)(~isnan(labl.(fld))));

annontype=fld(strfind(fld,'_')+1:end);
subjid=dlabel(1:min(strfind(dlabel,'.'))-1);
FShome=fullfile(getenv('SUBJECTS_DIR'),subjid);
switch(lower(annontype))
    case('ba')
        afile=fullfile(FShome,'label','BA.ctab');
    case('anot')
        afile=fullfile(FShome,'label','aparc.annot.ctab');
    case('aparc_a2009s')
        afile=fullfile(FShome,'label','aparc.annot.a2009s.ctab');
end

fid=fopen(afile,'r');
c=textscan(fid,'%s%s%d%d%d%d');
fclose(fid);

labels={}; cnt=1;
for i=1:length(labl.brainstructurelabel)
    l=strcat(repmat(cellstr([labl.brainstructurelabel{i} '_']),length(c{2}),1),c{2});
    labels={labels{:} l{cnt:end}};
    cnt=2;
end
labels=labels';
labels{1}=c{2}{1};

fldsO={'dimord' 'hdr' 'unit' 'brainstructure' 'brainstructurelabel' 'pos' 'tri'};
flds=fields(data);
fld2=flds{find(~ismember(flds,fldsO))};

s=[]; cnt=1;

for j=1:length(labIdx)
    lst=find(labl.(fld)==labIdx(j));
    s.label{cnt,1}=labels{labIdx(j)+1};
    s.mean(cnt,1)=nanmean(data.(fld2)(lst));
    s.median(cnt,1)=nanmedian(data.(fld2)(lst));
    s.std(cnt,1)=nanstd(data.(fld2)(lst));
    s.max(cnt,1)=nanmax(data.(fld2)(lst));
    s.min(cnt,1)=nanmin(data.(fld2)(lst));
    s.range(cnt,1)=s.max(cnt)-s.min(cnt);
    s.cnt(cnt,1)=length(lst);
    s.sum(cnt,1)=nansum(data.(fld2)(lst));
    
    cnt=cnt+1;
    
end

if(nargout==1)
    varargout{1}=struct2table(s);
end

if(nargin>2)
    writetable(struct2table(s),fileout);
end



