function rawFuA_symmetry = calcSymmetryMeasure(deltabeam)
% input data is sphers x subs

% initial definitions 
n = size(deltabeam,2);  % number of subjects 
p = size(deltabeam,1);  % seachlight size (voxels) 

% 1. 
% for each subject i compute the average spatial sign with all other
% subjects j and their reflections MA
for i = 1:size(deltabeam,2)
    subvec = deltabeam(:,i); 
    repsubvec = repmat(subvec, 1, size(deltabeam,2)-1);
    othersubs = deltabeam(:,1:size(deltabeam,2)~=i);
    avg(:,:,i) = (normc(repsubvec - othersubs) + normc(repsubvec + othersubs))/2;
end
% 2. 
% for each subject i compute the spatial signed rank Qi by averaging the
% the average spatial signs over all other subjects: 
Q = squeeze(mean(avg,2));

% 3. 
% Bind all the Qi, i = 1,...n vectors into a n x p matrix Q and compute 
% where 1 is a unit vector
[ qq , r ] = qr(Q); 
a = ones(1,size(Q,2)) * Q';
rawFuA_symmetry = a  * inv(Q*Q')  * a';

end