function HCP_syncMRI

HCProot='/disk/HCP/';
outfolder=fullfile(HCProot,'analyzed');

HCP_matlab_setenv;

system('rsync -vru --size-only /disk/mace2/scan_data/WPC-7030/2019* /disk/HCP/raw/MRI/');
system('rsync -vru --size-only /disk/mace3/scan_data/WPC-7030/2019* /disk/HCP/raw/MRI/');

%Find any new subjects and unpack the data
f=dir(fullfile('/disk','HCP','raw','MRI','*'));
for i=1:length(f)
    if(f(i).isdir & ~strcmp(f(i).name(1),'.'))
        a=rdir(fullfile('/disk','HCP','raw','MRI',f(i).name,'*','B*'));
        if(~isempty(a))
            a=fileparts(a(1).name);
            a=a(max(strfind(a,filesep))+1:end);
          
            if(isempty(strfind(a,'test')))
                disp(f(i).name)
                disp(a)
                a2=a;
                if(strcmp(a(1:3),'HCP'))
                    a2(1:3)=[];
                end
                HCP_unpack_data(['HCP' a2],fullfile('/disk','HCP','raw','MRI',f(i).name,a));
                HCP_LINK_MRI(['HCP' a2]);
            end
        end
    end
end