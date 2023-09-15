function HCP_MEG_makeFreqBands(subjid,outfolder)

HCP_matlab_setenv;
if(nargin<2)
    outfolder='/disk/HCP/analyzed';
end

fileAll=rdir(fullfile(outfolder,subjid,'*',['*MEG*-prep.dtseries.nii']));

for fI=1:length(fileAll)
    file=fileAll(fI).name;
    
    if(exist([file(1:strfind(file,'.dtseries')-1) '-beta-real.dtseries.nii'],'file'))
        disp(['skipping ' file]);
        continue;
    end
    
    
    disp(['processing ' file]);
    
    bands(1).name='delta';
    bands(1).range=[2 4];
    
    bands(2).name='theta';
    bands(2).range=[4 8];
    
    bands(3).name='alpha';
    bands(3).range=[8 12];
    
    bands(4).name='beta';
    bands(4).range=[12 30];
    
    bands(5).name='lowgamma';
    bands(5).range=[30 60];
    
    bands(6).name='highgamma';
    bands(6).range=[60 120];
    
    
    c=ft_read_cifti(file,'readdata',true);
    Fs=1/mean(diff(c.time));
    
    disp('running SVD');
    [U,S,V]=nirs.math.mysvd(c.dtseries-mean(c.dtseries,2)*ones(1,size(c.dtseries,2)));
    ncom = 306;
    data = S(1:ncom,1:ncom)*V(:,1:ncom)';
    disp('...done')
    
    W=[];
    for i=1:size(data,1)
        d=data(i,:);
        lst=find(abs(zscore(d))>6 | isnan(d));
        lstn=find(abs(zscore(d))<4);
        d(lst)=interp1(lstn,d(lstn),lst,'nearest','extrap');
        d=d-mean(d);
        d=d-mean(d);
        s=sqrt(var(d));
        d=d./s;
        [w, freq,time]=spectrogram(d,hanning(254),244,256,Fs);
        w=w*s;
        if(isempty(W))
            W=zeros(size(data,1),size(w,1),size(w,2));
        end
        W(i,:,:)=w;
    end
    W=permute(W,[1 3 2]);
    
    names={};
    w2=zeros(size(W,1),size(W,2),length(bands));
    for i=1:length(bands)
        lst=find(freq>=bands(i).range(1) & freq<bands(i).range(2));
        if(~isempty(lst))
            names{i}=bands(i).name;
            w2(:,:,i)=mean(W(:,:,lst),3);
            disp(bands(i).name);
        end
    end
    
    W2=zeros(size(U,1),size(w2,2),size(w2,3));
    for i=1:size(w2,3)
        W2(:,:,i)=U(:,1:ncom)*w2(:,:,i);
    end
    W=W2;
    
    for i=1:length(names)
        disp(['saving ' file(1:strfind(file,'.dtseries')-1) '-' names{i}]);
        c.dtseries=real(W(:,:,i));
        c.time=time;
        fileo=[file(1:strfind(file,'.dtseries')-1) '-' names{i} '-real'];
        
        ft_write_cifti(fileo,c,'parameter','dtseries','writesurface',false);
        c.dtseries=imag(W(:,:,i));
        c.time=time;
        fileo=[file(1:strfind(file,'.dtseries')-1) '-' names{i} '-imag'];
        ft_write_cifti(fileo,c,'parameter','dtseries','writesurface',false);
    end
    
end