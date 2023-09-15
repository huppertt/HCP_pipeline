function HCP_QCreportASL(folder,subjid);

if(nargin<1)
    folder='/disk/HCP/analyzed';
end

if(nargin<2)
    subjd=rdir(fullfile(folder,'*','stats','aseg.stats'));
    for i=1:length(subjd)
        subjid=strtok(subjd(i).name(length(folder)+2:end),'/');
        try;
            HCP_QCreportASL(folder,subjid);
        catch
            warning(['QC for ' subjid ' failed:' lasterr]);
        end
    end
    return
end

if(exist([folder filesep subjid filesep 'stats' filesep 'ASL_' subjid '.pdf']))
    disp(['Exists: skipping ' subjid]);
    return
end


curdir=pwd;

rpt = RptgenML.CReport('Description','HCP QC Stage-1 Report');
set(rpt,'Format','pdf-fop','Stylesheet','fo-NoChapterNumbers');

cfr_titlepage = rptgen.cfr_titlepage;
cfr_titlepage.Title=['HCP QC anlysis of ' subjid];
cfr_titlepage.Subtitle=['Analysis run on' datestr(now)];
setParent(cfr_titlepage,rpt);


sMRIrpt=rptgen.cfr_section('SectionTitle','ASL');
types={'ASL_MEDAIR1' 'ASL_MEDAIR2' 'ASL_MEDAIR3' 'ASL_CO2_1','ASL_CO2_2'};
cnt=1;
for j=1:length(types)
    try
    cfr_section3(cnt) = FreeSurfer_Report(folder,subjid,types{j});
    setParent(cfr_section3(cnt),sMRIrpt);
    cnt=cnt+1;
    end    
end

if(cnt==1)
   cd(curdir);
    return
end

setParent(sMRIrpt,rpt);

% 
% 
% 
% 
% MEGrpt=rptgen.cfr_section('SectionTitle','MEG Data');
% ff=rdir(fullfile(folder,subjid,'MEG*'));
% if(~isempty(ff))
%     cnt=1;
%     types={'raw'};
%     for j=1:length(types)
%         cfr_section2(j) = HCP_QA_report_MEG(folder,subjid,types{j});
%         setParent(cfr_section2(j),MEGrpt);
%     end
%     setParent(MEGrpt,rpt);
% end
% 

try
    save(fullfile(folder,subjid,'images','report.mat'),'rpt')
    cd(fullfile(folder,subjid,'images'));
    tt=report(rpt);
    system(['mv ' tt ' ' folder filesep subjid filesep 'stats' filesep 'ASL_' subjid '.pdf']);
end
% 
% system(['mkdir -p /Users/huppert/Desktop/HCPtmp/' subjid]);
% system(['mv /disk/HCP/analyzed/' subjid '/images /Useres/huppert/Desktop/HCPtmp/' subjid]);

cd(curdir);