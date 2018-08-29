function cv = prt_get_cv_type(cv_struct)
% assemble structure for performing cross-validation

if isfield(cv_struct,'cv_loso')
    cv = struct('type','loso','k',0);
elseif isfield(cv_struct,'cv_lkso')
    cv = struct('type','loso','k',cv_struct.cv_lkso.k_args);
elseif isfield(cv_struct,'cv_losgo')
    cv = struct('type','losgo','k',0);
elseif isfield(cv_struct,'cv_lksgo')
    cv = struct('type','losgo','k',cv_struct.cv_lksgo.k_args);
elseif isfield(cv_struct,'cv_lobo')
    cv = struct('type','lobo','k',0);
elseif isfield(cv_struct,'cv_lkbo')
    cv = struct('type','lobo','k',cv_struct.cv_lkbo.k_args);
elseif isfield(cv_struct,'cv_locbo')
    cv = struct('type','locbo','k',0);
elseif isfield(cv_struct,'cv_lkcbo')
    cv = struct('type','locbo','k',cv_struct.cv_lkcbo.k_args);
elseif isfield(cv_struct,'cv_loro') % currently implemented for MCKR only
    cv = struct('type','loro');
else
    cv = struct('type','custom','k',cv_struct.cv_custom{1},...
        'mat_file',cv_struct.cv_custom{1});
end
