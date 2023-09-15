function HCP_make_dconn_MEG(subjid,outfolder,fileIn,force)


HCProot='/disk/sulcus/analyzed';

if(nargin<2 || isempty(outfolder))
    outfolder=fullfile(HCProot,'COBRA');
end

if(nargin<3)
    fileIn=rdir(fullfile(outfolder,subjid,'MEG*','*.dtseries.nii'));
end


if(~isstruct(fileIn))
    fileIn.name=fileIn;
end


if(nargin<4)
    force=false;
end

fileInAll=fileIn;

for id=1:length(fileInAll)
    fileIn=fileInAll(id).name;
    disp(fileIn); tic;
    
    if(~isempty(strfind(fileIn,'.mat')))
        fileOut = [fileIn(1:strfind(fileIn,'.mat')-1) '.CPS.dconn.mat'];
    else
    fileOut = [fileIn(1:strfind(fileIn,'.dtseries')-1) '.CPS.dconn.mat'];
    end
    if(exist(fileOut) & ~force)
        return
    end
    
     if(~isempty(strfind(fileIn,'.mat')))
         data=load(fileIn);
         data.dtseries=data.data;
         data=rmfield(data,'data');
     else
        data=ft_read_cifti(fileIn);
     end
    
    Fs=1/mean(diff(data.time));
    modelorder = fix(30*Fs);
    robust_flag=true;
    
    % PCA filter to remove global signals
    [U,S,V]=nirs.math.mysvd(data.dtseries-mean(data.dtseries,2)*ones(1,size(data.dtseries,2)));
    ncom = 306;
    data = S(1:ncom,1:ncom)*V(:,1:ncom)';
    
    
    
    usenorm=0;
    W=[];
    
    for i=1:size(data,1)
        disp(i);
        d=data(i,:);
        lst=find(abs(zscore(d))>6 | isnan(d));
        lstn=find(abs(zscore(d))<4);
        d(lst)=interp1(lstn,d(lstn),lst,'nearest','extrap');
        d=d-mean(d);
        d=d-mean(d);
        s=sqrt(var(d));
        d=d./s;
        if(~usenorm)
            [w, freq]=spectrogram(d,hanning(254),244,256,Fs);
        else
            [w, freq]=nirs.math.normspectrogram(d,hanning(254),244,256,Fs);
        end
        w=w*s;
        if(isempty(W))
            W=zeros(size(data,1),size(w,1),size(w,2));
        end
        W(i,:,:)=w;
    end
    W=permute(W,[1 3 2]);
    W2=zeros(size(U,1),size(W,2),size(W,3));
    for i=1:size(W,3)
        W2(:,:,i)=U(:,1:ncom)*W(:,:,i);
    end
    W=W2;
    clear W2 S V;
    
    % coherence
    COH=zeros(size(W,1),size(W,1),size(W,3));
    for i=1:size(W,3)
        disp(i);
        COH(:,:,i)=abs(corrcoef(squeeze(W(:,:,i))'));
    end
    
    %Phase locking
    PLV=zeros(size(W,1),size(W,1),size(W,3));
    for i=1:size(W,3)
        disp(i);
        W2=squeeze(W(:,:,i))./abs(squeeze(W(:,:,i)));
        Wa=exp(1i*imag(W2));
        Wb=exp(-1i*imag(W2));
        PLV(:,:,i)=abs(Wa*Wb')/size(W,2);
    end
    
    %Cross-spectral density
    CPS=zeros(129,ncom,ncom,'single');
    for i=1:size(data,1)
        for j=i:size(data,1)
            disp([i j]);
            CPS(:,i,j)=single(cpsd(data(i,:),data(j,:),hanning(254),244,256,Fs));
            CPS(:,j,i)=CPS(:,i,j);
        end
    end
    C=permute(single(CPS),[2 3 1]);
    C=reshape(CPS,ncom,[]);
    C=U(:,1:ncom)*C;
    C=reshape(C,size(U,1),ncom,[]);
    C=permute(C,[2 1 3]);
    C=reshape(C,ncom,[]);
    C=U(:,1:ncom)*C;
    CPS=reshape(C,size(U,1),size(U,1),[]);
    clear C;
    
    Dconn.freq=freq;
    Dconn.R=single(CPS);
    fileOut = [fileIn(1:strfind(fileIn,'.dtseries')-1) '.CPS.dconn.mat'];
    save(fileOut,'Dconn','-MAT','-v7.3');
    
    Dconn.R=single(PLV);
    fileOut = [fileIn(1:strfind(fileIn,'.dtseries')-1) '.PLV.dconn.mat'];
    save(fileOut,'Dconn','-MAT','-v7.3');
    
    Dconn.R=single(COH);
    fileOut = [fileIn(1:strfind(fileIn,'.dtseries')-1) '.COH.dconn.mat'];
    save(fileOut,'Dconn','-MAT','-v7.3');
    
    disp(['time elapsed ' num2str(toc)]);
    clear U
end