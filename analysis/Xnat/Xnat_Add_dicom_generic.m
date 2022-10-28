function Xnat_Add_dicom_generic(f)

for i=1:length(f)
    [~,subjid]=fileparts(f(i).name);
    Session=[subjid '_MR1'];
    Xnat_AddMRISession(subjid,Session,f(i).name,jsess,'LOP-PROJ1');
end