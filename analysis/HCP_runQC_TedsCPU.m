path(path,'/disk/HCP/pipeline/analysis/');
HCP_matlab_setenv;
setenv('FREESURFER_HOME','/Applications/freesurfer');
setenv('PATH',['/Applications/freesurfer/bin/:' getenv('PATH')]);


f={'/disk/HCP/analyzed'
    '/disk/sulcus//ADRC'
    '/disk/sulcus//COHHYPER'
    '/disk/sulcus//COHPPG3'
    '/disk/sulcus//Chan-Ipah'
    '/disk/sulcus//HUP-IMB'
    '/disk/sulcus//Jessie_Gait'
    '/disk/sulcus//LOP-PROJ1'
    '/disk/sulcus//LOPPPG3'
    '/disk/sulcus//MACS'
    '/disk/sulcus//ParthaDev'
    '/disk/sulcus//R21NS102393-01'
    '/disk/sulcus//ROS-IDEA'
    '/disk/sulcus//ROS-MOVE'
    '/disk/sulcus//Sals-P5'
    '/disk/sulcus//NIAD'
    '/disk/sulcus//WPC-7055'
    '/disk/sulcus//BreathHold'};
    
for i=1:length(f)
    try
        cd(f{i});
        HCP_QCreport(pwd);
        HCP_QCreportPET(pwd);
        HCP_QCreportASL(pwd);
    end
end

for i=1:length(f)
    system(['mkdir -p ' f{i} '/Summary/PDF']);
    system(['cp -v ' f{i} '/*/stats/*.pdf ' f{i} '/Summary/PDF/']);
    system(['rm ' f{i} '/Summary/PDF/PET*.pdf']);
    system(['rm ' f{i} '/Summary/PDF/ASL*.pdf']);
    
    system(['mkdir -p ' f{i} '/Summary/ASL_PDF']);
    system(['cp -v ' f{i} '/*/stats/ASL*.pdf ' f{i} '/Summary/ASL_PDF/']);
    
    system(['mkdir -p ' f{i} '/Summary/PET_PDF']);
    system(['cp -v ' f{i} '/*/stats/PET*.pdf ' f{i} '/Summary/PET_PDF/']);
    
end