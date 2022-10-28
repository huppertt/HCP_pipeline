function tbl=getasegstats(file)

keywords={'BrainSeg,','BrainSegNotVent,','BrainSegNotVentSurf,','lhCortex'...
'rhCortex,','Cortex,','lhCorticalWhiteMatter,','rhCorticalWhiteMatter,','CorticalWhiteMatter,',...
'SubCortGray,','TotalGray,','SupraTentorial,','SupraTentorialNotVent,','SupraTentorialNotVentVox,',...
'Mask,','BrainSegVol-to-eTIV,','MaskVol-to-eTIV,','lhSurfaceHoles,','rhSurfaceHoles,',...
'SurfaceHoles,','EstimatedTotalIntraCranialVol,'};


fid=fopen(file,'r');
while(1)
    line=fgetl(fid);
    if(~ischar(line))
        break
    end
    for i=1:length(keywords)
        if(~isempty(strfind(line,keywords{i})))
            lst=strfind(line,',');
            v=str2num(line(lst(end-1)+1:lst(end)-1));
            values(i)=v;
        end
    end
    if(~isempty(strfind(line,'subjectname')))
        subjid=line(strfind(line,'subjectname')+length('subjectname '):end);
    end
end
fclose(fid);    

s=struct;
s.subjid={subjid};
for i=1:length(keywords)
    name=keywords{i}(1:end-1);
    name(strfind(name,'-'))='_';
    s=setfield(s,name,values(i));
end


tbl=struct2table(s);