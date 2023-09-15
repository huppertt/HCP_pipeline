outfolder = '/disk/sulcus1/COBRA';
subs = dir(outfolder)
subjids = {};
for i = 1:length(subs)
    if subs(i).isdir
        subjids = [subjids ; subs(i).name];
    end
end

have_tc = {};
for i = 1:length(subjids)
    if exist(fullfile(outfolder,subjids{i},'MNINonLinear','Results',[subjids{i} '_BOLD_REST_MMP_timecourses.mat']),'file')
        have_tc = [have_tc;subjids{i}];
    end
end

have_runs = zeros(length(have_tc),16);
have_full_TRs = zeros(length(have_tc),16);
nandata = {};

for i = 1:length(have_tc)
    load(fullfile(outfolder,have_tc{i},'MNINonLinear','Results',[have_tc{i} '_BOLD_REST_MMP_timecourses.mat']))
    
    for j = 1:8
        if ~tc_data(j).missing_raw
            have_runs(i,j) = 1;
            if size(tc_data(j).raw_tc(1).dat,2)==420
                have_full_TR(i,j) = 1;
            end  
        end
        if ~tc_data(j).missing_clean
            have_runs(i,j+8) = 1;
            if size(tc_data(j).clean_tc(1).dat,2)==420
                have_full_TR(i,j+8) = 1;
            end  
        end

        
    end
    if ~tc_data(1).missing_raw
        dat = [];
        for j = 1:372
            dat = [dat  tc_data(1).raw_tc(j).dat'];
        end
        
        if sum(isnan(dat(:)))>0
            nandata = [nandata ; have_tc{i}];
        end
    end
    
    disp([num2str(i) ' of ' num2str(length(have_tc))])
end

% Remove subjids without timecourse 1 (BOLD_REST1_AP)
idx_remove = [have_runs(:,1)==0];
have_tc(idx_remove)=[];

%Remove subjids with nans in TC 1
idx_remove = ismember(have_tc,nandata);
have_tc(idx_remove)=[];

% Vars to store tp tn fp fn
sensitivtity_pearson_raw = nan(length(have_tc),4);
sensitivtity_pearson_raw_ar = nan(length(have_tc),4);
sensitivtity_pearson_res = nan(length(have_tc),4);
sensitivtity_pearson_res_ar = nan(length(have_tc),4);

sensitivtity_part_raw = nan(length(have_tc),4);
sensitivtity_part_raw_ar = nan(length(have_tc),4);
sensitivtity_part_res = nan(length(have_tc),4);
sensitivtity_part_res_ar = nan(length(have_tc),4);

% For each subject, compute corr, partial corr w/w/o AR, w/w/o nuisance reg
for i = 1:length(have_tc)
    
    disp(['Beginning ' have_tc{i} ' Loading and prepping data.'])
    tic
    
    % Load dMRI connectivity
    if exist(fullfile(outfolder,have_tc{i},'T1w',have_tc{i},'dmri',[have_tc{i} '_dsistudio.fib.gz.HCP-MMP_subcort_atlas.count.pass.connectivity.mat']),'file')
        load( fullfile(outfolder,have_tc{i},'T1w',have_tc{i},'dmri',[have_tc{i} '_dsistudio.fib.gz.HCP-MMP_subcort_atlas.count.pass.connectivity.mat']) )
    else
        disp([have_tc{i} ' no dMRI matrix. Skipping.'])
        continue
    end
    % Load fMRI resting state time courses
    if exist(fullfile(outfolder,have_tc{i},'MNINonLinear','Results',[have_tc{i} '_BOLD_REST_MMP_timecourses.mat']),'file')
        load(fullfile(outfolder,have_tc{i},'MNINonLinear','Results',[have_tc{i} '_BOLD_REST_MMP_timecourses.mat']))
    else
        disp([have_tc{i} ' no fMRI matrix. Skipping.'])
        continue
    end
    
        % Check if output exists; if so, compute sens and spec
    if exist(fullfile(outfolder,have_tc{i},'T1w',have_tc{i},'dmri',[have_tc{i} '_rfMRI_conn_matrices.mat']))
       load(fullfile(outfolder,have_tc{i},'T1w',have_tc{i},'dmri',[have_tc{i} '_rfMRI_conn_matrices.mat']))
       continue
    end
    
    % Create data struct with first time course (BOLD_REST1_AP)
    for j = 1:376
        data.BOLD(:,j) = tc_data(1).raw_tc(j).dat';        
    end
    
    % Regress out nuisance vars (currently not all subs have motion vars)
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
    dconn = connectivity(:) > 0;
    fconn = p_pearson_raw(:) < 0.05;
    sens = [sum(dconn & fconn) sum(~dconn & ~fconn) sum(~dconn & fconn) sum(dconn & ~fconn)];
    sensitivtity_pearson_raw(i,:) = sens;
    toc
    
    % Compute correlations (raw data, with AR)
    disp('Computing raw Pearson correlation with AR.')
    tic
    [r_pearson_raw_ar,p_pearson_raw_ar] = corr(id);
    dconn = connectivity(:) > 0;
    fconn = p_pearson_raw_ar(:) < 0.05;
    sens = [sum(dconn & fconn) sum(~dconn & ~fconn) sum(~dconn & fconn) sum(dconn & ~fconn)];
    sensitivtity_pearson_raw_ar(i,:) = sens;
    toc
    
    % Compute correlations (resid data, no AR)
    disp('Computing residual Pearson correlation.')
    tic
    [r_pearson_res,p_pearson_res] = corr(dr);
    dconn = connectivity(:) > 0;
    fconn = p_pearson_res(:) < 0.05;
    sens = [sum(dconn & fconn) sum(~dconn & ~fconn) sum(~dconn & fconn) sum(dconn & ~fconn)];
    sensitivtity_pearson_res(i,:) = sens;
    toc
    
    % Compute correlations (resid data, with AR)
    disp('Computing residual Pearson correlation with AR.')
    tic
    [r_pearson_res_ar,p_pearson_res_ar] = corr(idr);
    dconn = connectivity(:) > 0;
    fconn = p_pearson_res_ar(:) < 0.05;
    sens = [sum(dconn & fconn) sum(~dconn & ~fconn) sum(~dconn & fconn) sum(dconn & ~fconn)];
    sensitivtity_pearson_res_ar(i,:) = sens;
    toc
    
    % Compute partial corr (raw data, no AR)
    disp('Computing raw partial correlation.')
    tic
    r_part_raw=eye(size(d,2));
    p_part_raw=eye(size(d,2));
    for j=1:size(d,2)
        for k=j+1:size(d,2)
            a=d(:,j);
            b=d(:,k);
            c=d; c(:,[j k])=[]; c = [ones(size(c,1),1) c];
            resids = [a b] -c*pinv(c'*c)*c'*[a b ];
            ar = resids(:,1) ; br = resids(:,2);
            [r,p]=corrcoef(ar,br);
            r_part_raw(j,k)=r(1,2);
            r_part_raw(k,j)=r(1,2);
            p_part_raw(j,k)=p(1,2);
            p_part_raw(k,j)=p(1,2);
        end
    end
    dconn = connectivity(:) > 0;
    fconn = p_part_raw(:) < 0.05;
    sens = [sum(dconn & fconn) sum(~dconn & ~fconn) sum(~dconn & fconn) sum(dconn & ~fconn)];
    sensitivtity_part_raw(i,:) = sens;
    toc
    
% Compute partial corr (raw data, with AR)
disp('Computing raw partial correlation with AR.')
tic
    r_part_raw_ar=eye(size(id,2));
    p_part_raw_ar=eye(size(id,2));
    for j=1:size(id,2)
        for k=j+1:size(id,2)
            a=id(:,j);
            b=id(:,k);
            c=id; c(:,[j k])=[]; c = [ones(size(c,1),1) c];
            resids = [a b] -c*pinv(c'*c)*c'*[a b ];
            ar = resids(:,1) ; br = resids(:,2);
            [r,p]=corrcoef(ar,br);
            r_part_raw_ar(j,k)=r(1,2);
            r_part_raw_ar(k,j)=r(1,2);
            p_part_raw_ar(j,k)=p(1,2);
            p_part_raw_ar(k,j)=p(1,2);
        end
    end
    dconn = connectivity(:) > 0;
    fconn = p_part_raw_ar(:) < 0.05;
    sens = [sum(dconn & fconn) sum(~dconn & ~fconn) sum(~dconn & fconn) sum(dconn & ~fconn)];
    sensitivtity_part_raw_ar(i,:) = sens;
    toc
    
    % Compute partial corr (resid data, no AR)
    disp('Computing residual partial correlation.')
    tic
    r_part_res=eye(size(dr,2));
    p_part_res=eye(size(dr,2));
    for j=1:size(dr,2)
        for k=j+1:size(dr,2)
            a=dr(:,j);
            b=dr(:,k);
            c=dr; c(:,[j k])=[]; c = [ones(size(c,1),1) c];
            resids = [a b] -c*pinv(c'*c)*c'*[a b ];
            ar = resids(:,1) ; br = resids(:,2);
            [r,p]=corrcoef(ar,br);
            r_part_res(j,k)=r(1,2);
            r_part_res(k,j)=r(1,2);
            p_part_res(j,k)=p(1,2);
            p_part_res(k,j)=p(1,2);
        end
    end
    dconn = connectivity(:) > 0;
    fconn = p_part_res(:) < 0.05;
    sens = [sum(dconn & fconn) sum(~dconn & ~fconn) sum(~dconn & fconn) sum(dconn & ~fconn)];
    sensitivtity_part_res(i,:) = sens;
    toc
    
    % Compute partial corr (resid data, with AR)
    disp('Computing residual partial correlation with AR.')
    tic
    r_part_res_ar=eye(size(idr,2));
    p_part_res_ar=eye(size(idr,2));
    for j=1:size(idr,2)
        for k=j+1:size(idr,2)
            a=idr(:,j);
            b=idr(:,k);
            c=idr; c(:,[j k])=[]; c = [ones(size(c,1),1) c];
            resids = [a b] -c*pinv(c'*c)*c'*[a b ];
            ar = resids(:,1) ; br = resids(:,2);
            [r,p]=corrcoef(ar,br);
            r_part_res_ar(j,k)=r(1,2);
            r_part_res_ar(k,j)=r(1,2);
            p_part_res_ar(j,k)=p(1,2);
            p_part_res_ar(k,j)=p(1,2);
        end
    end
    dconn = connectivity(:) > 0;
    fconn = p_part_res_ar(:) < 0.05;
    sens = [sum(dconn & fconn) sum(~dconn & ~fconn) sum(~dconn & fconn) sum(dconn & ~fconn)];
    sensitivtity_part_res_ar(i,:) = sens;
    toc
    
    save(fullfile(outfolder,have_tc{i},'T1w',have_tc{i},'dmri',[have_tc{i} '_rfMRI_conn_matrices.mat']),...
        'r_pearson_raw','p_pearson_raw','r_pearson_raw_ar','p_pearson_raw_ar',...
        'r_pearson_res','p_pearson_res','r_pearson_res_ar','p_pearson_res_ar',...
        'r_part_raw','p_part_raw','r_part_raw_ar','p_part_raw_ar',...
        'r_part_res','p_part_res','r_part_res_ar','p_part_res_ar')
        
end

