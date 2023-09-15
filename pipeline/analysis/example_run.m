% outfolder='/disk/NIRS/HCP/data';
% dicomfolder='/disk/NIRS/HCP/raw/mri/2014.12.15-11.48.36/14.12.15-11:48:34-STD-1.3.12.2.1107.5.2.32.35217/';
% subjid='Testing_1';
%  HCP_unpack_data(subjid,dicomfolder,outfolder)

% This function will unpack the entire HCP data/dcm directory into the
% right folders
tbl = HCP_unpack_data(subjid,dicomfolder,outfolder);

% This version supports other data that only has an MPRAGE 
info=HCP_convert_mprage(dicomfolder,subjid,outfolder);

% Once the data is unpacked, this will run the sMRI analysis
tbl=HCP_sMRI_analysis(subjid,outfolder)

% Or this will run all the subjects at once via slurm
d=dir;
cmd={}; 
cnt=1; 
for i=1:length(d); 
    if(d(i).isdir); 
        cmd{cnt}=['HCP_sMRI_analysis(''' d(i).name ''',''/disk/NIRS/R01/analyzed'')']; 
        cnt=cnt+1; 
    end;
end

% This function runs a series of commands (cellstr format) using "matlab -r
% <cmd>" submits on slurm
matlab2slurm(cmd);
