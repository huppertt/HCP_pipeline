function T = HCP_parse_curve_stats(file)

fid=fopen(file,'r');
fgetl(fid);
T={}; cnt=1;
while(1)
    s=struct;
    l=fgetl(fid);
    if(isnumeric(l))
        break;
    end
    s.name=l(1:strfind(l,':')-1);
    while(1)
        l=fgetl(fid);
        if(isempty(l) | isnumeric(l)); break; end;
        l=l(min(find(~isspace(l))):end);
        fld=l(min(find(isspace(l)))+1:end);
        fld=fld(1:strfind(fld,':')-1);
        fld(isspace(fld))=[];
        val=l(strfind(l,':')+1:end);
        val=val(min(find(~isspace(val))):end);
        if(~isempty(find(isspace(val))))
        
        comment=val(min(find(isspace(val)))+1:end);
        val=val(1:min(find(isspace(val)))-1);
        end
        if(~isempty(str2num(val))); val=str2num(val); end;
        fld(ismember(fld,'()-'))=[];
        
        s=setfield(s,fld,val);
    end
    if(isnumeric(l))
        break
    end
    
    T{cnt}=s;
    cnt=cnt+1;
end

fclose(fid);