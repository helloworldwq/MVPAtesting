function setting_up()
% add folders to path 
p = genpath(pwd); 
addpath(p); 
% print startup information to screen: 
startup_text()
% find SPM and neroelf install 
get_spm_and_neuroelf_install_location() 
% set up project folder structure 
makeDirStructure()
% download data from open fMRI 
downloadData() % note that you need at least 50GB of space on the drive! 
% unzip data
unzipData()
end