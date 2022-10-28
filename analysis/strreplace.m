function newstr=strreplace(str,old,new)

lst=strfind(str,old);

if(isempty(lst))
    newstr=str;
    return
end

newstr=new;

lst=[1-length(old) lst length(str)];

for i=1:length(lst)-1
    newstr=[newstr str(lst(i)+length(old):lst(i+1)-1) new];
end

newstr(1:length(new))=[];
newstr(end-length(new)+1:end)=[];
newstr(end+1)=str(end);