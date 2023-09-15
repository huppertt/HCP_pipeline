function HCP_MakeSummary(folder,force)

if(nargin<1)
    folder = '/disk/sulcus1/COBRA';
end
if(nargin<2)
    force=false;
end

curdir=pwd;

system(['mkdir -p ' folder filesep 'Summary']);
system(['mkdir -p ' folder filesep 'Summary' filesep 'Stats']);
system(['mkdir -p ' folder filesep 'Summary' filesep 'FS_Specs']);
system(['mkdir -p ' folder filesep 'Summary' filesep 'MSMSulc_Specs']);
system(['mkdir -p ' folder filesep 'Summary' filesep 'MSMAll_Specs']);
system(['mkdir -p ' folder filesep 'Summary' filesep 'Structural_QC']);


HCP_matlab_setenv;

tbl = HCP_check_analysis([],folder);

nirs.util.write_xls(fullfile(folder,'Summary','ProgressReport.xls'),tbl);


cd(folder)
f=rdir('*/MNINonLinear//*.164k_fs_LR.wb.spec');

for i=1:length(f); 
    if(isempty(strfind(f(i).name,'MSMSulc')) & isempty(strfind(f(i).name(1),[filesep '.'])))
        link_spec(f(i).name,'Summary/FS_Specs',force);
    end
end;

f=rdir('*/MNINonLinear//*MSMSulc.164k_fs_LR.wb.spec');

for i=1:length(f); 
    if(isempty(strfind(f(i).name(1),[filesep '.'])))
        link_spec(f(i).name,'Summary/MSMSulc_Specs',force);
    end
end;


f=rdir('*/MNINonLinear//*MSMSulc.164k_fs_LR.wb.spec');

for i=1:length(f); 
    if(isempty(strfind(f(i).name(1),[filesep '.'])))
        link_spec(f(i).name,'Summary/MSMSulc_Specs',force);
    end
end;


f=rdir('*/QC/*wb.scene')

for i=1:length(f); 
    if(isempty(strfind(f(i).name(1),[filesep '.'])))
        try;
        link_scene(f(i).name,'Summary/Structural_QC',force);
        end
    end
end;


f=rdir('*/MNINonLinear/fsaverage_LR32k/*.MSMAll_AllAreasMap.scene');
for i=1:length(f); 
    if(isempty(strfind(f(i).name(1),[filesep '.'])))
        try;
            link_scene(f(i).name,'Summary/MSMAll_Specs',force);
        end;
    end
end;

cd(curdir);
HCP_Report_Summary_Stats2(folder)
 
