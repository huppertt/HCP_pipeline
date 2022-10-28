function Xnat_AddMRISession(subjid,sessionname,dicomfolder,jsess,Project,force)
% dicomfolder='/Users/huppert/Desktop/HCP/raw/MRI/2017.01.09-07.47.43/209'
% subjid = 'HCP209';
% sessionname='MRI_Day1';

if(nargin<5)
    Project = 'COBRA';
end

if(nargin<6)
    force=false;
end

setenv('DYLD_LIBRARY_PATH','/Users/huppert/abin')

StudyNameMap = HCP_dicom_mapping(dicomfolder,subjid);

% figure out the date from the first scan
f=rdir(fullfile(dicomfolder,'*/MR*'));
if(isempty(f))
    return
end
info=dicominfo(f(1).name);

date=datestr(datenum(info.AcquisitionDate,'yyyymmdd'),'YYYY-mm-dd');

if(nargin<4)
    [~,jsess]=system('./CreateXnatJess.sh');
    jsess=jsess(end-32:end);
    jsess(double(jsess)==10)=[];
end


tbl2=Xnat_get_SubjectInfo(subjid,jsess);
if(isempty(tbl2))
    system(['./CreateSubject.sh ' Project ' ' subjid ' ' jsess]);
    system(['./CreateSession.sh ' Project ' ' subjid ' ' sessionname ' ' date ' ' jsess]);
elseif(isempty(find(ismember(tbl2.project,Project) & ismember(tbl2.label,sessionname))))
    system(['./CreateSession.sh ' Project ' ' subjid ' ' sessionname ' ' date ' ' jsess]);
end

% now add the scan folders
f=dir(dicomfolder);

for i=1:size(StudyNameMap,1)
    
    fold=dir(fullfile(dicomfolder,StudyNameMap{i,1}));
    
    if(~isempty(fold))
        f(ismember({f.name},{fold.name}))=[];
        files=rdir(fullfile(dicomfolder,fold(1).name,'MR*'));
        %scan=StudyNameMap{i,2}(strfind(StudyNameMap{i,2},'unprocessed/3T/')+length('unprocessed/3T/'):end);
        %scan=scan(1:min(strfind(scan,filesep))-1);
        
        if(length(f)<1)
            continue;
        end
        
        info=dicominfo(files(1).name);
        type=info.SeriesDescription;
        scan=num2str(info.SeriesNumber);
        
        if(~isempty(strfind(type,'BOLD_REST')))
            type=['rfMRI' type(5:end)];
        elseif(~isempty(strfind(type,'BOLD_')))
            type=['tfMRI' type(5:end)];
        end
        
        if( ~isempty(tbl2) && ~isempty(find(ismember(tbl2.type,type) & ismember(tbl2.ID,str2num(scan)))))
            iid=find(ismember(tbl2.type,type) & ismember(tbl2.ID,str2num(scan)));
            [~,msg]=system(['XnatDataClientCerebro -s ' jsess '  -m GET -r http://10.48.86.212:8080' tbl2.URI{iid} '/files?']);
            ndicoms=length(strfind(msg,'.dcm'))/2;
        else
            msg='';
            ndicoms=0;
        end
            
    
        if(force | ndicoms<length(files) | ( ~isempty(tbl2) && isempty(find(ismember(tbl2.type,type) & ismember(tbl2.ID,str2num(scan))))))
              
            
            system(['./CreateScan.sh ' Project ' '  subjid ' ' sessionname ' ' ...
                scan ' ' type ' ' jsess]);
            
            for j=1:length(files)
                [~,a,e]=fileparts(files(j).name);
                if(isempty(strfind(msg,[a e])))
                    info=dicominfo(files(j).name);
                    type=info.ProtocolName;
                    
                    type([strfind(type,'(') strfind(type,')') strfind(type,'.') strfind(type,' ')])='_';
                    
                    scan=num2str(info.SeriesNumber);
                    disp(files(j).name);
                    name=files(j).name(max(strfind(files(j).name,filesep))+1:end);
                    system(['./AddDICOMXnat.sh ' Project ' ' subjid ' ' sessionname ' ' ...
                        scan ' ' type ' ' files(j).name ' ' name ' ' jsess]);
                end
            end
        end
    end
end

% now do everything else

for i=1:length(f)
   % disp(i)
    if(~strcmp(f(i).name(1),'.') && f(i).isdir)
        files=rdir(fullfile(dicomfolder,f(i).name,'MR*'));
        %scan=StudyNameMap{i,2}(strfind(StudyNameMap{i,2},'unprocessed/3T/')+length('unprocessed/3T/'):end);
        %scan=scan(1:min(strfind(scan,filesep))-1);
        if(length(files)>0)
            info=dicominfo(files(1).name);
            type=info.SeriesDescription;
            type([strfind(type,'(') strfind(type,')') strfind(type,'.') strfind(type,' ') strfind(type,'&')])='_';
            scan=num2str(info.SeriesNumber);
            
            if( ~isempty(tbl2) && ~isempty(find(ismember(tbl2.type,type) & ismember(tbl2.ID,str2num(scan)))))
                iid=find(ismember(tbl2.type,type) & ismember(tbl2.ID,str2num(scan)));
                [~,msg]=system(['XnatDataClientCerebro -s ' jsess '  -m GET -r http://10.48.86.212:8080' tbl2.URI{iid} '/files?']);
                ndicoms=length(strfind(msg,'.dcm'))/2;
            else
                ndicoms=0;
            end
            
            if(force | ndicoms<length(files) | (isempty(tbl2) || (isempty(find(ismember(tbl2.type,type) & ismember(tbl2.ID,str2num(scan)))))))
 
                
                system(['./CreateScan.sh ' Project ' '  subjid ' ' sessionname ' ' ...
                    scan ' ' type ' ' jsess]);
                
                for j=1:length(files)
                    info=dicominfo(files(j).name);
                    type=info.ProtocolName;
                     type([strfind(type,'(') strfind(type,')') strfind(type,'.') strfind(type,' ')])='_';
                    scan=num2str(info.SeriesNumber);
                    disp(files(j).name);
                    name=files(j).name(max(strfind(files(j).name,filesep))+1:end);
                    system(['./AddDICOMXnat.sh ' Project ' ' subjid ' ' sessionname ' ' ...
                        scan ' ' type ' ' files(j).name ' ' name ' ' jsess]);
                end
            end
        end
    end
end
