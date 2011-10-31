function w=prt_KRR(K,t,reg)
    w=(K+reg*eye(size(K)))\t;
return