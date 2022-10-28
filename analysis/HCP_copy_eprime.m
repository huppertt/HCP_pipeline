function HCP_copy_eprime(subjid,outfolder)

HCProot='/disk/HCP';
if(nargin<2)
    outfolder=fullfile(HCProot,'analyzed');
end

HCP_matlab_setenv;  % Sets the FSL, Freesurfer, etc folders 

folder = fullfile('/disk/HCP/raw/','EPRIME_fMRI',subjid);

if(~exist(folder)==7)
    warning('No eprime files found')
    return
end

str={'MOTOR_run1','BOLD_MOTOR1_AP','Motor', 'BOLD_MOTOR';...
     'MOTOR_run2','BOLD_MOTOR2_PA','Motor', 'BOLD_MOTOR' ;...
     'WM_run1','BOLD_WM1_AP','WM', 'BOLD_WM';...
     'WM_run2','BOLD_WM2_PA','WM', 'BOLD_WM';...
     'LANGUAGE_run1','BOLD_LANGUAGE1_AP','Language', 'BOLD_LANGUAGE';...
     'LANGUAGE_run2','BOLD_LANGUAGE2_PA','Language', 'BOLD_LANGUAGE'};

 for i=1:size(str,1)
     f=dir(fullfile(folder,['*' str{i,1} '*']));
     if(~isempty(f))
         if(exist((fullfile(outfolder,subjid,'unprocessed','3T',str{i,2},'LINKED_DATA')))~=7)
             mkdir(fullfile(outfolder,subjid,'unprocessed','3T',str{i,2},'LINKED_DATA'))
             mkdir(fullfile(outfolder,subjid,'unprocessed','3T',str{i,2},'LINKED_DATA','EPRIME'))
             mkdir(fullfile(outfolder,subjid,'unprocessed','3T',str{i,2},'LINKED_DATA','EPRIME','EVs'))
         end
         for j=1:length(f)
             [~,~,ext]=fileparts(f(j).name);
             if(exist(fullfile(folder,f(j).name),'file'))
                 system(['mkdir -p ' fullfile(outfolder,subjid,'unprocessed','3T',str{i,2},'LINKED_DATA','EPRIME','EVs')]);
                 copyfile(fullfile(folder,f(j).name),fullfile(outfolder,subjid,'unprocessed','3T',str{i,2},'LINKED_DATA','EPRIME','EVs',...
                     [subjid '_' str{i,2} ext]));
             end
         end
         fileIn=fullfile(outfolder,subjid,'unprocessed','3T',str{i,2},'LINKED_DATA','EPRIME',...
             [str{i,2} '.txt']);
         if(exist(fileIn,'file'))
             
             fileOut=fullfile(outfolder,subjid,'unprocessed','3T',str{i,2},'LINKED_DATA','EPRIME','EVs',...
                 [subjid '_' str{i,2} '_TAB.txt']);
             system(['/usr/lib/ruby/gems/1.8/gems/optimus-ep-0.10.4/bin/eprime2tabfile --force ' fileIn ' --outfile=' fileOut]);
             
             if(~exist(fileOut))
                 warning(['failed to create ' fileOut]);
             end
             
             try
                 task=str{i,3};
                 system(['python ' HCProot '/pipeline/projects/Pipelines/tfMRI/scripts/' task '.py ' fileOut ' ' ...
                     fullfile(outfolder,subjid,'unprocessed','3T',str{i,2},'LINKED_DATA','EPRIME','EVs')]);
                 
             end
             
             ff=rdir( fullfile(outfolder,subjid,'unprocessed','3T',str{i,2},'LINKED_DATA','EPRIME','EVs','*.txt'));
             mri=rdir( fullfile(outfolder,subjid,'unprocessed','3T',str{i,2},[subjid '_3T_' str{i,2} '.nii.gz']));
             b=load_untouch_nii(mri(1).name);
             maxlength=b.hdr.dime.pixdim(5)*b.hdr.dime.dim(5);
             for idx=1:length(ff)
                 if(isempty(strfind(ff(idx).name,'TAB')))
                     try
                         d=dlmread(ff(idx).name);
                         lst=find(d(:,1)>maxlength);
                         d(lst,:)=0;
                         if(length(lst)>1)
                             warning(['Short file: ' mri(1).name]);
                             dlmwrite(ff(idx).name,d,'delimiter','\t');
                         end
                     catch
                         dlmwrite(ff(idx).name,zeros(1,3),'delimiter','\t');
                     end
                 end
             end
             
             system(['source ' HCProot '/pipeline/projects/Pipelines/Examples/Scripts/generate_level1_fsf.sh '...
                 ' --studyfolder=' outfolder ' --subject=' subjid ' --taskname=' str{i,2} ' --templatedir=' ...
                 HCProot '/pipeline/projects/Pipelines/Examples/fsf_templates --outdir=' fullfile(outfolder,subjid,'unprocessed','3T',str{i,2},'LINKED_DATA','EPRIME','EVs')]);
             
             system(['source ' HCProot '/pipeline/projects/Pipelines/Examples/Scripts/copy_evs_into_results.sh '...
                 '--studyfolder=' outfolder ' --subject=' subjid ' --taskname=' str{i,2}]);
             system(['cp ' fullfile(outfolder,subjid,'MNINonLinear','Results',str{i,2},'EVs',[str{i,2} '_hp200_s4_level1.fsf']) ' ' ...
                 fullfile(outfolder,subjid,'MNINonLinear','Results',str{i,2},[str{i,2} '_hp200_s4_level1.fsf'])]);
             
             if(exist(fullfile(outfolder,subjid,'MNINonLinear','Results',str{i,4}))~=7)
                 mkdir(fullfile(outfolder,subjid,'MNINonLinear','Results',str{i,4}));
             end
             
             system(['cp ' HCProot '/pipeline/projects/Pipelines/Examples/fsf_templates/' str{i,4} '_hp200_s4_level2.fsf '...
                 fullfile(outfolder,subjid,'MNINonLinear','Results',str{i,4},[str{i,4} '_hp200_s4_level2.fsf'])]);
         end
         
         
     end
 end