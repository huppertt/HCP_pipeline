function HCP_resample_ico(giftiIn,sphereIn,J,giftiOut)
% This function resamples a gifti file onto the standard ico-basis which is
% compatible with my wavelet code

HCP_matlab_setenv;

[p,f,ext]=fileparts(giftiIn);
if(~strcmp(ext,'.gii'))
    system(['mris_convert ' giftiIn ' tmp1.gii']);
    giftiIn='lh.tmp1.gii';
end
[p,f,ext]=fileparts(sphereIn);
if(~strcmp(ext,'.gii'))
    system(['mris_convert ' sphereIn ' tmp2.gii']);
    sphereIn='lh.tmp2.gii'; 
end

[p,f,ext]=fileparts(giftiOut);
if(~strcmp(ext,'.gii'))
    giftiOut2='lh.tmp3.gii';
else
    giftiOut2=giftiOut;
end


system(['${CARET7DIR}/wb_command -surface-resample ' ...
    giftiIn ' ' sphereIn ... 
    ' /disk/HCP/pipeline/templates/ico/ico' num2str(J-1) '.gii BARYCENTRIC ' ...
    giftiOut2 ]);

if(~strcmp(giftiOut,giftiOut2))
     system(['mris_convert ' giftiOut2 ' ' giftiOut]);
end

f=dir('lh.tmp*.gii');
for i=1:length(f);
    delete(f(i).name);
end
