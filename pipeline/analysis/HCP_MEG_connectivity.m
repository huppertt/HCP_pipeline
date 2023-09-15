function HCP_MEG_connectivity(f)
%f=rdir(fullfile(folder,'*/*EC_preproc.fif'));
HCP_matlab_setenv;
path(path,'/disk/HCP/pipeline/analysis/cifti');

if(~isstruct(f))
    name=f;
    f=struct;
    f.name=name;
end

for k=1:length(f)
%     MEG=eeg.io.loadFiff(f(k).name);
%     
%     j=eeg.modules.BandPassFilter;
%     j.highpass=1;
%     j.lowpass=25;
%     j.do_downsample=1;
%     j=eeg.modules.VarianceNormalize(j);
%     MEG=j.run(MEG);

%     raw=fiff_setup_read_raw(f(k).name);
%     hdr=raw.info;
%     data=fiff_read_raw_segment(raw);

    c=ft_read_cifti(f(k).name,'readsurface',false);
    Fs=1/mean(diff(c.time));
    data=c.dtseries';
    
    [fa,fb]=butter(4,[1 25]*2/Fs);
    data=filtfilt(fa,fb,data);
    data=resample(data,1,2);
    
    data=data-ones(size(data,1),1)*mean(data,1);
    data=data-ones(size(data,1),1)*mean(data,1);
    data = data./(ones(size(data,1),1)*sqrt(var(data,[],1)));
   
    % first preform a wavelet analysis to get the spectrogram
    
    
    
    data=data';
   
    a=size(data,1);
    S=zeros(a,a,65);
    for i=1:size(data,1)
        for j=i:size(data,1)
            
            [S(i,j,:),freq]=cpsd(data(i,:),data(j,:),[],[],128,50);
            S(j,i,:)=S(i,j,:);
            disp([i j]);
        end
       
    end
    fileout=f(k).name;
    [p,f,e]=fileparts(fileout);
    fileout=fullfile(p,[f '-conn.mat']);
    save(fileout,'S','freq');
end
