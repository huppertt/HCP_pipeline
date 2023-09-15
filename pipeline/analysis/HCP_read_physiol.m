function d = HCP_read_physiol(filen)
% example: physdata =
% HCP_read_physiol('/disk/HCP/raw/PHYSIOL_MRI/HCPtest1/')

f=dir([filen '*.log']);
cd(filen)
for i=1:length(f)
    info{i}= parsefile(f(i).name);
end

t=[]; d={}; n={}; tt={}; cnt=1;
for i=1:length(f)
    if(isfield(info{i},'ACQ_TIME_TICS'))
        if(isnumeric(info{i}.ACQ_TIME_TICS))
            t=[t; info{i}.ACQ_TIME_TICS];
            d{cnt}=info{i}.VALUE;
            n{cnt}=info{i}.LogDataType;
            tt{cnt}=info{i}.ACQ_TIME_TICS;
            cnt=cnt+1;
        end
    end
    if(isfield(info{i},'ACQ_START_TICS'))
        if(isnumeric(info{i}.ACQ_START_TICS))
            t=[t; info{i}.ACQ_START_TICS];
            t=[t; info{i}.ACQ_FINISH_TICS];
            scanIdx=i;
        end
    end
end
t=unique(t);

data=zeros(length(d),length(t));
for i=1:length(d)
    data(i,:)=interp1(tt{i},d{i},t);
end

slices=zeros(info{scanIdx}.NumSlices,length(t));
for idx=1:info{scanIdx}.NumSlices
    lst=find(info{scanIdx}.SLICE==idx-1);
    for j=1:length(lst)
        ll=find(t>=info{scanIdx}.ACQ_START_TICS(lst(j)) & ...
            t<info{scanIdx}.ACQ_FINISH_TICS(lst(j)));
        slices(idx,ll)=info{scanIdx}.VOLUME(lst(j));
    end
end
slices=single(slices);

d.data=data;
d.time=t;
d.slices=slices;


return

function info = parsefile(f)
fid=fopen(f,'r');

str=[];
info=struct;
while(isempty(strfind(str,'ACQ_')))
    str=fgetl(fid);
    try
       fld=strtrim(str(1:strfind(str,'=')-1));
       val=strtrim(str(strfind(str,'=')+1:end));
       if(~isempty(str2num(val)))
           val=str2num(val);
       end
       info=setfield(info,fld,val);
    end
    
end

flds={}; dlm='';
while(~isempty(str))
    dlm=[dlm '%s'];
    [flds{end+1},str]=strtok(str);
    
end
c=textscan(fid,dlm);

if(strcmp(info.LogDataType,'ACQUISITION_INFO'))
    for i=1:length(flds)
        c{i}=c{i}(1:end-2);
    end
end

for i=1:length(flds)
    if(any(cellfun(@(x)isempty(x),c{i})))
        lst=find(cellfun(@(x)isempty(x),c{i}));
        c{i}(lst)=repmat(cellstr('_'),length(lst),1);
    end
    
    val=strvcat(c{i});
    if(~isempty(str2num(val)))
        val=str2num(val);
    else
        val=cellstr(val);
    end
    info=setfield(info,flds{i},val);
end

fclose(fid);