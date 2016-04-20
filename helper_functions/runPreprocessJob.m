function runPreprocessJob(runwhat)
%subsToRun = subsUsedGet(20);
s150 = subsUsedGet(150);
s20 = subsUsedGet(20);
restsubs = sort(setdiff(s150,s20));
subsToRun = restsubs(121:133);
subsToRun = s20;

for i=1:length(subsToRun)
    runOneSub(sprintf('%s',sprintf('%3.3d',subsToRun(i))),runwhat);
    % to run in parllel comment section above and uncomment section below:
	startmatlab = 'matlabr2014b -nodisplay -r ';
		runprogram  = sprintf('"run runOneSub(''%s'',%d).m; exit;" ',sprintf('%3.3d',subsToRun(i)),runwhat);
	unix([startmatlab  runprogram ' &'])     
end
