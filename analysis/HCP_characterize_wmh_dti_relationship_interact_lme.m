% Run HCP_characterize_connectivity_alldays.m first

% idx_sc = zeros(372);
% idx_sc(361:end,:) = 1;
% idx_sc(:,361:end) = 1;
% idx_sc = logical(idx_sc);
% idx_sc = logical(idx_sc.*idx_ut);
idx_ut = logical(triu(ones(size(dconn_stack,1)),1));

numSubj = size(fconn_stack_all_raw,3);
numEdge = sum(idx_ut(:));

beta_WMH = nan(numEdge,1);
beta_DTI = nan(numEdge,1);
beta_DW = nan(numEdge,1);
se_WMH = nan(numEdge,1);
se_DTI = nan(numEdge,1);
se_DW = nan(numEdge,1);
t_WMH = nan(numEdge,1);
t_DTI = nan(numEdge,1);
t_DW = nan(numEdge,1);
p_WMH = nan(numEdge,1);
p_DTI = nan(numEdge,1);
p_DW = nan(numEdge,1);
frac_WMH = nan(numEdge,1);
frac_DTI = nan(numEdge,1);

% Why are there NaNs in WMH matrices?
wmh_stack(isnan(wmh_stack)) = 0;

% Extract subj-by-edge wmh, dti, and fc
fc = []; dti = []; wmh = [];
for i = 1:numSubj
    f = atanh(fconn_stack_all_raw_ar(:,:,i));
    d = dconn_stack(:,:,i);
    w = wmh_stack(:,:,i);
    fc = [fc ; f(idx_ut)'];
    dti = [dti ; d(idx_ut)'];
    wmh = [wmh ; w(idx_ut)'];
end
wmh_burden = nanmean(wmh,2);

for i = 1:numEdge
    y = fc(:,i);
    x = [ dti(:,i) wmh(:,i)];
    clear X
    X.F = y(:,1) ; X.D = x(:,1) ; X.W = x(:,2); X.Wgroup = 1+[wmh_burden>nanmedian(wmh_burden)];
    X =struct2table(X);
    if rank([X.D X.W X.W.*X.D X.Wgroup]) == 4   % & sum(x(:,1)>0)>0.0*length(y) & sum(x(:,2)>0)>0.2*length(y)
        mdl = fitlme(X,'F~D+W+D*W+(1|Wgroup)');
        beta_WMH(i) = mdl.Coefficients.Estimate(3);
        beta_DTI(i) = mdl.Coefficients.Estimate(2);
        beta_DW(i) = mdl.Coefficients.Estimate(4);
        frac_WMH(i) = sum(x(:,2)>0) / length(y);
        frac_DTI(i) = sum(x(:,1)>0) / length(y);
        t_WMH(i) = mdl.Coefficients.tStat(3);
        t_DTI(i) = mdl.Coefficients.tStat(2);
        t_DW(i) = mdl.Coefficients.tStat(4);
        p_WMH(i) = mdl.Coefficients.pValue(3);
        p_DTI(i) = mdl.Coefficients.pValue(2);
        p_DW(i) = mdl.Coefficients.pValue(4);
        se_WMH(i) = mdl.Coefficients.SE(3);
        se_DTI(i) = mdl.Coefficients.SE(2);
        se_DW(i) = mdl.Coefficients.SE(4);
        disp([num2str(i) ' of ' num2str(numEdge) ' completed.' ])
    else
        disp([num2str(i) ' of ' num2str(numEdge) ' skipped.' ])

    end
end


p_mat_DTI = triu(ones(size(d)),1);
p_mat_DTI(p_mat_DTI==1)=p_DTI;
p_mat_DTI = p_mat_DTI + p_mat_DTI';
frac_mat_DTI = triu(ones(size(d)),1);
frac_mat_DTI(frac_mat_DTI==1)=frac_DTI;
frac_mat_DTI = frac_mat_DTI + frac_mat_DTI';

p_mat_WMH = triu(ones(size(d)),1);
p_mat_WMH(p_mat_WMH==1)=p_WMH;
p_mat_WMH = p_mat_WMH + p_mat_WMH';
frac_mat_WMH = triu(ones(size(d)),1);
frac_mat_WMH(frac_mat_WMH==1)=frac_WMH;
frac_mat_WMH = frac_mat_WMH + frac_mat_WMH';

