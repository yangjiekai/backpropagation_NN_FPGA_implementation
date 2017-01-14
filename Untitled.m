fileID = fopen('list.txt','r');
data= fread(fileID);

CharData=char(data);
fclose(fileID);

rnd=[];
s=[];
hexval=[];
store=zeros(length(rnd)/32,1);
rnd=transpose(str2num(CharData));


count=1;
for i=1:length(rnd)
    if(count<32)
        s(end+1)=rnd(i);
        count=count+1;
    else
        hexval = binaryVectorToHex(s);
        d = hex2dec(hexval);
         store(end+1)=d;
        s=[];
        count=1;
        
    end
    
end
store1=[];
store2=[];



for i=1:length(store)
    if(store(i)>100000)
        store1(end+1)=store(i);
    else
        store2(end+1)=store(i);
    end
end
%rnd=dec2hex(CharData);
%% plot
subplot(1,2,1);
plot(store1);
subplot(1,2,2);
plot(store2);
xlabel('out_diff') % x-axis label
ylabel('#iterations') % y-axis label