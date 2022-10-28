function tbl=Xnat_addMEGSession(subjid,linkedonly,jsess,force)

Project = 'COBRA';

if(nargin<2)
    linkedonly=false;
end

if(nargin<4)
    force=false;
end


sessionname=[subjid '_MEG'];

MEGfiles = dir(fullfile('/disk','HCP','raw','MEG',subjid,'*.fif'));

if(isempty(MEGfiles))
    warning(['No MEG data ' subjid]);
    tbl=[];
    return
end

date=datestr(MEGfiles(1).datenum,'YYYY-mm-dd');

if(nargin<3 & nargout==0)
    [~,jsess]=system('./CreateXnatJess.sh');
    jsess=jsess(end-32:end);
    jsess(double(jsess)==10)=[];
end

tbl2=Xnat_get_SubjectInfo(subjid,jsess);

if(isempty(tbl2))
    warning(['could not find Xnat entry: ' subjid]);
    system(['./CreateSubject.sh COBRA ' subjid ' ' jsess]);
    
   system(['./CreateSessionMEG.sh COBRA ' subjid ' ' subjid '_MEG ' date ' ' jsess]);
   
    tbl2=table;
    %return;
end
lst=[];
for i=1:height(tbl2)
    if(isempty(strfind(tbl2.label{i},'MEG')))
        lst=[lst i];
    end
end
tbl2(lst,:)=[];

lst=[];
for i=1:height(tbl2)
    if(~isempty(strfind(tbl2.type{i},'test')))
        lst=[lst i];
    end
    if(~isempty(strfind(tbl2.type{i},'Unknown')))
        lst=[lst i];
    end
end

for i=1:length(lst)
    system(['XnatDataClientCerebro -s ' jsess '  -m DELETE -r http://10.48.86.212:8080' tbl2.URI{lst(i)}]);
end
tbl2(lst,:)=[];

if(height(tbl2)>0)
    tbl2(~ismember(tbl2.label,[subjid '_MEG']),:)=[];
end

tt=table;

for i=1:height(tbl2)
    a=Xnat_get_ScanInfo(tbl2.URI{i},jsess); 
    if(~isempty(a))
        if(~ismember('name',a.Properties.VariableNames))
            name=repmat({''},height(a),1);
            a=[a table(name)];
        end
        if(~ismember('instanceNumber',a.Properties.VariableNames))
            instanceNumber=NaN(height(a),1);
            a=[a table(instanceNumber)];
        end
        
        tt=[tt; a];
    end
end

if(isempty(tbl2))
    system(['./CreateSubject.sh ' Project ' ' subjid ' ' jsess]);
end


if(isempty(tbl2) || ~ismember(sessionname,tbl2.label))
   system(['./CreateSessionMEG.sh ' Project ' ' subjid ' ' sessionname ' ' date ' ' jsess]);
end

cnt=1;
s=struct;
for i=1:length(MEGfiles)
    scan=num2str(i);
    file=fullfile('/disk','HCP','raw','MEG',subjid,MEGfiles(i).name);
    file(strfind(file,'_'))=[];
    name=[];
    if(~isempty(strfind(lower(file),'empty')))
        type='room';
        name='MEG_EMPTY';
        link=[];
    elseif(~isempty(strfind(lower(file),'rest')) && ~isempty(strfind(lower(file),'open')))
        type='rfMEG';
        name='rfMEG_REST_EyesOpen';
        link=[];
    elseif(~isempty(strfind(lower(file),'rest')) && ~isempty(strfind(lower(file),'close')))
        type='rfMEG';
        name='rfMEG_REST_EyesClosed';
        link=[];
    elseif(~isempty(strfind(lower(file),'rest')))
        type='rfMEG';
        name='rfMEG_REST';
        link=[]; 
    elseif(~isempty(strfind(lower(file),'language1')))
        type='tfMEG';
        name='tfMEG_LANGUAGE1';
        link=dir(fullfile('/disk','HCP','raw','EPRIME_MEG',subjid,'*MEG_StoryM_run1*'));    
    elseif(~isempty(strfind(lower(file),'language2')))
        type='tfMEG';
        name='tfMEG_LANGUAGE2';
        link=dir(fullfile('/disk','HCP','raw','EPRIMEt_MEG',subjid,'*MEG_StoryM_run2*'));
    elseif(~isempty(strfind(lower(file),'motor1')))
        type='tfMEG';
        name='tfMEG_MOTOR1';
        link=[dir(fullfile('/disk','HCP','raw','EPRIME_MEG',subjid,'*Motort_run1*')); ...
            dir(fullfile('/disk','HCP','raw','EPRIME_MEG',subjid,'*MOTOR_run1*'))];
    elseif(~isempty(strfind(lower(file),'motor2')))
        type='tfMEG';
        name='tfMEG_MOTOR2';
        link=[dir(fullfile('/disk','HCP','raw','EPRIME_MEG',subjid,'*Motort_run2*')); ...
            dir(fullfile('/disk','HCP','raw','EPRIME_MEG',subjid,'*MOTOR_run2*'))];
    elseif(~isempty(strfind(lower(file),'wm1')))
        type='tfMEG';
        name='tfMEG_WM1';
        link=[dir(fullfile('/disk','HCP','raw','EPRIME_MEG',subjid,'*MEG_Wrkmem_run1*'));...
            dir(fullfile('/disk','HCP','raw','EPRIME_MEG',subjid,'*WM_run1*'))];
    elseif(~isempty(strfind(lower(file),'wm2')))
        type='tfMEG';
        name='tfMEG_WM2';
        link=[dir(fullfile('/disk','HCP','raw','EPRIME_MEG',subjid,'*MEG_Wrkmem_run2*'));...
            dir(fullfile('/disk','HCP','raw','EPRIME_MEG',subjid,'*WM_run2*'))];
    end
    file=fullfile('/disk','HCP','raw','MEG',subjid,MEGfiles(i).name);
        %disp(file)
        if(~isempty(name) )
          %  disp(name)
            if(nargout==0 && (isempty(tt) || ~ ismember(name,tt.cat_desc)))
               
                if(~isfield(tbl2,'type') || ~ismember(name,tbl2.type))
                    system(['./CreateScanMEG.sh ' Project ' ' subjid ' ' sessionname ' ' scan ' ' name ' ' jsess]); 
                end
                if(force | (isempty(tt) || ~ismember([name '.fif'],tt.name)))
                    system(['cp -v ' file ' raw.fif']);
                     system('rm /disk/HCP/.mne/mne-python.json');
                    system(['python3.5 /disk/HCP/pipeline/analysis/HCP_megpipe.py anom raw.fif']);
                    
                    system(['./AddFIFFXnat.sh ' Project ' ' subjid ' ' sessionname ' ' ...
                        scan ' ' name ' raw.fif ' name ' ' jsess]);
                    system('rm -f raw.fif');
                end
                
                if(length(link)>0)
                    for j=1:length(link)
                        [~,~,ext]=fileparts(link(j).name);
                       if(~isempty(strfind(link(j).name,'TAB')))
                            n = [name '_TAB' ext];
                            
                        else
                            n = [name ext];
                        end
                        
                        if(isempty(tt) || ~ismember(n,tt.name))
                            
                            file=fullfile('/disk','HCP','raw','EPRIME_MEG',subjid,link(j).name);
                          
                            
                            system(['./Add_LINKED_MEG_Xnat.sh ' Project ' ' subjid ' ' sessionname ' ' ...
                                scan ' ' name ' ' file ' ' n ' ' jsess]);
                        end
                    end
                else
                    link=struct;
                    link.name=[];
                end
            else
                if(isempty(link))
                      link=struct;
                    link.name=[];
                end
                
                s.Project{cnt,1}=Project;
                s.subjid{cnt,1}=subjid;
                s.sessionname{cnt,1}=sessionname;
                s.scan{cnt,1}=scan;
                s.name{cnt,1}=name;
                s.file{cnt,1}=file;
                s.link{cnt,1}=link.name;
                cnt=cnt+1;
            end
            
            
        end
    
end

if(nargout==1)
    tbl=struct2table(s);
end