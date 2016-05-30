function         [predicted_label, accuracy, third] = svmpredictwrapper(predicted, test, model)

        [~,predicted_label, accuracy, third] = evalc('svmpredict(predicted, test, model)');
