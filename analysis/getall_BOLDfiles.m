function files=getall_BOLDfiles(rootfolder,restonly)

if(nargin<2)
    restonly=false;
end

keywords={'BOLD','fMRI','REST'};
    

files=[];
for i=1:length(keywords)
    files=[files; dir(fullfile(rootfolder,['*' keywords{i} '*']))];
    files=[files; dir(fullfile(rootfolder,['*' lower(keywords{i}) '*']))];
    files=[files; dir(fullfile(rootfolder,['*' upper(keywords{i}) '*']))];
    files=[files; dir(fullfile(rootfolder,[keywords{i} '*']))];
    files=[files; dir(fullfile(rootfolder,[lower(keywords{i}) '*']))];
    files=[files; dir(fullfile(rootfolder,[upper(keywords{i}) '*']))];
    files=[files; dir(fullfile(rootfolder,['*' keywords{i}]))];
    files=[files; dir(fullfile(rootfolder,['*' lower(keywords{i})]))];
    files=[files; dir(fullfile(rootfolder,['*' upper(keywords{i})]))];
end

lst=[];
for i=1:length(files)
    if(files(i).isdir)
        lst=[lst; i];
    end
end
files=files(lst);
[~,i]=unique({files.name});
files=files(i);

