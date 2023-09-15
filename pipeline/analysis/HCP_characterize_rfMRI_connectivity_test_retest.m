
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
    if exist(fullfile(outfolder,subjids{i},'T1w',subjids{i},'dmri',[subjids{i} '_rfMRI_conn_matrices.mat']),'file') ... 
            & exist(fullfile(outfolder,subjids{i},'T1w',subjids{i},'dmri',[subjids{i} '_rfMRI_conn_matrices_d2.mat']),'file')
        have_conn = [have_conn;subjids{i}];
    end
end
disp(['Number of subjects with both day connectivity is ' num2str(length(have_conn))])

have_dti = {};
for i = 1:length(subjids)
    if exist(fullfile(outfolder,subjids{i},'T1w',subjids{i},'dmri',[subjids{i} '_dsistudio.fib.gz.HCP-MMP_subcort_atlas.count.pass.connectivity.mat']),'file')
        have_dti = [have_dti;subjids{i}];
    end
end
disp(['Number of subjects that have DTI is ' num2str(length(have_dti))])

have_conn = have_conn(ismember(have_conn,have_dti));

disp(['Number of subjects that have both is ' num2str(length(have_conn))])

CM_pearson_raw_d1 = [];
CM_pearson_raw_ar_d1 = [];
CM_pearson_res_d1 = [];
CM_pearson_res_ar_d1 = [];

CM_pearson_raw_d2 = [];
CM_pearson_raw_ar_d2 = [];
CM_pearson_res_d2 = [];
CM_pearson_res_ar_d2 = [];

DTI_components = [];
fconn_stack_d1 = [];
dconn_stack = [];
fconn_stack_d2 = [];

for i = 1:length(have_conn)
    load(fullfile(outfolder,have_conn{i},'T1w',have_conn{i},'dmri',[have_conn{i} '_rfMRI_conn_matrices.mat']))
    load(fullfile(outfolder,have_conn{i},'T1w',have_conn{i},'dmri',[have_conn{i} '_dsistudio.fib.gz.HCP-MMP_subcort_atlas.count.pass.connectivity.mat']))
    
    DTIcompNum = graphconncomp(sparse((connectivity+connectivity')>0));
    DTI_components(i) = DTIcompNum; 
    
    fconn_stack_d1 = cat(3,fconn_stack_d1,r_pearson_raw);
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
    cm = confusionmat(dconn,logical(fconn)); CM_pearson_raw_d1 = cat(3,CM_pearson_raw_d1,cm);
    
    fconn = r_pearson_raw_ar(idx_ut)'; % Extract upper tri as vector
    [~,idx] = sort(fconn,'descend');
    fconn(idx(1:sparsity))=1;
    fconn(idx(sparsity+1:end))=0;
    cm = confusionmat(dconn,logical(fconn)); CM_pearson_raw_ar_d1 = cat(3,CM_pearson_raw_ar_d1,cm);
    
    fconn = r_pearson_res(idx_ut)'; % Extract upper tri as vector
    [~,idx] = sort(fconn,'descend');
    fconn(idx(1:sparsity))=1;
    fconn(idx(sparsity+1:end))=0;
    cm = confusionmat(dconn,logical(fconn)); CM_pearson_res_d1 = cat(3,CM_pearson_res_d1,cm);
    
    fconn = r_pearson_res_ar(idx_ut)'; % Extract upper tri as vector
    [~,idx] = sort(fconn,'descend');
    fconn(idx(1:sparsity))=1;
    fconn(idx(sparsity+1:end))=0;
    cm = confusionmat(dconn,logical(fconn)); CM_pearson_res_ar_d1 = cat(3,CM_pearson_res_ar_d1,cm);
  
end



for i = 1:length(have_conn)
    load(fullfile(outfolder,have_conn{i},'T1w',have_conn{i},'dmri',[have_conn{i} '_rfMRI_conn_matrices_d2.mat']))
    load(fullfile(outfolder,have_conn{i},'T1w',have_conn{i},'dmri',[have_conn{i} '_dsistudio.fib.gz.HCP-MMP_subcort_atlas.count.pass.connectivity.mat']))
    
    
    fconn_stack_d2 = cat(3,fconn_stack_d2,r_pearson_raw);
    
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
    cm = confusionmat(dconn,logical(fconn)); CM_pearson_raw_d2 = cat(3,CM_pearson_raw_d2,cm);
    
    fconn = r_pearson_raw_ar(idx_ut)'; % Extract upper tri as vector
    [~,idx] = sort(fconn,'descend');
    fconn(idx(1:sparsity))=1;
    fconn(idx(sparsity+1:end))=0;
    cm = confusionmat(dconn,logical(fconn)); CM_pearson_raw_ar_d2 = cat(3,CM_pearson_raw_ar_d2,cm);
    
    fconn = r_pearson_res(idx_ut)'; % Extract upper tri as vector
    [~,idx] = sort(fconn,'descend');
    fconn(idx(1:sparsity))=1;
    fconn(idx(sparsity+1:end))=0;
    cm = confusionmat(dconn,logical(fconn)); CM_pearson_res_d2 = cat(3,CM_pearson_res_d2,cm);
    
    fconn = r_pearson_res_ar(idx_ut)'; % Extract upper tri as vector
    [~,idx] = sort(fconn,'descend');
    fconn(idx(1:sparsity))=1;
    fconn(idx(sparsity+1:end))=0;
    cm = confusionmat(dconn,logical(fconn)); CM_pearson_res_ar_d2 = cat(3,CM_pearson_res_ar_d2,cm);
    

end



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