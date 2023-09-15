function cfr_section = HCP_QA_report_MEG(folder,subjid,type)

if(nargin<2)
    type='raw';
end


ff=rdir(fullfile(folder,subjid,'MEG*'));

cfr_section = rptgen.cfr_section('SectionTitle',type);
cnt=1;

for i=1:length(ff);
    
    f=rdir(fullfile(ff(i).name,['*-' type '.fif']));
    [~,pp]=fileparts(f.name);
    rpt2(cnt) = local_QA_report_MEG(folder,f,subjid,[pp '_' type]);
   
    cfr_section1(cnt) = rptgen.cfr_section('SectionTitle',[type ' ' pp]);
    setParent(rpt2(cnt),cfr_section1(cnt));
    setParent(cfr_section1(cnt),cfr_section);
    cnt=cnt+1;
end

end


    
function rpt=local_QA_report_MEG(folder,f,subjid,type);
        
    

[~,file]=fileparts(f.name);

d=eeg.io.loadFiff(f.name);

s=sqrt(median(var(d.data,[],1)));

fig=figure; hold on;
for i=1:size(d.data,2);
    l(i)=plot(d.time,d.data(:,i)-i*s);
end

set(l,'Linewidth',1,'color','k');

s=zscore(sqrt(var(d.data,[],1)));
set(l(find(abs(s)>2)),'color','r');
axis tight

set(gca,'Fontsize',14);
set(gcf,'color','w');

fn={}; cnt=1;
for i=60:60:d.time(end);
    fn{cnt}=[type '_MEG_time' num2str(i-60) '-' num2str(i) '.png'];
    set(gca,'Xlim',[i-60 i])
    saveas(gcf,fn{cnt});
    cnt=cnt+1;
end
close(fig);

vrange=[min(s) max(s)];
[~,cmap] = evalc('flipud( cbrewer(''div'',''RdBu'',2001) )');
z = linspace(vrange(1), vrange(2), size(cmap,1))';

idx = bsxfun(@minus, s, z);
[~, idx] = min(abs(idx), [], 1);

colors = cmap(idx, :);
d.probe.draw(colors)
    
saveas(gcf,[type '_SNRMap.png']);

f=rdir(fullfile(folder,subjid,'/T1w/*/bem/*-head-dense.fif'));
src=mne_read_bem_surfaces(f.name);

figure; hold on;
s=scatter3(d.probe.electrodes.X,d.probe.electrodes.Y,d.probe.electrodes.Z);
h=nirs.util.plotmesh(src.rr*1000,src.tris);
set(gcf,'color','w');

view(180,20)
nirs.util.lightsurface;
saveas(gcf,'Reg1.png');


view(90,0)
nirs.util.lightsurface;
saveas(gcf,'Reg2.png');

view(180,90)
nirs.util.lightsurface;
saveas(gcf,'Reg3.png');

close all;

warning('off','signal:psd:PSDisObsolete');
figure; hold on;
for i=1:size(d.data,2);
    psd(d.data(:,i));
end

l=get(gca,'children');
set(l,'Linewidth',1,'color','k');
axis tight
set(gca,'XtickLabel',num2str(cellfun(@(x)str2num(x),get(gca,'XtickLabel'))*d.Fs/2));

saveas(gcf,[ type 'PSD.png']);

close all;

rpt = rptgen.cfr_section('SectionTitle',['MEG Report ' file]);

n=.8*7;


for i=1:length(fn)
    X(1,i)=rptgen.cfr_image('MaxViewportSize',[n n],...
    'ViewportSize',[n n],...
    'ViewportType','fixed',...
    'DocHorizAlign','center');
    X(1,i).FileName=fn{i};  
    X(1,i).Title=fn{i};
    X(1,i).Caption='MEG data';
end

cfr_table=nirs.util.reporttable(array2table(X'));

cfr_section4 = rptgen.cfr_section('SectionTitle','Channel Statistics');
setParent( cfr_table, cfr_section4);
setParent(cfr_section4,rpt);


cfr_section5 = rptgen.cfr_section('SectionTitle','Registration');
clear X;
n=.8*7;
X(1,1)=rptgen.cfr_image('MaxViewportSize',[n n],...
    'ViewportSize',[n n],...
    'ViewportType','fixed',...
    'DocHorizAlign','center');
X(1,1).FileName='Reg1.png';
X(1,1).Title='Frontal';
X(1,1).Caption='Registration';
       
X(1,2)=rptgen.cfr_image('MaxViewportSize',[n n],...
    'ViewportSize',[n n],...
    'ViewportType','fixed',...
    'DocHorizAlign','center');
X(1,2).FileName='Reg2.png';
X(1,2).Title='Side';
X(1,2).Caption='Registration';

X(1,3)=rptgen.cfr_image('MaxViewportSize',[n n],...
    'ViewportSize',[n n],...
    'ViewportType','fixed',...
    'DocHorizAlign','center');
X(1,3).FileName='Reg3.png';
X(1,3).Title='Top';
X(1,3).Caption='Registration';


cfr_table=nirs.util.reporttable(array2table(X'));
setParent( cfr_table, cfr_section5);
setParent(cfr_section5,rpt);

n=.8*7;
X=rptgen.cfr_image('MaxViewportSize',[n n],...
    'ViewportSize',[n n],...
    'ViewportType','fixed',...
    'DocHorizAlign','center');
XFileName=[type '_SNRMap.png'];
X.Title='SNR Map';
X.Caption='SNR';

cfr_section6 = rptgen.cfr_section('SectionTitle','SNR');

setParent( X, cfr_section6);
setParent(cfr_section6,rpt);


n=.8*7;
X=rptgen.cfr_image('MaxViewportSize',[n n],...
    'ViewportSize',[n n],...
    'ViewportType','fixed',...
    'DocHorizAlign','center');
XFileName=[ type 'PSD.png'];
X.Title='Power Spectrum';
X.Caption='PSD';
cfr_section7 = rptgen.cfr_section('SectionTitle','PSD');
setParent(X, cfr_section7);
setParent(cfr_section7,rpt);

close all;

system(['mkdir -p ' fullfile(folder,subjid,'images')]);
system(['mv *.png ' fullfile(folder,subjid,'images')]);

end