function HCP_run_all_automated(outfolder,jobs,force,runlocal)

if(nargin<3)
    force=false;
end

if(nargin<4)
    runlocal=false;
end

if(nargin<2)
    jobs=[0:9];
end


HCProot='/disk/HCP/';
if(nargin<1 || isempty(outfolder))
    outfolder=fullfile(HCProot,'analyzed');
end

tbl=HCP_check_analysis([],outfolder);

cmdlst={};
cnn=[];

[~,msg]=system('squeue');

for i=1:height(tbl)
    try
        if(~tbl.Stage0(i) & ismember(0,jobs))
            HCP_runall(tbl.Subjid{i},0,outfolder);
            tbl=HCP_check_analysis([],outfolder);
        end
        if(~tbl.Stage1(i) & tbl.Stage0(i) & ismember(1,jobs))
            if(isempty(strfind(msg,[tbl.Subjid{i} '_1'])))
                if( runlocal)
                    HCP_runall(tbl.Subjid{i},1,outfolder,force);
                else
                   cmdlst{end+1}=['HCP_runall(''' tbl.Subjid{i} ''',1,''' outfolder ',' num2str(force) ');'];
                   cnn(end+1)=1;
                end
            end
        end
        if(~tbl.Stage2(i) & tbl.Stage1(i) & exist(fullfile(outfolder,tbl.Subjid{i},'unprocessed','3T','Diffusion')) & ismember(2,jobs))
            if(isempty(strfind(msg,[tbl.Subjid{i} '_2'])))
                if( runlocal)
                    HCP_runall(tbl.Subjid{i},2,outfolder,force);
                else
                    
                   cmdlst{end+1}=['HCP_runall(''' tbl.Subjid{i} ''',2,''' outfolder ',' num2str(force) ');'];
                   cnn(end+1)=2;
                end
            end
        end
        if(~tbl.Stage3(i) & tbl.Stage1(i) & ismember(3,jobs))
            if(isempty(strfind(msg,[tbl.Subjid{i} '_3'])))
                if( runlocal)
                    HCP_runall(tbl.Subjid{i},3,outfolder,force);
                else
                    
                   cmdlst{end+1}=['HCP_runall(''' tbl.Subjid{i} ''',3,''' outfolder ',' num2str(force) ');'];
                   cnn(end+1)=3;
                end
            end
        end
        if(~tbl.Stage4(i) & tbl.Stage3(i) & ismember(4,jobs))
            if(isempty(strfind(msg,[tbl.Subjid{i} '_4'])))
                if( runlocal)
                    HCP_runall(tbl.Subjid{i},4,outfolder,force);
                else
                    
                   cmdlst{end+1}=['HCP_runall(''' tbl.Subjid{i} ''',4,''' outfolder ',' num2str(force) ');'];
                   cnn(end+1)=4;
                end
            end
        end
        if(~tbl.Stage5(i) & tbl.Stage1(i) & (exist(fullfile(outfolder,tbl.Subjid{i},'unprocessed','3T','ASL')) | force) & ismember(5,jobs))
            if(isempty(strfind(msg,[tbl.Subjid{i} '_5'])))
                if( runlocal)
                    HCP_runall(tbl.Subjid{i},5,outfolder,force);
                else
       
                   cmdlst{end+1}=['HCP_runall(''' tbl.Subjid{i} ''',5,''' outfolder ',' num2str(force) ');'];   
                   cnn(end+1)=5;
                end
            end
        end
        if(~tbl.Stage6(i) & tbl.Stage4(i) & ismember(6,jobs))
            if(isempty(strfind(msg,[tbl.Subjid{i} '_6'])))
                if( runlocal)
                    HCP_runall(tbl.Subjid{i},6,outfolder,force);
                else
                    
                   cmdlst{end+1}=['HCP_runall(''' tbl.Subjid{i} ''',6,''' outfolder ',' num2str(force) ');'];
                   cnn(end+1)=6;
                end
            end
        end
        if(~tbl.Stage7(i) & tbl.Stage1(i) & exist(fullfile(outfolder,tbl.Subjid{i},'unprocessed','PET')) & ismember(7,jobs))
            if(isempty(strfind(msg,[tbl.Subjid{i} '_7'])))
                if( runlocal)
                    HCP_runall(tbl.Subjid{i},7,outfolder,force);
                else
                   cmdlst{end+1}=['HCP_runall(''' tbl.Subjid{i} ''',7,''' outfolder ',' num2str(force) ');'];
                   cnn(end+1)=7;
                end
            end
        end
        if(tbl.Stage1(i) & ismember(8,jobs))
            if(isempty(strfind(msg,[tbl.Subjid{i} '_8'])))
                if( runlocal)
                    HCP_runall(tbl.Subjid{i},8,outfolder,force);
                else
                    
                   cmdlst{end+1}=['HCP_runall(''' tbl.Subjid{i} ''',8,''' outfolder ',' num2str(force) ');'];
                   cnn(end+1)=8;
                end
            end
            
        end
        if(tbl.Stage1(i) & ismember(9,jobs))
            if(isempty(strfind(msg,[tbl.Subjid{i} '_9'])))
                if( runlocal)
                    HCP_runall(tbl.Subjid{i},9,outfolder,force);
                else
                    
                   cmdlst{end+1}=['HCP_runall(''' tbl.Subjid{i} ''',9,''' outfolder ',' num2str(force) ');'];
                   cnn(end+1)=9;
                end
            end
            
        end
    end
end

[~,i]=sort(cnn);
cmdlst={cmdlst{i}}';

matlab2slurm(cmdlst);

return
