function HCP_Update_MRI_DICOMS

[~,flist]=system(['rsync -vru --size-only /disk/mace2/scan_data/WPC-7030/* /disk/HCP/raw/MRI']);

HCP_matlab_setenv;

f=rdir('/disk/HCP/raw/MRI/*/*');
for i=length(f):-1:1;
    if(f(i).isdir)
        try;
            HCP_rename_CCF(f(i).name);
        end
    end
end;

id = rdir('/disk/HCP/raw/MRI/*/*/BOLD_REST1*');
n={};
for i=1:length(id)
    n{i}=fileparts(id(i).name);
end
n=unique(n);



id = rdir('/disk/HCP/raw/MRI/*/*/BOLD_REST3*');
n2={};
for i=1:length(id)
    n2{i}=fileparts(id(i).name);
end
n2=unique(n2);



cd /disk/HCP/pipeline/analysis/Xnat/
[~,jsess]=system('./CreateXnatJess.sh');
jsess=jsess(end-32:end);
jsess(double(jsess)==10)=[];


for i=1:length(n)
    [~,subj]=fileparts(n{i});
    subj=['HCP' subj];
    Session=[subj '_MR1'];
    Xnat_AddMRISession(subj,Session,n{i},jsess,'COBRA',0);
end
for i=1:length(n2)
    [~,subj]=fileparts(n2{i});
    subj=['HCP' subj];
    Session=[subj '_MR2'];
    Xnat_AddMRISession(subj,Session,n2{i},jsess,'COBRA',0);
end



