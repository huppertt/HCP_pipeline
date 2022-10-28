function tbl=Xnat_addMRI_LINKED(subjid,jsess)

Project = 'COBRA';
if(nargin<2 & nargout==0)
    [~,jsess]=system('./CreateXnatJess.sh');
    jsess=jsess(end-32:end);
     jsess(double(jsess)==10)=[];
end

f=dir(fullfile('/disk/HCP/analyzed',subjid,'unprocessed/3T/BOLD*'));

tbl=Xnat_get_SubjectInfo(subjid,jsess);
tbl2=tbl;

if(isempty(tbl))
    return;
end

lst=[];
for i=1:height(tbl2)
    if(~isempty(strfind(tbl2.type{i},'/disk')))
        lst=[lst i];
    end
end
tbl2(lst,:)=[];
for i=1:height(tbl2)
  %  system(['XnatDataClientCerebro -s ' jsess '  -m DELETE -r http://10.48.86.212:8080' tbl2.URI{i}]);
end

%tbl=tbl(lst,:);        
tbltype=tbl.type;
tblURI=tbl.URI;

s=struct;


cnt=1; type={};
for i=1:length(f)
    task=f(i).name;
    
   
    if(isempty(strfind(task,'REST')))
        type{end+1}=['tfMRI_' task(min(strfind(task,'_'))+1:end)];
        if(ismember(type{end},tbl.type))
            scan=num2str(tbl.ID(ismember(tbl.type,type{end})));
        else
            type{end}=task;
            scan=num2str(tbl.ID(ismember(tbl.type,type{end})));
        end
    else
        type{end+1}=['rfMRI_' task(min(strfind(task,'_'))+1:end)];
        id=str2num(type{end}(11));
        % type(11)=[];
        if(ismember(type{end},tbl.type))
            scan=num2str(tbl.ID(ismember(tbl.type,type{end})));
        else
            type{end}=task;
            scan=num2str(tbl.ID(ismember(tbl.type,type{end})));
        end
        
    end
    
    if(isempty(find(ismember(tbltype,type{end}))))
        disp([ subjid ' ' type{end}]);
            
    end
    

end


type=unique(type);
tt=[];
for ii=1:length(type)
    ll=find(ismember(tbltype,type{ii}));
    if(~isempty(ll))
        b=tblURI{ll};
        
        a=Xnat_get_ScanInfo(b,jsess);
        try; a.cat_id=[]; end;
        if(~ismember('name',a.Properties.VariableNames))
            name=repmat({''},height(a),1);
            a=[a table(name)];
        end
        if(~ismember('instanceNumber',a.Properties.VariableNames))
            instanceNumber=NaN(height(a),1);
            a=[a table(instanceNumber)];
        end
        if(~isempty(a))
           tt = table_vcat({tt a});
            
        end
    end
end

for i=1:length(f)
    task=f(i).name;
    
    if(ismember(task,{'BOLD_MOTOR1_AP','BOLD_MOTOR2_PA','BOLD_LANGUAGE1_AP','BOLD_LANGUAGE2_PA','BOLD_REST3_AP','BOLD_REST3_PA','BOLD_REST4_AP','BOLD_REST4_PA'...
            'BOLD_MOTOR1_AP_PhysioLog','BOLD_MOTOR2_PA_PhysioLog','BOLD_LANGUAGE1_AP_PhysioLog','BOLD_LANGUAGE2_PA_PhysioLog',...
            'BOLD_REST3_AP_PhysioLog','BOLD_REST3_PA_PhysioLog','BOLD_REST4_AP_PhysioLog','BOLD_REST4_PA_PhysioLog'}))
        sessionname=[subjid '_MR2'];
    else
        sessionname=[subjid '_MR1'];
    end
    files=rdir(fullfile('/disk/HCP/analyzed',subjid,'unprocessed/3T',task,'LINKED*','*','*'));
    
        

    for j=1:length(files)
        if(~files(j).isdir)
            try
                 if(isempty(strfind(task,'REST')))
                    type=['tfMRI_' task(min(strfind(task,'_'))+1:end)];
                    type2=type;
                    if(ismember(type,tbl.type))
                        scan=num2str(tbl.ID(ismember(tbl.type,type)));
                    else
                        type=task;
                        scan=num2str(tbl.ID(ismember(tbl.type,type)));
                    end
                else
                    type=['rfMRI_' task(min(strfind(task,'_'))+1:end)];
                    type2=type;
                    id=str2num(type(11));
                    % type(11)=[];
                    if(ismember(type,tbl.type))
                        scan=num2str(tbl.ID(ismember(tbl.type,type)));
                    else
                        type=task;
                        scan=num2str(tbl.ID(ismember(tbl.type,type)));
                    end
                    
                end
                if(~isempty(strfind(type,'/disk')))
                    continue
                end
                
                file=files(j).name;
                [~,~,ext]=fileparts(file);
                if(strcmp(ext,'.log'))
                    ext=file(max(strfind(file,'_')):end);
                end
                
                if(~isempty(strfind(files(j).name,'TAB')))
                    n = [type '_TAB' ext];
                     n2 = [type2 '_TAB' ext];
                else
                    n = [type ext];
                    n2 = [type2 ext];
                end
                
                if(isempty(scan))
                   waring(['skipping ' subjid ' ' n]);
                   continue;
                end
                
                
                
                if(~ismember(n,tt.URI))
                    if(nargout==0)
                        system(['./Xnat_AddMRI_LINKED.sh ' Project ' ' subjid ' ' sessionname ' ' ...
                            scan ' ' type ' ' file ' ' n ' ' jsess]);
%                         system(['./Xnat_AddMRI_LINKED.sh ' Project ' ' subjid ' ' sessionname ' ' ...
%                             scan ' ' type2 ' ' file ' ' n2 ' ' jsess]);
                    end
                end
                
                s.scan{cnt,1}=scan;
                s.type{cnt,1}=type;
                s.file{cnt,1}=file;
                s.session{cnt,1}=sessionname;
                s.n{cnt,1}=n;
                cnt=cnt+1;
            end
        end
    end
end

if(nargout>0)
    tbl=struct2table(s);
end
