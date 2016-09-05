function export_vmp_to_nii(vmpinput,outfold)
%% Convert VMP to nii 
% input : .vmp BVQX object 
% output:  a .nii file for each vmp map name, named as the vmp map name 
% depedencies: a blank vmp template file in the space you want (either VMP
% or TAL. 


vmp = BVQXfile(fullfile(pwd,'blank_MNI_3x3res.vmp'));
mapstruc = vmp.Map(1);

for m = 1:vmpinput.NrOfMaps
    vmpraw = BVQXfile(fullfile(pwd,'blank_MNI_3x3res.vmp'));
    vmp = BVQXfile(fullfile(pwd,'blank_MNI_3x3res.vmp'));
    vmp.NrOfMaps        = 1;
    vmp.Map          = vmpinput.Map(m);
    fn = [genvarname(vmpinput.Map(m).Name) '.nii'];
    vmp.ExportNifti(fullfile(outfold,fn));
end
end