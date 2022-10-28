function SUVs=HCP_PETstats(folder)

if(nargin<1)
    folder='/disk/HCP/analyzed';
end

subj=dir(folder);

Names={'GTM','GTM_NOPSF','GTM_PVC','NoGTM'};

ROI(1).name='AnteriorCingulate';
ROI(1).list={'ctx-lh-rostralanteriorcingulate'
    'ctx-lh-caudalanteriorcingulate'
    'ctx-rh-rostralanteriorcingulate'
    'ctx-rh-caudalanteriorcingulate'};

ROI(2).name='AnteriorVentralStriatum';
ROI(2).list={'Left-Accumbens-area'
    'Left-Caudate'
    'Left-Putamen'
    'Right-Accumbens-area'
    'Right-Caudate'
    'Right-Putamen'};
ROI(3).name='SuperiorFrontal';
ROI(3).list={'ctx-lh-rostralmiddlefrontal'
    'ctx-lh-superiorfrontal'
    'ctx-lh-parstriangularis'
    'ctx-lh-frontalpole'
    'ctx-lh-parsopercularis'
    'ctx-lh-caudalmiddlefrontal'
    'ctx-lh-parsorbitalis'
    'ctx-rh-rostralmiddlefrontal'
    'ctx-rh-superiorfrontal'
    'ctx-rh-parstriangularis'
    'ctx-rh-frontalpole'
    'ctx-rh-parsopercularis'
    'ctx-rh-caudalmiddlefrontal'
    'ctx-rh-parsorbitalis'};
ROI(4).name='OrbitoFrontal';
ROI(4).list={'ctx-lh-lateralorbitofrontal'
    'ctx-lh-medialorbitofrontal'
    'ctx-rh-lateralorbitofrontal'
    'ctx-rh-medialorbitofrontal'};
ROI(5).name='Insula';
ROI(5).list={'ctx-lh-insula'
    'ctx-rh-insula'};
ROI(6).name='LateralTemporal';
ROI(6).list={'ctx-lh-superiortemporal'
    'ctx-lh-middletemporal'
    'ctx-lh-inferiortemporal'
    'ctx-lh-bankssts'
    'ctx-rh-superiortemporal'
    'ctx-rh-middletemporal'
    'ctx-rh-inferiortemporal'
    'ctx-rh-bankssts'};
ROI(7).name='Parietal';
ROI(7).list={'ctx-lh-inferiorparietal'
    'ctx-lh-superiorparietal'
    'ctx-lh-supramarginal'
    'ctx-rh-inferiorparietal'
    'ctx-rh-superiorparietal'
    'ctx-rh-supramarginal'};
ROI(8).name='PosteriorCingulate';
ROI(8).list={'ctx-lh-posteriorcingulate'
    'ctx-lh-isthmuscingulate'
    'ctx-rh-posteriorcingulate'
    'ctx-rh-isthmuscingulate'};
ROI(9).name='Precuneus';
ROI(9).list={'ctx-lh-precuneus'
    'ctx-rh-precuneus'};
ROI(10).name='Global';
ROI(10).list={'ctx-lh-rostralanteriorcingulate'
    'ctx-lh-caudalanteriorcingulate'
    'ctx-rh-rostralanteriorcingulate'
    'ctx-rh-caudalanteriorcingulate'
    'Left-Accumbens-area'
    'Left-Caudate'
    'Left-Putamen'
    'Right-Accumbens-area'
    'Right-Caudate'
    'Right-Putamen'
    'ctx-lh-rostralmiddlefrontal'
    'ctx-lh-superiorfrontal'
    'ctx-lh-parstriangularis'
    'ctx-lh-frontalpole'
    'ctx-lh-parsopercularis'
    'ctx-lh-caudalmiddlefrontal'
    'ctx-lh-parsorbitalis'
    'ctx-rh-rostralmiddlefrontal'
    'ctx-rh-superiorfrontal'
    'ctx-rh-parstriangularis'
    'ctx-rh-frontalpole'
    'ctx-rh-parsopercularis'
    'ctx-rh-caudalmiddlefrontal'
    'ctx-rh-parsorbitalis'
    'ctx-lh-lateralorbitofrontal'
    'ctx-lh-medialorbitofrontal'
    'ctx-rh-lateralorbitofrontal'
    'ctx-rh-medialorbitofrontal'
    'ctx-lh-insula'
    'ctx-rh-insula'
    'ctx-lh-superiortemporal'
    'ctx-lh-middletemporal'
    'ctx-lh-inferiortemporal'
    'ctx-lh-bankssts'
    'ctx-rh-superiortemporal'
    'ctx-rh-middletemporal'
    'ctx-rh-inferiortemporal'
    'ctx-rh-bankssts'
    'ctx-lh-inferiorparietal'
    'ctx-lh-superiorparietal'
    'ctx-lh-supramarginal'
    'ctx-rh-inferiorparietal'
    'ctx-rh-superiorparietal'
    'ctx-rh-supramarginal'
    'ctx-lh-posteriorcingulate'
    'ctx-lh-isthmuscingulate'
    'ctx-rh-posteriorcingulate'
    'ctx-rh-isthmuscingulate'
    'ctx-lh-precuneus'
    'ctx-rh-precuneus'};


delete(fullfile(folder,'Summary','Stats','PET_Stats_SUV.xls'));
delete(fullfile(folder,'Summary','Stats','PET_Stats_All.xls'));
delete(fullfile(folder,'Summary','Stats','PET_Stats_SUV.xlsx'));
delete(fullfile(folder,'Summary','Stats','PET_Stats_All.xlsx'));
delete(fullfile(folder,'Summary','PET_Stats_SUV.xls'));
delete(fullfile(folder,'Summary','PET_Stats_All.xls'));
delete(fullfile(folder,'Summary','PET_Stats_SUV.xlsx'));
delete(fullfile(folder,'Summary','PET_Stats_All.xlsx'));


for i=1:4
    cnt=1;
    t={};
    ID={};
    for j=1:length(subj)
        subjid=subj(j).name;
        
        
        f{1}=fullfile(folder,subjid,'PET','gtmpvc.output','gtm.stats.dat');
        f{2}=fullfile(folder,subjid,'PET','gtmpvc_noPSF.output','gtm.stats.dat');
        f{3}=fullfile(folder,subjid,'PET','gtm_noPVC.output','gtm.stats.dat');
        f{4}=fullfile(folder,subjid,'PET','nongtm.output','gtm.stats.dat');
        
        if(exist(f{i}))
            t{cnt}=HCP_stats2table(f{i});
             ID{cnt,1}=subjid;
            cnt=cnt+1;
            disp(subjid);
        end
        
    end
    Columns=unique(t{1}.ROI_name);

    Data=cell(cnt-1,length(Columns));
    Data2=cell(cnt-1,length(Columns));
    for j=1:length(t)
        lst=find(ismember(t{j}.ROI_name,{'Left-Cerebellum-Cortex', 'Right-Cerebellum-Cortex'}));
        n = sum(t{j}.PVC_uptake_wrt_Cerebellum(lst).*t{j}.Number_PET_Voxels(lst))/sum(t{j}.Number_PET_Voxels(lst)); 
  
        for k=1:length(Columns)
            lst=find(ismember(t{j}.ROI_name,Columns{k}));
            if(length(lst)>1)
                Data{j,k}=NaN;
                Data2{j,k}=NaN;
            else
            Data{j,k}=t{j}.Number_PET_Voxels(lst);
            Data2{j,k}=t{j}.PVC_uptake_wrt_Cerebellum(lst)/n;
            end
        end
    end
    ColsOrig=Columns;
      for j=1:length(Columns);
        Columns{j}(strfind(Columns{j},'-'))='_';
        if(isempty(Columns{j}))
            Columns{j}='empty';
        end
      end
     tbl=cell2table(Data,'VariableNames',Columns');
      
     tbl2=cell2table(Data2,'VariableNames',Columns');
      
    nirs.util.write_xls(fullfile(folder,'Summary','Stats','PET_Stats_All.xls'),[table(ID) tbl],[Names{i} '_SUV']);
    
      
    nirs.util.write_xls(fullfile(folder,'Summary','Stats','PET_Stats_All.xls'),[table(ID) tbl2],[Names{i} '_Volume']);
    
    for ii=1:size(Data,1)
        for jj=1:size(Data,2)
            if(isempty(Data{ii,jj}))
                Data(ii,jj)={NaN};
            end
        end
    end
        for ii=1:size(Data2,1)
        for jj=1:size(Data2,2)
            if(isempty(Data2{ii,jj}))
                Data2(ii,jj)={NaN};
            end
        end
    end
    
    D=cell2mat(Data2); D2=cell2mat(Data);
    SUV=struct;
    for j=1:length(ROI)
        lst=find(ismember(ColsOrig,ROI(j).list));
        SUV=setfield(SUV,ROI(j).name,nansum(D(:,lst).*D2(:,lst),2)./nansum(D2(:,lst),2));
     end
      nirs.util.write_xls(fullfile(folder,'Summary','Stats','PET_Stats_SUV.xls'),[table(ID) struct2table(SUV)],[Names{i} '_SUV']);
    
    SUVs{i}=[table(ID) struct2table(SUV)];
end





