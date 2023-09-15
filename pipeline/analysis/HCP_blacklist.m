function skip = HCP_blacklist(subjid)
skip=false;

listKnown={
    'HCP123'
    'HCP3228'
    'HCPHCPYC003'
    'HCPY003'
    'HCP_f0'
    'Summary'
    'f0837_'
    'f0846_'
    'f0850_'
    'f0859_'
    'f0873_'
    'mkdir -p ~'
    'unknow'
    'HCP383L'
    'h7126'
    'h7137'
    'h7143'
    'HCP_fO'};

skip=ismember(subjid,listKnown);

if(skip)
    1
end

return