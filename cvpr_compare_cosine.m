function dst=cvpr_compare_cosine(F1, F2)

dst=dot(F1,F2)/(norm(F1)*norm(F2));  
return;
