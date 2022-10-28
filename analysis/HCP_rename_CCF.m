function HCP_rename_CCF(folder,force)

% this function will rename a dicom folder according to the CCF naming
% convention

if(nargin<2)
    force=false;
end

if(exist(fullfile(folder,'converted.log')) && ~force)
    return
end


Rename={...
'AAHead_Scout_64ch-head-coil_160x160'   'AAHScout';...     
'AAHead_Scout_64ch-head-coil_MPR_cor'   'AAHScout_MPR_cor';...
'AAHead_Scout_64ch-head-coil_MPR_sag'   'AAHScout_MPR_sag';...
'AAHead_Scout_64ch-head-coil_MPR_tra'   'AAHScout_MPR_tra';...
'BIAS_BC_128x128'                       'BIAS_BC';...                           
'BIAS_BC_64channel'                     'BIAS_64CH';...                 
'BOLD_LANGUAGE1_AP_936x936'             'tfMRI_LANGUAGE1_AP';...                               
'BOLD_LANGUAGE1_AP_SBRef_936x936'       'tfMRI_LANGUAGE1_AP_SBRef';...    
'BOLD_LANGUAGE2_PA_936x936'             'tfMRI_LANGUAGE2_PA';...                               
'BOLD_LANGUAGE2_PA_SBRef_936x936'       'tfMRI_LANGUAGE2_PA_SBRef';...
'BOLD_WM1_AP_936x936'                   'tfMRI_WM1_AP';...                               
'BOLD_WM1_AP_SBRef_936x936'             'tfMRI_WM1_AP_SBRef';...    
'BOLD_WM2_PA_936x936'                   'tfMRI_WM2_PA';...                               
'BOLD_WM2_PA_SBRef_936x936'             'tfMRI_WM2_PA_SBRef';...
'BOLD_MOTOR1_AP_936x936'                'tfMRI_MOTOR1_AP'                    
'BOLD_MOTOR1_AP_SBRef_936x936'          'tfMRI_MOTOR1_AP_SBRef';...              
'BOLD_MOTOR2_PA_936x936'                'tfMRI_MOTOR2_PA';...                    
'BOLD_MOTOR2_PA_SBRef_936x936'          'tfMRI_MOTOR2_PA_SBRef';...  
'BOLD_REST1_AP_936x936'                 'rfMRI_REST_AP';...                      
'BOLD_REST1_AP_SBRef_936x936'           'rfMRI_REST_AP_SBRef';...             
'BOLD_REST1_PA_936x936'                 'rfMRI_REST_PA';...                   
'BOLD_REST1_PA_SBRef_936x936'           'rfMRI_REST_PA_SBRef';...                              
'BOLD_REST2_AP_936x936'                 'rfMRI_REST_AP';...                     
'BOLD_REST2_AP_SBRef_936x936'           'rfMRI_REST_AP_SBRef';...              
'BOLD_REST2_PA_936x936'                 'rfMRI_REST_PA';...                     
'BOLD_REST2_PA_SBRef_936x936'           'rfMRI_REST_PA_SBRef';...
'BOLD_REST3_AP_936x936'                 'rfMRI_REST_AP';...                      
'BOLD_REST3_AP_SBRef_936x936'           'rfMRI_REST_AP_SBRef';...             
'BOLD_REST3_PA_936x936'                 'rfMRI_REST_PA';...                   
'BOLD_REST3_PA_SBRef_936x936'           'rfMRI_REST_PA_SBRef';...                              
'BOLD_REST4_AP_936x936'                 'rfMRI_REST_AP';...                     
'BOLD_REST4_AP_SBRef_936x936'           'rfMRI_REST_AP_SBRef';...              
'BOLD_REST4_PA_936x936'                 'rfMRI_REST_PA';...                     
'BOLD_REST4_PA_SBRef_936x936'           'rfMRI_REST_PA_SBRef';...                
'SpinEchoFieldMap_AP_936x936'           'SpinEchoFieldMap_AP';...   
'SpinEchoFieldMap_PA_936x936'           'SpinEchoFieldMap_PA';...      
'dMRI_dir98_AP_1400x1400'               'DWI_dir98_AP';...   
'dMRI_dir98_AP_SBRef_1400x1400'         'DWI_dir98_AP_SBRef';...   
'dMRI_dir98_PA_1400x1400'               'DWI_dir98_PA';...
'dMRI_dir98_PA_SBRef_1400x1400'         'DWI_dir98_PA_SBRef';...
'dMRI_dir99_AP_1400x1400'               'DWI_dir99_AP';...   
'dMRI_dir99_AP_SBRef_1400x1400'         'DWI_dir99_AP_SBRef';...   
'dMRI_dir99_PA_1400x1400'               'DWI_dir99_PA';...   
'dMRI_dir99_PA_SBRef_1400x1400'         'DWI_dir99_PA_SBRef';...   
'localizer_512x512'                     'Localizer';...     
'localizer_aligned_512x512'             'Localizer_aligned';...
'T1w_MPR1_320x300'                      'T1w_MPR';...
'T2w_SPC1_320x300'                      'T2w_SPC'};

f=dir(fullfile(folder,['FieldMap_*']));
if(~isempty(f))
    for i=1:length(f)
        id(i)=str2num(f(i).name(strfind(f(i).name,'.')+1:end));
    end
    [~,i]=sort(id)
    f=f(i);
    Rename{end+1,1}=f(1).name;
    Rename{end,2}='FieldMap_Magnitude';
    if(length(f)>1)
        Rename{end+1,1}=f(2).name;
        Rename{end,2}='FieldMap_Phase';
    end
end
 
for i=1:size(Rename,1)
    f=rdir(fullfile(folder,[Rename{i,1} '*'],'MR*'));
    for j=1:length(f)
        info=dicominfo(f(j).name);
        info.SeriesDescription=Rename{i,2};
        x=dicomread(info);
        dicomwrite(x,f(j).name,info);
        disp([i j])
    end
end

system(['echo "CCF converted" >> ' fullfile(folder,'converted.log')]);