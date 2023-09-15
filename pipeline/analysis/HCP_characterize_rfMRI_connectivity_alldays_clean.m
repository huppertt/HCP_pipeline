
outfolder = '/disk/sulcus1/COBRA'; 
subs = dir(outfolder);
subjids = {};
for i = 1:length(subs)
    if subs(i).isdir
        subjids = [subjids ; subs(i).name];
    end
end


have_conn = {};
for i = 1:length(subjids)
    if exist(fullfile(outfolder,subjids{i},'T1w',subjids{i},'dmri',[subjids{i} '_rfMRI_conn_matrices_alldays_clean.mat']))
        have_conn = [have_conn;subjids{i}];
    end
end
disp(['Number of subjects with all days connectivity is ' num2str(length(have_conn))])

have_dti = {};
for i = 1:length(subjids)
    if exist(fullfile(outfolder,subjids{i},'T1w',subjids{i},'dmri',[subjids{i} '_dsistudio.fib.gz.HCP-MMP_subcort_atlas.count.pass.connectivity.mat']),'file')
        have_dti = [have_dti;subjids{i}];
    end
end
disp(['Number of subjects that have DTI is ' num2str(length(have_dti))])

have_wmh = {};
for i = 1:length(subjids)
    if exist(fullfile(outfolder,subjids{i},'T1w',subjids{i},'dmri',[subjids{i} '_dsistudio.fib.gz.HCP-MMP_subcort_atlas.lesion.pass.connectivity.mat']),'file')
        have_wmh = [have_wmh;subjids{i}];
    end
end
disp(['Number of subjects that have WMH is ' num2str(length(have_wmh))])

have_conn = have_conn(ismember(have_conn,have_dti));
have_conn = have_conn(ismember(have_conn,have_wmh));

disp(['Number of subjects that have all is ' num2str(length(have_conn))])

for i = 1:8
dat_raw(i).fconn_stack = [];
dat_raw_ar(i).fconn_stack = [];
dat_res(i).fconn_stack = [];
dat_res_ar(i).fconn_stack = [];
end


DTI_components = [];
dconn_stack = [];
wmh_stack = [];

for i = 1:length(have_conn)
    disp([num2str(i) ' ' have_conn{i} ' loading data and stacking matrices'])
    load(fullfile(outfolder,have_conn{i},'T1w',have_conn{i},'dmri',[have_conn{i} '_rfMRI_conn_matrices_alldays.mat']))
    load(fullfile(outfolder,have_conn{i},'T1w',have_conn{i},'dmri',[have_conn{i} '_dsistudio.fib.gz.HCP-MMP_subcort_atlas.count.pass.connectivity.mat']))

    
    DTIcompNum = graphconncomp(sparse((connectivity+connectivity')>0));
    DTI_components(i) = DTIcompNum;
    dconn_stack = cat(3,dconn_stack,connectivity);
    
    load(fullfile(outfolder,have_conn{i},'T1w',have_conn{i},'dmri',[have_conn{i} '_dsistudio.fib.gz.HCP-MMP_subcort_atlas.lesion.pass.connectivity.mat']))
    wmh_stack = cat(3,wmh_stack,connectivity);
    
    for j = 1:8
        
        dat_raw(j).fconn_stack = cat(3,dat_raw(j).fconn_stack,conn_data(j).r_pearson_raw);
        dat_raw_ar(j).fconn_stack = cat(3,dat_raw_ar(j).fconn_stack,conn_data(j).r_pearson_raw_ar);
        dat_res(j).fconn_stack = cat(3,dat_res(j).fconn_stack,conn_data(j).r_pearson_res);
        dat_res_ar(j).fconn_stack = cat(3,dat_res_ar(j).fconn_stack,conn_data(j).r_pearson_res_ar);
        
    end
    
end

% for i = 1:4
% megastack_d1(:,:,:,i) = dat_raw(i).fconn_stack;
% end
% for i = 5:8
% megastack_d2(:,:,:,i-4) = dat_raw(i).fconn_stack;
% end
for i =1:8
    megastack_raw(:,:,:,i) = dat_raw(i).fconn_stack;
    megastack_raw_ar(:,:,:,i) = dat_raw_ar(i).fconn_stack;
    megastack_res(:,:,:,i) = dat_res(i).fconn_stack;
    megastack_res_ar(:,:,:,i) = dat_res_ar(i).fconn_stack;
end


% fconn_stack_d1 = nanmean(megastack_d1,4);
% fconn_stack_d2 = nanmean(megastack_d2,4);
fconn_stack_all_raw = nanmean(megastack_raw,4);
fconn_stack_all_raw_ar = nanmean(megastack_raw_ar,4);
fconn_stack_all_res = nanmean(megastack_res,4);
fconn_stack_all_res_ar = nanmean(megastack_res_ar,4);

xtemp = [];
y = [];
idx_ut = logical(triu(ones(372),1));
% for i = 1:size(fconn_stack_d1,3)
%     d = dconn_stack(:,:,i);
%     c = fconn_stack_d1(:,:,i);
%     xtemp = [xtemp ; d(idx_ut)];
%     y = [y ; c(idx_ut)];
% end

% figure
% for i = 1:16
%     subplot(4,4,i);imagesc(fconn_stack_all(:,:,i));axis square
%     r = fconn_stack_all(:,:,i); r = r(idx_ut);
%     cmin = min(r) ; cmax = max(r);
%     caxis([cmin cmax])
%     title([num2str(cmin) ' ' num2str(cmax)])
% end