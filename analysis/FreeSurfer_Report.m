function rpt = FreeSurfer_Report(folder,subjid,type)

switch(type)
    case('T1')
        file=fullfile(folder,subjid,'T1w','T1w.nii.gz');
        a=load_untouch_nii(file);
        str=['-v ' file];
        ff='T1W';
    case('recon');
         file=fullfile(folder,subjid,'T1w','T1w.nii.gz');
         a=[];
         a.img=zeros(256,256,256);
         setenv('SUBJECTS_DIR',fullfile(folder,subjid,'T1w'));
         str=['-recon ' subjid];
         ff='RECON';
    case('T2')
         file=fullfile(folder,subjid,'T2w','T2w.nii.gz');
        a=load_untouch_nii(file);
        str=['-v ' file];
        ff='T2W';
    case('PET')
        file=fullfile(folder,subjid,'PET','PiB_acpc_restore.nii.gz');
        a=load_untouch_nii(file);
        str=['-v ' file ':colormap=pet -f ' folder '/' subjid '/T1w/' subjid '/surf/lh.pial ' folder '/' subjid '/T1w/' subjid '/surf/rh.pial'];
        ff='PET';
    otherwise
        str=type;
        file=fullfile(folder,subjid,str,[str '_flow_nonlin.nii.gz']);
        a=load_untouch_nii(file);
        str=['-v ' file ':colormap=jet -f ' folder '/' subjid '/T1w/' subjid '/surf/lh.pial ' folder '/' subjid '/T1w/' subjid '/surf/rh.pial'];
        ff='ASL';
        
        
end

system('rm -rf freeviewcmd.txt');
fid=fopen('freeviewcmd.txt','w+');
for i=1:10:size(a.img,1);
    fprintf(fid,' -viewport sagittal -layout 1 -slice %d %d %d -ss %s -noquit \n',i,round(size(a.img,2)/2),round(size(a.img,3)/2),[ff '_SAG_' num2str(i) '.png']);
end
fprintf(fid,' -quit');
fclose(fid);
system(['freeview ' str ' -cmd freeviewcmd.txt']);

if(strcmp(type,'recon'))
system('rm -rf freeviewcmd.txt');
fid=fopen('freeviewcmd.txt','w+');
for i=1:10:size(a.img,1)
    fprintf(fid,' -viewport coronal -layout 1 -slice %d %d %d -ss %s -noquit \n',round(size(a.img,1)/2),round(size(a.img,3)/2),i,[ff '_COR_' num2str(i) '.png']);
end
fprintf(fid,' -quit');
fclose(fid);
system(['freeview ' str ' -cmd freeviewcmd.txt']);

system('rm -rf freeviewcmd.txt');
fid=fopen('freeviewcmd.txt','w+');
for i=1:10:size(a.img,3);
    fprintf(fid,' -viewport axial -layout 1 -slice %d %d %d -ss %s -noquit \n',round(size(a.img,1)/2),i,round(size(a.img,2)/2),[ff '_AXIAL_' num2str(i) '.png']);
end
fprintf(fid,' -quit');
fclose(fid);
system(['freeview ' str ' -cmd freeviewcmd.txt ']);
else
    
    system('rm -rf freeviewcmd.txt');
    fid=fopen('freeviewcmd.txt','w+');
for i=1:10:size(a.img,2);
    fprintf(fid,' -viewport coronal -layout 1 -slice %d %d %d -ss %s -noquit \n',round(size(a.img,1)/2),i,round(size(a.img,3)/2),[ff '_COR_' num2str(i) '.png']);
end
fprintf(fid,' -quit');
fclose(fid);
system(['freeview ' str ' -cmd freeviewcmd.txt']);

system('rm -rf freeviewcmd.txt');
fid=fopen('freeviewcmd.txt','w+');
for i=1:10:size(a.img,3);
    fprintf(fid,' -viewport axial -layout 1 -slice %d %d %d -ss %s -noquit \n',round(size(a.img,1)/2),round(size(a.img,2)/2),i,[ff '_AXIAL_' num2str(i) '.png']);
end
fprintf(fid,' -quit');
fclose(fid);
system(['freeview ' str ' -cmd freeviewcmd.txt ']);
end

system(['mkdir -p ' fullfile(folder,subjid,'images')]);
system(['mv -f *.png ' fullfile(folder,subjid,'images')]);


f=rdir(fullfile(folder,subjid,'images',[ff '*.png']))

rpt = rptgen.cfr_section('SectionTitle',['sMRI ' subjid ' Report ' type]);
n=.8*7;

for i=1:length(f)
    X(1,i)=rptgen.cfr_image('MaxViewportSize',[n n],...
    'ViewportSize',[n n],...
    'ViewportType','fixed',...
    'DocHorizAlign','center');
    X(1,i).FileName=f(i).name;
    [~,ff2]=fileparts(f(i).name);
    X(1,i).Title=ff2;
    X(1,i).Caption=ff2;
end

cfr_table=nirs.util.reporttable(array2table(X'));

cfr_section4 = rptgen.cfr_section('SectionTitle','Channel Statistics');
setParent( cfr_table, cfr_section4);
setParent(cfr_section4,rpt);

