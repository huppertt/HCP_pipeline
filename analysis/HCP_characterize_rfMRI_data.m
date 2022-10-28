
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
    
    disp([num2str(i) ' of ' num2str(length(have_tc))])
end

% Remove subjids without timecourse 1 (BOLD_REST1_AP)
idx_remove = [have_runs(:,1)==0];
have_tc(idx_remove)=[];

% Build P and R distribution for 500 random pairs of subjects and regions

p_vals_intersubject = zeros(5000,1);
r_vals_intersubject = zeros(5000,1);
p_vals_intersubject_ar = zeros(5000,1);
r_vals_intersubject_ar = zeros(5000,1);

for i = 1:5000
    tic
    subjects = randsample(length(have_tc),2);
    regions = randsample(372,2);
    
%     load(fullfile(outfolder,have_tc{subjects(1)},'MNINonLinear','Results',[have_tc{subjects(1)} '_BOLD_REST_MMP_timecourses.mat']),'tc_data_mean')
%     mean_exist1 = isfield(tc_data_mean(1).raw_tc(regions(1)),'mean');
%     load(fullfile(outfolder,have_tc{subjects(2)},'MNINonLinear','Results',[have_tc{subjects(2)} '_BOLD_REST_MMP_timecourses.mat']),'tc_data_mean')
%     mean_exist2 = isfield(tc_data_mean(1).raw_tc(regions(1)),'mean');
%     
%     while ~mean_exist1 | ~mean_exist2
%         subjects = randsample(length(have_tc),2);
%         load(fullfile(outfolder,have_tc{subjects(1)},'MNINonLinear','Results',[have_tc{subjects(1)} '_BOLD_REST_MMP_timecourses.mat']),'tc_data_mean')
%         mean_exist1 = isfield(tc_data_mean(1).raw_tc(regions(1)),'mean');
%         load(fullfile(outfolder,have_tc{subjects(2)},'MNINonLinear','Results',[have_tc{subjects(2)} '_BOLD_REST_MMP_timecourses.mat']),'tc_data_mean')
%         mean_exist2 = isfield(tc_data_mean(1).raw_tc(regions(1)),'mean');
%     end
    

    load(fullfile(outfolder,have_tc{subjects(1)},'MNINonLinear','Results',[have_tc{subjects(1)} '_BOLD_REST_MMP_timecourses.mat']),'tc_data')
    tc1 = mean(tc_data(1).raw_tc(regions(1)).dat,1)';

    load(fullfile(outfolder,have_tc{subjects(2)},'MNINonLinear','Results',[have_tc{subjects(2)} '_BOLD_REST_MMP_timecourses.mat']),'tc_data')
    tc2 = mean(tc_data(1).raw_tc(regions(2)).dat,1)';
    
    tc1_ar = nirs.math.innovations(tc1,40);
    tc2_ar = nirs.math.innovations(tc2,40);
    
    [r,p] = corr(tc1,tc2);
    p_vals_intersubject(i) = p;
    r_vals_intersubject(i) = r;
    
    [r,p] = corr(tc1_ar,tc2_ar);
    p_vals_intersubject_ar(i) = p;
    r_vals_intersubject_ar(i) = r;
    
    disp(['Completed intersubject sample ' num2str(i) ' of 5000.'])
    toc
end


% Build P and R distribution for 500 random intra-subject regions

p_vals_intrasubject = zeros(5000,1);
r_vals_intrasubject = zeros(5000,1);
p_vals_intrasubject_ar = zeros(5000,1);
r_vals_intrasubject_ar = zeros(5000,1);

for i = 1:5000
    tic
    subjects = randsample(length(have_tc),1);
    regions = randsample(372,2);
    
    load(fullfile(outfolder,have_tc{subjects(1)},'MNINonLinear','Results',[have_tc{subjects(1)} '_BOLD_REST_MMP_timecourses.mat']),'tc_data')
%     mean_exist1 = isfield(tc_data_mean(1).raw_tc(regions(1)),'mean');

    
%     while ~mean_exist1 
%         subjects = randsample(length(have_tc),2);
%         load(fullfile(outfolder,have_tc{subjects(1)},'MNINonLinear','Results',[have_tc{subjects(1)} '_BOLD_REST_MMP_timecourses.mat']),'tc_data_mean')
%         mean_exist1 = isfield(tc_data_mean(1).raw_tc(regions(1)),'mean')
%     end
    
    tc1 = mean(tc_data(1).raw_tc(regions(1)).dat,1)';
    tc2 = mean(tc_data(1).raw_tc(regions(2)).dat,1)';
    tc1_ar = nirs.math.innovations(tc1,40);
    tc2_ar = nirs.math.innovations(tc2,40);
    
    [r,p] = corr(tc1,tc2);
    p_vals_intrasubject(i) = p;
    r_vals_intrasubject(i) = r;
    
    [r,p] = corr(tc1_ar,tc2_ar);
    p_vals_intrasubject_ar(i) = p;
    r_vals_intrasubject_ar(i) = r;
    
    disp(['Completed intrasubject sample ' num2str(i) ' of 5000.'])
    toc
end
      


d=data.BOLD(10:end,:);

d=data.resids(10:end,:);
d=d-ones(size(d,1),1)*mean(d,1);
% twice to prevent numerical precision errors
d=d-ones(size(d,1),1)*mean(d,1);
id=nirs.math.innovations(d,20);

C=eye(size(id,2));
P=eye(size(id,2));
Cpart=eye(size(id,2));
Ppart=eye(size(id,2));
for i=1:size(id,2)
  disp(i);
  for j=i+1:size(id,2)
    a=id(:,i);
    b=id(:,j);
    c=id; c(:,[i j])=[]; c = [ones(size(c,1),1) c];  
%     f1=regstats(a,[b c],'linear',{'fstat'});
%     f2=regstats(a,[c],'linear',{'fstat'});
%     f1b=regstats(b,[a c],'linear',{'fstat'});
%     f2b=regstats(b,[c],'linear',{'fstat'});
%     df=(f1b.fstat.f+f1.fstat.f-f2.fstat.f-f2b.fstat.f)/2;
%     if(df>0)
%       P(j,i)=1-chi2cdf(-2*log(df),1);
%       P(i,j)=P(j,i);
%     else
%       P(j,i)=1;
%       P(i,j)=1;
%     end
% Partial correlation version:    
%     H=eye(size(c,1))-c*pinv(c'*c)*c';   
%     ar = H*a;
%     br = H*b;
    
    resids = [a b] -c*pinv(c'*c)*c'*[a b ];
    ar = resids(:,1) ; br = resids(:,2);
    [r,p]=corrcoef(ar,br);
    Cpart(i,j)=r(1,2);
    Cpart(j,i)=r(1,2);
    Ppart(i,j)=p(1,2);
    Ppart(j,i)=p(1,2);
  end
end