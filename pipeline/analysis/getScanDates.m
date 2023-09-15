function dcmfolder=getScanDates(subjid,outfolder)

if(nargin<2)
    outfolder='/disk/HCP/analyzed';
end

dcmfolder={};
log=rdir(fullfile(outfolder,subjid,'dicomconvert_*.log'));
cnt=1;
for i=1:length(log)
    try
        fid=fopen(log(i).name,'r');
        fgetl(fid);
        line=fgetl(fid);
        ll=strfind(line,'/');
        dcmfolder{cnt,1}=line(1:ll(7));
        cnt=cnt+1;
    end
    
end