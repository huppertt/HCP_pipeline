function HCP_runall(subjid,stage,outfolder,force,HCProot)

HCP_matlab_setenv;

if(nargin<5)
    HCProot='/disk/HCP';
end
if(nargin<3 || isempty(outfolder))
    outfolder=fullfile(HCProot,'analyzed');
end


if(exist(fullfile(outfolder,subjid,'skip_processing.log')))
    a=importdata(fullfile(outfolder,subjid,'skip_processing.log'));
    if(~isempty(strfind(a,'*')) | ~isempty(strfind(s,num2str(state))))
    disp(['skipping ' subjid ' STAGE-' num2str(stage)]);
    end
end



if(nargin<4)
    force=false;
end

if(~exist(fullfile(outfolder,subjid)))
    mkdir(fullfile(outfolder,subjid));
end

if(~exist(fullfile(outfolder,subjid,'scripts')))
    mkdir(fullfile(outfolder,subjid,'scripts'));
end

switch(stage)
    case(0)
        disp('unpacking dicom data');
        disp(subjid);
        % Find the DICOM folder(s)
        f=rdir(fullfile(HCProot,'raw','MRI','*',subjid(4:end)));
        if(isempty(f))
            f=rdir(fullfile(HCProot,'raw','MRI','*',subjid));
        end
        dicomfolder=[];
        for i=1:length(f); dicomfolder{i}=fileparts(f(i).name); end;
        dicomfolder=unique(dicomfolder);
        if(length(dicomfolder)==0)
            disp('no dicom folders found');
        end
        for i=1:length(dicomfolder)
            disp(dicomfolder{i});
            try
                tbl=HCP_unpack_data(subjid,dicomfolder{i},outfolder);
                writetable(tbl,fullfile(outfolder,subjid,'scripts',['dicomconvert_' tbl.AcquisitionDate{1} '.log']),'FileType','text');
                str=['HCP_unpack_data(''' subjid ''',''' dicomfolder{i} ''',''' outfolder ''');'];
                system(['echo "' str '">> ' fullfile(outfolder,subjid,'scripts','processing.log')]);
            catch
                str=['FAILED: ' lasterr ' HCP_unpack_data(''' subjid ''',''' dicomfolder{i} ''',''' outfolder ''');'];
                str(strfind(str,'"'))=' ';
                system(['echo "' str '">> ' fullfile(outfolder,subjid,'scripts','processing.log')]);
            end
        end
        try
            HCP_unpack_MEG(subjid,outfolder);
            str=['HCP_unpack_MEG(''' subjid ''',''' outfolder ''');'];
            system(['echo "' str '">> ' fullfile(outfolder,subjid,'scripts','processing.log')]);
        catch
            str=['FAILED: ' lasterr ' HCP_unpack_MEG(''' subjid ''',''' outfolder ''');'];
            str(strfind(str,'"'))=' ';
            system(['echo "' str '">> ' fullfile(outfolder,subjid,'scripts','processing.log')]);
        end
        
        %% TODO - Unpack physiology files  // HCP_transfer_mri_physiol.m
        
        
    case(1.1)
        % Run sMRI analysis (infant version)
        try
            HCP_sMRI_analysis(subjid,outfolder,force,true);
            str=['HCP_sMRI_analysis(''' subjid ''',''' outfolder ''');'];
            system(['echo "' str '">> ' fullfile(outfolder,subjid,'scripts','processing.log')]);
        catch
            str=['FAILED: ' lasterr ' HCP_sMRI_analysis(''' subjid ''',''' outfolder ''');'];
            str(strfind(str,'"'))=' ';
            system(['echo "' str '">> ' fullfile(outfolder,subjid,'scripts','processing.log')]);
        end
        try
            HCP_subcortical(subjid,outfolder);
            str=['HCP_subcortical(''' subjid ''',''' outfolder ''');'];
            system(['echo "' str '">> ' fullfile(outfolder,subjid,'scripts','processing.log')]);
        catch
            str=['FAILED: ' lasterr ' HCP_subcortical(''' subjid ''',''' outfolder ''');'];
            str(strfind(str,'"'))=' ';
            system(['echo "' str '">> ' fullfile(outfolder,subjid,'scripts','processing.log')]);
        end
        try
            HCP_compute_scalp_distance(subjid,outfolder);
            HCP_makeIso2Mesh(subjid,outfolder);
            HCP_Label_1020(subjid,outfolder);
            
        end
            case(1.2)
       
        try
            HCP_subcortical(subjid,outfolder);
            str=['HCP_subcortical(''' subjid ''',''' outfolder ''');'];
            system(['echo "' str '">> ' fullfile(outfolder,subjid,'scripts','processing.log')]);
        catch
            str=['FAILED: ' lasterr ' HCP_subcortical(''' subjid ''',''' outfolder ''');'];
            str(strfind(str,'"'))=' ';
            system(['echo "' str '">> ' fullfile(outfolder,subjid,'scripts','processing.log')]);
        end
        try
            HCP_compute_scalp_distance(subjid,outfolder);
            HCP_makeIso2Mesh(subjid,outfolder);
            HCP_Label_1020(subjid,outfolder);
            
        end
    case(1)
        % Run sMRI analysis
        try
            HCP_sMRI_analysis(subjid,outfolder,force);
            str=['HCP_sMRI_analysis(''' subjid ''',''' outfolder ''');'];
            system(['echo "' str '">> ' fullfile(outfolder,subjid,'scripts','processing.log')]);
        catch
            str=['FAILED: ' lasterr ' HCP_sMRI_analysis(''' subjid ''',''' outfolder ''');'];
            str(strfind(str,'"'))=' ';
            system(['echo "' str '">> ' fullfile(outfolder,subjid,'scripts','processing.log')]);
        end
        try
            HCP_subcortical(subjid,outfolder);
            str=['HCP_subcortical(''' subjid ''',''' outfolder ''');'];
            system(['echo "' str '">> ' fullfile(outfolder,subjid,'scripts','processing.log')]);
        catch
            str=['FAILED: ' lasterr ' HCP_subcortical(''' subjid ''',''' outfolder ''');'];
            str(strfind(str,'"'))=' ';
            system(['echo "' str '">> ' fullfile(outfolder,subjid,'scripts','processing.log')]);
        end
        try
            HCP_compute_scalp_distance(subjid,outfolder);
            HCP_makeIso2Mesh(subjid,outfolder);
            HCP_Label_1020(subjid,outfolder);
            
        end
    case(-1)
        % Run sMRI analysis (MP2RAGE version)
        try
            HCP_sMRI_mp2rage_analysis(subjid,outfolder);
            str=['HCP_sMRI_mp2rage_analysis(''' subjid ''',''' outfolder ''');'];
            system(['echo "' str '">> ' fullfile(outfolder,subjid,'scripts','processing.log')]);
        catch
            str=['FAILED: ' lasterr ' HCP_sMRI_mp2rage_analysis(''' subjid ''',''' outfolder ''');'];
            str(strfind(str,'"'))=' ';
            system(['echo "' str '">> ' fullfile(outfolder,subjid,'scripts','processing.log')]);
        end
        try
            HCP_subcortical(subjid,outfolder);
            str=['HCP_subcortical(''' subjid ''',''' outfolder ''');'];
            system(['echo "' str '">> ' fullfile(outfolder,subjid,'scripts','processing.log')]);
        catch
            str=['FAILED: ' lasterr ' HCP_subcortical(''' subjid ''',''' outfolder ''');'];
            str(strfind(str,'"'))=' ';
            system(['echo "' str '">> ' fullfile(outfolder,subjid,'scripts','processing.log')]);
        end
    case(2)
        % Diffusion analysis
        try
            HCP_DTI_analysis(subjid,outfolder);
            str=['HCP_DTI_analysis(''' subjid ''',''' outfolder ''');'];
            system(['echo "' str '">> ' fullfile(outfolder,subjid,'scripts','processing.log')]);
        catch
            str=['FAILED: ' lasterr ' HCP_DTI_analysis(''' subjid ''',''' outfolder ''');'];
            str(strfind(str,'"'))=' ';
            system(['echo "' str '">> ' fullfile(outfolder,subjid,'scripts','processing.log')]);
        end
        
        %% TODO - DSI studio analysis
    case(3)
        % fMRI analysis
        try
            HCP_fMRI_analysis(subjid,outfolder,false,force);
            str=['HCP_fMRI_analysis(''' subjid ''',''' outfolder ''',false);'];
            system(['echo "' str '">> ' fullfile(outfolder,subjid,'scripts','processing.log')]);
        catch
            str=['FAILED: ' lasterr ' HCP_fMRI_analysis(''' subjid ''',''' outfolder ''',false);'];
            str(strfind(str,'"'))=' ';
            system(['echo "' str '">> ' fullfile(outfolder,subjid,'scripts','processing.log')]);
                        end
                        try
                            HCP_fMRI_surface_analysis(subjid,outfolder,false);
                            str=['HCP_fMRI_surface_analysis(''' subjid ''',''' outfolder ''',false);'];
                            system(['echo "' str '">> ' fullfile(outfolder,subjid,'scripts','processing.log')]);
                        catch
                            str=['FAILED: ' lasterr ' HCP_fMRI_surface_analysis(''' subjid ''',''' outfolder ''',false);'];
                            str(strfind(str,'"'))=' ';
                            system(['echo "' str '">> ' fullfile(outfolder,subjid,'scripts','processing.log')]);
                        end
                    case(-3)
                         % fMRI analysis
                        try
                            HCP_fMRI_ME_analysis(subjid,outfolder,false);
                            str=['HCP_fMRI_analysis(''' subjid ''',''' outfolder ''',false);'];
                            system(['echo "' str '">> ' fullfile(outfolder,subjid,'scripts','processing.log')]);
                        catch
                            str=['FAILED: ' lasterr ' HCP_fMRI_analysis(''' subjid ''',''' outfolder ''',false);'];
                            str(strfind(str,'"'))=' ';
                            system(['echo "' str '">> ' fullfile(outfolder,subjid,'scripts','processing.log')]);
                        end
                        try
                            HCP_fMRI_surface_analysis(subjid,outfolder,false);
                            str=['HCP_fMRI_surface_analysis(''' subjid ''',''' outfolder ''',false);'];
                            system(['echo "' str '">> ' fullfile(outfolder,subjid,'scripts','processing.log')]);
                        catch
                            str=['FAILED: ' lasterr ' HCP_fMRI_surface_analysis(''' subjid ''',''' outfolder ''',false);'];
                            str(strfind(str,'"'))=' ';
                            system(['echo "' str '">> ' fullfile(outfolder,subjid,'scripts','processing.log')]);
                        end
                    case(4)
                        try
                            HCP_resting_state(subjid,outfolder,false);
                            str=['HCP_resting_state(''' subjid ''',''' outfolder ''',false);'];
                            system(['echo "' str '">> ' fullfile(outfolder,subjid,'scripts','processing.log')]);
                        catch
                            str=['FAILED: ' lasterr ' HCP_resting_state(''' subjid ''',''' outfolder ''',false);'];
                            str(strfind(str,'"'))=' ';
                            system(['echo "' str '">> ' fullfile(outfolder,subjid,'scripts','processing.log')]);
                        end
                        try
                            HCP_MSM(subjid,outfolder);
                            str=[' HCP_MSM(''' subjid ''',''' outfolder ''');'];
                            system(['echo "' str '">> ' fullfile(outfolder,subjid,'scripts','processing.log')]);
                        catch
                            str=['FAILED: ' lasterr ' HCP_MSM(''' subjid ''',''' outfolder ''');'];
                            str(strfind(str,'"'))=' ';
                            system(['echo "' str '">> ' fullfile(outfolder,subjid,'scripts','processing.log')]);
                        end
                    case(5)

                        try
                            HCP_ASL_analysis(subjid,outfolder,false);
                            str=['HCP_ASL_analysis(''' subjid ''',''' outfolder ''');'];
                            system(['echo "' str '">> ' fullfile(outfolder,subjid,'scripts','processing.log')]);
                        catch
                            str=['FAILED: ' lasterr ' HCP_ASL_analysis(''' subjid ''',''' outfolder ''');'];
                            str(strfind(str,'"'))=' ';
            system(['echo "' str '">> ' fullfile(outfolder,subjid,'scripts','processing.log')]);
        end
        try
           HCP_SWI_registration(subjid,outfolder);
            str=['HCP_SWI_registration(''' subjid ''',''' outfolder ''');'];
            system(['echo "' str '">> ' fullfile(outfolder,subjid,'scripts','processing.log')]);
        catch
            str=['FAILED: ' lasterr ' HCP_SWI_registration(''' subjid ''',''' outfolder ''');'];
            str(strfind(str,'"'))=' ';
            system(['echo "' str '">> ' fullfile(outfolder,subjid,'scripts','processing.log')]);
        end
        try
            HCP_FLAIR_registration(subjid,outfolder);
            str=['HCP_FLAIR_registration(''' subjid ''',''' outfolder ''');'];
            system(['echo "' str '">> ' fullfile(outfolder,subjid,'scripts','processing.log')]);
        catch
            str=['FAILED: ' lasterr ' HCP_FLAIR_registration(''' subjid ''',''' outfolder ''');'];
            str(strfind(str,'"'))=' ';
            system(['echo "' str '">> ' fullfile(outfolder,subjid,'scripts','processing.log')]);
        end
%         try
%             HCP_RegisterStructurals(subjid,outfolder);
%             str=['HCP_RegisterStructurals(''' subjid ''',''' outfolder ''');'];
%             system(['echo "' str '">> ' fullfile(outfolder,subjid,'scripts','processing.log')]);
%         catch
%             str=['FAILED: ' lasterr ' HCP_RegisterStructurals(''' subjid ''',''' outfolder ''');'];
%             str(strfind(str,'"'))=' ';
%             system(['echo "' str '">> ' fullfile(outfolder,subjid,'scripts','processing.log')]);
%         end
    case(6)
        try
            HCP_fMRI_afni(subjid,outfolder,false);
            str=['HCP_fMRI_afni(''' subjid ''',''' outfolder ''',false);'];
            system(['echo "' str '">> ' fullfile(outfolder,subjid,'scripts','processing.log')]);
        catch
            str=['FAILED: ' lasterr ' HCP_fMRI_afni(''' subjid ''',''' outfolder ''',false);'];
            str(strfind(str,'"'))=' ';
            system(['echo "' str '">> ' fullfile(outfolder,subjid,'scripts','processing.log')]);
        end
        try
            HCP_fMRI_fsl(subjid,outfolder,false);
            str=['HCP_fMRI_fsl(''' subjid ''',''' outfolder ''',false);'];
            system(['echo "' str '">> ' fullfile(outfolder,subjid,'scripts','processing.log')]);
        catch
            str=['FAILED: ' lasterr ' HCP_fMRI_fsl(''' subjid ''',''' outfolder ''',false);'];
            str(strfind(str,'"'))=' ';
            system(['echo "' str '">> ' fullfile(outfolder,subjid,'scripts','processing.log')]);
        end
    case(7)
        %PET analysis
        try
            HCP_PET_analysis(subjid,outfolder);
            str=['HCP_PET_analysis(''' subjid ''',''' outfolder ''');'];
            system(['echo "' str '">> ' fullfile(outfolder,subjid,'scripts','processing.log')]);
        catch
            str=['FAILED: ' lasterr ' HCP_PET_analysis(''' subjid ''',''' outfolder ''');'];
            str(strfind(str,'"'))=' ';
            system(['echo "' str '">> ' fullfile(outfolder,subjid,'scripts','processing.log')]);
        end
    case(8)
        % connectivity analysis
        try
            HCP_MEG_preprocessing(subjid,outfolder,5,force);
        end
        try
            HCP_resample_dtseries2wavelets(subjid,5,outfolder);
        end
        try;
             HCP_MEG_makeFreqBands(subjid,outfolder);
        end
        try
           HCP_make_dconn_fMRI(subjid,outfolder);
        end
        try
        %   HCP_make_dconn_MEG(subjid,outfolder);
        end
    case(9)
            try; HCP_makeMNIsourcespace(subjid,5,outfolder); end;
            try; HCP_compute_scalp_distance(subjid,outfolder); end;
            try; HCP_makeIso2Mesh(subjid,outfolder); end;  % this fails if no mmclab on computer
            try; HCP_add_BEM_models(subjid,outfolder);  end;
            try; HCP_Label_1020(subjid,outfolder); end;
            try; HCP2nirsBEM(subjid,outfolder); end;
            
end

% system(['chmod -R 777 ' fullfile(outfolder,subjid)]);