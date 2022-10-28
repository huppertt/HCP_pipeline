function HCP_resample_cifti(fileIn,spherefile,fileOut,J)

if(isstr(fileIn))
    %read as cifti file
    d=ft_read_cifti(fileIn);
else
    d=fileIn;
    clear fileIn;
end

% read in the sphere surfaces for this file
spherefileL = spherefile;
spherefileL([strfind(spherefileL,'.L.') strfind(spherefileL,'.R.')]+1)='L';
spherefileR = spherefile;
spherefileR([strfind(spherefileR,'.L.') strfind(spherefileR,'.R.')]+1)='R';
    
L=gifti(spherefileL);
R=gifti(spherefileR);

lstL=find(d.brainstructure==find(ismember(d.brainstructurelabel,'CORTEX_LEFT')));
lstR=find(d.brainstructure==find(ismember(d.brainstructurelabel,'CORTEX_RIGHT')));

d2=d;
flds=fields(d);

flds={flds{~ismember(flds,{'dimord','hdr','unit','brainstructure',...
    'brainstructurelabel','pos','tri','transform','time','dim'})}};

vIn={};
for i=1:length(flds)
    data=d.(flds{i});
    [dL,facesL]=semireg_sphere_resample(L.vertices,L.faces,data(lstL,:),J);
    [dR,facesR]=semireg_sphere_resample(R.vertices,R.faces,data(lstR,:),J);
    d2.(flds{i})=[dL; dR];
    vIn{end+1}='parameter';
    vIn{end+1}=flds{i};
    
    if(size(data,2)>1)
           vIn{end+1}='dimord';
            vIn{end+1}=d2.dimord;
            d2.dim=[size(d2.(flds{i}),1) 1 1];
                        
    end
    
    
    
end

if(all(all(isnan(d.pos([lstL lstR],:)))))
    vIn{end+1}='writesurface';
    vIn{end+1}=false;
    d2.pos=nan(size(dL,1)+size(dR,1),3);
    d2.tri=[facesL; facesR+size(dL,1)];
else
    
    
    vL(:,1)=semireg_sphere_resample(L.vertices,L.faces,d.pos(lstL,1),J);
    vL(:,2)=semireg_sphere_resample(L.vertices,L.faces,d.pos(lstL,2),J);
    vL(:,3)=semireg_sphere_resample(L.vertices,L.faces,d.pos(lstL,3),J);
    
    vR(:,1)=semireg_sphere_resample(R.vertices,R.faces,d.pos(lstR,1),J);
    vR(:,2)=semireg_sphere_resample(R.vertices,R.faces,d.pos(lstR,2),J);
    vR(:,3)=semireg_sphere_resample(R.vertices,R.faces,d.pos(lstR,3),J);
    d2.pos=[vL; vR];
    d2.tri=[facesL; facesR+size(dL,1)];
    
end

d2.brainstructure=[ones(size(dL,1),1); ones(size(dR,1),1)*2];
d2.brainstructurelabel={'CORTEX_LEFT' 'CORTEX_RIGHT'};

ft_write_cifti(fileOut,d2,vIn{:});