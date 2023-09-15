function HCP_rfMRI_MMP_cov_matrix_alldays(subjid,outfolder,force)

if nargin < 3
    force = 0;
end

% Check if output exists; if so, compute sens and spec
if exist(fullfile(outfolder,subjid,'T1w',subjid,'dmri',[subjid '_rfMRI_cov_matrices_alldays.mat'])) & ~force
    disp([subjid 'conn matrices already saved. Skipping...'])
    return
end

disp(['Beginning ' subjid ' Loading and prepping data.'])
tic

% Load dMRI connectivity
% if exist(fullfile(outfolder,subjid,'T1w',subjid,'dmri',[subjid '_dsistudio.fib.gz.HCP-MMP_subcort_atlas.count.pass.connectivity.mat']),'file')
%     load( fullfile(outfolder,subjid,'T1w',subjid,'dmri',[subjid '_dsistudio.fib.gz.HCP-MMP_subcort_atlas.count.pass.connectivity.mat']) )
% else
%     disp([subjid ' no dMRI matrix. Skipping.'])
%     return
% end

% Load fMRI resting state time courses
if exist(fullfile(outfolder,subjid,'MNINonLinear','Results',[subjid '_BOLD_REST_MMP_timecourses.mat']),'file')
    load(fullfile(outfolder,subjid,'MNINonLinear','Results',[subjid '_BOLD_REST_MMP_timecourses.mat']))
else
    disp([subjid ' no fMRI timecourses. Skipping.'])
    return
end

% check if any clean time courses missing
for i = 1:8
    if tc_data(i).missing_clean
        scan_present(i) = 0;
    else
        scan_present(i) = 1;
    end
end
scan_idx = find(scan_present==1);
 
for i = 1:8
    
    % Create data struct with first time course (BOLD_REST1_AP)
    clear data;
    for j = 1:376
        data.BOLD(:,j) = tc_data(i).raw_tc(j).dat';
    end
    
    % Regress out WM/CSF nuisance vars (currently not all subs have motion vars)
    x = [ones(size(data.BOLD,1),1) data.BOLD(:,373:end)];
    data.resids = data.BOLD -x*pinv(x'*x)*x'*data.BOLD ;
    
    % Rename data as compact vars
    % Raw data w/w/o AR
    d=data.BOLD(10:end,1:372);
    d=d-ones(size(d,1),1)*mean(d,1);
    % twice to prevent numerical precision errors
    d=d-ones(size(d,1),1)*mean(d,1);
    id=nirs.math.innovations(d,20);
    % Resids w/w/o AR
    dr=data.resids(10:end,1:372);
    dr=dr-ones(size(dr,1),1)*mean(dr,1);
    % twice to prevent numerical precision errors
    dr=dr-ones(size(dr,1),1)*mean(dr,1);
    idr=nirs.math.innovations(dr,20);
    toc
    
    % Compute covariance (raw data, no AR)
    disp('Computing raw covariance.')
    tic
    [cov_data(i).cov_raw] = cov(d);
    toc
    
    % Compute correlations (raw data, with AR)
    disp('Computing raw covariance with AR.')
    tic
    [cov_data(i).cov_raw_ar] = cov(id);
    toc
    
    % Compute correlations (resid data, no AR)
    disp('Computing residual  covariance.')
    tic
    [cov_data(i).cov_res] = cov(dr);
    toc
    
    % Compute correlations (resid data, with AR)
    disp('Computing residual covariance with AR.')
    tic
    [cov_data(i).cov_res_ar] = cov(idr);
    toc
    
    
end


save(fullfile(outfolder,subjid,'T1w',subjid,'dmri',[subjid '_rfMRI_cov_matrices_alldays.mat']),...
    'cov_data')