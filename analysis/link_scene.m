function link_scene(filename,target,force)
% this function creates a link to the original filename and all the targets that allows the spec files to be moved


if(nargin<3)
    force=false;
end

fs = '\';
%filename=fullfile(pwd,filename);
[p,f,e]=fileparts(filename);


if(exist([target filesep f e],'file') & ~force)
    return
end


system(['cp -v ' filename ' ' target filesep f e]);
sceneOut=[target filesep f e];

system(['grep Name= ' sceneOut '> temp.txt']);

fid = fopen('temp.txt','r');
files={};
files2={};
while(1)
    line=fgetl(fid);
    if(~ischar(line))
        break
    end
   % disp(line)
    if(~isempty(strfind(line,'Name=')))
        line=line(min(strfind(line,'"'))+1:max(strfind(line,'"'))-1);
        
        line(isspace(line))=[];
        if(exist(fullfile(p,line),'file'))
            files{end+1}=fullfile(p,line);
            files2{end+1}=line;
        end
    end
end
fclose(fid);
delete('temp.txt');


system(['grep /disk/ ' sceneOut '> temp.txt']);
fid = fopen('temp.txt','r');
while(1)
    line=fgetl(fid);
    if(~ischar(line))
        break
    end
    line=line(strfind(line,'CDATA[')+6:end);
    line=line(1:strfind(line,']]></Object>')-1);
    %disp(line);
    
    line(isspace(line))=[];
    if(exist(line,'file'))
        files{end+1}=line;
        [~,line,e]=fileparts(line)
        files2{end+1}=[line e];
    end
end
fclose(fid);
delete('temp.txt');

[files,i]=unique(files);
files2={files2{i}};


if(isempty(files))
    return
end

for i=1:length(files)
    files3{i}=strrep(files{i},'/','\/');
end


system(['cp ' sceneOut ' ' sceneOut 'A']);
system(['cp ' sceneOut ' ' sceneOut 'B']);

subjid = f(1:max(strfind(f,'.'))-1);


for i=1:length(files)
    [p,ff,e] = fileparts(files{i});
    ff=[ff e];
    
    system(['mkdir -p ' target filesep 'linked' filesep subjid]);
    system(['ln -T ' files{i} ' ' target filesep 'linked' filesep subjid filesep files2{i}]);
    
    fs = '\';
    system(['sed ''s/' files2{i} '/linked\' fs subjid '\' fs ff '/g'' ' sceneOut 'A > ' sceneOut '2']);
%     fs = '/';
%     system(['sed ''s/' files2{i} '/linked\' fs subjid '\' fs ff '/g'' ' sceneOut 'B > ' sceneOut '3']);
    
        
    system(['rm ' sceneOut 'A']);
%    system(['rm ' sceneOut 'B']);
    system(['mv ' sceneOut '2 ' sceneOut 'A']);
%    system(['mv ' sceneOut '3 ' sceneOut 'B']);
end


system(['sed ''s/<?xml version="1.0" encoding="UTF-8"?>/ /g'' ' sceneOut 'A > test']);
system(['mv test ' sceneOut 'A']);
system(['sed ''s/<CaretSpecFile Version="1.0">/ /g'' ' sceneOut 'A > test']) ;
system(['mv test ' sceneOut 'A']);
system(['sed ''s/<MetaData>/ /g'' ' sceneOut 'A > test']) ;
system(['mv test ' sceneOut 'A']);
system(['sed ''s/<\/MetaData>/ /g'' ' sceneOut 'A > test']) ;
system(['mv test ' sceneOut 'A']);

system(['sed ''s/<\/CaretSpecFile>/ /g'' ' sceneOut 'A > test']);
system(['mv test ' sceneOut]);


for i=1:length(files);
    pp{i}=fileparts(files{i}); 
end;
pp=unique(pp);
for i=1:length(pp)
    pp{i}=strrep(pp{i},'/','\/');
end

for i=1:length(pp)
    system(['sed ''s/' pp{i} '/ /g'' ' sceneOut '>test']);
    system(['mv test ' sceneOut]);
end


%system(['cat ' sceneOut 'B >>' sceneOut]);
%system(['cat ' sceneOut 'A >>' sceneOut]);
  
system(['rm ' sceneOut 'A']);
system(['rm ' sceneOut 'B']);

subjid=subjid(1:min(strfind(subjid,'.'))-1);
n=['linked\/' subjid '.structuralQC\/'];
n2=['linked\\' subjid '.structuralQC\\'];
%sceneOut='HCP201.structuralQC.wb.scene';

system(['sed ''s/' n '/' n2 '/g'' ' sceneOut '>test']);
system(['mv test ' sceneOut]);


n='.\/linked';
n2='linked';
system(['sed ''s/' n '/' n2 '/g'' ' sceneOut '>test']);
system(['mv test ' sceneOut]);

n=['linked\\' subjid '.structuralQC\\linked'];
n2='linked';


system(['sed ''s/' n '/' n2 '/g'' ' sceneOut '>test']);
system(['mv test ' sceneOut]);



% 
% subjid = f(1:max(strfind(f,'.'))-1);
% 
% for i=1:length(files)
%     [p,ff,e] = fileparts(files{i});
%     ff=[ff e];
%     
%     system(['mkdir -p ' target filesep 'linked' filesep subjid]);
%     system(['ln -T ' files{i} ' ' target filesep 'linked' filesep subjid filesep files2{i}]);
%     
%     system(['sed ''s/' files3{i} '/linked\\' subjid '\\' ff '/g'' ' sceneOut ' > ' sceneOut '2']);
%     system(['rm ' sceneOut]);
%     system(['mv ' sceneOut '2 ' sceneOut]);
% end