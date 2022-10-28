function flag=iszerobyte(filename)

flag=false;
try
    r=dir(filename);
    for i=1:length(r)
        flag=(flag | (r(i).bytes==0));
    end
end
return 