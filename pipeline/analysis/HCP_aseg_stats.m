function stats = HCP_aseg_stats(file)

fid=fopen(file,'r');

cnt=1;
while(1)
    line=fgetl(fid);
    if(~isstr(line))
        break;
    end
    if(~isempty(strfind(line,'# Measure')))
        [a,b,c,d,e]=strread(line,'%s%s%s%f%s','delimiter',',');
        stats.Name{cnt,1}=b{1};
        stats.Value(cnt,1)=d;
        stats.Units{cnt,1}=e{1};
        stats.Comment{cnt,1}=c{1};
        cnt=cnt+1;
    end
end
fclose(fid);
stats=struct2table(stats);