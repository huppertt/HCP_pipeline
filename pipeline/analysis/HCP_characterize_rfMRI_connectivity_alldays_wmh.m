  
outfolder = '/disk/HCP/analyzed'; 
subs = dir(outfolder);
subjids = {};
for i = 1:length(subs)
    if subs(i).isdir
        subjids = [subjids ; subs(i).name];
    end
end

%Subjids final list
subjids = {'HCP205'	'HCP206'	'HCP208'	'HCP209'	'HCP212'	'HCP213'	'HCP215'	'HCP216'	'HCP218'	'HCP222'	'HCP224'	'HCP225'	'HCP226'	'HCP227'	'HCP229'	'HCP230'	'HCP231'	'HCP235'	'HCP236'	'HCP242'	'HCP243'	'HCP244'	'HCP246'	'HCP247'	'HCP248'	'HCP250'	'HCP251'	'HCP252'	'HCP253'	'HCP256'	'HCP258'	'HCP259'	'HCP263'	'HCP264'	'HCP265'	'HCP266'	'HCP267'	'HCP268'	'HCP270'	'HCP271'	'HCP273'	'HCP275'	'HCP276'	'HCP279'	'HCP280'	'HCP281'	'HCP282'	'HCP283'	'HCP284'	'HCP285'	'HCP286'	'HCP288'	'HCP289'	'HCP290'	'HCP292'	'HCP293'	'HCP294'	'HCP296'	'HCP297'	'HCP298'	'HCP299'	'HCP302'	'HCP303'	'HCP304'	'HCP305'	'HCP306'	'HCP307'	'HCP308'	'HCP309'	'HCP310'	'HCP315'	'HCP319'	'HCP325'	'HCP327'	'HCP328'	'HCP329'	'HCP332'	'HCP334'	'HCP336'	'HCP337'	'HCP340'	'HCP341'	'HCP343'	'HCP345'	'HCP349'	'HCP350'	'HCP351'	'HCP354'	'HCP355'	'HCP356'	'HCP357'	'HCP358'	'HCP359'	'HCP360'	'HCP362'	'HCP363'	'HCP364'	'HCP365'	'HCP366'	'HCP367'	'HCP368'	'HCP369'	'HCP370'	'HCP372'	'HCP373'	'HCP379'	'HCP382'	'HCP383'	'HCP384'	'HCP387'	'HCP390'	'HCP391'	'HCP393'	'HCP394'	'HCP399'	'HCP400'	'HCP404'	'HCP405'	'HCP406'	'HCP407'	'HCP409'	'HCP411'	'HCP412'	'HCP414'	'HCP415'	'HCP417'	'HCP418'	'HCP419'	'HCP420'	'HCP421'	'HCP422'	'HCP423'	'HCP424'	'HCP425'	'HCP426'	'HCP427'	'HCP428'	'HCP429'	'HCP432'	'HCP437'	'HCP438'	'HCP439'	'HCP442'	'HCP446'	'HCP447'	'HCP449'	'HCP450'	'HCP451'	'HCP453'	'HCP454'	'HCP455'	'HCP456'	'HCP457'	'HCP458'	'HCP460'	'HCP461'	'HCP462'	'HCP465'	'HCP466'	'HCP467'	'HCP468'	'HCP469'	'HCP470'	'HCP473'	'HCP475'	'HCP476'	'HCP477'	'HCP478'	'HCP481'	'HCP482'	'HCP484'	'HCP485'	'HCP486'	'HCP487'	'HCP490'	'HCP491'	'HCP494'	'HCP495'	'HCP498'	'HCP501'	'HCP502'	'HCP503'	'HCP505'	'HCP507'	'HCP510'	'HCP511'	'HCP512'	'HCP513'	'HCP515'	'HCP516'	'HCP517'	'HCP518'	'HCP520'	'HCP522'	'HCP523'	'HCP524'	'HCP525'	'HCP526'	'HCP529'	'HCP530'	'HCP531'};

have_conn = {};
for i = 1:length(subjids)
    if exist(fullfile(outfolder,subjids{i},'T1w',subjids{i},'dmri',[subjids{i} '_rfMRI_conn_matrices_alldays.mat']))
        have_conn = [have_conn;subjids{i}];
    end
end
disp(['Number of subjects with all days connectivity is ' num2str(length(have_conn))])

% have_dti = {};
% for i = 1:length(subjids)
%     if exist(fullfile(outfolder,subjids{i},'T1w',subjids{i},'dmri',[subjids{i} '_dsistudio.fib.gz.HCP-MMP_subcort_atlas.count.end.connectivity.mat']),'file') % |...
%            % exist(fullfile(outfolder,subjids{i},'T1w',subjids{i},'dmri',[subjids{i} '_dsistudio.trk.gz.HCP-MMP_subcort_atlas.count.end.connectivity.mat']),'file')
%         have_dti = [have_dti;subjids{i}];
%     end
% end
% disp(['Number of subjects that have DTI is ' num2str(length(have_dti))])
% 
% have_wmh = {};
% for i = 1:length(subjids)
%     if exist(fullfile(outfolder,subjids{i},'T1w',subjids{i},'dmri',[subjids{i} '_dsistudio.fib.gz.HCP-MMP_subcort_atlas.lesion.end.connectivity.mat']),'file') % | ...
%           %  exist(fullfile(outfolder,subjids{i},'T1w',subjids{i},'dmri',[subjids{i} '_dsistudio.trk.gz.HCP-MMP_subcort_atlas.lesion.end.connectivity.mat']),'file')
%         have_wmh = [have_wmh;subjids{i}];
%     end
% end
% disp(['Number of subjects that have WMH is ' num2str(length(have_wmh))])

have_dti = {};
for i = 1:length(subjids)
    if exist(fullfile(outfolder,subjids{i},'T1w',subjids{i},'dmri',[subjids{i} '_dsistudio.trk.gz.HCP-MMP_subcort_atlas.count.end.connectivity.mat']),'file')
        have_dti = [have_dti;subjids{i}];
    end
end
disp(['Number of subjects that have DTI is ' num2str(length(have_dti))])

have_dti_wmh = {};
for i = 1:length(subjids)
    if exist(fullfile(outfolder,subjids{i},'T1w',subjids{i},'dmri',[subjids{i} '_WMH_conn.HCP-MMP_subcort_atlas.count.end.connectivity.mat']),'file')
        have_dti_wmh = [have_dti_wmh;subjids{i}];
    end
end
disp(['Number of subjects that have DTI-WMHonly is ' num2str(length(have_dti_wmh))])

have_wmh = {};
for i = 1:length(subjids)
    if exist(fullfile(outfolder,subjids{i},'T1w',subjids{i},'dmri',[subjids{i} '_dsistudio.trk.gz.HCP-MMP_subcort_atlas.lesion.end.connectivity.mat']),'file')
        have_wmh = [have_wmh;subjids{i}];
    end
end
disp(['Number of subjects that have WMH is ' num2str(length(have_wmh))])


have_conn = have_conn(ismember(have_conn,have_dti));
have_conn = have_conn(ismember(have_conn,have_dti_wmh));
have_conn = have_conn(ismember(have_conn,have_wmh));

disp(['Number of subjects that have all is ' num2str(length(have_conn))])

for i = 1:8
dat_raw(i).fconn_stack = [];
dat_raw_ar(i).fconn_stack = [];
dat_res(i).fconn_stack = [];
dat_res_ar(i).fconn_stack = [];
end


DTI_components = [];
dconn_stack = [];
dconn_wmh_stack = [];
wmh_stack = [];

for i = 1:length(have_conn)
    disp([num2str(i) ' ' have_conn{i} ' loading data and stacking matrices'])
    load(fullfile(outfolder,have_conn{i},'T1w',have_conn{i},'dmri',[have_conn{i} '_rfMRI_conn_matrices_alldays.mat']))
    if exist(fullfile(outfolder,have_conn{i},'T1w',have_conn{i},'dmri',[have_conn{i} '_dsistudio.fib.gz.HCP-MMP_subcort_atlas.count.end.connectivity.mat']),'file')
        load(fullfile(outfolder,have_conn{i},'T1w',have_conn{i},'dmri',[have_conn{i} '_dsistudio.fib.gz.HCP-MMP_subcort_atlas.count.end.connectivity.mat']))
    elseif exist(fullfile(outfolder,have_conn{i},'T1w',have_conn{i},'dmri',[have_conn{i} '_dsistudio.trk.gz.HCP-MMP_subcort_atlas.count.end.connectivity.mat']),'file')
        load(fullfile(outfolder,have_conn{i},'T1w',have_conn{i},'dmri',[have_conn{i} '_dsistudio.trk.gz.HCP-MMP_subcort_atlas.count.end.connectivity.mat']))
    end

    
    DTIcompNum = graphconncomp(sparse((connectivity+connectivity')>0));
    DTI_components(i) = DTIcompNum;
    dconn_stack = cat(3,dconn_stack,connectivity);
    
    load(fullfile(outfolder,have_conn{i},'T1w',have_conn{i},'dmri',[have_conn{i} '_WMH_conn.HCP-MMP_subcort_atlas.count.end.connectivity.mat']))
    dconn_wmh_stack = cat(3,dconn_wmh_stack,connectivity);
    
    
    if exist(fullfile(outfolder,have_conn{i},'T1w',have_conn{i},'dmri',[have_conn{i} '_dsistudio.fib.gz.HCP-MMP_subcort_atlas.lesion.end.connectivity.mat']),'file')
        load(fullfile(outfolder,have_conn{i},'T1w',have_conn{i},'dmri',[have_conn{i} '_dsistudio.fib.gz.HCP-MMP_subcort_atlas.lesion.end.connectivity.mat']))
    elseif exist(fullfile(outfolder,have_conn{i},'T1w',have_conn{i},'dmri',[have_conn{i} '_dsistudio.trk.gz.HCP-MMP_subcort_atlas.lesion.end.connectivity.mat']),'file')
        load(fullfile(outfolder,have_conn{i},'T1w',have_conn{i},'dmri',[have_conn{i} '_dsistudio.trk.gz.HCP-MMP_subcort_atlas.lesion.end.connectivity.mat']))
    end
    
    wmh_stack = cat(3,wmh_stack,connectivity);
    
    for j = 1:8
        
        dat_raw(j).fconn_stack = cat(3,dat_raw(j).fconn_stack,conn_data(j).r_pearson_raw);
        dat_raw_ar(j).fconn_stack = cat(3,dat_raw_ar(j).fconn_stack,conn_data(j).r_pearson_raw_ar);
        dat_res(j).fconn_stack = cat(3,dat_res(j).fconn_stack,conn_data(j).r_pearson_res);
        dat_res_ar(j).fconn_stack = cat(3,dat_res_ar(j).fconn_stack,conn_data(j).r_pearson_res_ar);
        
    end
    
end

% for i = 1:4
% megastack_d1(:,:,:,i) = dat_raw(i).fconn_stack;
% end
% for i = 5:8
% megastack_d2(:,:,:,i-4) = dat_raw(i).fconn_stack;
% end
for i =1:8
    megastack_raw(:,:,:,i) = dat_raw(i).fconn_stack;
    megastack_raw_ar(:,:,:,i) = dat_raw_ar(i).fconn_stack;
    megastack_res(:,:,:,i) = dat_res(i).fconn_stack;
    megastack_res_ar(:,:,:,i) = dat_res_ar(i).fconn_stack;
end


% fconn_stack_d1 = nanmean(megastack_d1,4);
% fconn_stack_d2 = nanmean(megastack_d2,4);
fconn_stack_all_raw = nanmean(megastack_raw,4);
fconn_stack_all_raw_ar = nanmean(megastack_raw_ar,4);
fconn_stack_all_res = nanmean(megastack_res,4);
fconn_stack_all_res_ar = nanmean(megastack_res_ar,4);

xtemp = [];
y = [];
idx_ut = logical(triu(ones(372),1));
% for i = 1:size(fconn_stack_d1,3)
%     d = dconn_stack(:,:,i);
%     c = fconn_stack_d1(:,:,i);
%     xtemp = [xtemp ; d(idx_ut)];
%     y = [y ; c(idx_ut)];
% end

% figure
% for i = 1:16
%     subplot(4,4,i);imagesc(fconn_stack_all(:,:,i));axis square
%     r = fconn_stack_all(:,:,i); r = r(idx_ut);
%     cmin = min(r) ; cmax = max(r);
%     caxis([cmin cmax])
%     title([num2str(cmin) ' ' num2str(cmax)])
% end