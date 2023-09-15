function HCP_WMHstats(outfolder)

if(nargin<1)
    outfolder='/disk/HCP/analyzed';
end

f=rdir(fullfile(outfolder,'*','T2FLAIR','*.dat'));
for i=1:length(f)
    f(i).name=f(i).name(1:strfind(f(i).name,'/T2FLAIR/')-1);
end
folders=unique({f.name});

for i=1:length(folders)
    disp(['processing: ' folders]);
    stats{i}=WMHstats(folders{i});
end

L=[];
for i=1:length(stats)
    L=[L(:); stats{i}.Region(:)];
end
lst=[];
for i=1:length(L)
        if(~isempty(strfind(L{i},'ctx-')));
        lst=[lst; i];
    end
end
L(lst)=[];
L=unique(L);

flds=stats{1}.Properties.VariableNames;
flds={flds{~ismember(flds,'Region')}};

for i=1:length(folders)
    SubjID{i,1}=folders{i}(length(outfolder)+2:end);
end

for i=1:length(flds)
    tt{i}=struct;
    tt{i}.Regions=L;
    for sI=1:length(SubjID)
        f=nan(length(L),1);
        for j=1:length(L)
            idx=find(ismember(stats{sI}.Region,L{j}));
            if(~isempty(idx))
                try
                    f(j)=stats{sI}.(flds{i})(idx);
                end
            end
        end
        tt{i}=setfield(tt{i},SubjID{sI},f);
    end
    tt{i}=struct2table(tt{i});
end

for i=1:length(tt)
    nirs.util.write_xls(fullfile(outfolder,'Summary','Stats','HCP_WMH_stats.xls'),tt{i},flds{i});
end






function s=WMHstats(folder)
f=rdir(fullfile(folder,'T2FLAIR','*.dat'));
TBL={};
L=[];
for i=1:length(f)
        TBL{i}=HCP_stats2table(f(i).name);
    f(i).name=strrep(f(i).name,'_WMH_','_N4_');
     Name{i}=f(i).name(strfind(f(i).name,'_N4_')+1:end);
    Name{i}=Name{i}(1:strfind(Name{i},'_stats.dat')-1);
    L=[L(:); TBL{i}.StructName(:)];
end

L=unique(L);
s=struct;
s.Region=L;
for i=1:length(Name)
    ff=nan(length(L),1);
    for j=1:length(L);
        idx=find(ismember(TBL{i}.StructName,L(j)));
        if(~isempty(idx))
            ff(j)=TBL{i}.Volume_mm3(idx);
        end
    end
    s=setfield(s,genvarname(Name{i}),ff);
end

s=struct2table(s);
nirs.util.write_xls(fullfile(folder,'stats','WMH_stats.xls'),s);

return
