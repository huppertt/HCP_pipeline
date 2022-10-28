function TRK2Conn(trkfile,surface)

[hdr,tr]=trk_read(trkfile);

starts=zeros(length(tr),3);
ends=zeros(length(tr),3);
len=zeros(length(tr),1);

for i=1:length(tr)
    starts(i,:)=tr(i).matrix(1,:);
    ends(i,:)=tr(i).matrix(end,:);
    
    lst=[1:tr(i).nPoints-1; 2:tr(i).nPoints]';
    len(i)=sum(sqrt(sum((tr(i).matrix(lst(:,1),:)-tr(i).matrix(lst(:,2),:)).^2,2)));
end

ConnMtx = zeros(length(nodes),length(nodes));

T=delaunayn(double(nodes));
[ks,ds]=dsearchn(double(nodes),T,starts);
[ke,de]=dsearchn(double(nodes),T,ends);

thr=.5;

lst=find(ds<thr & de<thr);
for i=1:length(lst)
    ConnMtx(sub2ind(size(ConnMtx),ks(lst(i)),ke(lst(i))))=ConnMtx(sub2ind(size(ConnMtx),ks(lst(i)),ke(lst(i))))+len(lst(i));
    ConnMtx(sub2ind(size(ConnMtx),ke(lst(i)),ks(lst(i))))=ConnMtx(sub2ind(size(ConnMtx),ke(lst(i)),ks(lst(i))))+len(lst(i));
end

%save to .gv (DOT) graph format
str=sprintf('graph DTI {\r');
for i=1:length(lst)
    str=sprintf('%s\tnode%d -- node%d [weight="%f"];\r',str,ke(lst(i)),ks(lst(i)),len(lst(i)));
end
str=sprintf('%s}',str);

% GraphML version
str=sprintf('<?xml version="1.0" encoding="UTF-8"?>\r');
str=sprintf('%s<graphml xmlns="http://graphml.graphdrawing.org/xmlns"\r',str);
str=sprintf('%sxmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"\r',str);
str=sprintf('%sxsi:schemaLocation="http://graphml.graphdrawing.org/xmlns\r',str);
str=sprintf('%shttp://graphml.graphdrawing.org/xmlns/1.0/graphml.xsd">\r',str);
str=sprintf('%s\t<graph id="G" edgedefault="undirected">\r',str);
str=sprintf('%s\t<key id="d0" for="edge" attr.name="weight" attr.type="double"/>\r');

nall=unique([ks(lst) ke(lst)]);
for i=1:length(nall)
    str=sprintf('%s\t\t<node id="n%d"/>\r',str,i);
end
[~,ks1]=ismember(ks(lst),nall);
[~,ke1]=ismember(ks(lst),nall);
for i=1:length(ks1)
    str=sprintf('%s\t\t<edge id="e%d" source="n%d" target="n%d"/><data key="d0">%4.3f</data></edge>\r',...
        str,i,ks1(i),ke1(i),len(lst(i)));
end
str=sprintf('%s\t</graph>\r',str);
str=sprintf('%s</graphml>\r',str);