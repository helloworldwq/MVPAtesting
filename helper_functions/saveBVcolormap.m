function saveBVcolormap()

mapname = 'RoeeCmap2.olt';
mapdir  = 'C:\Program Files (x86)\BrainVoyager\MapLUTs';


poscols = [ 127   0     0;
    128     0    38;
   189     0    38;
   227    26    28;
   252    78    42;
   253   141    60;
   254   178    76;
   254   217   118;
   255   237   160;
   255   255   204]
  

negcols = [255,247,236;
254,232,200;
253,212,158;
253,187,132;
252,141,89;
239,101,72;
215,48,31;
179,0,0;
127,0,0
187,0,0]; 

colorprint = [poscols ; negcols];

fid = fopen(fullfile(pwd,mapname),'w+'); 

for i = 1:size(colorprint,1)
    fprintf(fid,'Color%d:  %d %d %d\n',...
        i,...
        colorprint(i,1),...
        colorprint(i,2),...
        colorprint(i,3));
end


