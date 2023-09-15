function tbl = HCP_tracula_FA_table(outfolder)

subs = dir(outfolder);subjids={};
for i = 1:length(subs)
if subs(i).isdir
subjids = [subjids ; subs(i).name];
end
end

tracts = {'acomm_avg16_syn_bbr'	'cc.bodyc_avg16_syn_bbr'	'cc.bodyp_avg16_syn_bbr'	'cc.bodypf_avg16_syn_bbr'	'cc.bodypm_avg16_syn_bbr'	'cc.bodyt_avg16_syn_bbr'	'cc.genu_avg16_syn_bbr'	'cc.rostrum_avg16_syn_bbr'	'cc.splenium_avg16_syn_bbr'	'lh.af_avg16_syn_bbr'	'lh.ar_avg16_syn_bbr'	'lh.atr_avg16_syn_bbr'	'lh.cbd_avg16_syn_bbr'	'lh.cbv_avg16_syn_bbr'	'lh.cst_avg16_syn_bbr'	'lh.emc_avg16_syn_bbr'	'lh.fat_avg16_syn_bbr'	'lh.fx_avg16_syn_bbr'	'lh.ilf_avg16_syn_bbr'	'lh.mlf_avg16_syn_bbr'	'lh.or_avg16_syn_bbr'	'lh.slf1_avg16_syn_bbr'	'lh.slf2_avg16_syn_bbr'	'lh.slf3_avg16_syn_bbr'	'lh.uf_avg16_syn_bbr'	'mcp_avg16_syn_bbr'	'rh.af_avg16_syn_bbr'	'rh.ar_avg16_syn_bbr'	'rh.atr_avg16_syn_bbr'	'rh.cbd_avg16_syn_bbr'	'rh.cbv_avg16_syn_bbr'	'rh.cst_avg16_syn_bbr'	'rh.emc_avg16_syn_bbr'	'rh.fat_avg16_syn_bbr'	'rh.fx_avg16_syn_bbr'	'rh.ilf_avg16_syn_bbr'	'rh.mlf_avg16_syn_bbr'	'rh.or_avg16_syn_bbr'	'rh.slf1_avg16_syn_bbr'	'rh.slf2_avg16_syn_bbr'	'rh.slf3_avg16_syn_bbr'	'rh.uf_avg16_syn_bbr'};

tbl = {};

for s = 1:length(subjids)
    if exist( fullfile(outfolder,subjids{s},'T1w',subjids{s},'tracula_new',subjids{s},'dpath' ),'dir' )
        row = {subjids{s}};
        disp(['Running subject ' subjids{s}])
        for t = 1:length(tracts)
        
            if exist( fullfile(outfolder,subjids{s},'T1w',subjids{s},'tracula_new',subjids{s},'dpath',tracts{t},'pathstats.overall.txt' ),'file')
    
                tractstats = fileread( fullfile(outfolder,subjids{s},'T1w',subjids{s},'tracula_new',subjids{s},'dpath',tracts{t},'pathstats.overall.txt' ) );
                FA_str = regexp(tractstats,'FA_Avg (\d*)\.(\d*)', 'match');
                strs = strsplit(FA_str{:},' ');
                FA = str2double(strs{2});
                %disp([subjids{s} ' tract ' strrep(tracts{t},'_avg16_syn_bbr','') ' FA is ' num2str(FA)   ])
                row = [row FA];
            else
                row = [row NaN];
            end
            
        end
        %row
        %length(row)
        if length(row)==length(tracts)+1;
           tbl = [tbl ; row]; 
        end
    end
    
end
varnames = strrep( strrep(tracts,'_avg16_syn_bbr','') ,'.','_');
tbl = cell2table(tbl, 'Variablenames', [{'SubjectID'} varnames]);

writetable(tbl, fullfile(outfolder,'Tracula_FA_values.csv'))