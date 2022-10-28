function HCP_unpack_MEG(subjid,outfolder)
% Thisv function copys the MEG data from raw/subjid into the analyzed folder

if(nargin==0)
    f=dir(fullfile('/disk','HCP','raw','MEG','HCP*'));
    for i=1:length(f);
        HCP_unpack_MEG(f(i).name);
        HCP_LINK_MEG(f(i).name);
    end;
    return
end


if(HCP_blacklist(subjid))
    return
end

HCProot='/disk/HCP/';
if(nargin<2)
    outfolder=fullfile(HCProot,'analyzed');
end

rawfolder=fullfile(outfolder,'..','raw','MEG',subjid);
if(~exist(rawfolder))
    error(['raw data does not exist:' rawfolder]);
end

files=dir(fullfile(rawfolder,'*.fif'));
if(isempty(files))
    warning(['raw data does not exist:' rawfolder]);
    return
end

fnames=strvcat(files.name);
for i=1:length(files)
    disp(files(i).name)
    if(~isempty(strfind(lower(files(i).name),'lang')))
        type='MEG_LANGUAGE';
    elseif(~isempty(strfind(lower(files(i).name),'motor')))
        type='MEG_MOTOR';
    elseif(~isempty(strfind(lower(files(i).name),'wm')))
        type='MEG_WM';
    elseif(~isempty(strfind(lower(files(i).name),'rest')))
        type='MEG_REST';
    elseif(~isempty(strfind(lower(files(i).name),'empty')))
        continue
    elseif(~isempty(strfind(lower(files(i).name),'trans')))
        continue
    else
        warning(['file type not recognized: ' files(i).name])
        continue;
    end
    
    if(strfind(lower(files(i).name),'open'))
        type=[type '_OPEN'];
    elseif(strfind(lower(files(i).name),'close'))
        type=[type '_CLOSE'];
    end
    
    
    if(strfind(lower(files(i).name),'2.fif') | strfind(lower(files(i).name),'ing2'))
        type=[type '2'];
    elseif(strfind(lower(files(i).name),'3.fif'))
        type=[type '3'];
    elseif(strfind(lower(files(i).name),'4.fif'))
        type=[type '4'];
    else
        type=[type '1'];
    end
    
    
    
    if(~exist(fullfile(outfolder,subjid,type)))
        mkdir(fullfile(outfolder,subjid,type))
    end
    
    system(['mkdir -p ' fullfile(outfolder,subjid,'unprocessed','MEG',type)]);
    system(['mkdir -p ' fullfile(outfolder,subjid,'unprocessed','MEG','EMPTY')])
    
    system(['rsync -vru --size-only ' fullfile(rawfolder,files(i).name) ' ' fullfile(outfolder,subjid,type,[subjid '-' type '-raw.fif'])]);
    %  system(['cp -v ' fullfile(rawfolder,[lower(subjid) '-trans.fif']) ' ' fullfile(outfolder,subjid,type,[subjid '-' type '-trans.fif'])]);
    
    system(['rsync -vru --size-only ' fullfile(rawfolder,files(i).name) ' ' fullfile(outfolder,subjid,'unprocessed','MEG',type,[subjid '-' type '-raw.fif'])]);
    %  system(['cp -v ' fullfile(rawfolder,[lower(subjid) '-trans.fif']) ' ' fullfile(outfolder,subjid,type,[subjid '-' type '-trans.fif'])]);
    
    EMPTY=dir(fullfile(rawfolder,['*empty*.fif']));
    if(~isempty(EMPTY))
        EMPTY=fullfile(rawfolder,EMPTY(1).name);
        system(['rsync -vru --size-only ' EMPTY ' ' fullfile(outfolder,subjid,type,[subjid '-empty.fif'])]);
        system(['rsync -vru --size-only ' EMPTY ' ' fullfile(outfolder,subjid,'unprocessed','MEG','EMPTY',[subjid '-empty.fif'])]);
        
    end
    
    
end
