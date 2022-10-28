a=ft_read_cifti('BOLD_REST1_Atlas_MSMSulc_prepared.dtseries.nii');

lst=find(~all(isnan(a.dtseries),2) & ~all(a.dtseries==0,2));
[yfilt,f] = nirs.math.innovations(a.dtseries(lst,:)',10,true);

[r,p]=corrcoef(single(yfilt));