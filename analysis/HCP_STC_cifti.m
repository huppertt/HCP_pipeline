function HCP_STC2_ciftvi(files,subjid,outfolder)v

% assume all the files have the same source spacev

keyword='raw_proc_';

for i=1:length(files)
    str=files(i).name;
    fldname{i}=str(strfind(str,keyword)+length(keyword):end);
    
    if(isempty(strfind( fldname{i},'-lh.stc')))
        hemi(i)=1;
    else
        hemi(i)=2;
    end
        
    fldname{i}= fldname{i}(1:[strfind( fldname{i},'-lh.stc') strfind( fldname{i},'-rh.stc')]-1);
end

stcL = mne_read_stc_file(files(min(find(hemi==1))).name);
stcR = mne_read_stc_file(files(min(find(hemi==2))).name);

folder=fileparts(files(1).name);

srcspace=rdir(fullfile(folder,'*-src.fif.gz'));
if(~isempty(srcspace))
    system(['gzip -d ' srcspace(1).name]);
end
srcspace=rdir(fullfile(folder,'*-src.fif'));
src=mne_read_source_spaces(srcspace(1).name);

template = fullfile(outfolder,subjid,'MNINonLinear',[subjid '.thickness.164k_fs_LR.dscalar.nii']);
c=ft_read_cifti(template);
c.dimord='pos_time';

c=rmfield(c,'thickness');
c.brainstructure=[ones(size(src(1).rr,1),1); 2*ones(size(src(2).rr,1),1)];
c.pos = [src(1).rr; src(2).rr];
c.tri=[src(1).use_tris; src(2).use_tris+length(src(1).rr)];

uflds=unique(fldname);
for i=1:length(uflds)
    iL = find(ismember(fldname,uflds{i}) & hemi==1);
    iR = find(ismember(fldname,uflds{i}) & hemi==2);
    stcL=mne_read_stc_file(files(iL).name);
    stcR=mne_read_stc_file(files(iR).name);
    data=zeros(length(c.pos),size(stc.data,2));
    data(stcL.vertices,:)=stcL.data;
    data(stcR.vertices+size(src(1).rr,1),:)=stcR.data;
    
    c.time = stcL.tmin+[0:size(stcL.data,2)-1]*stcL.tstep;
    
   fld=uflds{i};
   if(~isempty(strfind(fld,'_')))
   fld=[fld(max(strfind(fld,'_'))+1:end) '_' fld(1:max(strfind(fld,'_')-1))];
   fld(isspace(fld))='_';
   end
   fld(find(double(fld)<48))='_';
    ff{i}=fld;
    c=setfield(c,fld,data);
end
    