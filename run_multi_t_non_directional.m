function run_multi_t_non_directional()
startmatlab = 'matlabr2015a -nodisplay -nojvm -r ';
% generic base code: 
%runprogram  = sprintf('"run runOneSub(%s).m; exit;" ','001');
%unix([startmatlab  runprogram ' &'])


%substorun = importdata('subsused2.txt');
%substorun = sort(substorun);
%substorun = [ 4    22    26    55    58    92   107   129   132   151   156   159   176   182   185   192   213   216 ];
%substorun = [132 ];
s150 = subsUsedGet(150);
s20 = subsUsedGet(20);
substorun = sort(setdiff(s150,s20));
substorun = unique([s150,s20]);
%substorun = subsUsedGet(20);
%pause(250*51);
%substorun = [ 48 201 200 213 203 199 209 212 206 204 208 207 215 205     ]
substorun = substorun(101:153);
%oldfuncname = MAIN_doSearchLightCrossValFolds_Ht2_NewT2013_subproc(%d, %d)
substorun = [2:18];
substorun = s20;
exclude = [5 7 9 10 12 15 ] ; 
%substorun = setxor(substorun, exclude);
%MAIN_doSearchLightCrossValFolds_Ht2_NewT2013_subproc

for i =1:20
	subnum = substorun(i);
	runprogram  = sprintf('"run MAIN_doSearchLightCrossValFolds_Ht2_NewT2013_subproc(%d,%d); exit;" ',subnum,1);
	pause(0.1);
	unix([startmatlab  runprogram ' &'])     
end

end