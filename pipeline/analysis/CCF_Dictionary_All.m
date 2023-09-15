function CCF_Dictionary_All(outfolder)

if(nargin<1)
    outfolder='/disk/HCP/analyzed/'
end
curdir=pwd;
cd /disk/HCP/pipeline/analysis/Xnat/
d=dir(outfolder);
s={}; T={};
for i=1:length(d); 
    disp(d(i).name)
    try; 
        T{i}=HCP_report_Dictioary_CCF(d(i).name); 
    catch;
        s{end+1}=d(i).name; 
    end; 
end;

if(isempty(T))
    return
end
TT=table;
for i=1:length(T)
     if(~isempty(T{i})); 
         TT=T{i}(:,2:end);
         break;
     end
end
for i=1:length(T); 
    if(~isempty(T{i})); 
        TT=[TT table(table2array(T{i}(:,1)),'VariableNames',{d(i).name})]; 
    end; 
end;

for i=1:height(TT); if(isempty(TT.description{i})); TT.description{i}=' '; end; end;

if(~isempty(TT))
    nirs.util.write_xls(fullfile(outfolder,'Summary/CCF_Dictionay_v2.xlsx'),TT);
end
cd(curdir)