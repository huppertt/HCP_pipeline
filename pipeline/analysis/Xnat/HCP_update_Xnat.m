function HCP_update_xnat

HCP_matlab_setenv;

f=rdir('/disk/HCP/raw/MRI/*/*');
for i=1:length(f); 
    try;
        HCP_rename_CCF(f(i).name); 
    end
end;

HCP_progress_report;


tbl=readtable('/disk/HCP/raw/aligned-scans.txt');
for i=1:height(tbl)
    s=tbl.Scans{i};
    if(~isempty(s))
        lst=strfind(s,'_');
        s=s(1:lst(3)-1);
        MRIscan = fullfile('/disk/HCP/analyzed',['HCP' tbl.subjid{i}],'unprocessed','3T',s);
        if(~exist(fullfile(MRIscan,'LINKED_DATA','PHYSIOL')))
            mkdir(fullfile(MRIscan,'LINKED_DATA'));
            mkdir(fullfile(MRIscan,'LINKED_DATA','PHYSIOL'));
            s2=tbl.scandata{i};
            s2(strfind(s2,'_'))='.';
            f=fullfile('/disk/HCP/raw/PHYSIOL_MRI',s2,[tbl.name{i} '*']);
            system(['cp -v ' f ' ' fullfile(MRIscan,'LINKED_DATA','PHYSIOL/')]);
        end
    end
end

 
p='/disk/HCP/raw/EPRIME_fMRI';
f=dir(p);
cnt=1;
for i=1:length(f)
    f2=dir(fullfile(p,f(i).name,'*.edat2'));
    for j=1:length(f2)
        if(~isempty(strfind(f2(j).name,'MOTOR_run1')))
            str='BOLD_MOTOR1_AP';
        elseif(~isempty(strfind(f2(j).name,'MOTOR_run2')))
            str='BOLD_MOTOR2_PA';
        elseif(~isempty(strfind(f2(j).name,'WM_run1')))
            str='BOLD_WM1_AP';
        elseif(~isempty(strfind(f2(j).name,'WM_run2')))
            str='BOLD_WM2_PA';
        elseif(~isempty(strfind(f2(j).name,'LANGUAGE_run1')))
            str='BOLD_LANGUAGE1_AP';
        elseif(~isempty(strfind(f2(j).name,'LANGUAGE_run2')))
            str='BOLD_LANGUAGE2_PA';
        end
        s.subjid{cnt,1}=f(i).name;
        s.eprime{cnt,1}=fullfile(p,f(i).name,f2(j).name);
        s.type{cnt,1}=str;
        cnt=cnt+1;
    end
end
tbl=struct2table(s);
for i=1:height(tbl)
    p2=fullfile('/disk/HCP/analyzed',tbl.subjid{i},'unprocessed','3T',tbl.type{i},'LINKED_DATA','EPRIME');
    if(~exist(p2))
        mkdir(p2);
        system(['cp -v ' tbl.eprime{i} ' ' p2 filesep tbl.type{i} '.edat2']);
        [pp,e,~]=fileparts(tbl.eprime{i});
        system(['cp -v ' pp filesep e '.txt ' p2 filesep tbl.type{i} '.txt']);
    end
end

system('rm -rf /disk/HCP/analyzed/*test*');

cd /disk/HCP/pipeline/analysis/Xnat/

[~,jsess]=system('./CreateXnatJess.sh');
jsess=jsess(end-32:end);
jsess(double(jsess)==10)=[];


f=dir('/disk/HCP/raw/MEG/');
for i=1:length(f);
    tbl=Xnat_get_SubjectInfo(f(i).name,jsess);
    if(~ismember([f(i).name '_MEG'],unique(tbl.label)))
        try
            Xnat_addMEGSession(f(i).name,false,jsess);
            tbl=Xnat_addMEGSession(f(i).name);
            
            p=fullfile('/disk','HCP','analyzed');
            mkdir(fullfile(p,tbl.subjid{1},'unprocessed','MEG'))
            for j=1:height(tbl)
                p2=fullfile(p,tbl.subjid{j},'unprocessed','MEG',tbl.name{j});
                mkdir(p2);
                system(['cp -v ' tbl.file{j} ' ' fullfile(p2,[tbl.name{j} '.fif'])]);
                pp=fullfile('/disk','HCP','raw','EPRIME_MEG',tbl.subjid{1});
                if(~isempty(tbl.link{j}))
                    p2=fullfile(p,tbl.subjid{j},'unprocessed','MEG',tbl.name{j},'LINKED_DATA');
                    mkdir(p2);
                    p2=fullfile(p,tbl.subjid{j},'unprocessed','MEG',tbl.name{j},'LINKED_DATA','EPRIME');
                    mkdir(p2);
                    system(['cp -v ' pp filesep tbl.link{j} ' ' fullfile(p2,[tbl.name{j} '.edat2'])]);
                    l=tbl.link{j};
                    [~,l,ext]=fileparts(l);
                    system(['cp -v ' pp filesep l '.txt ' fullfile(p2,[tbl.name{j} '.txt'])]);
                end
                
            end
        end
    else
        disp(['skipping ' f(i).name]);
    end
    
end;

f=dir(fullfile('/disk/HCP/analyzed/HCP*'));
for i=1:length(f)
    Xnat_AddMRI_LINKED(f(i).name,jsess);
end
