function tbl=PET_stats(outfolder,subjid)

if(nargin<1 || isempty(outfolder))
    outfolder='/disk/sulcus1/COBRA';
end

if(nargin<2 || isempty(subjid))
    subjid=dir(outfolder);
    subjid={subjid(:).name};
end

if(~iscellstr(subjid))
    subjid=cellstr(subjid);
end

T={}; cnt=1;
N={};
for i=1:length(subjid)
   f=fullfile(outfolder,subjid{i},'stats','PiB_SUV.stats');
   if(exist(f,'file'))
       fid=fopen(f,'r');
       c=textscan(fid,'%d%d%s%s%f%f%f%f');
       fclose(fid);
       T{cnt}=c;
       N{cnt}=subjid{i};
       cnt=cnt+1;
       
   end 
end
if(isempty(T))
    tbl=[];
    return;
end
D=cell(length(T),1+length(T{1}{1}));  % value
D2=cell(length(T),1+length(T{1}{1}));  %std
D3=cell(length(T),1+length(T{1}{1})); %voxels

for i=1:length(T);
    D{i,1}=N{i};
    for j=1:size(D,2)-1
        D{i,1+j}=T{i}{7}(j);
        D2{i,1+j}=T{i}{8}(j);
        D3{i,1+j}=T{i}{5}(j);
    end
end

colnames={'subjid' T{1}{3}{:}};
for i=1:length(colnames); colnames{i}(strfind(colnames{i},'-'))='_'; end;

a=find(ismember(colnames,'Left_Amygdala'));
b=find(ismember(colnames,'Right_Amygdala'));


for i=1:size(D,1)
    n=(D3{i,a}*D{i,a}+D3{i,b}*D{i,b})/(D3{i,a}+D3{i,b});
    for j=2:size(D,2)
        D{i,j}=D{i,j}/n;
    end
end


tbl=cell2table(D,'VariableNames',colnames);

if(nargout==0)
    nirs.util.write_xls(fullfile(outfolder,'Summary','Stats','PET_Summary.xlsx'),tbl);
end
