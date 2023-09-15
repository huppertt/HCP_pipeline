function fileOut=HCP_N4filter(file,force)

if(nargin<2)
    force=false;
end

fileIn=file;
fileOut=strrep(file,'.nii','_N4.nii');

if(exist(fileOut) & ~force)
    return
end

if ismac
    cmd='/Applications/Slicer.app/Contents/lib/Slicer-4.11/cli-modules/';
elseif isunix
    %cmd='/home/pkg/software//slicer/Slicer-4.4.0-linux-amd64/lib/Slicer-4.4/cli-modules/';
    cmd='/usr/local/bin/Slicer/lib/Slicer-4.11/cli-modules/';
else
    error('OS not known');
end

cmd=[cmd 'N4ITKBiasFieldCorrection'...
    ' --meshresolution 1,1,1' ...
    ' --splinedistance 0'...
    ' --bffwhm 0' ...
    ' --iterations 50,40,30' ...
    ' --convergencethreshold 0.0001'...
    ' --bsplineorder 3'...
    ' --shrinkfactor 4'...
    ' --wienerfilternoise 0'...
    ' --nhistogrambins 0'...
    ' ' fileIn ' ' fileOut];
    
system(cmd);
