function [R2,Io] = HCP_ME_combine(files,TE,mask,fileOut,R2,Io)

for i=1:length(files)
    disp(files{i});
    a(i)=load_untouch_nii(files{i});
end
if(~isempty(mask))
mask=load_nii(mask);
lst=find(mask.img);
else
    mask=a(1);
    mask.img=mean(mask.img,4);
    for i=2:length(a);
        mask.img=mask.img+mean(a(i).img,4);
    end
    mask.img=1*(mask.img>1000);
    lst=find(mask.img);
end



if(nargin<5)
    %solve for R2
    Y=[]; X=[];
    for i=1:length(a)
        b=reshape(a(i).img,[],size(a(i).img,4));
        Y=[Y b(lst,:)];
        X=[X; TE(i)*ones(size(a(i).img,4),1)];
    end
    Y=double(Y);
    Y=log(Y);
    Y(find(Y==-Inf))=NaN;
    X(:,2)=1;
   
   lst2=find(~any(isnan(Y),2));
   
    
   b=inv(X'*X)*X'*Y(lst2,:)';
   R2=mask;
   Io=mask;
   R2.img(:)=0;
   Io.img(:)=0;
   R2.img(lst(lst2))=abs(b(1,:));
   Io.img(lst(lst2))=abs(b(2,:));
      
end

bold = a(1);
bold.img(:)=0;
bold.img=double(bold.img);
dR2=zeros(size(bold.img,1)*size(bold.img,2)*size(bold.img,3),size(bold.img,4));
for i=1:length(a)
    b=reshape(double(a(i).img),[],size(a(i).img,4));
    dR2 = dR2 + (log(b)-reshape(double(Io.img),[],1)*ones(1,size(a(i).img,4)))/TE(i);    
end
dR2=dR2/length(a);
dR2=sign(real(dR2)).*abs(dR2);

b=exp(reshape(double(Io.img),[],1)*ones(1,size(a(i).img,4))+dR2);
b(find(b==Inf | b==-Inf | isnan(b) | b>max(a(1).img(:))*1.5))=0;  % also get rid of the points that were close to divide by zeros
bold.img(:)=b;    
    
save_untouch_nii(bold,fileOut);    



