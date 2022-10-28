function C = FCM3(img,mask,clust)

[a,b,c]=size(img);

lst=find(mask);
C=zeros(a,b,c,clust);
[center,U,obj_fcn] = fcm(img(lst),clust);
[~,id]=sort(center);
for j=1:clust
    m=zeros(a,b,c);
    m(lst)=U(id(j),:);
    C(:,:,:,j)=m;
end

% 
% C1=zeros(a,b,c,clust);
% C2=zeros(a,b,c,clust);
% C3=zeros(a,b,c,clust);
% 
% 
% 
% for i=1:c
%     lst=find(squeeze(mask(:,:,i)));
%     if(length(lst)>2)
%     im=squeeze(img(:,:,i));
%     [center,U,obj_fcn] = fcm(im(lst),clust);
%     [~,id]=sort(center);
%     for j=1:clust
%         m=nan(a,b);
%         m(lst)=U(id(j),:);
%         C1(:,:,i,j)=m;
%     end
%     end
% end
% 
% 
% for i=1:b
%     lst=find(squeeze(mask(:,i,:)));
%      if(length(lst)>2)
%     im=squeeze(img(:,i,:));
%     [center,U,obj_fcn] = fcm(im(lst),clust);
%      [~,id]=sort(center);
%     for j=1:clust
%         m=nan(a,1,c);
%         m(lst)=U(id(j),:);
%         C2(:,i,:,j)=m;
%     end
%      end
% end
% 
% 
% 
% for i=1:a
%     lst=find(squeeze(mask(i,:,:)));
%      if(length(lst)>2)
%     im=squeeze(img(i,:,:));
%     [center,U,obj_fcn] = fcm(im(lst),clust);
%      [~,id]=sort(center);
%     for j=1:clust
%         m=nan(1,b,c);
%         m(lst)=U(id(j),:);
%         C3(i,:,:,j)=m;
%     end
%      end
% end
