function HCP_cifti(a,fld)
figure;

if(nargin<2)
fldsO={'dimord' 'hdr' 'unit' 'brainstructure' 'brainstructurelabel' 'pos' 'tri'};
flds=fields(a);
fld=flds{find(~ismember(flds,fldsO))};
end

vmax=max(abs(a.(fld)));



h = patch('vertices',a.pos,'faces',a.tri, ... 
    'FaceVertexCData',a.(fld),...
    'facecolor','interp', ...
    'edgecolor','none');
camlight; lighting gouraud
colormap(jet), colorbar
caxis([-vmax vmax])