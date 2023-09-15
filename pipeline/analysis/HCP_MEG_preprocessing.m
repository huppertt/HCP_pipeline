function HCP_MEG_preprocessing(subjid,outfolder,J,force)
% This function copys the MEG data from raw/subjid into the analyzed folder

HCProot='/disk/HCP/';
%Scriptfolder = '/disk/HCP/pipeline/analysis/';

if(nargin<2 || isempty(outfolder))
    outfolder=fullfile(HCProot,'analyzed');
end

if(nargin<3)
    J=5;
end

if(nargin<4)
    force=false;
end


HCP_matlab_setenv;
setenv('SUBJECTS_DIR',fullfile(outfolder,subjid,'T1w'))
setenv('SUBJECT',subjid);

% f=rdir(fullfile(outfolder,subjid,'MEG*','*.dtseries.nii'));
% if(~isempty(f) & ~force)
%     return
% end


HCP_makeMNIsourcespace(subjid,J,outfolder,force);
HCP_Label_1020(subjid,outfolder,force);

files=rdir(fullfile(outfolder,subjid,'MEG*/*-raw.fif'));

if(isempty(files))
    files=rdir(fullfile(outfolder,subjid,'MEG*/*-raw.fif'));
end

if(isempty(files))
    files=rdir(fullfile(outfolder,subjid,'unprocessed','MEG','*/*.fif'));
    efiles=rdir(fullfile(outfolder,subjid,'unprocessed','MEG','*/*empty*.fif'));
    for j=1:length(files)
        type = fileparts(files(j).name);
        type=type(max(strfind(type,filesep))+1:end);
        type=upper(type);
        if(~strcmp(type,'EMPTY'))
            system(['mkdir -p ' fullfile(outfolder,subjid,['MEG_' type])]);
            system(['rsync -vru --size-only ' files(j).name ' ' fullfile(outfolder,subjid,['MEG_' type],[type '-raw.fif'])]);
            if(~isempty(efiles))
                system(['rsync -vru --size-only ' efiles(1).name ' ' fullfile(outfolder,subjid,['MEG_' type],['empty.fif'])]);
            end
        end
    end
    files=rdir(fullfile(outfolder,subjid,'MEG*/*-raw.fif'));
end


for i=1:length(files)
    try
    fileIn=files(i).name;
    fileOut = [fileIn(1:strfind(fileIn,'.fif')-5) '-prep.fif'];
   
    if(exist(fileOut))
        disp([' skipping: ' fileOut]);
        continue;
    end
    
    try
        HCP_FIFF2HPI(subjid,outfolder,fileIn,force);

    end
    % max filter gets a bit messed up inside python
    % Hendrik: Only apply tsss will get better result
    if(~exist(fileOut,'file') || force)
        
        p=fileparts(fileIn);
        fO= [fileIn(1:strfind(fileIn,'.fif')-5) '-raw_sss.fif'];
        fOb= [fileIn(1:strfind(fileIn,'.fif')-5) '-raw_tsss.fif'];
        system(['/neuro/bin/util/maxfilter -f ' fileIn ' -o ' fO ' -force -v -trans default -hp ' p filesep 'meg_motion.txt -autobad on']);
        system(['/neuro/bin/util/maxfilter -f ' fO ' -o ' fOb ' -force -v -st']);
        
        %     fO= [fileIn(1:strfind(fileIn,'.fif')-5) '-raw_tsss.fif'];
        %     system(['/neuro/bin/util/maxfilter -f ' fileIn ' -o ' fO ' -force -v -st'])
        %    fileIn=fO;
        fileIn=fOb;
        
        system(['python3.5 ' fullfile(HCProot,'pipeline','analysis','HCP_megpipe.py')...
            ' prep ' fileIn ' ' fileOut]);
    end
    
    subj_dir=fullfile(outfolder,subjid,'T1w');
    subj=subjid;
    trans=[files(i).name(1:strfind(files(i).name,'.fif')-1) '-trans.fif'];
    
    if(exist(trans,'file'))
        fOut=fileOut(1:strfind(fileOut,'.fif')-1);
         fileo=[fOut '.dtseries.nii'];
         
         if(exist(fileo,'file') & ~force)
             continue;
         end
        
        src=fullfile(outfolder,subjid,'MNINonLinear',...
            ['waveletJ' num2str(J)],[subjid '-ico' num2str(J) '-src.fif']);
        fwd='''None''';
        inv='''None''';
        pp=fileparts(fileIn);
        empty=dir(fullfile(pp,'*empty*.fif'));
        if(isempty(empty))
            empty='''None''';
        else
            empty=fullfile(pp,empty(1).name);
        end
        system(['python3.5 ' fullfile(HCProot,'pipeline','analysis','HCP_megpipe.py')...
            ' source ' fileOut ' ' subj_dir ' ' trans ' ' subj ' ' ...
            src ' ' fwd ' ' inv ' ' empty]);
        %      system(['python3.5 ' fullfile(Scriptfolder,'MEG_Proc.py')...
        %          ' source ' fileOut ' ' subj_dir ' ' trans ' ' subj ' ' ...
        %          src ' ' fwd ' ' inv ' ' empty]);
        
        
        
        template = fullfile(outfolder,subjid,'MNINonLinear',['waveletJ' num2str(J)],[subjid '.LR.pial.dscalar.nii']);
        c=ft_read_cifti(template);
        c.dimord='pos_time';
        
        c=rmfield(c,'x_coordinate');
        c=rmfield(c,'y_coordinate');
        c=rmfield(c,'z_coordinate');
        
        l=mne_read_stc_file(fullfile([fOut '-native-lh.stc']));
        r=mne_read_stc_file(fullfile([fOut '-native-rh.stc']));
        c.time = l.tmin+[0:size(l.data,2)-1]*l.tstep;
        c.dtseries=[l.data; r.data];
        c.dtseries=c.dtseries*10^14;
       
        ft_write_cifti(fOut,c,'parameter','dtseries','writesurface',true);
        disp(['Write MEG data to : ' fileo]);
    
    
    else
        disp('skipping regisitration and source localization');
    end
    end
end





