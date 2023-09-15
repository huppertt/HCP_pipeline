function dicomtbl = SummarizeDICOMS(folder)

tbl=HCP_check_analysis([],folder);

if(~isempty(strfind(folder,'ROS-MOVE')))
    dicomfolder='ROS-MOVE';
end

f=[rdir(['/disk/scan_data_archive/*/' dicomfolder '/']); ...
    rdir(['/mace2/scan_data/' dicomfolder '/'])];

dicomtbl=struct;
uniquescans={};
for i=1:length(f)
    [dicomtbl.folder{i,1}, dicomtbl.scan_date{i,1}]=fileparts(f(i).name);
    sub=dir(f(i).name);
    dicomtbl.subjID{i,1}=sub(end).name;
    files=struct;
    scans=dir(fullfile(f(i).name,dicomtbl.subjID{i}));
    lst=[];
    for j=1:length(scans)
        if(strcmp(scans(j).name(1),'.'));
            lst=[lst j];
        end
    end
    scans(lst)=[];
    for j=1:length(scans)
        files.type{j,1}=scans(j).name(1:strfind(scans(j).name,'.')-1);
        files.name{j,1}=scans(j).name;
        dcms=dir(fullfile(f(i).name,dicomtbl.subjID{i},scans(j).name,'*'));
        lst=[];
        for k=1:length(dcms)
            if(dcms(k).isdir)
                lst=[lst k];
            elseif(contains(dcms(k).name,'.nii') | contains(dcms(k).name,'.b') | contains(dcms(k).name,'.json'))
                lst=[lst k];
            end
        end
        dcms(lst)=[];
        files.count{j,1}=length(dcms);
        info=dicominfo(fullfile(f(i).name,dicomtbl.subjID{i},scans(j).name,dcms(1).name));
        try
            files.sequence{j,1}=info.SequenceName;
        end
        try
            files.software{j,1}=info.SoftwareVersion;
        end
        files.dicom_info{j,1}=info;
        uniquescans{end+1,1}=files.type{j,1};
        uniquescans{end,2}=info;
        uniquescans{end,3}=dicomtbl.subjID{i,1};
        uniquescans{end,4}=dicomtbl.folder{i,1};
        uniquescans{end,5}=length(dcms);
    end
    dicomtbl.scans{i,1}=files;
end


   flds={'ImplementationVersionName'
       'SeriesDescription'
    'ScanningSequence'
    'SequenceVariant'
    'ScanOptions'
    'MRAcquisitionType'
    'SequenceName'
    'AngioFlag'
    'SliceThickness'
    'RepetitionTime'
    'EchoTime'
    'NumberOfPhaseEncodingSteps'
    'EchoTrainLength'
    'PercentSampling'
    'PercentPhaseFieldOfView'
    'PixelBandwidth'
    'TransmitCoilName'
    'InPlanePhaseEncodingDirection'
    'FlipAngle'
    'VariableFlipAngleFlag'
    'Rows'
    'Columns'};
Numerics={'SliceThickness'
    'RepetitionTime'
    'EchoTime'
    'NumberOfPhaseEncodingSteps'
    'EchoTrainLength'
    'PercentSampling'
    'PercentPhaseFieldOfView'
    'PixelBandwidth'
    'FlipAngle'
    'Rows'
    'Columns'};

scans=struct;
scans.scanName={};
for j=1:length(flds)
   if(ismember(flds{j},Numerics))
       scans=setfield(scans,flds{j},[]);
   else
    scans=setfield(scans,flds{j},{});
   end
end
for i=1:size(uniquescans,1)
    scans.scanName{i,1}=uniquescans{i,1};
    for j=1:length(flds)
        
        if(ismember(flds{j},Numerics))
            try
                scans.(flds{j})(i,1)=uniquescans{i,2}.(flds{j});
            catch
                scans.(flds{j})(i,1)=-1;
            end
            uniquescans{i,5+j}=scans.(flds{j})(i,1);
        else
            try
                scans.(flds{j}){i,1}=uniquescans{i,2}.(flds{j});
            catch
                scans.(flds{j}){i,1}='none';
            end
            uniquescans{i,5+j}=scans.(flds{j}){i,1};
        end
        
    end
end

types={'Backprojection','REST_PA','REST_AP','relCBF','TRUST','flow_pc3d_sag',...
    'dMRI_DSI64','TSE_FLAIR','T2w_SPC1','T1w_MPR1','PASL','SWI','FieldMap','MRAC',...
    'Perfusion_Weighted','localizer','AAHScout'};

scantypes={};
for i=1:length(types)
    lst=find(contains({uniquescans{:,7}}',types{i}));
    [a,~,b]=unique(cell2table(uniquescans(lst,8:27)));
    
        for k=1:length(lst)
            uniquescans{lst(k),28}=[types{i} '_' num2str(b(k))];
        end
        for j=1:height(a)
            scantypes{end+1,1}=types{i};
            scantypes{end,2}=[types{i} '_' num2str(j)];
            ii=min(find(b==j));
            scantypes{end,3}=uniquescans{lst(ii),1};
            scantypes{end,4}=uniquescans{lst(ii),2};
            for k=8:27
                scantypes{end,4+k-6}=uniquescans{lst(ii),k};
            end
        end
        
end
       

Data={};
Data(:,1)=usubj;
for i=1:length(usubj)
    for j=1:length(uscans)
        lst=find(ismember(uniquescans(:,3),usubj{i}) & ismember(uniquescans(:,end),uscans{j}));
        cnt=0;
        for k=1:length(lst)
            cnt=cnt+uniquescans{lst(k),5};
        end
        Data{i,1+j}=cnt;
       
    end
    lst=find(ismember(uniquescans(:,3),usubj{i}));
     Data{i,79}=uniquescans{lst(1),2}.StudyDate;
end

datatble=cell2table(Data,'VariableNames',{'Subjid' uscans{:} 'date'});
datatblekey=cell2table(scantypes,'VariableNames',{'ScanType','ScanSubType','dicominfo',flds{3:end}});
    
