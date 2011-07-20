function Kr = prt_remove_confounds(K,C)

n=size(K,1);
R=eye(n)-C*pinv(C);
Kr=R'*K*R;

return