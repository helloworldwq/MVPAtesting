function model = svmtrainwrapper(labels,train)
textToEval = ['svmtrain(labels,train,' ' ''-t 0'' ' ')']; % linear svm 
[~,model] = evalc(textToEval);