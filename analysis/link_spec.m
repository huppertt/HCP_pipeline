function link_spec(filename,target,force)
% this function creates a link to the original filename and all the targets that allows the spec files to be moved

if(nargin<3)
    force=false;
end


filename=fullfile(pwd,filename);
[p,f,e]=fileparts(filename);

if(exist([target filesep f e],'file') & ~force)
    return
end


system(['cp -v ' filename ' ' target filesep f e]);
sceneOut=[target filesep f e];


fid = fopen(sceneOut,'r');
files={};
files2={};
while(1)
    line=fgetl(fid);
      if(~ischar(line))
        break
      end
    line(isspace(line))=[];
    if(exist(fullfile(p,line),'file'))
        files{end+1}=fullfile(p,line);
        files2{end+1}=line;
    end
end
fclose(fid);

subjid = f(1:min(strfind(f,'.'))-1);

system(['cp ' sceneOut ' ' sceneOut 'A']);
system(['cp ' sceneOut ' ' sceneOut 'B']);


for i=1:length(files)
    [p,ff,e] = fileparts(files{i});
    ff=[ff e];
    
    system(['mkdir -p ' target filesep 'linked' filesep subjid]);
    system(['ln -T ' files{i} ' ' target filesep 'linked' filesep subjid filesep files2{i}]);
    
    fs = '\';
    system(['sed ''s/' files2{i} '/linked\' fs subjid '\' fs ff '/g'' ' sceneOut 'A > ' sceneOut '2']);
    fs = '/';
    system(['sed ''s/' files2{i} '/linked\' fs subjid '\' fs ff '/g'' ' sceneOut 'B > ' sceneOut '3']);
    
        
    system(['rm ' sceneOut 'A']);
    system(['rm ' sceneOut 'B']);
    system(['mv ' sceneOut '2 ' sceneOut 'A']);
    system(['mv ' sceneOut '3 ' sceneOut 'B']);
end


system(['sed ''s/<?xml version="1.0" encoding="UTF-8"?>/ /g'' ' sceneOut 'A > test']);
system(['mv test ' sceneOut 'A']);
system(['sed ''s/<CaretSpecFile Version="1.0">/ /g'' ' sceneOut 'A > test']) ;
system(['mv test ' sceneOut 'A']);
system(['sed ''s/<MetaData>/ /g'' ' sceneOut 'A > test']) ;
system(['mv test ' sceneOut 'A']);
system(['sed ''s/<\/MetaData>/ /g'' ' sceneOut 'A > test']) ;
system(['mv test ' sceneOut 'A']);

system(['sed ''s/<\/CaretSpecFile>/ /g'' ' sceneOut 'B > test']);
system(['mv test ' sceneOut 'B']);
   
system(['rm ' sceneOut]);
system(['cat ' sceneOut 'B >>' sceneOut]);
system(['cat ' sceneOut 'A >>' sceneOut]);
  
system(['rm ' sceneOut 'A']);
system(['rm ' sceneOut 'B']);


return