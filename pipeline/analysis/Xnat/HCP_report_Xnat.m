function tbl = HCP_report_Xnat(Subject,t)

if(nargin<2 || isempty(t))
    t=Xnat_get_all_data(Subject);
end

if(isa(t.cat_id,'cell'))
    t(ismember(t.cat_desc,'PhoenixZIPReport'),:)=[];
    t.cat_id=cell2mat(t.cat_id);
end

s=struct;
cnt=1;
IDS=unique(t.cat_id);
for i=1:length(IDS)
    lst2=find(t.cat_id==IDS(i));
    names=unique(t.cat_desc(lst2));
    for j=1:length(names)
        lst=find(t.cat_id==IDS(i) & ismember(t.cat_desc,names{j}));
        s.nDICOMS(cnt,1)=length(find(ismember(t.format(lst),{'DICOM'})));
        s.nLINK(cnt,:)=length(find(ismember(t.label(lst),{'LINKED_DATA'})));
        
        s.nFIFF(cnt,1)=length(find(ismember(t.format(lst),{' '}) & ismember(t.label(lst),{'RAW'})));
        s.name{cnt,1}=t.cat_desc{lst(1)};
        s.SUbjID{cnt,1}=Subject;
        cnt=cnt+1;
    end
end

tbl=struct2table(s);