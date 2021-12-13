function dst=cvpr_compare_l1(F1, F2)

diff=abs(F1-F2);
dst=sum(diff);
return;
