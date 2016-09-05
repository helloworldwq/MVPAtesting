function reportVMPanatomicalRegionsToTextFile()
% this code prints a text table to command line with the anaotmical labels
% of each map in the VMP 

[fn,pn] = uigetfile('*.vmp','choose vmp file'); 
clc
vmp = BVQXfile(fullfile(pn,fn));
opts = struct('minsize',2,...
            'clconn','edge',...
               'mni2tal',false,...
               'localmin', 50);
               
for i = 1:vmp.NrOfMaps
    [c,t,v,vo] = vmp.ClusterTable(i,0,opts);
    fprintf('%s :\n\n',vmp.Map(i).Name);
    fprintf('%s',t);
end

end



%  VMP::ClusterTable  - generate a table with clusters
%  
%  FORMAT:       [c, t, v, vo] = obj.ClusterTable(mapno [, thresh [, opts]])
%  
%  Input fields:
%  
%        mapno       map number (1 .. NrOfMaps)
%        thresh      either p/r values (0 .. 1) or t/F value (1 .. Inf)
%                    if not given or 0, uses the LowerThreshold of map
%        opts        optional settings
%         .altmaps   alternative maps to extract values from (default: [])
%         .altstat   either of 'mean' or {'peak'}
%         .cclag     flag, interpret the threshold as lag number (false)
%         .clconn    cluster connectivity ('face', {'edge'}, 'vertex')
%         .icbm2tal  flag, VMP coords are passed to icbm2tal (default: false)
%         .localmax  break down larger clusters threshold (default: Inf)
%         .localmaxi iterate on sub-clusters (default: false)
%         .localmin  minimum size for sub-clusters (default: 2)
%         .localmsz  print sub-cluster sizes (default: false)
%         .lupcrd    look-up coordinate, either or 'center', 'cog', {'peak'}
%         .minsize   minimum cluster size (map resolution, default by map)
%         .mni2tal   flag, VMP coords are passed to mni2tal (default: false)
%         .showneg   flag, negative values are considered (default: false)
%         .showpos   flag, positive values are considered (default: true)
%         .sorting   either of 'maxstat', {'maxstats'}, 'size', 'x', 'y', 'z'
%         .svc       small-volume correction (either VOI, voxels, or image)
%         .svcdilate dilate SVC mask for visual interpolation (default true)
%         .svcthresh threshold for SVC (default: 0.05)
%         .tdclient  flag, lookup closest talairach label (default false)
%  
%  Output fields:
%  
%        c           1xC struct with properties of clusters
%        t           text table output
%        v           thresholded map (in VMP resolution!)
%        vo          if requested, VOI structure with (TAL) coords
%  
%  TYPES: CMP, HDR, HEAD, MSK, VMP
%  
%  Note: if only one output is requested, the table is text table is
%        returned!!
%  
%  Note: icbm2tal overrides mni2tal!
%  
%  Note: svc only valid for VMP (given FWHM estimate in RunTimeVars!)
%  
%  Using: bvcoordconv, clustervol, correlinvtstat, correlpvalue, dilate3d,
%         flexinterpn_method, limitrangec, lsqueeze, minmaxmean, sdist,
%         smoothdata3, smoothkern.