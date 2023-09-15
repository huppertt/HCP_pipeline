path(path,genpath('/home/theodore/Desktop/pipeline/analysis/'));
HCP_matlab_setenv;

setenv('FREESURFER_HOME', '/usr/local/freesurfer');
setenv('PATH', [ '/usr/local/freesurfer/bin:' getenv('PATH')]);
%setenv('LD_LIBRARY_PATH',['/usr/local/freesurfer/lib/qt/lib/:' getenv('LD_LIBRARY_PATH')]);
setenv('LD_LIBRARY_PATH','/usr/local/freesurfer/lib/qt/lib');

f={'/home/theodore/Desktop/HCP'
    '/home/theodore/Desktop/sulcus//ADRC'
    '/home/theodore/Desktop/sulcus//COHHYPER'
    '/home/theodore/Desktop/sulcus//COHPPG3'
    '/home/theodore/Desktop/sulcus//Chan-Ipah'
    '/home/theodore/Desktop/sulcus//HUP-IMB'
    '/home/theodore/Desktop/sulcus//Jessie_Gait'
    '/home/theodore/Desktop/sulcus//LOP-PROJ1'
    '/home/theodore/Desktop/sulcus//LOPPPG3'
    '/home/theodore/Desktop/sulcus//MACS'
    '/home/theodore/Desktop/sulcus//ParthaDev'
    '/home/theodore/Desktop/sulcus//R21NS102393-01'
    '/home/theodore/Desktop/sulcus//ROS-IDEA'
    '/home/theodore/Desktop/sulcus//ROS-MOVE'
    '/home/theodore/Desktop/sulcus//ROS-369'
    '/home/theodore/Desktop/sulcus//Sals-P5'
    '/home/theodore/Desktop/sulcus//NIAD'
    '/home/theodore/Desktop/sulcus//WPC-7055'
    '/home/theodore/Desktop/sulcus//BreathHold'
    '/home/theodore/Desktop/sulcus//CATOV-BRAIN'};
    
for i=length(f):-1:1
    try
        cd(f{i});
        HCP_QCreport(pwd);
        HCP_QCreportPET(pwd);
        HCP_QCreportASL(pwd);
    end
    system(['mkdir -p ' f{i} '/Summary/PDF']);
    system(['cp -v ' f{i} '/*/stats/*.pdf ' f{i} '/Summary/PDF/']);
    system(['rm ' f{i} '/Summary/PDF/PET*.pdf']);
    system(['rm ' f{i} '/Summary/PDF/ASL*.pdf']);
    
    system(['mkdir -p ' f{i} '/Summary/ASL_PDF']);
    system(['cp -v ' f{i} '/*/stats/ASL*.pdf ' f{i} '/Summary/ASL_PDF/']);
    
    system(['mkdir -p ' f{i} '/Summary/PET_PDF']);
    system(['cp -v ' f{i} '/*/stats/PET*.pdf ' f{i} '/Summary/PET_PDF/']);
    
end