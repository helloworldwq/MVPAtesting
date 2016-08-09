function saveBVcolormap()

mapname = 'RoeeCmap1.olt';
mapdir  = 'C:\Program Files (x86)\BrainVoyager\MapLUTs';
tmpmap = floor(colormap.*255);
poscols = tmpmap(linspace(1,64,10),:); % positive colors 
negcols = zeros(10,3);

poscols = [255,255,255;
142,178,236;
28,100,217;
22,139,174;
51,217,123;
96,205,96;
155,104,90;
206,41,79;
231,96,48;
255,151,17]; 

negcols = [255,255,255;
142,178,236;
28,100,217;
22,139,174;
51,217,123;
96,205,96;
155,104,90;
206,41,79;
231,96,48;
255,151,17]; 

colorprint = [poscols ; negcols];

fid = fopen(fullfile(pwd,mapname),'w+'); 

for i = 1:size(colorprint,1)
    fprintf(fid,'Color%d:  %d %d %d\n',...
        i,...
        colorprint(i,1),...
        colorprint(i,2),...
        colorprint(i,3));
end


