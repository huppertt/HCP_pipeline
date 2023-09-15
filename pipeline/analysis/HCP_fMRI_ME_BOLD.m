function HCP_fMRI_ME_BOLD(subjid,outfolder,str)

HCProot='/disk/HCP';
if(nargin<2 || isempty(outfolder))
    outfolder=fullfile(HCProot,'analyzed');
end

if(~isstruct(subjid))
    subjid.name=subjid;
end

HCP_matlab_setenv;  % Sets the FSL, Freesurfer, etc folders 

e={}; cnt=1;
for i=1:length(subjid)
    for idx=1:length(str)
        echos = dir(fullfile(outfolder,subjid(i).name,'unprocessed','3T',str{idx},[subjid(i).name '_3T_' str{idx} '_TE*.nii.gz']));
        for j=1:length(echos)
            e{cnt}=strtok(echos(j).name(strfind(echos(j).name,[str{idx} '_TE'])+length([str{idx} '_TE']):end),'.');
            cnt=cnt+1;
        end
    
    end
end
e=unique(e);


for j=1:length(e)
    
    %This does the fMRI pre-processing
    TaskList='"';
    PhaseEncodinglist='"';
    jobs={};
    
    for i=1:length(subjid)
        for idx=1:length(str)
            system(['rm ' fullfile(outfolder,subjid(i).name,'unprocessed','3T',str{idx},[subjid(i).name '_3T_' str{idx} '.nii.gz'])]);
            system(['ln -sv ' fullfile(outfolder,subjid(i).name,'unprocessed','3T',str{idx},[subjid(i).name '_3T_' str{idx} '_TE' e{j} '.nii.gz']) ' ' ...
                fullfile(outfolder,subjid(i).name,'unprocessed','3T',str{idx},[subjid(i).name '_3T_' str{idx} '.nii.gz'])]);
            
            TaskList=[TaskList str{idx} ' '];
            if(~isempty(strfind(str{idx},'RL')));
                direction='x';
            elseif(~isempty(strfind(str{idx},'LR')));
                direction='x-';
            elseif(~isempty(strfind(str{idx},'PA')));
                direction='y';
            else
                direction='y-';
            end;
            PhaseEncodinglist=[PhaseEncodinglist direction ' '];
            jobs{end+1}=['source ' HCProot '/pipeline/projects/Pipelines/Examples/Scripts/GenericfMRIVolumeProcessingPipelineBatch.sh --runlocal --StudyFolder=' ...
                outfolder ' --Subjlist="' subjid(i).name '" --Tasklist=' str{idx} ' --Phaselist=' direction];
            
        end
    end
    
    PhaseEncodinglist=[PhaseEncodinglist(1:end-1) '"'];
    TaskList=[TaskList(1:end-1) '"'];
    
    for i=1:length(jobs)
        system(jobs{i});
    end
    
    %once it is run let's move and rename the data
    for i=1:length(subjid)
        for idx=1:length(str)
            system(['mkdir -p ' subjid(i).name filesep str{idx} filesep e{j} filesep]);
            system(['mv -v ' subjid(i).name filesep str{idx} filesep '* ' subjid(i).name filesep str{idx} filesep e{j} filesep])
            
            for j2=1:j-1
                system(['mv ' subjid(i).name filesep str{idx} filesep e{j} filesep e{j2} ' ' ...
                    subjid(i).name filesep str{idx} filesep ]);
            
            end
        end
    end
    
end

%now apply the same to the other echo data

%TODO

for i=1:length(subjid)
    for idx=1:length(str)
        % make a combined mask
        
        st=['${FSLDIR}/bin/fslmaths ' fullfile(outfolder,subjid(i).name,str{idx},e{1},[str{idx} '_nonlin_mask.nii.gz'])];
        for j=2:length(e)
            st=[st ' -mul ' fullfile(outfolder,subjid(i).name,str{idx},e{j},[str{idx} '_nonlin_mask.nii.gz'])];
        end
        st = [st ' -bin ' fullfile(outfolder,subjid(i).name,str{idx},[str{idx} '_nonlin_mask.nii.gz'])];
        system(st);
        
        st=['${FSLDIR}/bin/fslmaths ' fullfile(outfolder,subjid(i).name,str{idx},e{1},'brainmask_fs.2.0.nii.gz') ];
        for j=2:length(e)
            st=[st ' -mul ' fullfile(outfolder,subjid(i).name,str{idx},e{j},'brainmask_fs.2.0.nii.gz')];
        end
        st = [st ' -bin ' fullfile(outfolder,subjid(i).name,str{idx},'brainmask_fs.2.0.nii.gz')];
        system(st);
        
        system(['cp -v ' fullfile(outfolder,subjid(i).name,str{idx},e{1},'BiasField.2.0.nii.gz') ' ' fullfile(outfolder,subjid(i).name,str{idx},'BiasField.2.0.nii.gz')]);
        system(['cp -v ' fullfile(outfolder,subjid(i).name,str{idx},e{1},'T1w_restore.2.0.nii.gz') ' ' fullfile(outfolder,subjid(i).name,str{idx},'T1w_restore.2.0.nii.gz')]);

        
         for j=1:length(e)
            f{1}{j}= fullfile(outfolder,subjid(i).name,str{idx},e{j},[str{idx} '_nonlin.nii.gz']);
            f{2}{j}= fullfile(outfolder,subjid(i).name,str{idx},e{j},[str{idx} '_nonlin_norm.nii.gz']);
            f{3}{j}= fullfile(outfolder,subjid(i).name,str{idx},e{j},[str{idx} '_SBRef_nonlin.nii.gz']);
            f{4}{j}= fullfile(outfolder,subjid(i).name,str{idx},e{j},[str{idx} '_SBRef_nonlin_norm.nii.gz']);
            ee=e{j}; ee(strfind(ee,'p'))='.';
            TE(j)=str2num(ee);
         end
         mask=fullfile(outfolder,subjid(i).name,str{idx},'brainmask_fs.2.0.nii.gz');
         
         
        [R2, Io]=HCP_ME_combine(f{1},TE,mask,fullfile(outfolder,subjid(i).name,str{idx},[str{idx} '_nonlin.nii.gz']));
        HCP_ME_combine(f{2},TE,mask,fullfile(outfolder,subjid(i).name,str{idx},[str{idx} '_nonlin_norm.nii.gz']),R2,Io);
        HCP_ME_combine(f{4},TE,mask,fullfile(outfolder,subjid(i).name,str{idx},[str{idx} '_SBRef_nonlin_norm.nii.gz']),R2,Io);
        HCP_ME_combine(f{4},TE,mask,fullfile(outfolder,subjid(i).name,str{idx},[str{idx} '_SBRef_nonlin.nii.gz']),R2,Io);
        
    
    end
end


