function HCP_Add_MRI_XNAT(id)

subjid=['HCP' num2str(id)];

[~,jsess]=system('./CreateXnatJess.sh');
jsess=jsess(end-32:end);
jsess(double(jsess)==10)=[];


for j=1:2;
    Session=[subjid '_MR' num2str(j)];
    
    if(j==1)
        dcm=rdir(['/disk/HCP/raw/MRI/*/',num2str(id) '/BOLD_REST1*']);
    else
        dcm=rdir(['/disk/HCP/raw/MRI/*/',num2str(id) '/BOLD_REST3*']);
    end
    if(~isempty(dcm))
        dcm=fileparts(dcm(1).name);
        Xnat_AddMRISession(subjid,Session,dcm,jsess);
    end
end;