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
        sum(isnan(dat(:)))>0
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

p_vals_intersubject = zeros(length(have_tc),1);
r_vals_intersubject = zeros(length(have_tc),1);
p_vals_intersubject_ar = zeros(length(have_tc),1);
r_vals_intersubject_ar = zeros(length(have_tc),1);

for i = 1:length(have_tc)
    tic
    subjects = randsample(length(have_tc),2);
    regions = [8 188]; % Left and right motor cortex
    
    load(fullfile(outfolder,have_tc{subjects(1)},'MNINonLinear','Results',[have_tc{subjects(1)} '_BOLD_REST_MMP_timecourses.mat']),'tc_data')
    dat1 = nan(420,372);
    for j = 1:372
        dat1(:,j) = tc_data(1).raw_tc(j).dat';
    end
    dat1_ar = nirs.math.innovations(dat1,20);
    tc1 = mean(tc_data(1).raw_tc(regions(1)).dat,1)';
    tc1_ar = nirs.math.innovations(tc1,20);
    
    load(fullfile(outfolder,have_tc{subjects(2)},'MNINonLinear','Results',[have_tc{subjects(2)} '_BOLD_REST_MMP_timecourses.mat']),'tc_data')
%     dat2 = nan(420,372);
%     for j = 1:372
%         dat2(:,j) = tc_data(1).raw_tc(j).dat';
%     end
%     dat2_ar = nirs.math.innovations(dat1,20);
    tc2 = mean(tc_data(1).raw_tc(regions(1)).dat,1)';
    tc2_ar = nirs.math.innovations(tc2,20);
    
    a = tc1;
    b = tc2;
    c = dat1; c(:,regions) = []; c = [ones(420,1) c];
%     H=eye(size(c,1))-c*pinv(c'*c)*c'; 
%     ar = H*a;
%     br = H*b;
resids = [a b] - c*pinv(c'*c)*c'*[a b];
ar = resids(:,1) ; br = resids(:,2);
    
    [r,p] = corr(ar,br);
    p_vals_intersubject(i) = p;
    r_vals_intersubject(i) = r;
    
    a = tc1_ar;
    b = tc2_ar;
    c = dat1_ar; c(:,regions) = []; c = [ones(420,1) c];
%     H=eye(size(c,1))-c*pinv(c'*c)*c'; 
%     ar = H*a;
%     br = H*b;
resids = [a b] -c*pinv(c'*c)*c'*[a b ];
ar = resids(:,1) ; br = resids(:,2);
    
    [r,p] = corr(ar,br);
    p_vals_intersubject_ar(i) = p;
    r_vals_intersubject_ar(i) = r;
    
    disp(['Completed intersubject sample ' num2str(i) ' of ' num2str(length(have_tc))])
    toc
end


p_vals_intrasubject = zeros(length(have_tc),1);
r_vals_intrasubject = zeros(length(have_tc),1);
p_vals_intrasubject_ar = zeros(length(have_tc),1);
r_vals_intrasubject_ar = zeros(length(have_tc),1);

for i = 1:length(have_tc)
 tic
    subjects = [i];
    regions = [8 188];
    
    load(fullfile(outfolder,have_tc{subjects(1)},'MNINonLinear','Results',[have_tc{subjects(1)} '_BOLD_REST_MMP_timecourses.mat']),'tc_data')
    
    dat1 = nan(420,372);
    for j = 1:372
        dat1(:,j) = tc_data(1).raw_tc(j).dat';
    end
    dat1_ar = nirs.math.innovations(dat1,20);
    tc1 = mean(tc_data(1).raw_tc(regions(1)).dat,1)';
    tc1_ar = nirs.math.innovations(tc1,20);
    
    tc2 = mean(tc_data(1).raw_tc(regions(2)).dat,1)';
    tc2_ar = nirs.math.innovations(tc2,20);
    
    a = tc1;
    b = tc2;
    c = dat1; c(:,regions) = []; c = [ones(420,1) c];
%     H=eye(size(c,1))-c*pinv(c'*c)*c'; 
%     ar = H*a;
%     br = H*b;
resids = [a b] - c*pinv(c'*c)*c'*[a b];
ar = resids(:,1) ; br = resids(:,2);
    
    [r,p] = corr(ar,br);
    p_vals_intrasubject(i) = p;
    r_vals_intrasubject(i) = r;
    
    
    a = tc1_ar;
    b = tc2_ar;
    c = dat1_ar; c(:,regions) = []; c = [ones(420,1) c];
%     H=eye(size(c,1))-c*pinv(c'*c)*c'; 
%     ar = H*a;
%     br = H*b;
resids = [a b] - c*pinv(c'*c)*c'*[a b];
ar = resids(:,1) ; br = resids(:,2);
    
    [r,p] = corr(ar,br);
    p_vals_intrasubject_ar(i) = p;
    r_vals_intrasubject_ar(i) = r;
    
    disp(['Completed intrasubject sample ' num2str(i) ' of ' num2str(length(have_tc))])
    toc
end

truth = [zeros(length(have_tc),1) ; ones(length(have_tc),1)];

p_raw = [p_vals_intersubject ; p_vals_intrasubject];
p_ar = [p_vals_intersubject_ar ; p_vals_intrasubject_ar];

[tp_raw,fp_raw] = nirs.testing.roc(truth,p_raw);
[tp_ar,fp_ar] = nirs.testing.roc(truth,p_ar);