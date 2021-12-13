function dst=cvpr_compare_mahalanobis(E, q1, q2)
x=q1-q2;
x=(x.^2)./(E.value');
x=sum(x);
dst=sqrt(x);
return;