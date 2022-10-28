
system('rsync -vru HCP@10.48.86.212:/sulcusdata/HCP/raw/PET/* /disk/HCP/raw/PET/needtosort/');
HCP_unpack_PET;

system('rsync -vru HCP@10.48.88.33:tmp/*/*.fif /disk/HCP/raw/MEG/unsorted');
system('ssh HCP@10.48.88.33 -f "rm -v ~/tmp/*/*.fif"');
cd /disk/HCP/raw/MEG
sortdata;

cd /disk/HCP/raw/EPRIME_MEG
sortdata;

cd /disk/HCP/raw/EPRIME_fMRI
sortdata;

cd /disk/HCP/pipeline/analysis/Xnat/;
HCP_AddAll_Xnat;


cd /aionraid/huppertt/XnatDB;
Run_All_Analysis;

cd /disk/HCP/analyzed
HCP_run_all_automated;

HCP_run_all_automated([],[3 5 7 8 9],false,true);

