function HCP2nirsBEM(subjid,rootfolder)
lambda=[690 830];

if(exist(fullfile(rootfolder,subjid,'T1w',subjid,'bem',[subjid '-MCX.mdl'])))
    disp([fullfile(rootfolder,subjid,'T1w',subjid,'bem',[subjid '-MCX.mdl']) ' exists: SKIPPING']);
    return;
end

skin = fullfile(rootfolder,subjid,'T1w',subjid,'bem','outer_skin.surf');
oskull = fullfile(rootfolder,subjid,'T1w',subjid,'bem','outer_skull.surf');
iskull = fullfile(rootfolder,subjid,'T1w',subjid,'bem','inner_skull.surf');
brain = fullfile(rootfolder,subjid,'T1w',subjid,'bem','brain.surf');
pialL = fullfile(rootfolder,subjid,'T1w',subjid,'surf','lh.pial');
pialR = fullfile(rootfolder,subjid,'T1w',subjid,'surf','rh.pial');

sphereL = fullfile(rootfolder,subjid,'T1w',subjid,'surf','lh.sphere.reg');
sphereR = fullfile(rootfolder,subjid,'T1w',subjid,'surf','rh.sphere.reg');

[v,f]=read_surf(skin); 
mesh(1)=nirs.core.Mesh(v,f+1);
mesh(1)=reducemesh(mesh(1),.1);
mesh(1).transparency=.1;


fid=fopen(which('ext1020.sfp'),'r');
marker=textscan(fid,'%s\t%d\t%d\t%d');
fclose(fid);
Pos=double([marker{2} marker{3} marker{4}]);

Pos = icbm_spm2tal(Pos);

[TR, TT] = icp(mesh(1).nodes',Pos');
Pos=(TR*Pos'+TT*ones(1,size(Pos,1)))';

for i=1:3
    k=dsearchn(mesh(1).nodes,Pos);
    Pos=mesh(1).nodes(k,:);
    Pos2=double([marker{2} marker{3} marker{4}]);
    Pos(:,4)=1;
    Pos2(:,4)=1;
    T=Pos2\Pos;
    Pos=Pos2*T;
    Pos(:,4)=[];
end


fidtbl=table(marker{1},Pos(:,1),Pos(:,2),Pos(:,3),repmat({'10-20'},length(marker{1}),1),...
    repmat({'mm'},length(marker{1}),1),repmat(true,length(marker{1}),1),...
    'VariableNames',mesh(1).fiducials.Properties.VariableNames);

if(height(mesh(1).fiducials)==0)
    mesh(1).fiducials=fidtbl;
else
   mesh(1).fiducials=[mesh(1).fiducials; fidtbl];
end

[v,f]=read_surf(oskull); 
mesh(2)=nirs.core.Mesh(v,f+1);
mesh(2)=reducemesh(mesh(2),.1);
mesh(2).transparency=.1;

[v,f]=read_surf(iskull); 
mesh(3)=nirs.core.Mesh(v,f+1);
mesh(3)=reducemesh(mesh(3),.1);
mesh(3).transparency=.1;
 
[v,f]=read_surf(brain); 
mesh(4)=nirs.core.Mesh(v,f+1);
mesh(4)=reducemesh(mesh(4),.1);
mesh(4).transparency=.1;

ss=mne_read_source_spaces(fullfile(rootfolder,subjid,...
    'MNINonLinear','waveletJ5',[subjid '-ico5-src.fif']));


% options.keep_subdivision=true;
% [vertex,face] = compute_semiregular_sphere(6,options);
% 
% [v,f]=read_surf(sphereL);
% T=delaunay(v);
% kL=dsearchn(v,T,100*vertex{end}');
% 
% [vL,~]=read_surf(pialL); 
% 
% [v,f]=read_surf(sphereR);
% T=delaunay(v);
% kR=dsearchn(v,T,100*vertex{end}');
% 
% [vR,~]=read_surf(pialR); 


mesh(5)=nirs.core.Mesh([ss(1).rr*1000; ss(2).rr*1000],[ss(1).use_tris+1; ss(2).use_tris+1+size(ss(1).rr,1)]);
mesh(5).transparency=1;

fwdBEM=nirs.forward.NirfastBEM;
fwdBEM.mesh=mesh;
fwdBEM.probe.link.type=lambda;

fwdBEM.prop={nirs.media.tissues.skin(lambda) ...
            nirs.media.tissues.bone(lambda) ...
            nirs.media.tissues.water(lambda) ...
            nirs.media.tissues.brain(lambda,.70,60)...
            nirs.media.tissues.brain(lambda,.70,60)};
disp('Running NIRFAST Precompute K');
tic; 
fwdBEM=fwdBEM.precomputeK;
disp(['time elapsed: ' num2str(toc)]);
save(fullfile(rootfolder,subjid,'T1w',subjid,'bem','NIRFASTBEM-ico5-bem-sol.mesh'),'fwdBEM','-MAT');        



%make the volume-based segmentations foe MCExtreme and tMCimg
HCP_compute_scalp_distance(subjid,rootfolder);

r=gifti(fullfile(rootfolder,subjid,'T1w',subjid,'bem','R.pial.surf.gii'));
l=gifti(fullfile(rootfolder,subjid,'T1w',subjid,'bem','L.pial.surf.gii'));

[nodes,faces]=read_surf(fullfile(rootfolder,subjid,'T1w',subjid,'bem','outer_skin.surf'));
p0=floor(min(nodes));
p1=ceil(max(nodes));

dx=1;

img=surf2vol(nodes,faces+1,p0(1)-dx:dx:p1(1)+dx,p0(2)-dx:dx:p1(2)+dx,p0(3)-dx:dx:p1(3)+dx);
img=1*imfill(img,'holes');

[nodes,faces]=read_surf(fullfile(rootfolder,subjid,'T1w',subjid,'bem','outer_skull.surf'));
img2=surf2vol(nodes,faces+1,p0(1)-dx:dx:p1(1)+dx,p0(2)-dx:dx:p1(2)+dx,p0(3)-dx:dx:p1(3)+dx);
img2=2*imfill(img2,'holes');
img=max(img,img2);

n2=[r.vertices; l.vertices];
for i=1:length(nodes); 
    id=dsearchn(n2,nodes(i,:)); 
    n3(i,:)=nodes(i,:)+(n2(id,:)-nodes(i,:))/2; 
end;
nodes=n3;
%[nodes,faces]=read_surf(fullfile(rootfolder,subjid,'T1w',subjid,'bem','inner_skull.surf'));
img2=surf2vol(nodes,faces+1,p0(1)-dx:dx:p1(1)+dx,p0(2)-dx:dx:p1(2)+dx,p0(3)-dx:dx:p1(3)+dx);
img2=3*imfill(img2,'holes');
img=max(img,img2);

img2=surf2vol(r.vertices,r.faces,p0(1)-dx:dx:p1(1)+dx,p0(2)-dx:dx:p1(2)+dx,p0(3)-dx:dx:p1(3)+dx);
img2=4*imfill(img2,'holes');
img=max(img,img2);

img2=surf2vol(l.vertices,l.faces,p0(1)-dx:dx:p1(1)+dx,p0(2)-dx:dx:p1(2)+dx,p0(3)-dx:dx:p1(3)+dx);
img2=4*imfill(img2,'holes');
img=max(img,img2);

r=gifti(fullfile(rootfolder,subjid,'T1w',subjid,'bem','R.white.surf.gii'));
img2=surf2vol(r.vertices,r.faces,p0(1)-dx:dx:p1(1)+dx,p0(2)-dx:dx:p1(2)+dx,p0(3)-dx:dx:p1(3)+dx);
img2=5*imfill(img2,'holes');
img=max(img,img2);

l=gifti(fullfile(rootfolder,subjid,'T1w',subjid,'bem','L.white.surf.gii'));
img2=surf2vol(l.vertices,l.faces,p0(1)-dx:dx:p1(1)+dx,p0(2)-dx:dx:p1(2)+dx,p0(3)-dx:dx:p1(3)+dx);
img2=5*imfill(img2,'holes');
img=max(img,img2);


fwdMCX=nirs.forward.MCXLab;
origin(1)=min(find(p0(1)-dx:dx:p1(1)+dx>=0));
origin(2)=min(find(p0(2)-dx:dx:p1(2)+dx>=0));
origin(3)=min(find(p0(3)-dx:dx:p1(3)+dx>=0));
   
fwdMCX.image=nirs.core.Image(img,[dx dx dx], origin );
fwdMCX.prop={nirs.media.tissues.skin(lambda) ...
            nirs.media.tissues.bone(lambda) ...
            nirs.media.tissues.water(lambda) ...
            nirs.media.tissues.brain(lambda,.70,60)...
            nirs.media.tissues.brain(lambda,.70,60)...
            nirs.media.tissues.brain(lambda,.70,60)...
            nirs.media.tissues.brain(lambda,.70,60)};

save(fullfile(rootfolder,subjid,'T1w',subjid,'bem',[subjid '-MCX.mdl']),'fwdMCX','-MAT');        



