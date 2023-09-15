
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
    if exist(fullfile(outfolder,subjids{i},'T1w',subjids{i},'dmri',[subjids{i} '_rfMRI_conn_matrices.mat']),'file')
        have_conn = [have_conn;subjids{i}];
    end
end
disp(['Number of subjects with connectivity is ' num2str(length(have_conn))])

have_dti = {};
for i = 1:length(subjids)
    if exist(fullfile(outfolder,subjids{i},'T1w',subjids{i},'dmri',[subjids{i} '_dsistudio.fib.gz.HCP-MMP_subcort_atlas.count.pass.connectivity.mat']),'file')
        have_dti = [have_dti;subjids{i}];
    end
end
disp(['Number of subjects that have DTI is ' num2str(length(have_dti))])

have_conn = have_conn(ismember(have_conn,have_dti));

disp(['Number of subjects that have both is ' num2str(length(have_conn))])
CM_pearson_raw = [];
CM_pearson_raw_ar = [];
CM_pearson_res = [];
CM_pearson_res_ar = [];

CM_part_raw = [];
CM_part_raw_ar = [];
CM_part_res = [];
CM_part_res_ar = [];

DTI_components = [];
fconn_stack = [];
dconn_stack = [];

for i = 1:length(have_conn)
    load(fullfile(outfolder,have_conn{i},'T1w',have_conn{i},'dmri',[have_conn{i} '_rfMRI_conn_matrices.mat']))
    load(fullfile(outfolder,have_conn{i},'T1w',have_conn{i},'dmri',[have_conn{i} '_dsistudio.fib.gz.HCP-MMP_subcort_atlas.count.pass.connectivity.mat']))
    
    DTIcompNum = graphconncomp(sparse((connectivity+connectivity')>0));
    DTI_components(i) = DTIcompNum; 
    
    fconn_stack = cat(3,fconn_stack,r_pearson_raw);
    dconn_stack = cat(3,dconn_stack,connectivity);
    
    idx_ut = logical(triu(ones(size(connectivity)),1)); % Get upper triagular indices
    
    dconn = connectivity(idx_ut)';
%     dconn_stack = [dconn_stack ; dconn];
    
    dconn = dconn>0; % Extract upper tri as vector; binarize
    sparsity = sum(dconn);
    
    fconn = r_pearson_raw(idx_ut)'; % Extract upper tri as vector
%     fconn_stack = [fconn_stack ; fconn];
    
    [~,idx] = sort(fconn,'descend');
    fconn(idx(1:sparsity))=1;
    fconn(idx(sparsity+1:end))=0;
    cm = confusionmat(dconn,logical(fconn)); CM_pearson_raw = cat(3,CM_pearson_raw,cm);
    
    fconn = r_pearson_raw_ar(idx_ut)'; % Extract upper tri as vector
    [~,idx] = sort(fconn,'descend');
    fconn(idx(1:sparsity))=1;
    fconn(idx(sparsity+1:end))=0;
    cm = confusionmat(dconn,logical(fconn)); CM_pearson_raw_ar = cat(3,CM_pearson_raw_ar,cm);
    
    fconn = r_pearson_res(idx_ut)'; % Extract upper tri as vector
    [~,idx] = sort(fconn,'descend');
    fconn(idx(1:sparsity))=1;
    fconn(idx(sparsity+1:end))=0;
    cm = confusionmat(dconn,logical(fconn)); CM_pearson_res = cat(3,CM_pearson_res,cm);
    
    fconn = r_pearson_res_ar(idx_ut)'; % Extract upper tri as vector
    [~,idx] = sort(fconn,'descend');
    fconn(idx(1:sparsity))=1;
    fconn(idx(sparsity+1:end))=0;
    cm = confusionmat(dconn,logical(fconn)); CM_pearson_res_ar = cat(3,CM_pearson_res_ar,cm);
    
    fconn = r_part_raw(idx_ut)'; % Extract upper tri as vector
    [~,idx] = sort(fconn,'descend');
    fconn(idx(1:sparsity))=1;
    fconn(idx(sparsity+1:end))=0;
    cm = confusionmat(dconn,logical(fconn)); CM_part_raw= cat(3,CM_part_raw,cm);
    
    fconn = r_part_raw_ar(idx_ut)'; % Extract upper tri as vector
    [~,idx] = sort(fconn,'descend');
    fconn(idx(1:sparsity))=1;
    fconn(idx(sparsity+1:end))=0;
    cm = confusionmat(dconn,logical(fconn)); CM_part_raw_ar= cat(3,CM_part_raw_ar,cm);
    
    fconn = r_part_res(idx_ut)'; % Extract upper tri as vector
    [~,idx] = sort(fconn,'descend');
    fconn(idx(1:sparsity))=1;
    fconn(idx(sparsity+1:end))=0;
    cm = confusionmat(dconn,logical(fconn)); CM_part_res= cat(3,CM_part_res,cm);
    
    fconn = r_part_res_ar(idx_ut)'; % Extract upper tri as vector
    [~,idx] = sort(fconn,'descend');
    fconn(idx(1:sparsity))=1;
    fconn(idx(sparsity+1:end))=0;
    cm = confusionmat(dconn,logical(fconn)); CM_part_res_ar= cat(3,CM_part_res_ar,cm);
end

% for i = 1:26
% disp(['Sensitivity: ' num2str( CM_part_res_ar(2,2,i)/(CM_part_res_ar(2,2,i)+CM_part_res_ar(2,1,i)) ) ' Specificity: ' num2str( CM_part_res_ar(1,1,i)/(CM_part_res_ar(1,1,i)+CM_part_res_ar(1,2,i)) )])
% end

figure
subplot(2,4,1)
title('Pearson raw')
bar(  [ mean(squeeze(CM_pearson_raw(2,2,:)./(CM_pearson_raw(2,2,:)+CM_pearson_raw(2,1,:)))) mean(squeeze(CM_pearson_raw(1,1,:)./(CM_pearson_raw(1,1,:)+CM_pearson_raw(1,2,:)))) ]  )
set(gca,'XtickLabel',{'Sens','Spec'})

subplot(2,4,2)
title('Pearson raw AR')
bar(  [ mean(squeeze(CM_pearson_raw_ar(2,2,:)./(CM_pearson_raw_ar(2,2,:)+CM_pearson_raw_ar(2,1,:)))) mean(squeeze(CM_pearson_raw_ar(1,1,:)./(CM_pearson_raw_ar(1,1,:)+CM_pearson_raw_ar(1,2,:)))) ]  )
set(gca,'XtickLabel',{'Sens','Spec'})

subplot(2,4,3)
title('Pearson res')
bar(  [ mean(squeeze(CM_pearson_res(2,2,:)./(CM_pearson_res(2,2,:)+CM_pearson_res(2,1,:)))) mean(squeeze(CM_pearson_res(1,1,:)./(CM_pearson_res(1,1,:)+CM_pearson_res(1,2,:)))) ]  )
set(gca,'XtickLabel',{'Sens','Spec'})

subplot(2,4,4)
title('Pearson res AR')
bar(  [ mean(squeeze(CM_pearson_res_ar(2,2,:)./(CM_pearson_res_ar(2,2,:)+CM_pearson_res_ar(2,1,:)))) mean(squeeze(CM_pearson_res_ar(1,1,:)./(CM_pearson_res_ar(1,1,:)+CM_pearson_res_ar(1,2,:)))) ]  )
set(gca,'XtickLabel',{'Sens','Spec'})

subplot(2,4,5)
title('Partial raw')
bar(  [ mean(squeeze(CM_part_raw(2,2,:)./(CM_part_raw(2,2,:)+CM_part_raw(2,1,:)))) mean(squeeze(CM_part_raw(1,1,:)./(CM_part_raw(1,1,:)+CM_part_raw(1,2,:)))) ]  )
set(gca,'XtickLabel',{'Sens','Spec'})

subplot(2,4,6)
title('Partial raw AR')
bar(  [ mean(squeeze(CM_part_raw_ar(2,2,:)./(CM_part_raw_ar(2,2,:)+CM_part_raw_ar(2,1,:)))) mean(squeeze(CM_part_raw_ar(1,1,:)./(CM_part_raw_ar(1,1,:)+CM_part_raw_ar(1,2,:)))) ]  )
set(gca,'XtickLabel',{'Sens','Spec'})

subplot(2,4,7)
title('Partial res')
bar(  [ mean(squeeze(CM_part_res(2,2,:)./(CM_part_res(2,2,:)+CM_part_res(2,1,:)))) mean(squeeze(CM_part_res(1,1,:)./(CM_part_res(1,1,:)+CM_part_res(1,2,:)))) ]  )
set(gca,'XtickLabel',{'Sens','Spec'})

subplot(2,4,8)
title('Partial res AR')
bar(  [ mean(squeeze(CM_part_res_ar(2,2,:)./(CM_part_res_ar(2,2,:)+CM_part_res_ar(2,1,:)))) mean(squeeze(CM_part_res_ar(1,1,:)./(CM_part_res_ar(1,1,:)+CM_part_res_ar(1,2,:)))) ]  )
set(gca,'XtickLabel',{'Sens','Spec'})



% for i = 1:size(dconn_stack,3)
%     [S,C]=graphconncomp(sparse(dconn_stack(:,:,i)>0));
%     count_stack(i,:) = C;
%     counts = [];
%     for j = unique(C)
%         counts(j) = nnz(C==j);
%     end
%     if numel(counts)>1
%         disp([have_conn{i} ' component counts are : ' num2str(counts) ]);
%     end
% end