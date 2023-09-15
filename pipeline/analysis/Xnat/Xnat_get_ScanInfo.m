function tbl = Xnat_get_ScanInfo(URI,jsess)

if(nargin<2)
[~,jsess]=system('./CreateXnatJess.sh');
jsess=jsess(end-32:end);
jsess(double(jsess)==10)=[];
end

[~,msg]=system(['XnatDataClientCerebro -s ' jsess '  -m GET -r http://10.48.86.212:8080' ...
    URI '/resources/?']);

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
        if(isempty(b) & (strcmp(a,'frames') | strcmp(a,'file_count') | strcmp(a,'file_size')))
            b=NaN;
        elseif(isempty(b))
            b=' ';
        end
        t{i,j}=b;
        header{j}=a;
    end   
end

if(~exist('header'))
    tbl=table;
    return
end

resourcestbl = cell2table(t,'VariableNames',header);

tbl=[];
for id=1:height(resourcestbl)
    [~,msg]=system(['XnatDataClientCerebro -s ' jsess '  -m GET -r http://10.48.86.212:8080' ...
        URI '/resources/' resourcestbl.label{id} '?']);
    
    str=msg(strfind(msg,'<cat:entries>'):strfind(msg,'</cat:entries>')-1);
    str=str(min(find(double(str)==10))+1:end);
    
    starts=strfind(str,'<cat:');
    ends=strfind(str,'/>');
    
    t={}; header={};
    for i=1:length(starts)
        s=[' ' str(starts(i)+1:ends(i)-1) ' '];
        sc=strfind(s,' ');
        for j=2:length(sc)-1
            ss=s(sc(j)+1:sc(j+1)-1);
            [a,b]=strtok(ss,'=');
            b=b(3:end-1);
            if(~isempty(str2num(b)))
                b=str2num(b);
            end
            if(isempty(b) & (strcmp(a,'frames') | strcmp(a,'file_count') | strcmp(a,'file_size')))
                b=NaN;
            elseif(isempty(b))
                b=' ';
            end
            t{i,j-1}=b;
            a(strfind(a,':'))='_';
            header{j-1}=a;
        end
    end
    if(~isempty(t))
        tt=resourcestbl(id,:);
        tt(:,ismember(tt.Properties.VariableNames,header))=[];
        tbl2=[repmat(tt,size(t,1),1) cell2table(t,'VariableNames',header)];
        if(~isempty(tbl))
            n=tbl.Properties.VariableNames(~ismember(tbl.Properties.VariableNames,tbl2.Properties.VariableNames));
            a=cell(height(tbl2),length(n));
            for k=1:length(n)
                ty=class(tbl.(n{k})(1));
                if(strcmp(ty,'cell'))
                    a1='';
                else
                    a1=NaN;
                end
                for l=1:height(tbl2)
                    a{l,k}=a1;
                end
            end
            tbl2=[tbl2 cell2table(a,'VariableNames',n)];
            
              n=tbl2.Properties.VariableNames(~ismember(tbl2.Properties.VariableNames,tbl.Properties.VariableNames));
            a=cell(height(tbl),length(n));
            for k=1:length(n)
                ty=class(tbl2.(n{k})(1));
                if(strcmp(ty,'cell'))
                    a1='';
                else
                    a1=NaN;
                end
                for l=1:height(tbl)
                    a{l,k}=a1;
                end
            end
            tbl=[tbl cell2table(a,'VariableNames',n)];
            
            
        end
try;        tbl=[tbl; tbl2]; end;
    end
    
end