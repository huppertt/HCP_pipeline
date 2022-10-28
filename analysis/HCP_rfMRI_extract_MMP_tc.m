function [tc_data] = HCP_rfMRI_extract_MMP_tc(subjid, outfolder, force)

if(nargin<3)
    force=false;
end

HCP_matlab_setenv
fsldir = '/disk/HCP/pipeline/external/fslnew';

if exist(fullfile(outfolder,subjid,'MNINonLinear','Results',[subjid '_BOLD_REST_MMP_timecourses.mat']),'file') & force==false
   disp([subjid ' alread completed and force = 0. Skipping.'])
   return
end

if ~exist(fullfile(outfolder,subjid,'T1w',subjid,'dmri','HCP-MMP_subcort_atlas.nii.gz'),'file')
    disp([subjid ' atlas missing.'])
    return
end

% Bring subject-specific atlas from ACPC to MNINonLinear alignment in BOLD resolution (this can take a bit with NN matching)

if ~exist(fullfile(outfolder,subjid,'T1w',subjid,'dmri','HCP-MMP_subcort_atlas_MNINonLinear.nii.gz'),'file') | force
    system(['applywarp '...
        ' --in='   fullfile(outfolder,subjid,'T1w',subjid,'dmri','HCP-MMP_subcort_atlas.nii.gz') ...
        ' --ref='  fullfile(outfolder,subjid,'MNINonLinear','T1w_restore.2.nii.gz') ...
        ' --warp=' fullfile(outfolder,subjid,'MNINonLinear','xfms','acpc_dc2standard.nii.gz') ...
        ' --interp=nn ' ...
        ' --out='  fullfile(outfolder,subjid,'T1w',subjid,'dmri','HCP-MMP_subcort_atlas_MNINonLinear.nii.gz') ...
        ' -v ' ...
        ])
end

% Bring subject-specific aseg FS file in BOLD resolution (this can take a bit with NN matching)

if ~exist(fullfile(outfolder,subjid,'T1w',subjid,'dmri','aparc+aseg.2.nii.gz'),'file') | force
    system(['flirt '...
        ' -in '   fullfile(outfolder,subjid,'MNINonLinear','aparc+aseg.nii.gz') ...
        ' -ref '  fullfile(outfolder,subjid,'MNINonLinear','T1w_restore.2.nii.gz') ...
        ' -interp nearestneighbour ' ...
        ' -applyxfm -init ' fullfile(fsldir,'etc','flirtsch','ident.mat')...
        ' -out '  fullfile(outfolder,subjid,'T1w',subjid,'dmri','aparc+aseg.2.nii.gz') ...
        ' -v ' ...
        ])
end

% Create vars to store timecourses and regressors for subject
tc_data = struct;



% For each resting state scan (e.g., REST1_AP, REST1_PA, REST2_AP,...):
runs = {'BOLD_REST1_AP','BOLD_REST1_PA','BOLD_REST2_AP','BOLD_REST2_PA','BOLD_REST3_AP','BOLD_REST3_PA','BOLD_REST4_AP','BOLD_REST4_PA'};

% Load atlas
atlas = load_untouch_nii(fullfile(outfolder,subjid,'T1w',subjid,'dmri','HCP-MMP_subcort_atlas_MNINonLinear.nii.gz'));
atlas=atlas.img;

% Load aseg+aparc
aseg = load_untouch_nii(fullfile(outfolder,subjid,'T1w',subjid,'dmri','aparc+aseg.2.nii.gz'));
aseg=aseg.img;


for r = 1: length(runs)
    
    disp([subjid ' beginning tc extraction for run ' runs{r}])
    tc_data(r).name = runs{r};
    
    
    %Check for missing data
    tc_data(r).missing_raw = true;
    tc_data(r).missing_clean = true;
    if exist(fullfile(outfolder,subjid,'MNINonLinear','Results',runs{r},[runs{r} '.nii.gz']))
        tc_data(r).missing_raw = false;
    end
    if exist(fullfile(outfolder,subjid,'MNINonLinear','Results',runs{r},[runs{r} '_hp2000_clean.nii.gz']))
        tc_data(r).missing_clean = false;
    end
    if tc_data(r).missing_raw | tc_data(r).missing_clean
        disp(['Some data missing from run ' runs{r}])
    end
    
    % Extract motion coeffs from pipeline, store 
    if exist(fullfile(outfolder,subjid,'MNINonLinear','Results',runs{r},'Movement_Regressors.txt'),'file')
        tc_data(r).motionregs = load(fullfile(outfolder,subjid,'MNINonLinear','Results',runs{r},'Movement_Regressors.txt'));
    else
        tc_data(r).motionregs = [];
    end
    
    % Extract data from these images by comparing with atlas
    % CURRENTLY HARD-CODED FOR 372 ROIS
    
    
    if tc_data(r).missing_raw == false
        % Load raw timecourse data
        BOLD_base = load_untouch_nii(fullfile(outfolder,subjid,'MNINonLinear','Results',runs{r},[runs{r} '.nii.gz']));
        BOLD_base = BOLD_base.img;
        
        if size(BOLD_base,4) ~= 420
            disp(['Number of raw TRs different than expected: ' num2str(size(BOLD_base,4))])
        end
        
        % Loop over all voxels, storing coord and value for each label
        display(['Collecting raw tc for run ' num2str(r)])
        tic
        max_size = floor(numel(atlas)/20);
        % Loop over 372 Cortical + subcortical regions
        for l = 1:372
            %disp(['Collecting data for run ' num2str(r) ' ROI number ' num2str(l) ])
            %tic
            dat_matrix_raw = NaN(max_size,size(BOLD_base,4)); % Prealloc to save time
            d = 1;
            for i = 1:size(BOLD_base,1)
                for j = 1:size(BOLD_base,2)
                    for k = 1:size(BOLD_base,3)
                        if atlas(i,j,k) == l
                            dat_matrix_raw(d,:)   = squeeze(BOLD_base(i,j,k,:))';
                            d = d+1;
                            if d > max_size
                                display('Index higher than max num voxels?')
                            end
                        end
                    end
                end
            end
            
            dat_matrix_raw(any(isnan(dat_matrix_raw),2),:) = [];
            tc_data(r).raw_tc(l).dat = mean(dat_matrix_raw,1);
            %toc
            
            % Regress out motion for raw data
%             if ~isempty(tc_data(r).motionregs)
%                 y = tc_data(r).raw_tc(l).dat'; % data equals t-by-n BOLD values (discard first few TRs)
%                 regs = [ones(length(tc_data(r).motionregs),1) tc_data(r).motionregs];
%                 betas = inv(regs'*regs)*regs'*y;
%                 resids = y - regs*betas; % Compute residuals
%                 tc_data(r).raw_tc(l).resids = mean(resids',1); % Store residuals for analysis
%             else
%                 tc_data(r).raw_tc(l).resids = []; % Store residuals for analysis
%             end
            
        end
        
        % Loop over WM and ventricles
        
        for l = 373:376
            idx = [2 41 4 43];
            %disp(['Collecting data for run ' num2str(r) ' ROI number ' num2str(l) ])
            %tic
            dat_matrix_raw = NaN(max_size,size(BOLD_base,4)); % Prealloc to save time
            d = 1;
            for i = 1:size(BOLD_base,1)
                for j = 1:size(BOLD_base,2)
                    for k = 1:size(BOLD_base,3)
                        if aseg(i,j,k) == idx(l-372)
                            dat_matrix_raw(d,:)   = squeeze(BOLD_base(i,j,k,:))';
                            d = d+1;
                            if d > max_size
                                display('Index higher than max num voxels?')
                            end
                        end
                    end
                end
            end
            
            dat_matrix_raw(any(isnan(dat_matrix_raw),2),:) = [];
            tc_data(r).raw_tc(l).dat = mean(dat_matrix_raw,1);
            %toc
            
            % Regress out motion for raw data
%             if ~isempty(tc_data(r).motionregs)
%                 y = tc_data(r).raw_tc(l).dat'; % data equals t-by-n BOLD values (discard first few TRs)
%                 regs = [ones(length(tc_data(r).motionregs),1) tc_data(r).motionregs];
%                 betas = inv(regs'*regs)*regs'*y;
%                 resids = y - regs*betas; % Compute residuals
%                 tc_data(r).raw_tc(l).resids = mean(resids',1); % Store residuals for analysis
%             else
%                 tc_data(r).raw_tc(l).resids = []; % Store residuals for analysis
%             end
            
        end
        
        toc
        
    end
   
    if tc_data(r).missing_clean == false
        % Load cleaned timecourse data
        BOLD_clean = load_untouch_nii(fullfile(outfolder,subjid,'MNINonLinear','Results',runs{r},[runs{r} '_hp2000_clean.nii.gz']));
        BOLD_clean = BOLD_clean.img;
        
        if size(BOLD_clean,4) ~= 420
            disp(['Number of clean TRs different than expected: ' num2str(size(BOLD_clean,4))])
        end
        
        % Loop over all voxels, storing coord and value for each label
        display(['Collecting clean tc for run ' num2str(r)])
        tic
        max_size = floor(numel(atlas)/20);
        
        % Loop over ROIs
        for l = 1:372
            %disp(['Collecting data for run ' num2str(r) ' ROI number ' num2str(l) ])
            %tic
            dat_matrix_clean = NaN(max_size,size(BOLD_clean,4));
            d = 1;
            for i = 1:size(BOLD_base,1)
                for j = 1:size(BOLD_base,2)
                    for k = 1:size(BOLD_base,3)
                        if atlas(i,j,k) == l
                            dat_matrix_clean(d,:) = squeeze(BOLD_clean(i,j,k,:))';
                            d = d+1;
                            if d > max_size
                                display('Index higher than max num voxels?')
                            end
                        end
                    end
                end
            end
            
            dat_matrix_clean(any(isnan(dat_matrix_clean),2),:) = [];
            tc_data(r).clean_tc(l).dat = mean(dat_matrix_clean,1);
            %toc
            
             % Regress out motion for clean data
%             if ~isempty(tc_data(r).motionregs)
%                 y = tc_data(r).clean_tc(l).dat'; % data equals t-by-n BOLD values (discard first few TRs)
%                 regs = [ones(length(tc_data(r).motionregs),1) tc_data(r).motionregs];
%                 betas = inv(regs'*regs)*regs'*y;
%                 resids = y - regs*betas; % Compute residuals
%                 tc_data(r).clean_tc(l).resids = mean(resids',1); % Store residuals for analysis
%             else
%                 tc_data(r).clean_tc(l).resids = []; % Store residuals for analysis
%             end
            
        end
        
        % Loop over WM and ventricles
        
        for l = 373:376
            idx = [2 41 4 43];
            %disp(['Collecting data for run ' num2str(r) ' ROI number ' num2str(l) ])
            %tic
            dat_matrix_clean = NaN(max_size,size(BOLD_clean,4));
            d = 1;
            for i = 1:size(BOLD_base,1)
                for j = 1:size(BOLD_base,2)
                    for k = 1:size(BOLD_base,3)
                        if aseg(i,j,k) == idx(l-372);
                            dat_matrix_clean(d,:) = squeeze(BOLD_clean(i,j,k,:))';
                            d = d+1;
                            if d > max_size
                                display('Index higher than max num voxels?')
                            end
                        end
                    end
                end
            end
            
            dat_matrix_clean(any(isnan(dat_matrix_clean),2),:) = [];
            tc_data(r).clean_tc(l).dat = mean(dat_matrix_clean,1);
            %toc
            
            % Regress out motion for clean data
%             if ~isempty(tc_data(r).motionregs)
%                 y = tc_data(r).clean_tc(l).dat'; % data equals t-by-n BOLD values (discard first few TRs)
%                 regs = [ones(length(tc_data(r).motionregs),1) tc_data(r).motionregs];
%                 betas = inv(regs'*regs)*regs'*y;
%                 resids = y - regs*betas; % Compute residuals
%                 tc_data(r).clean_tc(l).resids = mean(resids',1); % Store residuals for analysis
%             else
%                 tc_data(r).clean_tc(l).resids = []; % Store residuals for analysis
%             end
            
        end
        
        toc
            
    end
    
    
    
   

    
    % Bandpass filter? (0.01-0.2Hz), save to struct
    
    % Compute AR innovations, save to struct
%     disp(['Computing innovations for run ' num2str(r)])
%     tic
%     for l = 1:372
%         tc_data(r).raw_tc(l).innov = nirs.math.innovations( tc_data(r).raw_tc(l).resids' , 20)';
%         tc_data(r).clean_tc(l).innov = nirs.math.innovations( tc_data(r).clean_tc(l).resids' , 20)';
%     end
%     toc
end


disp([subjid ' saving file'])
tic
save(fullfile(outfolder,subjid,'MNINonLinear','Results',[subjid '_BOLD_REST_MMP_timecourses.mat']),'-v7.3','tc_data')
toc