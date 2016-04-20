function get_spm_install_location() 
spmdir = uigetdir(pwd,'please select the directory with SPM12 install\n');
p  = genpath(spmdir);
addpath(p); 
end