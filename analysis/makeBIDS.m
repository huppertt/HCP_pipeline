function makeBIDS(BIDSfolder,datafolder,subject)

if(nargin<1)
    BIDSfolder='/disk/sulcus1/COBRA_BIDS';
end
if(nargin<2)
    datafolder='/disk/sulcus1/COBRA';
end

if(nargin<3)
    s=rdir(fullfile(datafolder,'*','unprocessed','3T'));
    
    for i=1:length(s)
        subj{i}=s(i).name(length(datafolder)+2:end);
        subj{i}=subj{i}(1:min(strfind(subj{i},filesep))-1);
    end    
    subj=unique(subj);
    for i=1:length(subj)
        makeBIDS(BIDSfolder,datafolder,subj{i});
    end
    return
end


system(['mkdir -p ' BIDSfolder filesep 'sub-' subject filesep 'anat']);

f{1}=fullfile(datafolder,subject,'unprocessed','3T','T1w_MPR1',[subject '_3T_T1w_MPR1.nii.gz']);
f2{1}=fullfile( BIDSfolder,['sub-' subject],'anat',['sub-' subject '_T1w.nii.gz']); 

f{2}=fullfile(datafolder,subject,'unprocessed','3T','T2w_SPC1',[subject '_3T_T2w_SPC1.nii.gz']);
f2{2}=fullfile( BIDSfolder,['sub-' subject],'anat',['sub-' subject '_T2w.nii.gz']);

ff=rdir(fullfile(datafolder,subject,'unprocessed','3T','*BOLD*','*BOLD*.nii.gz'));
for i=1:length(ff)
    if( ff(i).bytes>0)
    if(isempty(strfind(ff(i).name,'SBRef')))
        [~,e]=fileparts(ff(i).name);
        e=e(strfind(e,'BOLD')+5:end);
        e=e(1:strfind(e,'.')-1);
        e(strfind(e,'-'))=[];
        e(strfind(e,'_'))=[];
        f{end+1}=ff(i).name;
        f2{end+1}=fullfile( BIDSfolder,['sub-' subject],'func',['sub-' subject '_task-' e '_run-01_bold.nii.gz']);
    end
    else
        disp(['zero byte: ' ff(i).name]);
    end
end

for i=1:length(f)
    if(exist(f{i}))
        system(['mkdir -p ' fileparts(f2{i})]);
        system(['ln -T ' f{i} ' ' f2{i}]);
        
        if(isempty(strfind(f2{i},'bold')))
        % make JSON file
        json=[f2{i}(1:strfind(f2{i},'.')) 'json'];
        
        fid=fopen(json,'w');
        fprintf(fid,'{\n');
        fprintf(fid,['   "Name":"' f{i} '"\n']);
        fprintf(fid,'}');
        fclose(fid);
        else
            
        % make JSON file
        json=[f2{i}(1:strfind(f2{i},'.')) 'json'];
        e=f2{i}(strfind(f2{i},'task-')+5:strfind(f2{i},'run')-2);
        fid=fopen(json,'w');
        fprintf(fid,'{\n');
        fprintf(fid,['   "Name":"' f{i} '",\n']);
        fprintf(fid,['   "RepetitionTime":0.8,\n']);       
        fprintf(fid,['   "TaskName":"' e '"\n']);
        fprintf(fid,'}');
        fclose(fid);
        end
    end
end

% TODO fmap images

fid=fopen(fullfile( BIDSfolder,'dataset_description.json'),'w');
fprintf(fid,'{\n');
fprintf(fid,'   "Name":"Human Connectome Project",\n');
fprintf(fid,'   "BIDSVersion":"1.0.2"\n');
fprintf(fid,'}');
fclose(fid);

