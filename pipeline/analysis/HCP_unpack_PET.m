function HCP_unpack_PET


% f=dir('/disk/HCP/raw/PET/PETdynamic/HCP*');
% for i=1:length(f)
%     n{i}=f(i).name(1:6);
% end
% n=unique(n);
% 
% for i=1:length(n)  
%     system(['mkdir -p /disk/HCP/analyzed/' n{i} '/unprocessed/PET/dynamic']);
%     system(['rsync -vru --size-only /disk/HCP/raw/PET/PETdynamic/' n{i} '*/* /disk/HCP/analyzed/' n{i} '/unprocessed/PET/dynamic/']);
% end

n={};
f=dir('/disk/HCP/raw/PET/*.nii');
for i=1:length(f)
    n{i}=f(i).name(1:min(strfind(f(i).name,'_'))-1);
end
n=unique(n);
for i=1:length(n)
    
    
    if(HCP_blacklist(n{i}))
        continue
    end
    
    
    system(['mkdir -p /disk/HCP/analyzed/' n{i} '/unprocessed/PET']);
    system(['rsync -vru --size-only /disk/HCP/raw/PET/' n{i} '_*.nii /disk/HCP/analyzed/' n{i} '/unprocessed/PET/']);
end