function PRT=prt_load(fname)

%function to load the PRT.mat and check its integrity regarding the kernels
%and feature sets that it is supposed to contain. Updates the feature set
%name if needed.
%
% input  : name of the PRT.mat, path comprised
%
% output : PRT structure updated
%--------------------------------------------------------------------------
%Written by J. Schrouff, 11/11/2011

try
    load(fname)
catch
    beep
    disp('Could not load file')
    PRT=[];
    return
end

%get path
prtdir=fileparts(fname);

%for each feature set, check that the corresponding .dat is present in the
%same directory and update the name of the file array if needed
if isfield(PRT,'fas')
    ind=[];
    for i=1:length(PRT.fas)
        %get the name of the file array
        fa_name=PRT.fas(i).dat.fname;
        [fadir,fan,faext]=fileparts(fa_name);
        if ~strcmpi(fadir,prtdir) %directories of PRT and feature set are different
            if ~exist([prtdir,filesep,fan,faext],'file')  %no feature set found
                beep
                disp(['No feature set named ',fan,' found in the PRT directory'])
                disp('Information linked to that feature set is deleted')
                disp('Computing the weights or using non-kernel methods using that feature set won''t be permitted')
            else  %file exists but under the new directory
                PRT.fas(i).dat.fname=[prtdir,filesep,fan,faext];
                ind=[ind,i];
            end
        else
            ind=[ind,i];
        end
    end
    if isempty(ind)
        PRT=rmfield(PRT,'fas');
        PRT=rmfield(PRT,'fs');
    elseif length(ind)~=i
        %When a model comports the modality of the deleted fas, get rid of
        %the corresponding fs and model
        PRT.fas=PRT.fas(ind);
    end
end

save([prtdir,filesep,'PRT.mat'],'PRT')


            
                
                
                
                
                
