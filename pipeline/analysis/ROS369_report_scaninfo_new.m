function ROS369_report_scaninfo(folder)

clear Tbls
s=dir(fullfile(folder,'*'));
lst=[];
for i=1:length(s)
    if(s(i).isdir)
        lst=[lst i];
    end
end
s=s(lst);
lst2=[];
for i=1:length(s)
    scandates{i}=ROS369_getScanDates(s(i).name);
    if(isempty(scandates{i}));
        lst2=[lst2 i];
    end
end

Tbls{1}=struct;
for i=1:length(s)
    dates={};
    for j=1:length(scandates{i})
        if(strcmp(scandates{i}{j}(end),'/'))
            scandates{i}{j}(end)=[];
        end
        lst=strfind(scandates{i}{j},'/');
        dates{j}=scandates{i}{j}(lst(end-1)+1:lst(end)-1);
        dates{j}=datestr(datenum(dates{j},'YYYY.mm.dd-HH.MM.SS'));
    end
    [~,ii]=sort(datenum(dates),'ascend');
    
    Tbls{1}.ID{i,1}=s(i).name;
    if(length(dates)>0)
        Tbls{1}.MR1date{i,1}=dates{ii(1)};
        Tbls{1}.MR1dcmfolder{i,1}=scandates{i}{ii(1)};
    else
        Tbls{1}.MR1date{i,1}=[];
        Tbls{1}.MR1dcmfolder{i,1}=[];
    end
    
    
    
%     if(length(dates)>1)
%         Tbls{1}.MR2date{i,1}=dates{ii(2)};
%         Tbls{1}.MR2dcmfolder{i,1}=scandates{i}{ii(2)};
%     else
%         Tbls{1}.MR2date{i,1}=[];
%         Tbls{1}.MR2dcmfolder{i,1}=[];
%     end
    
    scandates{i}={scandates{i}{ii(:)}};
    
%     MEGfiles = rdir(fullfile('/disk','HCP','raw','MEG',s(i).name,'*.fif'));
%     
%     if(~isempty(MEGfiles))
%         %date=datestr(MEGfiles(1).datenum,'YYYY-mm-dd');
%         info=fiff_read_meas_info(MEGfiles(1).name);
%         date=datestr(double(info.meas_id.secs)/24/3600+datenum(1970,1,1));
%         Tbls{1}.MEGdate{i,1}=date;
%     else
%         Tbls{1}.MEGdate{i,1}=[];
%     end
    
%     petfiles=rdir(['/disk/HCP/raw/PET/PETdynamic/' s(i).name '*/PI*']);
%     if(~isempty(petfiles))
%         date=dicominfo(petfiles(1).name);
%         Tbls{1}.PETdate{i,1}=datestr(datenum(date.StudyDate,'yyyymmdd'));
%     else
%         if(~isempty(rdir(['/disk/HCP/analyzed/' s(i).name '/unprocessed/PET/*.nii'])))
%             Tbls{1}.PETdate{i,1}='NIFTI found but not raw data';
%         else
%         Tbls{1}.PETdate{i,1}=[];
%         end
%     end
    
end

flds={'T1w_MPR1' 'T2w_SPC1' 'T2FLAIR' 'HEAD_RFMRI_REST_AP' 'HEAD_RFMRI_REST_PA' ...
    'ASL' 'DWI' 'SWI' 'TRUST' 'flow_pc3d_sag_venc10_sinus_MSUM' };

Tbls{2}=struct;
Tbls{2}=setfield(Tbls{2},'ID',{});
% Tbls{2}=setfield(Tbls{2},'NumberDCMS_MR1',[]);
% Tbls{2}=setfield(Tbls{2},'NumberDCMS_MR2',[]);
for j=1:length(flds)
    Tbls{2}=setfield(Tbls{2},flds{j},[]);
end
% Tbls{2}=setfield(Tbls{2},'MEG',[]);
%Tbls{2}=setfield(Tbls{2},'PET',[]);

for i=1:length(s)
    disp(s(i).name);
    Tbls{2}.ID{i,1}=s(i).name;
    
%     Tbls{2}.NumberDCMS_MR1(i,1)=0;
%     Tbls{2}.NumberDCMS_MR2(i,1)=0;
%     try
%         Tbls{2}.NumberDCMS_MR1(i,1)=length(rdir(fullfile(scandates{i}{1},'**','MR*')));
%         if(length(scandates{i})>1)
%             Tbls{2}.NumberDCMS_MR2(i,1)=length(rdir(fullfile(scandates{i}{2},'**','MR*')));
%         end
%     end
    for j=1:length(flds)
        
        if(~isempty(strfind(flds{j},'DWI')))
            f2='Diffusion';
        elseif(~isempty(strfind(flds{j},'flow_pc3d_sag_venc10_sinus_MSUM')))
            f2='PCA';
        else
            f2=flds{j};
        end
        
        f=dir(fullfile(folder,s(i).name,'unprocessed','3T',f2,[s(i).name '_3T_' flds{j} '.nii.gz']));
        
        Tbls{2}.(flds{j})(i,1)=~isempty(f);
    end
%     f=rdir(fullfile('/aionraid/huppertt/XnatDB/ROS-369/',s(i).name,'unprocessed','MEG','**','*.fif'));
%     Tbls{2}.MEG(i,1)=length(f);
    %f=dir(fullfile(folder,s(i).name,'unprocessed','PET','*.nii'));
    %Tbls{2}.PET(i,1)=length(f);
    
end


asegstats=HCP_statsAll(folder,'aseg.stats');
wmstats=HCP_statsAll(folder,'wmparc.stats');

flds=unique(asegstats.StructName);
Tbls{3}=struct;
Tbls{3}=setfield(Tbls{3},'ID',{});
for j=1:length(flds)
    %flds2{j,1}=genvarname(flds{j});
    flds2{j,1}=flds{j,1};
    flds2{j,1}(strfind(flds2{j,1},'-'))='_';
    if(j<4)
        flds2{j}=['x' flds2{j}];
    end
    Tbls{3}=setfield(Tbls{3},flds2{j},[]);
end

for i=1:length(s)
     disp(s(i).name);
    Tbls{3}.ID{i,1}=s(i).name;
    for j=1:length(flds)
        lst=find(ismember(asegstats.ID,s(i).name) & ismember(asegstats.StructName,flds{j}));
        if(~isempty(lst))
        Tbls{3}.(flds2{j})(i,1)=mean(asegstats.Volume_mm3(lst));
        else
            Tbls{3}.(flds2{j})(i,1)=NaN;
        end
            
    end
end

flds=unique(wmstats.StructName);
Tbls{4}=struct;
Tbls{4}=setfield(Tbls{4},'ID',{});
flds2={};
for j=1:length(flds)
    %flds2{j,1}=genvarname(flds{j});
    flds2{j,1}=flds{j};
    flds2{j,1}(strfind(flds2{j,1},'-'))='_';
    Tbls{4}=setfield(Tbls{4},flds2{j},[]);
end
for i=1:length(s)
     disp(s(i).name);
    Tbls{4}.ID{i,1}=s(i).name;
    for j=1:length(flds)
        lst=find(ismember(wmstats.ID,s(i).name) & ismember(wmstats.StructName,flds{j}));
        if(~isempty(lst))
        Tbls{4}.(flds2{j})(i,1)=mean(wmstats.Volume_mm3(lst));
        else
            Tbls{4}.(flds2{j})(i,1)=NaN;
        end
            
    end
end


L{1}='aparc.stats';
L{2}='aparc.DKTatlas40.stats';
L{3}='aparc.a2009s.stats';
L{4}='BA.stats';
L{5}='entorhinal_exvivo.stats';

Tbl=[];
for i=1:length(L)
    t=HCP_statsAll(folder,['rh.' L{i}]);
    t=[t table(repmat(cellstr('rh'),height(t),1),'VariableNames',{'Hemisphere'})];
    t=[t table(repmat(cellstr(L{i}),height(t),1),'VariableNames',{'Method'})];
    Tbl=[Tbl; t];
end
for i=1:length(L)
    t=HCP_statsAll(folder,['lh.' L{i}]);
    t=[t table(repmat(cellstr('lh'),height(t),1),'VariableNames',{'Hemisphere'})];
    t=[t table(repmat(cellstr(L{i}),height(t),1),'VariableNames',{'Method'})];
    Tbl=[Tbl; t];
end


flds=strcat(Tbl.StructName,repmat(cellstr('_'),height(Tbl),1),Tbl.Hemisphere,...
    repmat(cellstr('_'),height(Tbl),1),Tbl.Method);
for i=1:length(flds)
    flds{i}(strfind(flds{i},'.'))='_';
    flds{i}(strfind(flds{i},'-'))='_';
    flds{i}(strfind(flds{i},'-'))='_';  
end
uflds=unique(flds);


F ={'NumVert'    'SurfArea'    'GrayVol'    'ThickAvg'    'ThickStd'    'MeanCurv'    'GausCurv'    'FoldInd'    'CurvInd'};

for i=1:length(F)
    D={};
    for i2=1:length(s)
        D{1,i2}=s(i2).name;
        for i3=1:length(uflds)
            lst=find(ismember(Tbl.ID,s(i2).name) & ismember(flds,uflds{i3}));
            if(~isempty(lst))
                D{i3+1,i2}=Tbl.(F{i})(lst);
            else
                D{i3+1,i2}=NaN;
            end
        end
      
    end
    Tbls{4+i}=cell2table(D','VariableNames',{'ID' uflds{:}});
    disp([F{i} ' done'])     
end


flds={  'BrainSeg'
    'BrainSegNotVent'
    'BrainSegNotVentSurf'
    'lhCorte'
    'rhCortex'
    'Cortex'
    'lhCorticalWhiteMatter'
    'rhCorticalWhiteMatter'
    'CorticalWhiteMatter'
    'SubCortGray'
    'TotalGray'
    'SupraTentorial'
    'SupraTentorialNotVent'
    'SupraTentorialNotVentVox'
    'Mask'
    'BrainSegVol_to_eTIV'
    'MaskVol_to_eTIV'
    'lhSurfaceHoles'
    'rhSurfaceHoles'
    'SurfaceHoles'
    'EstimatedTotalIntraCranialVol'};

st=struct;
st=setfield(st,'ID',{});
for i=1:length(flds)
    st=setfield(st,flds{i},[]);
end

for i=1:length(s); 
    disp(s(i).name);
    st.ID{i,1}=s(i).name;
     for j=1:length(flds)
            st.(flds{j})(i,1)=NaN;
        end
    try
        fname=fullfile(folder,s(i).name,'stats','aseg.stats');
        t=getasegstats(fname);
        
        for j=1:length(flds)
            st.(flds{j})(i,1)=t.(flds{j});
        end
    end
end;
Tbls{1}=struct2table(Tbls{1});
Tbls{2}=struct2table(Tbls{2});
Tbls{3}=struct2table(Tbls{3});
Tbls{4}=struct2table(Tbls{4});

Tbls{end+1}=struct2table(st);

% This section grabs TRUST Yv and R2 values
st = struct;
flds = {'Yv','R2'};
st=setfield(st,'ID',{});
for i=1:length(flds)
    st=setfield(st,flds{i},[]);
end

for i=1:length(s);
    disp(s(i).name);
    st.ID{i,1}=s(i).name;
    for j=1:length(flds)
        st.(flds{j})(i,1)=NaN;
    end
    try
        load( fullfile(folder,s(i).name,'TRUST',[s(i).name, '_TRUST_fit_noPCA.mat']) );
        st.('Yv')(i,1)=Y_v;
        st.('R2')(i,1)=R2;
        
    end
end;
Tbls{end+1}=struct2table(st);
% st=struct;
% % tbl=HCP_PETstats('/aionraid/huppertt/XnatDB/ROS-369/');
% tbl = table;
% flds=tbl{4}.Properties.VariableNames;
% flds = {};
% st.ID={};
% for j=2:length(flds)
%     st=setfield(st,flds{j},[]);
% end
% for i=1:length(s)
%     st.ID{i,1}=s(i).name;
%     idx=find(ismember(tbl{4}.ID,s(i).name));
%     for j=2:length(flds)
%         if(isempty(idx))
%             st.(flds{j})(i,1)=NaN;
%         else
%             st.(flds{j})(i,1)=tbl{4}.(flds{j})(idx);
%         end
%     end
% end


Sheets={'ScanDates','ScanCounts','AsegVolume','WMVolume','FS_NumVert','FS_SurfArea','FS_GrayVol',...
    'FS_ThickAvg','FS_ThickStd','FS_MeanCurv','FS_GausCurv','FS_FoldInd','FS_CurvInd','FS_AsegStats',...
    'TRUST_Yv'};



%Tbls{end+1}=struct2table(st);


for i=1:length(Tbls)
    Tbls{i}(lst2,:)=[];
end

delete(fullfile(folder,'Summary','ROS369_StatsAll.xls'));
delete(fullfile(folder,'Summary','ROS369_StatsAll.xlsx'));


save(fullfile(folder,'Summary','ROS369_StatsAll_tables.mat'),'Tbls','Sheets')
for i=1:length(Sheets)
    disp(Sheets{i});
    try
    nirs.util.write_xls(fullfile(folder,'Summary','ROS369_StatsAll.xls'),Tbls{i},Sheets{i});
    catch
        warning(lasterr);
    end
end


