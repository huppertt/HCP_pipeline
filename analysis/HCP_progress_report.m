function HCP_progress_report
folder= '/disk/HCP/raw';

MRIscans = dir(fullfile(folder,'MRI'));
MRIscans(1:2)=[];

cnt=1;
for i=1:length(MRIscans)
    if(MRIscans(i).isdir)
        disp(MRIscans(i).name);
        date = MRIscans(i).name;
        loc = rdir(fullfile(folder,'MRI',MRIscans(i).name,'**','localizer*'));
        if(~isempty(loc))
            [~,s]=fileparts(fileparts(loc(1).name));
            f=dir(fullfile(loc(1).name,'MR*'));
            dcminf=dicominfo(fullfile(loc(1).name,f(1).name));
            subjid = dcminf.PatientID;

            if(~strcmp(subjid,s))
                warning('subject IDs do not match')
                disp(s);
                subjid=s;
            end

            scans=dir(fileparts(loc(1).name));
            scans(1:2)=[];

            for j=1:length(scans)
                if(scans(j).isdir)
                    disp(j)
                    f=dir(fullfile(fileparts(loc(1).name),scans(j).name,'MR*'));
                    if(~isempty(f))
                        dcminf=dicominfo(fullfile(fileparts(loc(1).name),scans(j).name,f(1).name));

                        data(cnt).subjid=subjid;
                        data(cnt).date=date;
                        data(cnt).folder=loc(1).name;
                        data(cnt).scan_name =dcminf.ProtocolName;
                        data(cnt).scan_number =dcminf.SeriesNumber;
                        data(cnt).scan_type =dcminf.SequenceName;
                        data(cnt).scan_time =dcminf.AcquisitionTime;
                        data(cnt).scan_folder=scans(j).name;
                        cnt=cnt+1;
                    end
                end
            end
        end
    end
end

tblMRI=struct2table(data);
writetable(tblMRI,fullfile(folder,['MRI-scans.txt']));

%%
Physcans = dir(fullfile(folder,'PHYSIOL_MRI'));
Physcans(1:2)=[];
cnt=1;
for i=1:length(Physcans)
    disp(Physcans(i).name);
    if(Physcans(i).isdir)
        
        date = Physcans(i).name;
        loc = fullfile(folder,'PHYSIOL_MRI',Physcans(i).name);
        f=dir(fullfile(loc,'*_info.log'));
        
        for j=1:length(f)
            try
                name=f(j).name(1:strfind(f(j).name,'_info.log'));
                p=dir([loc filesep name 'puls.log']);
                r=dir([loc filesep name 'resp.log']);
                e=dir([loc filesep name 'ecg.log']);
                in=dir([loc filesep name 'info.log']);
                t=dir([loc filesep name 'ext.log']);
                
                info = parsefile([loc filesep f(j).name]);
                data2(cnt).date=date;
                data2(cnt).NumVolumes=info.NumVolumes;
                data2(cnt).scandata=info.ScanDate;
                if(~iscell(info.ACQ_START_TICS))
                    data2(cnt).aqstart=info.ACQ_START_TICS(1);
                    data2(cnt).aqstart=info.ACQ_FINISH_TICS(end);
                else
                    data2(cnt).aqstart=NaN;
                    data2(cnt).aqstart=NaN;
                    
                end
                data2(cnt).name=name;
                data2(cnt).folder=loc;
                data2(cnt).info=in.name;
                data2(cnt).pulse=p.name;
                data2(cnt).resp=r.name;
                data2(cnt).ecg=e.name;
                data2(cnt).ext=t.name;
                cnt=cnt+1;
            catch
                disp(['error: ' f(j).name])
            end
        end
    end
end

tblPhys=struct2table(data2);
writetable(tblPhys,fullfile(folder,['PHYS-scans.txt']));
%tblMRI=readtable(fullfile(folder,['MRI-scans.txt']));
%tblPhys=readtable(fullfile(folder,['PHYS-scans.txt']));

% align the Phys and MRI tables
for i=1:height(tblPhys);
    try; d2(i)=datenum(tblPhys.scandata{i},'YYYYmmdd_HHMMSS');
    catch; d2(i)=NaN;
    end;
end;

for i=1:height(tblMRI);
    try; d(i)=datenum(tblMRI.date{i},'YYYY.mm.dd-HH.MM.SS');
    catch d(i)=NaN;
    end;
end;

[k,di]=dsearchn(d',d2');

lst=find(di<1E-1);

MRIfolder=tblMRI.date(k(lst));
PHY=[tblMRI(k(lst),1) table(MRIfolder) tblPhys(lst,:)];
PHY(isnan(PHY.aqstart) | PHY.NumVolumes<10,:)=[];

PHY(~ismember(PHY.NumVolumes,[420 372 260 295]),:)=[];


PHY=sortrows(PHY,{'subjid','MRIfolder','aqstart'});
PHY(ismember(PHY.subjid,{'123', 'HCPtest1','hcptest4'}),:)=[];

bytes=[];
for i=1:height(PHY); aa=dir(fullfile(PHY.folder{i},PHY.info{i})); bytes(i)=aa.bytes; end;
PHY=PHY([find(bytes==765840) find(bytes== 1482024) find(bytes==917544)...
    find(bytes== 1312680) find(bytes== 999472) find(bytes==  933224)],:);
PHY=sortrows(PHY,{'subjid','MRIfolder','aqstart'});

fold=unique(PHY.MRIfolder);
Scans=cell(height(PHY),1);
for i=1:length(fold)
    lst=find(ismember(PHY.MRIfolder,fold{i}) & PHY.NumVolumes==420);
    lst2=find(ismember(PHY.MRIfolder,fold{i}) & PHY.NumVolumes==372);
    lst3=find(ismember(PHY.MRIfolder,fold{i}) & PHY.NumVolumes==260);
    lst4=find(ismember(PHY.MRIfolder,fold{i}) & PHY.NumVolumes==295);
    a=[length(lst) length(lst2) length(lst3) length(lst4)];
    disp(a)
    %disp(PHY(lst,1:5));
    %pause;
    
    ff=rdir(fullfile('/disk/HCP/raw/MRI',fold{i},'*','BOLD_REST*'));
    cnt=1;
    for j=1:length(ff)
        if(isempty(strfind(ff(j).name,'SBREF')))
            if(length(dir(ff(j).name))>200 & cnt<length(lst)+1)
                Scans{lst(cnt)}=ff(j).name;
                cnt=cnt+1;
            end
        end
    end
    
    ff=rdir(fullfile('/disk/HCP/raw/MRI',fold{i},'*','BOLD_WM*'));
    cnt=1;
    for j=1:length(ff)
        if(isempty(strfind(ff(j).name,'SBREF')))
            if(length(dir(ff(j).name))>20 & cnt<length(lst2)+1)
                Scans{lst2(cnt)}=ff(j).name;
                cnt=cnt+1;
            end
        end
    end
    ff=rdir(fullfile('/disk/HCP/raw/MRI',fold{i},'*','BOLD_MOTOR*'));
    cnt=1;
    for j=1:length(ff)
        if(isempty(strfind(ff(j).name,'SBREF')))
            if(length(dir(ff(j).name))>20 & cnt<length(lst3)+1)
                Scans{lst3(cnt)}=ff(j).name;
                cnt=cnt+1;
            end
        end
    end
    
    ff=rdir(fullfile('/disk/HCP/raw/MRI',fold{i},'*','BOLD_LANGUAGE*'));
    cnt=1;
    for j=1:length(ff)
        if(isempty(strfind(ff(j).name,'SBREF')))
            if(length(dir(ff(j).name))>20 & cnt<length(lst4)+1)
                Scans{lst4(cnt)}=ff(j).name;
                cnt=cnt+1;
            end
        end
    end
    
    
end

PHY=[table(Scans) PHY];

lst=[];
for i=1:length(Scans)
    if(isempty(Scans{i}))
        lst=[lst i];
    end
end
PHY(lst,:)=[];

for i=1:height(PHY); PHY.subjid{i}=['HCP' PHY.subjid{i}(1:3)]; end;


writetable(PHY,fullfile(folder,['aligned-scans.txt']));


tbl=readtable(fullfile(folder,['aligned-scans.txt']));

for i=1:height(tbl)
    s=tbl.Scans{i};
    lst=strfind(s,'_');
    s=s(1:lst(3)-1);
    [~,s]=fileparts(s);
    MRIscan = fullfile('/disk/HCP/analyzed',tbl.subjid{i},'unprocessed','3T',s);
    system(['mkdir -p ' fullfile(MRIscan,'LINKED_DATA')]);
    system(['mkdir -p ' fullfile(MRIscan,'LINKED_DATA','PHYSIOL')]);
    s2=tbl.scandata{i};
    s2(strfind(s2,'_'))='.';
    f=fullfile('/disk/HCP/raw/PHYSIOL_MRI',s2,[tbl.name{i} '*']);
    system(['rsync -vru --size-only ' f ' ' fullfile(MRIscan,'LINKED_DATA','PHYSIOL/')]);
end



end





function info = parsefile(f)
fid=fopen(f,'r');

str=[];
info=struct;
while(isempty(strfind(str,'ACQ_')))
    str=fgetl(fid);
    if(str==-1)
        break
    end
    try
        fld=strtrim(str(1:strfind(str,'=')-1));
        val=strtrim(str(strfind(str,'=')+1:end));
        if(~isempty(str2num(val)))
            val=str2num(val);
        end
        info=setfield(info,fld,val);
    end
    
end

if(isempty(info))
    return
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
end
