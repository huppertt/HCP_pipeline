function HCP_rename_All(oldname,newname,outfolder)

f=rdir(fullfile(outfolder,oldname,['**/' oldname '*']));

for i=1:length(f)
    f2(i)=f(i);
    str=f2(i).name;
    [p,fi,e]=fileparts(str);
    lst=max(strfind(fi,oldname));
    fi=[newname fi(lst+length(oldname):end)];
        
    f2(i).name=fullfile(p,[fi e]);
end

for i=1:length(f);
    system(['mv -vuf ' f(i).name ' ' f2(i).name]);
end

specfiles=rdir(fullfile(outfolder,oldname,'**','*.spec'));
for i=1:length(specfiles)
    disp(specfiles(i).name)
    system(['sed -i ''s/' oldname '/' newname '/g'' ' specfiles(i).name]);
end

if(exist(fullfile(outfolder,newname)))
    system(['rsync -vur ' fullfile(outfolder,oldname,'*') ' ' fullfile(outfolder,newname)]);
    system(['rm -rf ' fullfile(outfolder,oldname)]);
else
    system(['mv -v ' fullfile(outfolder,oldname) ' ' fullfile(outfolder,newname)]);
end