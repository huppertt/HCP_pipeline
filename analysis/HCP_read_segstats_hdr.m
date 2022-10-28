function tbl = HCP_read_segstats_hdr(file)

fid=fopen(file,'r');
cnt=1;

while(1)
    line=fgetl(fid);
    if(~isstr(line))
        break
    end
    
    if(~isempty(strfind(line,'# Measure')))
        c=textscan(line,'%s%s%s%f%s','Delimiter',',');
        c{2}{1}(strfind(c{2}{1},'-'))='_';
        Names{cnt,1}=c{2}{1};
        Units{cnt,1}=c{5}{1};
        Desc{cnt,1}=c{3}{1};
        Value(cnt,1)=c{4};
        cnt=cnt+1;
    end
end

tbl=table(Names,Value,Units,Desc);