function tbl2=Xnat_get_SubjectInfo(subjid,jsess)

if(isempty(strfind(getenv('PATH'),':/disk/HCP/pipeline/xnat_remote/xnat-tools/')))
setenv('PATH',[getenv('PATH') ':/disk/HCP/pipeline/xnat_remote/xnat-tools/']);
end

if(nargin<2)
    [~,jsess]=system('./CreateXnatJess.sh');
    jsess=jsess(end-32:end);
    jsess(double(jsess)==10)=[];
end


tbl = Xnat_get_SessionInfo(jsess);


if(isempty(tbl))
    tbl2=[];
    return
end
tbl(~ismember(tbl.SubjID,subjid),:)=[];
tbl(ismember(tbl.xsiType,'val:protocolData'),:)=[];

tbl2=[];
for id=1:height(tbl)
    
    [~,msg]=system(['XnatDataClientCerebro -s ' jsess '  -m GET -r http://10.48.86.212:8080' ...
        tbl.URI{id} '/scans?columns=ID,xnat:imageScanData/frames,type,series_description']);
    
    str=msg(strfind(msg,'{"ResultSet'):end);
    str=str(1:min(find(double(str)==10))-1);
    str=str(strfind(str,'[')+1:strfind(str,']')-1);
    
    starts=strfind(str,'{');
    ends=strfind(str,'}');
    
    t={};
    for i=1:length(starts)
        s=[',' str(starts(i)+1:ends(i)-1) ','];
        sc=strfind(s,',');
        for j=1:length(sc)-1
            ss=s(sc(j)+1:sc(j+1)-1);
            [a,b]=strtok(ss,':');
            a=a(2:end-1);
            b=b(3:end-1);
            if(~isempty(str2num(b)))
                b=str2num(b);
            end
            if(isempty(b) & strcmp(a,'frames'))
                b=NaN;
            elseif(isempty(b))
                b=' ';
            end
            if(strcmp(a,'ID') & isstr(b) && isempty(str2num(b)))
                b=NaN;
            end
                
            t{i,j}=b;
            header{j}=a;
        end
        
        
    end
    if(~isempty(t))
        tt=tbl(id,:);
        tt(:,ismember(tt.Properties.VariableNames,header))=[];
        
        tbl3= cell2table(t,'VariableNames',header);
        tbl3= [repmat(tt,height(tbl3),1) tbl3];
        
        tbl2=[tbl2; tbl3];
    end
end

if(~isempty(tbl2))
tbl2=sortrows(tbl2,{'date','ID'});

redonames={'rfMRI_REST_AP_SBRef','rfMRI_REST_PA_SBRef','rfMRI_REST_AP','rfMRI_REST_PA',...
    'rfMRI_MOTOR_AP_SBRef','rfMRI_MOTOR_PA_SBRef','rfMRI_MOTOR_AP','rfMRI_MOTOR_PA',...
    'rfMRI_WM_AP_SBRef','rfMRI_WM_PA_SBRef','rfMRI_WM_AP','rfMRI_WM_PA',...
    'rfMRI_LANGUAGE_AP_SBRef','rfMRI_LANGUAGE_PA_SBRef','rfMRI_LANGUAGE_AP','rfMRI_LANGUAGE_PA',...
    'rfMEG_REST','tfMEG_MOTOR','tfMEG_LANGAUGE','tfMEG_WM'};

for j=1:length(redonames)
    lst=find(ismember(tbl2.type,redonames{j}));
    ii=strfind(redonames{j},'_');
    if(length(ii)>1)
    pre=redonames{j}(1:ii(2)-1);
    post=redonames{j}(ii(2):end);
    else
        pre=redonames{j};
        post='';
    end
    for i=1:length(lst)
        tbl2.type{lst(i)}=[pre num2str(i) post];
    end
end
end
return
