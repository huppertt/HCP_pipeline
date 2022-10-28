function ROSMOVE_rfMRI_conn_matrix_superregions(subjid,outfolder,force)

if nargin < 3
    force = 0;
end

% Check if prereq met
if ~exist(fullfile(outfolder,subjid,'MNINonLinear','Results',[subjid '_MMP_CIC_timecourses_superregions.mat']),'file')
    disp([subjid ' timeseries not yet extracted. Returning'])
    return;
end

% Check if output exists; if so, compute sens and spec
if exist(fullfile(outfolder,subjid,'MNINonLinear','Results',[subjid '_rfMRI_conn_matrix_superregions.mat'])) & ~force
    disp([subjid 'conn matrix already saved. Skipping...'])
    return
end

disp(['Beginning ' subjid ' Loading and prepping data.'])
tic

load(fullfile(outfolder,subjid,'MNINonLinear','Results',[subjid '_MMP_CIC_timecourses_superregions.mat']))

% Create data struct 
for j = 1:16
    data.BOLD(:,j) = tc_data.raw_tc(j).dat';
end

% Regress out nuisance vars 
x = [ones(size(data.BOLD,1),1) tc_data.motionregs data.BOLD(:,17:end)];
data.resids = data.BOLD -x*pinv(x'*x)*x'*data.BOLD ;

% Rename data as compact vars
% Raw data w/w/o AR
d=data.BOLD(10:end,1:16);
d=d-ones(size(d,1),1)*mean(d,1);
% twice to prevent numerical precision errors
d=d-ones(size(d,1),1)*mean(d,1);
id=nirs.math.innovations(d,20);
% Resids w/w/o AR
dr=data.resids(10:end,1:16);
dr=dr-ones(size(dr,1),1)*mean(dr,1);
% twice to prevent numerical precision errors
dr=dr-ones(size(dr,1),1)*mean(dr,1);
idr=nirs.math.innovations(dr,20);
toc

% Compute correlations (raw data, no AR)
disp('Computing raw Pearson correlation.')
tic
[r_pearson_raw,p_pearson_raw] = corr(d);
toc

% Compute correlations (raw data, with AR)
disp('Computing raw Pearson correlation with AR.')
tic
[r_pearson_raw_ar,p_pearson_raw_ar] = corr(id);
toc

% Compute correlations (resid data, no AR)
disp('Computing residual Pearson correlation.')
tic
[r_pearson_res,p_pearson_res] = corr(dr);
toc

% Compute correlations (resid data, with AR)
disp('Computing residual Pearson correlation with AR.')
tic
[r_pearson_res_ar,p_pearson_res_ar] = corr(idr);
toc

save(fullfile(outfolder,subjid,'MNINonLinear','Results',[subjid '_rfMRI_conn_matrix_superregions.mat']),...
    'r_pearson_raw','p_pearson_raw','r_pearson_raw_ar','p_pearson_raw_ar',...
    'r_pearson_res','p_pearson_res','r_pearson_res_ar','p_pearson_res_ar')
