function HCP_Add_MRIQC_XNAT(jsess)


f=[rdir('/disk/mace2/scan_data/homeless/ABCD^*/*/*/ABCD_QA*'); ...
    rdir('/disk/mace2/scan_data/homeless/ABCD^*/*/*/abcd_qa*')];
for i=1:length(f)
    n=f(i).name;
    [n,~]=fileparts(n);
    n=n(1:max(strfind(n,filesep))-1);
    system(['rsync -vru --size-only ' n ' /disk/HCP/raw/QA']);
end

if(nargin<1)

[~,jsess]=system('./CreateXnatJess.sh');
jsess=jsess(end-32:end);
jsess(double(jsess)==10)=[];

end
tbl = Xnat_get_SessionInfo(jsess);
tbl=tbl(ismember(tbl.project,'MRRC_QA'),:);


qa=dir('/disk/HCP/raw/QA/2*');
qa(1)=[];

for i=length(qa):-1:1;
    subjid=qa(i).name;
    subjid(strfind(subjid,'.'))='-';
    if(~ismember(subjid,tbl.SubjID))
        dcm=[rdir(fullfile('/disk/HCP/raw/QA/',qa(i).name,'abcd*'));...
            rdir(fullfile('/disk/HCP/raw/QA/',qa(i).name,'ABCD*'))];
        if(length(dcm)>0)
            Session=[subjid '_QA'];
            try
                Xnat_AddMRISession(subjid,Session,dcm(1).name,jsess,'MRRC_QA',false);
            end
        end
    end
end;
 
% qa=rdir('/disk/HCP/raw/QA/2*');
% for i=1:length(qa); 
%     p=['/disk/HCP/analyzed/QC/' qa(i).name]; 
%     if(~exist(p,'dir')); system(['mkdir -p ' p]); 
%         system(['dcm2nii -4 y -g y -d n -e n ' qa(i).name]); 
%         system(['mv -v ' qa(i).name '/*.nii.gz ' p]); 
%         system(['mv -v ' qa(i).name '/*.bv* ' p]); 
%     end; 
% end;