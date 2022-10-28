function tbl = HCP_unpack_data(subjid,dicomfolder,outfolder)
% % Example:
% outfolder='/disk/NIRS/HCP/data';
% dicomfolder='/disk/NIRS/HCP/raw/mri/2014.12.15-11.48.36/14.12.15-11:48:34-STD-1.3.12.2.1107.5.2.32.35217/';
% subjid='Testing_1';
%  HCP_unpack_data(subjid,dicomfolder,outfolder)

if(HCP_blacklist(subjid))
    return
end


HCProot='/disk/HCP/';
if(nargin<3)
    outfolder=fullfile(HCProot,'analyzed');
end

HCP_matlab_setenv;  % Sets the FSL, Freesurfer, etc folders 


StudyNameMap = HCP_dicom_mapping(dicomfolder,subjid);

 
if(~exist(outfolder))
    mkdir(outfolder)
end
if(~exist(fullfile(outfolder,subjid)))
    mkdir(fullfile(outfolder,subjid));
end

for idx=1:size(StudyNameMap,1)
    
    if(~isempty(strfind(StudyNameMap{idx,1},'.nii.gz')) && exist(fullfile(outfolder,subjid,StudyNameMap{idx,1})))
        system(['cp -v ' outfolder filesep subjid filesep StudyNameMap{idx,1} ' ' outfolder filesep subjid filesep StudyNameMap{idx,2}]);
        if(~isempty(strfind(StudyNameMap{idx,2},'FieldMapMagnitude')))
            f=[outfolder filesep subjid filesep StudyNameMap{idx,2}];
            f2=[outfolder filesep subjid filesep  fileparts(StudyNameMap{idx,2}) filesep subjid '_3T_FieldMapPhase.nii.gz'];
            system(['flirt -in ' f ' -ref ' f2 ' -applyxfm -out ' f]);
        end
    else
        fol=dir(fullfile(dicomfolder,StudyNameMap{idx,1}));
        lst=[];
        for i=1:length(fol)
            if(~fol(i).isdir)
                lst=[lst i];
            end
            if(~isempty(strfind(fol(i).name,'SBRef')))
                lst=[lst i];
            end
              if(~isempty(strfind(fol(i).name,'PhysioLog')))
                lst=[lst i];
              end
              if(~isempty(strfind(fol(i).name,'_arb_m0')))
                lst=[lst i];
              end
              if(~isempty(strfind(fol(i).name,'S3_ND')))
                lst=[lst i];
            end
        end
        fol(lst)=[];
        if(~isempty(fol))
            if(~isempty(strfind(StudyNameMap{idx,1},'T1w_MPR*')) | ~isempty(strfind(outfolder,'/disk/HCP')) | ...
                    ~isempty(strfind(StudyNameMap{idx,1},'T2w_SPC*')))
                fol=fol(1);
            end
            for ii=1:length(fol)
                 if(length(fol)>1 & ii>1)
                     thisfold=[fileparts(StudyNameMap{idx,2}) '_' num2str(ii)];
                 else
                    thisfold=fileparts(StudyNameMap{idx,2});
                    
                 end
                
                 if(~isempty(strfind(thisfold,'PHYSIOLOG')))
                     continue;
                 end
                [~,ff,ee]=fileparts(StudyNameMap{idx,2});
                 
                [~, ff, ee2]=fileparts(ff);
                ee=[ee2 ee];
                
                if(length(fol)>1 & ii>1)
                    ff=[ff '_' num2str(ii)];
                end
                ff=[ff ee];
                 
                localfol=fullfile(outfolder,subjid);
                system(['mkdir -p ' fullfile(localfol,thisfold)]);
                
                
                
                f=dir(fullfile(dicomfolder,fol(ii).name,'MR*'));
                if(~isempty(f))
                    fol(ii).name(strfind(fol(ii).name,'>'))='*';
                    fol(ii).name(strfind(fol(ii).name,'<'))='*';
                    
                    if(isempty(strfind(StudyNameMap{idx,1},'DWI')) & isempty(strfind(StudyNameMap{idx,1},'dMRI')) &...
                            isempty(strfind(StudyNameMap{idx,1},'Perfusion_Weighted')) & ...
                            isempty(strfind(StudyNameMap{idx,1},'ASL')) & isempty(strfind(StudyNameMap{idx,1},'dti')) & ...
                            isempty(strfind(StudyNameMap{idx,1},'asl')))
                        if(exist(fullfile(outfolder,subjid,thisfold,ff))==0)
                            system(['mri_convert -it siemens_dicom ' dicomfolder filesep fol(ii).name filesep f(1).name ' ' outfolder filesep subjid filesep thisfold filesep ff]);
                            if(exist(fullfile(outfolder,subjid,thisfold,ff))==0)
                                warning(['conversion failed ' StudyNameMap{idx,2} ' : trying dcm2nii']);
                                outfolder2=fullfile(HCProot,'tmp');
                            system(['rm ' outfolder '/*.nii.gz']);
                            system(['rm ' outfolder '/*.json']);
                            system(['rm ' outfolder '/*.bval']);
                            system(['rm ' outfolder '/*.bvec']);
                            system(['rm ' outfolder '/*.nii']);
                            system(['dcm2niix -p N -g Y -o ' outfolder2 ' ' fullfile(dicomfolder,fol(ii).name,f(1).name)]);
                                % fi=strtok(StudyNameMap{idx,2},'.');
                                fi=ff(1:min(strfind(ff,'.'))-1);
                                system(['gzip ' outfolder '/*.nii']);
                                system(['mv ' outfolder2 '/*.nii.gz ' outfolder filesep subjid filesep thisfold filesep fi '.nii.gz']);
                                system(['mv ' outfolder2 '/*.json ' outfolder filesep subjid filesep thisfold filesep '.json']);
                            end
                        end
                    else
                        if(exist(fullfile(outfolder,subjid,thisfold,ff))==0)
                            system(['rm ' outfolder '/*.nii.gz']);
                            system(['rm ' outfolder '/*.json']);
                            system(['rm ' outfolder '/*.bval']);
                            system(['rm ' outfolder '/*.bvec']);
                            system(['rm ' outfolder '/*.nii']);
                            % Use dcm2nii to get the bvec and bval fields from the dicoms
                            %system(['dcm2niix -n Y -p N -d N -i N -g Y -o ' outfolder ' -4 Y ' fullfile(dicomfolder,fol(ii).name,f(1).name)]);
                            system(['dcm2niix -p N -g Y -o ' outfolder ' ' fullfile(dicomfolder,fol(ii).name,f(1).name)]);
                            
                            fi=ff(1:min(strfind(ff,'.'))-1);
                            system(['gzip ' outfolder '/*.nii']);  
                            system(['mv ' outfolder '/*.nii.gz ' outfolder filesep subjid filesep thisfold filesep fi '.nii.gz' ]);
                            system(['mv ' outfolder '/*.json ' outfolder filesep subjid filesep thisfold filesep '.json' ]);
                            if(~isempty(strfind(StudyNameMap{idx,1},'DWI')) | ~isempty(strfind(StudyNameMap{idx,1},'dMRI'))||...
                                    ~isempty(strfind(StudyNameMap{idx,1},'dti')))
                                system(['mv ' outfolder '/*.bval ' outfolder filesep subjid filesep thisfold filesep fi '.bval']);
                                system(['mv ' outfolder '/*.bvec ' outfolder filesep subjid filesep thisfold filesep fi '.bvec']);
                            end
                        else
                            disp([' exists: ' fullfile(outfolder,subjid,thisfold,ff) ]);
                        end
                        
                    end
                end
            end
        end
    end
end


%tbl = HCP_report_file_integrity(fullfile(outfolder,subjid),'import');
info={};
folder=dir(dicomfolder); cnt=1;
for i=1:length(folder)
    try
        if(folder(i).isdir)
            f=dir(fullfile(dicomfolder,folder(i).name,'MR*'));
            if(~isempty(f))
                f=fullfile(dicomfolder,folder(i).name,f(1).name);
                info{cnt}=dicominfo(f); cnt=cnt+1;
                fclose all;
            end
        end
    end
end
if(isempty(info))
    warning(['no DICOMS found: ' dicomfolder]);
    return
end
flds=fields(info{1});
for i=1:length(info)
    flds={flds{ismember(flds,fields(info{i}))}};
end
s=struct;
for j=1:length(flds)
    try
    if(isstr(info{1}.(flds{j})))
        ff=cellstr(info{1}.(flds{j}));
    elseif(length(info{1}.(flds{j}))>1)
        continue;
    else
        ff=info{1}.(flds{j});
    end
    for i=1:length(info)
        if(iscellstr(ff))
            ff(i,1)=cellstr(info{i}.(flds{j}));
        else
            ff(i,1)=info{i}.(flds{j});
        end
    end
    s=setfield(s,flds{j},ff);
    end
end
tbl=struct2table(s);
tbl=sortrows(tbl,'SeriesNumber');
try
    system(['mkdir -p ' fullfile(outfolder,subjid)]);
    writetable(tbl,fullfile(outfolder,subjid,['dicomconvert_' tbl.AcquisitionDate{1} '.log']),'FileType','text');
end

if(strcmp(info{1}.StationName,'MRC35216') | strcmp(info{1}.StationName,'MRC67078') | ~isempty(strfind(subjid,'HCP')))
    %prisma1
    system(['cp /disk/HCP/pipeline/coeff.Prisma1.grad ' fullfile(outfolder,subjid,'unprocessed','3Tprisma_coef.grad')]);
end
   


return
