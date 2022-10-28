cd /disk/sulcus1/COBRA/
ff=rdir('HCP*/BOLD*/BOLD*_orig.nii.gz');
HCP_matlab_setenv

for i=1:length(ff)
    cd('/disk/sulcus1/COBRA');
    [p,f,e]=fileparts(ff(i).name);
    f=strtok(f,'.'); e=['.nii.gz']
    system(['mkdir -p ' p '/mcf']);
    cd([ p '/mcf']);
    if(~exist([f '_mcf.par']))
        system(['mcflirt -in ../' f e ' -o ' f '_mcf -report -plots -stats'])
    else
        disp(['skipping ' f]);
    end
end