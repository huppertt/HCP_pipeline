function [RptgenML_CReport1] = buildHCP(folder,subjid)
%BUILDHCP
%  Auto-generated by MATLAB on 04-Jul-2018 20:07:45
 
HCP_matlab_setenv;
%warning('on','rptgen:ComponentInit');
curdir=pwd;
cd('/disk/HCP/pipeline/analysis/Xnat/');


[~,jsess]=system('./CreateXnatJess.sh');
jsess=jsess(end-32:end);
jsess(double(jsess)==10)=[];
tbl2=Xnat_get_SubjectInfo(subjid,jsess);
tbl2(~ismember(tbl2.project,'COBRA'),:)=[];


lst=find(ismember(tbl2.label,[subjid '_MR1']));
for i=1:length(lst)
    disp(i);
    tbl = Xnat_get_ScanInfo(tbl2.URI{lst(i)},jsess);
    id=tbl.cat_id(1);
    if(iscell(id))
        id=id{1};
    end
    
        try
        Scan_Number(i,1) = id;
    catch
        Scan_Number(i,1) =NaN;
    end
    Date{i,1} = tbl2.date{lst(i)};
    Series{i,1}=tbl2.type{lst(i)};
    Number_Scans(i,1)=tbl2.frames(lst(i));
    Insert_Date{i,1}=tbl2.insert_date{lst(i)};
    
    lst2=find(ismember(tbl.label,'LINKED_DATA'));
    cnt=0;
    for ii=1:length(lst2)
        if(~isempty(strfind(tbl.URI{lst2(ii)},'.log')))
            cnt=cnt+1;
        end
    end
    Has_Physiology(i,1)=cnt;
    
     lst2=find(ismember(tbl.label,'LINKED_DATA'));
    cnt=0;
    for ii=1:length(lst2)
        if(~isempty(strfind(tbl.URI{lst2(ii)},'.edat2')))
            cnt=cnt+1;
        end
        if(~isempty(strfind(tbl.URI{lst2(ii)},'.txt')))
            cnt=cnt+1;
        end
    end
    
    Has_Eprime(i,1)=cnt;
  
end
t=table(Scan_Number,Date,Series,Number_Scans,Insert_Date,Has_Physiology,Has_Eprime);


clear Scan_Number Date Series Number_Scans Insert_Date Has_Physiology Has_Eprime
lst=find(ismember(tbl2.label,[subjid '_MR2']));

for i=1:length(lst)
    disp(i);
    tbl = Xnat_get_ScanInfo(tbl2.URI{lst(i)},jsess);
    
     id=tbl.cat_id(1);
    if(iscell(id))
        id=id{1};
    end
    try
        Scan_Number(i,1) = id;
    catch
        Scan_Number(i,1) =NaN;
    end
    
    Date{i,1} = tbl2.date{lst(i)};
    Series{i,1}=tbl2.type{lst(i)};
    Number_Scans(i,1)=tbl2.frames(lst(i));
    Insert_Date{i,1}=tbl2.insert_date{lst(i)};
    
    lst2=find(ismember(tbl.label,'LINKED_DATA'));
    cnt=0;
    for ii=1:length(lst2)
        if(~isempty(strfind(tbl.URI{lst2(ii)},'.log')))
            cnt=cnt+1;
        end
    end
    Has_Physiology(i,1)=cnt;
    
     lst2=find(ismember(tbl.label,'LINKED_DATA'));
    cnt=0;
    for ii=1:length(lst2)
        if(~isempty(strfind(tbl.URI{lst2(ii)},'.edat2')))
            cnt=cnt+1;
        end
        if(~isempty(strfind(tbl.URI{lst2(ii)},'.txt')))
            cnt=cnt+1;
        end
    end
    
    Has_Eprime(i,1)=cnt;
  
end
t2=table(Scan_Number,Date,Series,Number_Scans,Insert_Date,Has_Physiology,Has_Eprime);



clear Scan_Number Date Series Number_Scans Insert_Date Has_Physiology Has_Eprime
lst=find(ismember(tbl2.label,[subjid '_MEG']));
for i=1:length(lst)
    disp(i);
    tbl = Xnat_get_ScanInfo(tbl2.URI{lst(i)},jsess);
    if(~isempty(tbl))
      id=tbl.cat_id(1);
    if(iscell(id))
        id=id{1};
    end
    
        try
        Scan_Number(i,1) = id;
    catch
        Scan_Number(i,1) =NaN;
    end
    Date{i,1} = tbl2.date{lst(i)};
    Series{i,1}=tbl2.type{lst(i)};
    Number_Scans(i,1)=tbl2.frames(lst(i));
    Insert_Date{i,1}=tbl2.insert_date{lst(i)};
    
 
    lst2=find(ismember(tbl.label,'LINKED_DATA'));
    cnt=0;
    for ii=1:length(lst2)
        if(~isempty(strfind(tbl.URI{lst2(ii)},'.edat2')))
            cnt=cnt+1;
        end
        if(~isempty(strfind(tbl.URI{lst2(ii)},'.txt')))
            cnt=cnt+1;
        end
    end
    
    Has_Eprime(i,1)=cnt;
    end
  
end
if(exist('Scan_Number','var'))
    t3=table(Scan_Number,Date,Series,Insert_Date,Has_Eprime);
    t3(t3.Scan_Number==0,:)=[];
else
    t3=table;
end


clear Scan_Number Date Series Number_Scans Insert_Date Has_Physiology Has_Eprime
lst=[];
for i=1:height(tbl2)
    if(~isempty(strfind(tbl2.type{i},'fMRI_REST')))
        lst=[lst; i];
    end
end

for i=1:length(lst)
    disp(i);
    tbl = Xnat_get_ScanInfo(tbl2.URI{lst(i)},jsess);
    
     id=tbl.cat_id(1);
    if(iscell(id))
        id=id{1};
    end
    
        try
        Scan_Number(i,1) = id;
    catch
        Scan_Number(i,1) =NaN;
    end
    Date{i,1} = tbl2.date{lst(i)};
    Series{i,1}=tbl2.type{lst(i)};
    Number_Scans(i,1)=tbl2.frames(lst(i));
    Insert_Date{i,1}=tbl2.insert_date{lst(i)};
    
    lst2=find(ismember(tbl.label,'LINKED_DATA'));
    cnt=0;
    for ii=1:length(lst2)
        if(~isempty(strfind(tbl.URI{lst2(ii)},'.log')))
            cnt=cnt+1;
        end
    end
    Has_Physiology(i,1)=cnt;
    
     lst2=find(ismember(tbl.label,'LINKED_DATA'));
    cnt=0;
    for ii=1:length(lst2)
        if(~isempty(strfind(tbl.URI{lst2(ii)},'.edat2')))
            cnt=cnt+1;
        end
        if(~isempty(strfind(tbl.URI{lst2(ii)},'.txt')))
            cnt=cnt+1;
        end
    end
    
    Has_Eprime(i,1)=cnt;
  
end
t4=table(Scan_Number,Date,Series,Number_Scans,Insert_Date,Has_Physiology,Has_Eprime);




% Create RptgenML.CReport
RptgenML_CReport1 = RptgenML.CReport('Format','pdf-fop',...
'Stylesheet','default-fo');
% setedit(RptgenML_CReport1);

% Create rptgen.cfr_titlepage
rptgen_cfr_titlepage1 = rptgen.cfr_titlepage('Subtitle',subjid,...
'Title','HCP Data Analysis QC');
rptgen_cfr_text1 = rptgen.cfr_text;
set(rptgen_cfr_titlepage1,'AbstractComp',rptgen_cfr_text1);
rptgen_cfr_text2 = rptgen.cfr_text;
set(rptgen_cfr_titlepage1,'LegalNoticeComp',rptgen_cfr_text2);
rptgen_cfr_image1 = rptgen.cfr_image('isCopyFile',false,'FileName','',...
'MaxViewportSize',[7 9]);
set(rptgen_cfr_titlepage1,'ImageComp',rptgen_cfr_image1);
setParent(rptgen_cfr_titlepage1,RptgenML_CReport1);

% Create rptgen.cfr_section
% Create rptgen.cfr_section
rptgen_cfr_section1 = rptgen.cfr_section('SectionTitle','MRI Information');
setParent(rptgen_cfr_section1,RptgenML_CReport1);

rptgen_cfr_section2 = rptgen.cfr_section('SectionTitle','Data Collection');
setParent(rptgen_cfr_section2,rptgen_cfr_section1);


% Create rptgen.cfr_ext_table
rptgen_cfr_ext_table1 = nirs.util.reporttable(t);
rptgen_cfr_ext_table1.TableTitle='MRI Day 1';
rptgen_cfr_ext_table1.NumCols=num2str(width(t));
% rptgen_cfr_ext_table1 = rptgen.cfr_ext_table('NumCols','5',...
% 'TableTitle','MRI Day 1');
setParent(rptgen_cfr_ext_table1,rptgen_cfr_section2);



% Create rptgen.cfr_ext_table
% rptgen_cfr_ext_table2 = rptgen.cfr_ext_table('NumCols','5',...
% 'TableTitle','MRI Day 1');
rptgen_cfr_ext_table2 = nirs.util.reporttable(t2);
rptgen_cfr_ext_table2.TableTitle='MRI Day 2';
rptgen_cfr_ext_table2.NumCols=num2str(width(t2));
setParent(rptgen_cfr_ext_table2,rptgen_cfr_section2);
 


% Create rptgen.cfr_ext_table
% rptgen_cfr_ext_table3 = rptgen.cfr_ext_table('NumCols','3',...
% 'TableTitle','MEG');
rptgen_cfr_ext_table3 = nirs.util.reporttable(t3);
rptgen_cfr_ext_table3.TableTitle='MEG';
rptgen_cfr_ext_table3.NumCols=num2str(width(t3));
setParent(rptgen_cfr_ext_table3,rptgen_cfr_section2);




%% Create rptgen.cfr_section
rptgen_cfr_section3 = rptgen.cfr_section('SectionTitle','sMRI QC');
setParent(rptgen_cfr_section3,rptgen_cfr_section1);
 
%% Create rptgen.cfr_section
rptgen_cfr_section4 = rptgen.cfr_section('SectionTitle','T1w');
setParent(rptgen_cfr_section4,rptgen_cfr_section3);
 
% Create rptgen.cfr_ext_table
rptgen_cfr_ext_table4 = rptgen.cfr_ext_table('NumCols','4',...
'TableTitle','MPRAGE');
setParent(rptgen_cfr_ext_table4,rptgen_cfr_section4);


f=rdir(fullfile(folder,subjid,'images','T1W_AXIAL*.png'));
for i=1:length(f)
    ll(i)=str2num(f(i).name(max(strfind(f(i).name,'_'))+1:strfind(f(i).name,'.')-1));
end
[~,lst]=sort(ll);
f=f(lst); 

ncolumns=4;
nrows = ceil(length(f)/ncolumns);

% Create rptgen.cfr_ext_table_colspec
rptgen_cfr_ext_table_colspec14 = rptgen.cfr_ext_table_colspec;
setParent(rptgen_cfr_ext_table_colspec14,rptgen_cfr_ext_table4);
 
for n=1:ncolumns
    % Create rptgen.cfr_ext_table_colspec
    rptgen_cfr_ext_table_colspec15(n,1) = rptgen.cfr_ext_table_colspec('ColNum',num2str(i),...
        'ColName',['c' num2str(i)]);
    setParent(rptgen_cfr_ext_table_colspec15(n),rptgen_cfr_ext_table4);
end
% Create rptgen.cfr_ext_table_body
rptgen_cfr_ext_table_body4 = rptgen.cfr_ext_table_body;
setParent(rptgen_cfr_ext_table_body4,rptgen_cfr_ext_table4);

cnt=1;
for i=1:nrows
    % Create rptgen.cfr_ext_table_row
    rptgen_cfr_ext_table_row10(i,1) = rptgen.cfr_ext_table_row;
    setParent(rptgen_cfr_ext_table_row10(i,1),rptgen_cfr_ext_table_body4);
    
    for j=1:ncolumns
        rptgen_cfr_ext_table_entry40(i,j) = rptgen.cfr_ext_table_entry;
        setParent(rptgen_cfr_ext_table_entry40(i,j),rptgen_cfr_ext_table_row10(i,1));
        
        if(cnt<=length(f))
            % Create rptgen.cfr_image
            rptgen_cfr_image2(i,j) = rptgen.cfr_image('isCopyFile',false,...
                'MaxViewportSize',[1.5 1.5],...
                'ViewportSize',[1.5 1.5],...
                'ViewportType','fixed',...
                'isInline',true);
             rptgen_cfr_image2(i,j).FileName=f(cnt).name;
            setParent(rptgen_cfr_image2(i,j),rptgen_cfr_ext_table_entry40(i,j));
        end
        cnt=cnt+1;
    end
    
    
end






%% Create rptgen.cfr_section
rptgen_cfr_section5 = rptgen.cfr_section('SectionTitle','T2w');
setParent(rptgen_cfr_section5,rptgen_cfr_section3);
 
% Create rptgen.cfr_ext_table
rptgen_cfr_ext_table5 = rptgen.cfr_ext_table('NumCols','4',...
'TableTitle','SPACE');
setParent(rptgen_cfr_ext_table5,rptgen_cfr_section5);


f=rdir(fullfile(folder,subjid,'images','T2W_AXIAL*.png'));
ll=[];
for i=1:length(f)
    ll(i)=str2num(f(i).name(max(strfind(f(i).name,'_'))+1:strfind(f(i).name,'.')-1));
end
[~,lst]=sort(ll);
f=f(lst); 

ncolumns=4;
nrows = ceil(length(f)/ncolumns);

% Create rptgen.cfr_ext_table_colspec
rptgen_cfr_ext_table_colspec16 = rptgen.cfr_ext_table_colspec;
setParent(rptgen_cfr_ext_table_colspec16,rptgen_cfr_ext_table5);
 
for n=1:ncolumns
    % Create rptgen.cfr_ext_table_colspec
    rptgen_cfr_ext_table_colspec16(n,1) = rptgen.cfr_ext_table_colspec('ColNum',num2str(i),...
        'ColName',['c' num2str(i)]);
    setParent(rptgen_cfr_ext_table_colspec16(n),rptgen_cfr_ext_table5);
end
% Create rptgen.cfr_ext_table_body
rptgen_cfr_ext_table_body5 = rptgen.cfr_ext_table_body;
setParent(rptgen_cfr_ext_table_body5,rptgen_cfr_ext_table5);

cnt=1;
for i=1:nrows
    % Create rptgen.cfr_ext_table_row
    rptgen_cfr_ext_table_row11(i,1) = rptgen.cfr_ext_table_row;
    setParent(rptgen_cfr_ext_table_row11(i,1),rptgen_cfr_ext_table_body5);
    
    for j=1:ncolumns
        rptgen_cfr_ext_table_entry50(i,j) = rptgen.cfr_ext_table_entry;
        setParent(rptgen_cfr_ext_table_entry50(i,j),rptgen_cfr_ext_table_row11(i,1));
        
        if(cnt<=length(f))
            % Create rptgen.cfr_image
            rptgen_cfr_image3(i,j) = rptgen.cfr_image('isCopyFile',false,...
                'MaxViewportSize',[1.5 1.5],...
                'ViewportSize',[1.5 1.5],...
                'ViewportType','fixed',...
                'isInline',true);
             rptgen_cfr_image3(i,j).FileName=f(cnt).name;
            setParent(rptgen_cfr_image3(i,j),rptgen_cfr_ext_table_entry50(i,j));
        end
        cnt=cnt+1;
    end
    
    
end






%% Create rptgen.cfr_section
rptgen_cfr_section6 = rptgen.cfr_section('SectionTitle','FREESURFER');
setParent(rptgen_cfr_section6,rptgen_cfr_section3);
 
% Create rptgen.cfr_ext_table
rptgen_cfr_ext_table6 = rptgen.cfr_ext_table('NumCols','4',...
'TableTitle','FREESURFER');
setParent(rptgen_cfr_ext_table6,rptgen_cfr_section6);


f=rdir(fullfile(folder,subjid,'images','RECON_AXIAL*.png'));
ll=[];
for i=1:length(f)
    ll(i)=str2num(f(i).name(max(strfind(f(i).name,'_'))+1:strfind(f(i).name,'.')-1));
end
[~,lst]=sort(ll);
f=f(lst); 

ncolumns=4;
nrows = ceil(length(f)/ncolumns);

% Create rptgen.cfr_ext_table_colspec
rptgen_cfr_ext_table_colspec17 = rptgen.cfr_ext_table_colspec;
setParent(rptgen_cfr_ext_table_colspec17,rptgen_cfr_ext_table6);
 
for n=1:ncolumns
    % Create rptgen.cfr_ext_table_colspec
    rptgen_cfr_ext_table_colspec17(n,1) = rptgen.cfr_ext_table_colspec('ColNum',num2str(i),...
        'ColName',['c' num2str(i)]);
    setParent(rptgen_cfr_ext_table_colspec17(n),rptgen_cfr_ext_table6);
end
% Create rptgen.cfr_ext_table_body
rptgen_cfr_ext_table_body6 = rptgen.cfr_ext_table_body;
setParent(rptgen_cfr_ext_table_body6,rptgen_cfr_ext_table6);

cnt=1;
for i=1:nrows
    % Create rptgen.cfr_ext_table_row
    rptgen_cfr_ext_table_row12(i,1) = rptgen.cfr_ext_table_row;
    setParent(rptgen_cfr_ext_table_row12(i,1),rptgen_cfr_ext_table_body6);
    
    for j=1:ncolumns
        rptgen_cfr_ext_table_entry60(i,j) = rptgen.cfr_ext_table_entry;
        setParent(rptgen_cfr_ext_table_entry60(i,j),rptgen_cfr_ext_table_row12(i,1));
        
        if(cnt<=length(f))
            % Create rptgen.cfr_image
            rptgen_cfr_image4(i,j) = rptgen.cfr_image('isCopyFile',false,...
                'MaxViewportSize',[1.5 1.5],...
                'ViewportSize',[1.5 1.5],...
                'ViewportType','fixed',...
                'isInline',true);
             rptgen_cfr_image4(i,j).FileName=f(cnt).name;
            setParent(rptgen_cfr_image4(i,j),rptgen_cfr_ext_table_entry60(i,j));
        end
        cnt=cnt+1;
    end
    
    
end



 
% Create rptgen.cfr_section
rptgen_cfr_section7 = rptgen.cfr_section('SectionTitle','Resting State');
setParent(rptgen_cfr_section7,rptgen_cfr_section1);
 
% Create rptgen.cfr_paragraph
rptgen_cfr_paragraph40 = rptgen.cfr_paragraph;
rptgen_cfr_text42 = rptgen.cfr_text('Content','Resting State Scans');
set(rptgen_cfr_paragraph40,'ParaTextComp',rptgen_cfr_text42);
setParent(rptgen_cfr_paragraph40,rptgen_cfr_section7);






% Create rptgen.cfr_ext_table
rptgen_cfr_ext_table7 = nirs.util.reporttable(t4);
rptgen_cfr_ext_table7.TableTitle='RESTING BOLD SCANS';
rptgen_cfr_ext_table7.NumCols=num2str(width(t4));
rptgen_cfr_ext_table7.IsPgwide=1;
setParent(rptgen_cfr_ext_table7,rptgen_cfr_section7);

% 
% t4(find(t4.Number_Scans==1),:)=[];
% 
% for i=1:1; %height(t4)
%     % Create rptgen.cfr_section
%     rptgen_cfr_section8(i,1) = rptgen.cfr_section('StyleName','rgSect2Title',...
%         'SectionTitle',t4.Series{i});
%     setParent(rptgen_cfr_section8(i,1),rptgen_cfr_section7);
%     
%     
%     %% REPLACE
%     if(1)
%         
%         % Create rptgen.cfr_ext_table
%         rptgen_cfr_ext_table8 = rptgen.cfr_ext_table('NumCols','4',...
%             'TableTitle','MPRAGE');
%         setParent(rptgen_cfr_ext_table8,rptgen_cfr_section8);
%         
%         % Create rptgen.cfr_ext_table_colspec
%         rptgen_cfr_ext_table_colspec31 = rptgen.cfr_ext_table_colspec;
%         setParent(rptgen_cfr_ext_table_colspec31,rptgen_cfr_ext_table8);
%         
%         % Create rptgen.cfr_ext_table_colspec
%         rptgen_cfr_ext_table_colspec32 = rptgen.cfr_ext_table_colspec('ColNum','2',...
%             'ColName','c2');
%         setParent(rptgen_cfr_ext_table_colspec32,rptgen_cfr_ext_table8);
%         
%         % Create rptgen.cfr_ext_table_colspec
%         rptgen_cfr_ext_table_colspec33 = rptgen.cfr_ext_table_colspec('ColNum','3',...
%             'ColName','c3');
%         setParent(rptgen_cfr_ext_table_colspec33,rptgen_cfr_ext_table8);
%         
%         % Create rptgen.cfr_ext_table_colspec
%         rptgen_cfr_ext_table_colspec34 = rptgen.cfr_ext_table_colspec('ColNum','4',...
%             'ColName','c4');
%         setParent(rptgen_cfr_ext_table_colspec34,rptgen_cfr_ext_table8);
%         
%         % Create rptgen.cfr_ext_table_body
%         rptgen_cfr_ext_table_body8 = rptgen.cfr_ext_table_body;
%         setParent(rptgen_cfr_ext_table_body8,rptgen_cfr_ext_table8);
%         
%         % Create rptgen.cfr_ext_table_row
%         rptgen_cfr_ext_table_row40 = rptgen.cfr_ext_table_row;
%         setParent(rptgen_cfr_ext_table_row40,rptgen_cfr_ext_table_body8);
%         
%         % Create rptgen.cfr_ext_table_row
%         rptgen_cfr_ext_table_row41 = rptgen.cfr_ext_table_row;
%         setParent(rptgen_cfr_ext_table_row41,rptgen_cfr_ext_table_row40);
%         
%         % Create rptgen.cfr_ext_table_entry
%         rptgen_cfr_ext_table_entry163 = rptgen.cfr_ext_table_entry;
%         setParent(rptgen_cfr_ext_table_entry163,rptgen_cfr_ext_table_row41);
%         
%         % Create rptgen.cfr_image
%         rptgen_cfr_image110 = rptgen.cfr_image('isCopyFile',false,...
%             'MaxViewportSize',[1.5 1.5],...
%             'ViewportSize',[1.5 1.5],...
%             'ViewportType','fixed',...
%             'isInline',true);
%         setParent(rptgen_cfr_image110,rptgen_cfr_ext_table_entry163);
%         
%         % Create rptgen.cfr_ext_table_entry
%         rptgen_cfr_ext_table_entry164 = rptgen.cfr_ext_table_entry;
%         setParent(rptgen_cfr_ext_table_entry164,rptgen_cfr_ext_table_row41);
%         
%         % Create rptgen.cfr_image
%         rptgen_cfr_image111 = rptgen.cfr_image('isCopyFile',false,...
%             'MaxViewportSize',[1.5 1.5],...
%             'ViewportSize',[1.5 1.5],...
%             'ViewportType','fixed',...
%             'isInline',true);
%         setParent(rptgen_cfr_image111,rptgen_cfr_ext_table_entry164);
%         
%         % Create rptgen.cfr_ext_table_entry
%         rptgen_cfr_ext_table_entry165 = rptgen.cfr_ext_table_entry;
%         setParent(rptgen_cfr_ext_table_entry165,rptgen_cfr_ext_table_row41);
%         
%         % Create rptgen.cfr_image
%         rptgen_cfr_image112 = rptgen.cfr_image('isCopyFile',false,...
%             'MaxViewportSize',[1.5 1.5],...
%             'ViewportSize',[1.5 1.5],...
%             'ViewportType','fixed',...
%             'isInline',true);
%         setParent(rptgen_cfr_image112,rptgen_cfr_ext_table_entry165);
%         
%         % Create rptgen.cfr_ext_table_entry
%         rptgen_cfr_ext_table_entry166 = rptgen.cfr_ext_table_entry;
%         setParent(rptgen_cfr_ext_table_entry166,rptgen_cfr_ext_table_row41);
%         
%         % Create rptgen.cfr_image
%         rptgen_cfr_image113 = rptgen.cfr_image('isCopyFile',false,...
%             'MaxViewportSize',[1.5 1.5],...
%             'ViewportSize',[1.5 1.5],...
%             'ViewportType','fixed',...
%             'isInline',true);
%         setParent(rptgen_cfr_image113,rptgen_cfr_ext_table_entry166);
%         
%         % Create rptgen.cfr_ext_table_entry
%         rptgen_cfr_ext_table_entry167 = rptgen.cfr_ext_table_entry;
%         setParent(rptgen_cfr_ext_table_entry167,rptgen_cfr_ext_table_row40);
%         
%         % Create rptgen.cfr_image
%         rptgen_cfr_image114 = rptgen.cfr_image('isCopyFile',false,...
%             'MaxViewportSize',[1.5 1.5],...
%             'ViewportSize',[1.5 1.5],...
%             'ViewportType','fixed',...
%             'isInline',true);
%         setParent(rptgen_cfr_image114,rptgen_cfr_ext_table_entry167);
%         
%         % Create rptgen.cfr_ext_table_entry
%         rptgen_cfr_ext_table_entry168 = rptgen.cfr_ext_table_entry;
%         setParent(rptgen_cfr_ext_table_entry168,rptgen_cfr_ext_table_row40);
%         
%         % Create rptgen.cfr_image
%         rptgen_cfr_image115 = rptgen.cfr_image('isCopyFile',false,...
%             'MaxViewportSize',[1.5 1.5],...
%             'ViewportSize',[1.5 1.5],...
%             'ViewportType','fixed',...
%             'isInline',true);
%         setParent(rptgen_cfr_image115,rptgen_cfr_ext_table_entry168);
%         
%         % Create rptgen.cfr_ext_table_entry
%         rptgen_cfr_ext_table_entry169 = rptgen.cfr_ext_table_entry;
%         setParent(rptgen_cfr_ext_table_entry169,rptgen_cfr_ext_table_row40);
%         
%         % Create rptgen.cfr_image
%         rptgen_cfr_image116 = rptgen.cfr_image('isCopyFile',false,...
%             'MaxViewportSize',[1.5 1.5],...
%             'ViewportSize',[1.5 1.5],...
%             'ViewportType','fixed',...
%             'isInline',true);
%         setParent(rptgen_cfr_image116,rptgen_cfr_ext_table_entry169);
%         
%         % Create rptgen.cfr_ext_table_entry
%         rptgen_cfr_ext_table_entry170 = rptgen.cfr_ext_table_entry;
%         setParent(rptgen_cfr_ext_table_entry170,rptgen_cfr_ext_table_row40);
%         
%         % Create rptgen.cfr_image
%         rptgen_cfr_image117 = rptgen.cfr_image('isCopyFile',false,...
%             'MaxViewportSize',[1.5 1.5],...
%             'ViewportSize',[1.5 1.5],...
%             'ViewportType','fixed',...
%             'isInline',true);
%         setParent(rptgen_cfr_image117,rptgen_cfr_ext_table_entry170);
%         
%         % Create rptgen.cfr_ext_table_row
%         rptgen_cfr_ext_table_row42 = rptgen.cfr_ext_table_row;
%         setParent(rptgen_cfr_ext_table_row42,rptgen_cfr_ext_table_body8);
%         
%         % Create rptgen.cfr_ext_table_entry
%         rptgen_cfr_ext_table_entry171 = rptgen.cfr_ext_table_entry;
%         setParent(rptgen_cfr_ext_table_entry171,rptgen_cfr_ext_table_row42);
%         
%         % Create rptgen.cfr_image
%         rptgen_cfr_image118 = rptgen.cfr_image('isCopyFile',false,...
%             'MaxViewportSize',[1.5 1.5],...
%             'ViewportSize',[1.5 1.5],...
%             'ViewportType','fixed',...
%             'isInline',true);
%         setParent(rptgen_cfr_image118,rptgen_cfr_ext_table_entry171);
%         
%         % Create rptgen.cfr_ext_table_entry
%         rptgen_cfr_ext_table_entry172 = rptgen.cfr_ext_table_entry;
%         setParent(rptgen_cfr_ext_table_entry172,rptgen_cfr_ext_table_row42);
%         
%         % Create rptgen.cfr_image
%         rptgen_cfr_image119 = rptgen.cfr_image('isCopyFile',false,...
%             'MaxViewportSize',[1.5 1.5],...
%             'ViewportSize',[1.5 1.5],...
%             'ViewportType','fixed',...
%             'isInline',true);
%         setParent(rptgen_cfr_image119,rptgen_cfr_ext_table_entry172);
%         
%         % Create rptgen.cfr_ext_table_entry
%         rptgen_cfr_ext_table_entry173 = rptgen.cfr_ext_table_entry;
%         setParent(rptgen_cfr_ext_table_entry173,rptgen_cfr_ext_table_row42);
%         
%         % Create rptgen.cfr_image
%         rptgen_cfr_image120 = rptgen.cfr_image('isCopyFile',false,...
%             'MaxViewportSize',[1.5 1.5],...
%             'ViewportSize',[1.5 1.5],...
%             'ViewportType','fixed',...
%             'isInline',true);
%         setParent(rptgen_cfr_image120,rptgen_cfr_ext_table_entry173);
%         
%         % Create rptgen.cfr_ext_table_entry
%         rptgen_cfr_ext_table_entry174 = rptgen.cfr_ext_table_entry;
%         setParent(rptgen_cfr_ext_table_entry174,rptgen_cfr_ext_table_row42);
%         
%         % Create rptgen.cfr_image
%         rptgen_cfr_image121 = rptgen.cfr_image('isCopyFile',false,...
%             'MaxViewportSize',[1.5 1.5],...
%             'ViewportSize',[1.5 1.5],...
%             'ViewportType','fixed',...
%             'isInline',true);
%         setParent(rptgen_cfr_image121,rptgen_cfr_ext_table_entry174);
%         
%         % Create rptgen.cfr_image
%         rptgen_cfr_image122 = rptgen.cfr_image('MaxViewportSize',[3 9],...
%             'ViewportSize',[3 9],...
%             'ViewportType','fixed');
%         setParent(rptgen_cfr_image122,rptgen_cfr_section8);
%     end
%     
%     
% end





 
% Create rptgen.cfr_section
rptgen_cfr_section9 = rptgen.cfr_section('SectionTitle','Segmentation Statistics');
setParent(rptgen_cfr_section9,rptgen_cfr_section1);
 
% Create rptgen.cfr_paragraph
rptgen_cfr_paragraph41 = rptgen.cfr_paragraph;
rptgen_cfr_text444 = rptgen.cfr_text('Content','FreeSurfer Stats');
set(rptgen_cfr_paragraph41,'ParaTextComp',rptgen_cfr_text444);
setParent(rptgen_cfr_paragraph41,rptgen_cfr_section9);


ff=rdir(fullfile(folder,subjid,'stats','*.stats'));


for i=1:length(ff)
    try
    tbl=HCP_stats2table(ff(i).name);
    [~,pp]=fileparts(ff(i).name);
    % Create rptgen.cfr_section
    rptgen_cfr_section2b(i) = rptgen.cfr_section('SectionTitle',pp);
    setParent(rptgen_cfr_section2b(i),rptgen_cfr_section9);
    
    
    % Create rptgen.cfr_ext_table
    rptgen_cfr_ext_table1b(i) = nirs.util.reporttable(tbl);
    rptgen_cfr_ext_table1b(i).TableTitle=pp;
    rptgen_cfr_ext_table1b(i).NumCols=num2str(width(tbl));
    rptgen_cfr_ext_table1b(i).IsPgwide=1;
    
    setParent(rptgen_cfr_ext_table1b(i),rptgen_cfr_section2b(i));
    end
end





return






% 
% 
% 
% 
% 
% 
% 
% 
% 
% 
% % Create rptgen.cfr_section
% rptgen_cfr_section16 = rptgen.cfr_section('StyleName','rgChapterTitle',...
% 'SectionTitle','MEG Information');
% setParent(rptgen_cfr_section16,RptgenML_CReport1);
%  
% % Create rptgen.cfr_section
% rptgen_cfr_section17 = rptgen.cfr_section('StyleName','rgSect1Title',...
% 'SectionTitle','Registration');
% setParent(rptgen_cfr_section17,rptgen_cfr_section16);
%  
% % Create rptgen.cfr_ext_table
% rptgen_cfr_ext_table15 = rptgen.cfr_ext_table('NumCols','3');
% setParent(rptgen_cfr_ext_table15,rptgen_cfr_section17);
%  
% % Create rptgen.cfr_ext_table_colspec
% rptgen_cfr_ext_table_colspec60 = rptgen.cfr_ext_table_colspec;
% setParent(rptgen_cfr_ext_table_colspec60,rptgen_cfr_ext_table15);
%  
% % Create rptgen.cfr_ext_table_colspec
% rptgen_cfr_ext_table_colspec61 = rptgen.cfr_ext_table_colspec('ColNum','2',...
% 'ColName','c2');
% setParent(rptgen_cfr_ext_table_colspec61,rptgen_cfr_ext_table15);
%  
% % Create rptgen.cfr_ext_table_colspec
% rptgen_cfr_ext_table_colspec62 = rptgen.cfr_ext_table_colspec('ColNum','3',...
% 'ColName','c3');
% setParent(rptgen_cfr_ext_table_colspec62,rptgen_cfr_ext_table15);
%  
% % Create rptgen.cfr_ext_table_body
% rptgen_cfr_ext_table_body15 = rptgen.cfr_ext_table_body;
% setParent(rptgen_cfr_ext_table_body15,rptgen_cfr_ext_table15);
%  
% % Create rptgen.cfr_ext_table_row
% rptgen_cfr_ext_table_row61 = rptgen.cfr_ext_table_row;
% setParent(rptgen_cfr_ext_table_row61,rptgen_cfr_ext_table_body15);
%  
% % Create rptgen.cfr_ext_table_entry
% rptgen_cfr_ext_table_entry250 = rptgen.cfr_ext_table_entry;
% setParent(rptgen_cfr_ext_table_entry250,rptgen_cfr_ext_table_row61);
%  
% % Create rptgen.cfr_image
% rptgen_cfr_image188 = rptgen.cfr_image('MaxViewportSize',[7 9]);
% setParent(rptgen_cfr_image188,rptgen_cfr_ext_table_entry250);
%  
% % Create rptgen.cfr_ext_table_entry
% rptgen_cfr_ext_table_entry251 = rptgen.cfr_ext_table_entry;
% setParent(rptgen_cfr_ext_table_entry251,rptgen_cfr_ext_table_row61);
%  
% % Create rptgen.cfr_image
% rptgen_cfr_image189 = rptgen.cfr_image('MaxViewportSize',[7 9]);
% setParent(rptgen_cfr_image189,rptgen_cfr_ext_table_entry251);
%  
% % Create rptgen.cfr_ext_table_entry
% rptgen_cfr_ext_table_entry252 = rptgen.cfr_ext_table_entry;
% setParent(rptgen_cfr_ext_table_entry252,rptgen_cfr_ext_table_row61);
%  
% % Create rptgen.cfr_image
% rptgen_cfr_image190 = rptgen.cfr_image('MaxViewportSize',[7 9]);
% setParent(rptgen_cfr_image190,rptgen_cfr_ext_table_entry252);
%  
% % Create rptgen.cfr_ext_table_row
% rptgen_cfr_ext_table_row62 = rptgen.cfr_ext_table_row;
% setParent(rptgen_cfr_ext_table_row62,rptgen_cfr_ext_table_body15);
%  
% % Create rptgen.cfr_ext_table_entry
% rptgen_cfr_ext_table_entry253 = rptgen.cfr_ext_table_entry;
% setParent(rptgen_cfr_ext_table_entry253,rptgen_cfr_ext_table_row62);
%  
% % Create rptgen.cfr_image
% rptgen_cfr_image191 = rptgen.cfr_image('MaxViewportSize',[7 9]);
% setParent(rptgen_cfr_image191,rptgen_cfr_ext_table_entry253);
%  
% % Create rptgen.cfr_ext_table_entry
% rptgen_cfr_ext_table_entry254 = rptgen.cfr_ext_table_entry;
% setParent(rptgen_cfr_ext_table_entry254,rptgen_cfr_ext_table_row62);
%  
% % Create rptgen.cfr_image
% rptgen_cfr_image192 = rptgen.cfr_image('MaxViewportSize',[7 9]);
% setParent(rptgen_cfr_image192,rptgen_cfr_ext_table_entry254);
%  
% % Create rptgen.cfr_ext_table_entry
% rptgen_cfr_ext_table_entry255 = rptgen.cfr_ext_table_entry;
% setParent(rptgen_cfr_ext_table_entry255,rptgen_cfr_ext_table_row62);
%  
% % Create rptgen.cfr_image
% rptgen_cfr_image193 = rptgen.cfr_image('MaxViewportSize',[7 9]);
% setParent(rptgen_cfr_image193,rptgen_cfr_ext_table_entry255);
%  
% % Create rptgen.cfr_section
% rptgen_cfr_section18 = rptgen.cfr_section('StyleName','rgSect1Title',...
% 'SectionTitle','Resting State');
% setParent(rptgen_cfr_section18,rptgen_cfr_section16);
%  
% % Create rptgen.cfr_section
% rptgen_cfr_section19 = rptgen.cfr_section('StyleName','rgSect2Title',...
% 'SectionTitle','RESTING 1');
% setParent(rptgen_cfr_section19,rptgen_cfr_section18);
%  
% % Create rptgen.cfr_image
% rptgen_cfr_image194 = rptgen.cfr_image('MaxViewportSize',[3 9],...
% 'ViewportSize',[3 9],...
% 'ViewportType','fixed');
% setParent(rptgen_cfr_image194,rptgen_cfr_section19);
%  
% % Create rptgen.cfr_ext_table
% rptgen_cfr_ext_table16 = rptgen.cfr_ext_table('NumCols','1',...
% 'TableTitle','MEG_REST1');
% setParent(rptgen_cfr_ext_table16,rptgen_cfr_section19);
%  
% % Create rptgen.cfr_ext_table_colspec
% rptgen_cfr_ext_table_colspec63 = rptgen.cfr_ext_table_colspec;
% setParent(rptgen_cfr_ext_table_colspec63,rptgen_cfr_ext_table16);
%  
% % Create rptgen.cfr_ext_table_body
% rptgen_cfr_ext_table_body16 = rptgen.cfr_ext_table_body;
% setParent(rptgen_cfr_ext_table_body16,rptgen_cfr_ext_table16);
%  
% % Create rptgen.cfr_ext_table_row
% rptgen_cfr_ext_table_row63 = rptgen.cfr_ext_table_row;
% setParent(rptgen_cfr_ext_table_row63,rptgen_cfr_ext_table_body16);
%  
% % Create rptgen.cfr_ext_table_entry
% rptgen_cfr_ext_table_entry256 = rptgen.cfr_ext_table_entry;
% setParent(rptgen_cfr_ext_table_entry256,rptgen_cfr_ext_table_row63);
%  
% % Create rptgen.cfr_image
% rptgen_cfr_image195 = rptgen.cfr_image('MaxViewportSize',[2 9],...
% 'ViewportSize',[2 9],...
% 'ViewportType','fixed',...
% 'Caption','0-60s');
% setParent(rptgen_cfr_image195,rptgen_cfr_ext_table_entry256);
%  
% % Create rptgen.cfr_ext_table_row
% rptgen_cfr_ext_table_row64 = rptgen.cfr_ext_table_row;
% setParent(rptgen_cfr_ext_table_row64,rptgen_cfr_ext_table_body16);
%  
% % Create rptgen.cfr_ext_table_entry
% rptgen_cfr_ext_table_entry257 = rptgen.cfr_ext_table_entry;
% setParent(rptgen_cfr_ext_table_entry257,rptgen_cfr_ext_table_row64);
%  
% % Create rptgen.cfr_image
% rptgen_cfr_image196 = rptgen.cfr_image('MaxViewportSize',[2 9],...
% 'ViewportSize',[2 9],...
% 'ViewportType','fixed',...
% 'Caption','0-60s');
% setParent(rptgen_cfr_image196,rptgen_cfr_ext_table_entry257);
%  
% % Create rptgen.cfr_ext_table_row
% rptgen_cfr_ext_table_row65 = rptgen.cfr_ext_table_row;
% setParent(rptgen_cfr_ext_table_row65,rptgen_cfr_ext_table_body16);
%  
% % Create rptgen.cfr_ext_table_entry
% rptgen_cfr_ext_table_entry258 = rptgen.cfr_ext_table_entry;
% setParent(rptgen_cfr_ext_table_entry258,rptgen_cfr_ext_table_row65);
%  
% % Create rptgen.cfr_image
% rptgen_cfr_image197 = rptgen.cfr_image('MaxViewportSize',[2 9],...
% 'ViewportSize',[2 9],...
% 'ViewportType','fixed',...
% 'Caption','0-60s');
% setParent(rptgen_cfr_image197,rptgen_cfr_ext_table_entry258);
%  
% % Create rptgen.cfr_section
% rptgen_cfr_section20 = rptgen.cfr_section('StyleName','rgSect2Title',...
% 'SectionTitle','RESTING 2');
% setParent(rptgen_cfr_section20,rptgen_cfr_section18);
%  
% % Create rptgen.cfr_image
% rptgen_cfr_image198 = rptgen.cfr_image('MaxViewportSize',[3 9],...
% 'ViewportSize',[3 9],...
% 'ViewportType','fixed');
% setParent(rptgen_cfr_image198,rptgen_cfr_section20);
%  
% % Create rptgen.cfr_ext_table
% rptgen_cfr_ext_table17 = rptgen.cfr_ext_table('NumCols','1',...
% 'TableTitle','MEG_REST1');
% setParent(rptgen_cfr_ext_table17,rptgen_cfr_section20);
%  
% % Create rptgen.cfr_ext_table_colspec
% rptgen_cfr_ext_table_colspec64 = rptgen.cfr_ext_table_colspec;
% setParent(rptgen_cfr_ext_table_colspec64,rptgen_cfr_ext_table17);
%  
% % Create rptgen.cfr_ext_table_body
% rptgen_cfr_ext_table_body17 = rptgen.cfr_ext_table_body;
% setParent(rptgen_cfr_ext_table_body17,rptgen_cfr_ext_table17);
%  
% % Create rptgen.cfr_ext_table_row
% rptgen_cfr_ext_table_row66 = rptgen.cfr_ext_table_row;
% setParent(rptgen_cfr_ext_table_row66,rptgen_cfr_ext_table_body17);
%  
% % Create rptgen.cfr_ext_table_entry
% rptgen_cfr_ext_table_entry259 = rptgen.cfr_ext_table_entry;
% setParent(rptgen_cfr_ext_table_entry259,rptgen_cfr_ext_table_row66);
%  
% % Create rptgen.cfr_image
% rptgen_cfr_image199 = rptgen.cfr_image('MaxViewportSize',[2 9],...
% 'ViewportSize',[2 9],...
% 'ViewportType','fixed',...
% 'Caption','0-60s');
% setParent(rptgen_cfr_image199,rptgen_cfr_ext_table_entry259);
%  
% % Create rptgen.cfr_ext_table_row
% rptgen_cfr_ext_table_row67 = rptgen.cfr_ext_table_row;
% setParent(rptgen_cfr_ext_table_row67,rptgen_cfr_ext_table_body17);
%  
% % Create rptgen.cfr_ext_table_entry
% rptgen_cfr_ext_table_entry260 = rptgen.cfr_ext_table_entry;
% setParent(rptgen_cfr_ext_table_entry260,rptgen_cfr_ext_table_row67);
%  
% % Create rptgen.cfr_image
% rptgen_cfr_image200 = rptgen.cfr_image('MaxViewportSize',[2 9],...
% 'ViewportSize',[2 9],...
% 'ViewportType','fixed',...
% 'Caption','0-60s');
% setParent(rptgen_cfr_image200,rptgen_cfr_ext_table_entry260);
%  
% % Create rptgen.cfr_ext_table_row
% rptgen_cfr_ext_table_row68 = rptgen.cfr_ext_table_row;
% setParent(rptgen_cfr_ext_table_row68,rptgen_cfr_ext_table_body17);
%  
% % Create rptgen.cfr_ext_table_entry
% rptgen_cfr_ext_table_entry261 = rptgen.cfr_ext_table_entry;
% setParent(rptgen_cfr_ext_table_entry261,rptgen_cfr_ext_table_row68);
%  
% % Create rptgen.cfr_image
% rptgen_cfr_image201 = rptgen.cfr_image('MaxViewportSize',[2 9],...
% 'ViewportSize',[2 9],...
% 'ViewportType','fixed',...
% 'Caption','0-60s');
% setParent(rptgen_cfr_image201,rptgen_cfr_ext_table_entry261);
%  
% % Create rptgen.cfr_section
% rptgen_cfr_section21 = rptgen.cfr_section('StyleName','rgSect1Title',...
% 'SectionTitle','Task');
% setParent(rptgen_cfr_section21,rptgen_cfr_section16);
%  
% % Create rptgen.cfr_section
% rptgen_cfr_section22 = rptgen.cfr_section('StyleName','rgSect2Title',...
% 'SectionTitle','WM 1');
% setParent(rptgen_cfr_section22,rptgen_cfr_section21);
%  
% % Create rptgen.cfr_image
% rptgen_cfr_image202 = rptgen.cfr_image('MaxViewportSize',[3 9],...
% 'ViewportSize',[3 9],...
% 'ViewportType','fixed');
% setParent(rptgen_cfr_image202,rptgen_cfr_section22);
%  
% % Create rptgen.cfr_ext_table
% rptgen_cfr_ext_table18 = rptgen.cfr_ext_table('NumCols','1',...
% 'TableTitle','MEG_REST1');
% setParent(rptgen_cfr_ext_table18,rptgen_cfr_section22);
%  
% % Create rptgen.cfr_ext_table_colspec
% rptgen_cfr_ext_table_colspec65 = rptgen.cfr_ext_table_colspec;
% setParent(rptgen_cfr_ext_table_colspec65,rptgen_cfr_ext_table18);
%  
% % Create rptgen.cfr_ext_table_body
% rptgen_cfr_ext_table_body18 = rptgen.cfr_ext_table_body;
% setParent(rptgen_cfr_ext_table_body18,rptgen_cfr_ext_table18);
%  
% % Create rptgen.cfr_ext_table_row
% rptgen_cfr_ext_table_row69 = rptgen.cfr_ext_table_row;
% setParent(rptgen_cfr_ext_table_row69,rptgen_cfr_ext_table_body18);
%  
% % Create rptgen.cfr_ext_table_entry
% rptgen_cfr_ext_table_entry262 = rptgen.cfr_ext_table_entry;
% setParent(rptgen_cfr_ext_table_entry262,rptgen_cfr_ext_table_row69);
%  
% % Create rptgen.cfr_image
% rptgen_cfr_image203 = rptgen.cfr_image('MaxViewportSize',[2 9],...
% 'ViewportSize',[2 9],...
% 'ViewportType','fixed',...
% 'Caption','0-60s');
% setParent(rptgen_cfr_image203,rptgen_cfr_ext_table_entry262);
%  
% % Create rptgen.cfr_section
% rptgen_cfr_section23 = rptgen.cfr_section('StyleName','rgSect2Title',...
% 'SectionTitle','WM 2');
% setParent(rptgen_cfr_section23,rptgen_cfr_section21);
%  
% % Create rptgen.cfr_image
% rptgen_cfr_image204 = rptgen.cfr_image('MaxViewportSize',[3 9],...
% 'ViewportSize',[3 9],...
% 'ViewportType','fixed');
% setParent(rptgen_cfr_image204,rptgen_cfr_section23);
%  
% % Create rptgen.cfr_ext_table
% rptgen_cfr_ext_table19 = rptgen.cfr_ext_table('NumCols','1',...
% 'TableTitle','MEG_REST1');
% setParent(rptgen_cfr_ext_table19,rptgen_cfr_section23);
%  
% % Create rptgen.cfr_ext_table_colspec
% rptgen_cfr_ext_table_colspec66 = rptgen.cfr_ext_table_colspec;
% setParent(rptgen_cfr_ext_table_colspec66,rptgen_cfr_ext_table19);
%  
% % Create rptgen.cfr_ext_table_body
% rptgen_cfr_ext_table_body19 = rptgen.cfr_ext_table_body;
% setParent(rptgen_cfr_ext_table_body19,rptgen_cfr_ext_table19);
%  
% % Create rptgen.cfr_ext_table_row
% rptgen_cfr_ext_table_row70 = rptgen.cfr_ext_table_row;
% setParent(rptgen_cfr_ext_table_row70,rptgen_cfr_ext_table_body19);
%  
% % Create rptgen.cfr_ext_table_entry
% rptgen_cfr_ext_table_entry263 = rptgen.cfr_ext_table_entry;
% setParent(rptgen_cfr_ext_table_entry263,rptgen_cfr_ext_table_row70);
%  
% % Create rptgen.cfr_image
% rptgen_cfr_image205 = rptgen.cfr_image('MaxViewportSize',[2 9],...
% 'ViewportSize',[2 9],...
% 'ViewportType','fixed',...
% 'Caption','0-60s');
% setParent(rptgen_cfr_image205,rptgen_cfr_ext_table_entry263);
 
