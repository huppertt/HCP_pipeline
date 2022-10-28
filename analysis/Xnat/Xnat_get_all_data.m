function varargout = Xnat_get_all_data(subjid,outfolder,HCProot,jsess)


if(nargin<3)
    HCProot='/disk/HCP/';
end
if(nargin<2 || isempty(outfolder))
    outfolder=fullfile(HCProot,'analyzed');
end


HCP_matlab_setenv;

if(nargin<4)
    [~,jsess]=system('./CreateXnatJess.sh');
    jsess=jsess(end-32:end);
    jsess(double(jsess)==10)=[];
end
    
if(nargin<1 || isempty(subjid))
    tbl = Xnat_get_SessionInfo(jsess);
    tbl(~ismember(tbl.project,{'COBRA'}),:)=[];
    tbl(ismember(tbl.SubjID,''),:)=[];
    subjids = unique(tbl.SubjID);
    for i=1:length(subjids)
        disp(['Processing ' subjids{i}]);
        try
            if(nargout==0)
                Xnat_get_all_data(subjids{i},outfolder,HCProot,jsess);
            else
                T{i}=Xnat_get_all_data(subjids{i},outfolder,HCProot,jsess);
               
            end
        end
    end
    varargout={table_vcat(T)};
    return
end

tbl2=Xnat_get_SubjectInfo(subjid,jsess);

if(isempty(tbl2))
    disp(subjid);
    varargout{1}=[];
    return
end

tbl={}; cnt=1;
for i=1:height(tbl2)
    t = Xnat_get_ScanInfo(tbl2.URI{i},jsess);
    if(~isempty(t))
        tbl{cnt}=t;
        cnt=cnt+1;
    end
    disp(i);
end

flds={};
for i=1:length(tbl)
    flds{i}=tbl{i}.Properties.VariableNames';
end
flds=unique(vertcat(flds{:}));

for i=1:length(tbl)
    b(i,:)=ismember(flds,tbl{i}.Properties.VariableNames);
end

lst=find(any(~b,1));
for i=1:length(tbl)
    for j=1:length(lst)
        if(ismember({flds{lst(j)}},tbl{i}.Properties.VariableNames))
            tbl{i}.(flds{lst(j)})=[];
        end
    end
end

tbl = table_vcat(tbl);
tbl=[table(repmat(cellstr(subjid),height(tbl),1)) tbl];
if(nargout==0)
    file=fullfile(outfolder,subjid,'scripts','Xnat_upload.txt');
    writetable(tbl,file);
else
    file=fullfile(outfolder,subjid,'scripts','Xnat_upload.txt');
    writetable(tbl,file);
    varargout{1}=tbl;
end