function HCP_AddAll_Xnat(outfolder,jsess)


HCProot='/disk/HCP/';
if(nargin<2 || isempty(outfolder))
    outfolder=fullfile(HCProot,'analyzed');
end

HCP_matlab_setenv;

try
system('rsync -vru --size-only /disk/mace2/scan_data/WPC-7030/2020* /disk/HCP/raw/MRI/');
end
try
system('rsync -vru --size-only /disk/mace3/scan_data/WPC-7030/2020* /disk/HCP/raw/MRI/');
end

%Find any new subjects and unpack the data
f=dir(fullfile('/disk','HCP','raw','MRI','*'));
for i=1:length(f)
    if(f(i).isdir & ~strcmp(f(i).name(1),'.'))
        a=rdir(fullfile('/disk','HCP','raw','MRI',f(i).name,'*','B*'));
        if(~isempty(a))
            a=fileparts(a(1).name);
            a=a(max(strfind(a,filesep))+1:end);
          
            if(isempty(strfind(a,'test')))
                disp(f(i).name)
                disp(a)
                a2=a;
                if(strcmp(a(1:3),'HCP'))
                    a2(1:3)=[];
                end
                HCP_unpack_data(['HCP' a2],fullfile('/disk','HCP','raw','MRI',f(i).name,a));
                HCP_LINK_MRI(['HCP' a2]);
            end
        end
    end
end




%Find any new MEG data and uppack
f=dir(fullfile('/disk','HCP','raw','MEG','HCP*'));
for i=1:length(f); 
    HCP_unpack_MEG(f(i).name); 
    HCP_LINK_MEG(f(i).name);
end;

% Unpack any PET data
HCP_unpack_PET;

curdir=pwd;
cd('/disk/HCP/raw/MRI')
f=rdir('*/*/*/*.log');
for i=1:length(f); 
    p=f(i).name(1:min(strfind(f(i).name,'/'))-1); 
    p(strfind(p,'.'))=[];
    p(strfind(p,'-'))='.';
    disp(p); 
    system(['mkdir -p ../PHYSIOL_MRI/' p]); 
    system(['rsync -vru ' f(i).name ' ../PHYSIOL_MRI/' p]); 
end;

for i=1:length(f);
    if(isempty(strfind(f(i).name,'error')));
        p=fileparts(f(i).name);
        subjid=['HCP' p(min(strfind(p,'/'))+1:max(strfind(p,'/'))-1)];
        
        if(HCP_blacklist(subjid))
            continue;
        end
        
        task=p(max(strfind(p,'/'))+1:strfind(p,'x')-1);
        task=task(1:max(strfind(task,'_'))-1);
        
        system(['mkdir -p ' fullfile(outfolder,subjid,'unprocessed','3T',task,'LINKED_DATA','PHYSIOL')]);
        system(['rsync -vru ' f(i).name ' ' fullfile(outfolder,subjid,'unprocessed','3T',task,'LINKED_DATA','PHYSIOL')]);
        
        if(~isempty(strfind(task,'PhysioLog')))
            task=task(1:max(strfind(task,'_'))-1);
            
            system(['mkdir -p ' fullfile(outfolder,subjid,'unprocessed','3T',task,'LINKED_DATA','PHYSIOL')]);
            system(['rsync -vru ' f(i).name ' ' fullfile(outfolder,subjid,'unprocessed','3T',task,'LINKED_DATA','PHYSIOL')]);
        end
    end
    
end


cd(curdir);

%HCP_progress_report;


%HCP_Update_MRI_DICOMS;

tbl=HCP_check_analysis([],outfolder);



f=rdir(fullfile(outfolder,'HCP*/unprocessed/3T/*/LINKED_DATA/EPRIME/*.txt'));
f2=rdir(fullfile(outfolder,'HCP*/unprocessed/MEG/*/LINKED_DATA/EPRIME/*.txt'));
fa=rdir(fullfile(outfolder,'../raw/EPRIME_fMRI/HCP*/*.txt'));
f2a=rdir(fullfile(outfolder,'../raw/EPRIME_MEG/HCP*/*.txt'));

f=[f; f2; fa; f2a];
for i=1:length(f)
    if(isempty(strfind(f(i).name,'TAB')))
        [p,ff,e]=fileparts(f(i).name);
        fO =fullfile(p,[ff '_TAB' e]);
        if(~exist(fO))
            disp(f(i).name);
            system(['/usr/lib/ruby/gems/1.8/gems/optimus-ep-0.10.4/bin/eprime2tabfile ' f(i).name ' --outfile=' fO ' --force']);
        end
    end
end


cd('/disk/HCP/pipeline/analysis/Xnat');

 [~,jsess]=system('./CreateXnatJess.sh');
    jsess=jsess(end-32:end);
     jsess(double(jsess)==10)=[];

tstart=now;
for i=1:height(tbl)
    Xnat_AddMRI_LINKED(tbl.Subjid{i},jsess);
    Xnat_addMEGSession(tbl.Subjid{i},0,jsess,false);
   % Xnat_addPETSession(tbl.Subjid{i},jsess);
   
   if((now-tstart)*60*24>30)
       [~,jsess]=system('./CreateXnatJess.sh');
       jsess=jsess(end-32:end);
       jsess(double(jsess)==10)=[];
       tstart=tic;
   end
   
end


HCP_Add_MRIQC_XNAT(jsess);
