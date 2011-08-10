function Kr = prt_remove_confounds(K,C)

%__________________________________________________________________________
% Copyright (C) 2011, ...

% Written by 
% $Id$


n=size(K,1);
R=eye(n)-C*pinv(C);
Kr=R'*K*R;

return