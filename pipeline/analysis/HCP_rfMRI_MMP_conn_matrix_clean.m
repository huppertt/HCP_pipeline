function HCP_rfMRI_MMP_conn_matrix_clean(subjid,outfolder,force)

if nargin < 3
    force = 0;
end

% Check if output exists; if so, compute sens and spec
if exist(fullfile(outfolder,subjid,'T1w',subjid,'dmri',[subjid '_rfMRI_conn_matrices_clean.mat'])) & ~force
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

% Create data struct with first time course (BOLD_REST1_AP)
for j = 1:376
    data.BOLD(:,j) = tc_data(1).clean_tc(j).dat';
end

% Regress out WM/CSF nuisance vars (currently not all subs have motion vars)
x = [ones(length(data.BOLD),1) data.BOLD(:,373:end)];
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

% % Compute partial corr (raw data, no AR)
% disp('Computing raw partial correlation.')
% tic
% r_part_raw=eye(size(d,2));
% p_part_raw=eye(size(d,2));
% for j=1:size(d,2)
%     for k=j+1:size(d,2)
%         disp(k)
%         a=d(:,j);
%         b=d(:,k);
%         c=d; c(:,[j k])=[]; c = [ones(size(c,1),1) c];
%         resids = [a b] -c*pinv(c'*c)*c'*[a b ];
%         ar = resids(:,1) ; br = resids(:,2);
%         [r,p]=corrcoef(ar,br);
%         r_part_raw(j,k)=r(1,2);
%         r_part_raw(k,j)=r(1,2);
%         p_part_raw(j,k)=p(1,2);
%         p_part_raw(k,j)=p(1,2);
%     end
% end
% toc
% 
% % Compute partial corr (raw data, with AR)
% disp('Computing raw partial correlation with AR.')
% tic
% r_part_raw_ar=eye(size(id,2));
% p_part_raw_ar=eye(size(id,2));
% for j=1:size(id,2)
%     for k=j+1:size(id,2)
%         a=id(:,j);
%         b=id(:,k);
%         c=id; c(:,[j k])=[]; c = [ones(size(c,1),1) c];
%         resids = [a b] -c*pinv(c'*c)*c'*[a b ];
%         ar = resids(:,1) ; br = resids(:,2);
%         [r,p]=corrcoef(ar,br);
%         r_part_raw_ar(j,k)=r(1,2);
%         r_part_raw_ar(k,j)=r(1,2);
%         p_part_raw_ar(j,k)=p(1,2);
%         p_part_raw_ar(k,j)=p(1,2);
%     end
% end
% toc
% 
% % Compute partial corr (resid data, no AR)
% disp('Computing residual partial correlation.')
% tic
% r_part_res=eye(size(dr,2));
% p_part_res=eye(size(dr,2));
% for j=1:size(dr,2)
%     for k=j+1:size(dr,2)
%         a=dr(:,j);
%         b=dr(:,k);
%         c=dr; c(:,[j k])=[]; c = [ones(size(c,1),1) c];
%         resids = [a b] -c*pinv(c'*c)*c'*[a b ];
%         ar = resids(:,1) ; br = resids(:,2);
%         [r,p]=corrcoef(ar,br);
%         r_part_res(j,k)=r(1,2);
%         r_part_res(k,j)=r(1,2);
%         p_part_res(j,k)=p(1,2);
%         p_part_res(k,j)=p(1,2);
%     end
% end
% toc
% 
% % Compute partial corr (resid data, with AR)
% disp('Computing residual partial correlation with AR.')
% tic
% r_part_res_ar=eye(size(idr,2));
% p_part_res_ar=eye(size(idr,2));
% for j=1:size(idr,2)
%     for k=j+1:size(idr,2)
%         a=idr(:,j);
%         b=idr(:,k);
%         c=idr; c(:,[j k])=[]; c = [ones(size(c,1),1) c];
%         resids = [a b] -c*pinv(c'*c)*c'*[a b ];
%         ar = resids(:,1) ; br = resids(:,2);
%         [r,p]=corrcoef(ar,br);
%         r_part_res_ar(j,k)=r(1,2);
%         r_part_res_ar(k,j)=r(1,2);
%         p_part_res_ar(j,k)=p(1,2);
%         p_part_res_ar(k,j)=p(1,2);
%     end
% end
% toc

save(fullfile(outfolder,subjid,'T1w',subjid,'dmri',[subjid '_rfMRI_conn_matrices_clean.mat']),...
    'r_pearson_raw','p_pearson_raw','r_pearson_raw_ar','p_pearson_raw_ar',...
    'r_pearson_res','p_pearson_res','r_pearson_res_ar','p_pearson_res_ar')