function tbl = QAstats(file)

%file='ABCDQAfMRI.nii.gz'

p=file(1:max(strfind(file,filesep)));
f=file(max(strfind(file,filesep))+1:end);
f=f(1:min(strfind(f,'.'))-1);
e='.nii.gz';

curdir=pwd;
cd(p);
HCP_matlab_setenv;

if(~exist([f '_mcf.par'],'file'))
    system(['${FSLDIR}/bin/mcflirt -in ' f e ' -stats -report -plots']);
end
a=dlmread([f '_mcf.par']);

n=load_nii([f '_mcf_sigma.nii.gz']);
x=zeros(size(n.img,1),size(n.img,2),1,size(n.img,3));
x(:)=n.img(:);
x=uint8(x);
s(1)=min(x(:));
s(2)=max(x(:));

fig=figure;
montage(x);
caxis(s);
colormap(jet);
colorbar;
title('sigma')
saveas(fig,'Sigma.tif','tif');


n=load_nii([f '_mcf_variance.nii.gz']);
x=zeros(size(n.img,1),size(n.img,2),1,size(n.img,3));
x(:)=n.img(:);
x=uint8(x);
s(1)=min(x(:));
s(2)=max(x(:));

fig=figure;
montage(x);
caxis(s);
colormap(jet);
colorbar;
title('variance');
saveas(fig,'Variance.tif','tif');


fig=figure;
subplot(2,1,1);
plot(a(:,1:3)*360/2/pi);
xlabel('TR');
ylabel('degrees');
legend({'rot-X','rot-Y','rot-Z'});

subplot(2,1,2);
plot(a(:,4:6));
xlabel('TR');
ylabel('mm');
legend({'trans-X','trans-Y','trans-Z'});
saveas(fig,'Motion.tif','tif');

close all;

n=load_nii('ABCDQAfMRI_mcf.nii.gz');
x=zeros(size(n.img,1),size(n.img,2),1,size(n.img,3));
x(:)=mean(n.img,4);
x=x/max(x(:))*255;
x=uint8(x);
s(1)=min(x(:));
s(2)=max(x(:));

fig=figure;
montage(x);
caxis(s);
colormap(jet);
colorbar;
title('mean');
saveas(fig,'Mean_Int.tif','tif');

x=zeros(size(n.img,1),size(n.img,2),1,size(n.img,3));
x(:)=var(double(n.img),[],4);
x=sqrt(x);
x=x/max(x(:))*255;
x=uint8(x);
s(1)=min(x(:));
s(2)=max(x(:));

fig=figure;
montage(x);
caxis(s);
colormap(jet);
colorbar;
title('StdDev');

saveas(fig,'StdDev_Int.tif','tif');
st=struct;
st.Filename=file;

st.rotX=max(a(:,1),[],1);
st.rotY=max(a(:,2),[],1);
st.rotZ=max(a(:,3),[],1);
st.transX=max(a(:,4),[],1);
st.transY=max(a(:,5),[],1);
st.transZ=max(a(:,6),[],1);

st.rotXstd=std(a(:,1),[],1);
st.rotYstd=std(a(:,2),[],1);
st.rotZstd=std(a(:,3),[],1);
st.transXstd=std(a(:,4),[],1);
st.transYstd=std(a(:,5),[],1);
st.transZstd=std(a(:,6),[],1);

x=mean(n.img(end/2+[-10:10],end/2+[-10:10],end/2+[-10 10],:),4);
st.meanIntens=mean(x(:));
st.stdInten=std(x(:));

st.maxInten=max(x(:));
st.minInten=min(x(:));


st.meanIntensWhole=mean(n.img(:));
st.stdIntenWhole=std(double(n.img(:)));

st.maxIntenWhole=max(n.img(:));
st.minIntenWhole=min(n.img(:));


tbl=struct2table(st);

cd(curdir);

return

