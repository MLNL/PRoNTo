function [CV,ID] = prt_compute_cv_mat(PRT, in, modelid, use_nested_cv)
% Function to compute the cross-validation matrix. Also does error checking

% Check if the use_nested_cv varible has been inputed
if ~exist('use_nested_cv', 'var')
    use_nested_cv = false;
end


fid = prt_init_fs(PRT, in.fs(1));

% TODO: The code bellow is not very well written, the PRT.model(modelid).input.cv.k
% field should probably be set outside this function. If not, then PRT has
% to be an output of the function (to update the value of k)


% create the PRT.model(modelid).input.cv field
if ~isfield(PRT.model(modelid).input, 'cv')
    PRT.model(modelid).input.cv={};
end

% if isfield(in.cv,'k')
if isfield(PRT.model(modelid).input.cv,'k')
    %     k=in.cv.k;  %k-fold CV
    k = PRT.model(modelid).input.cv.k;
else
    k=0; %loo cv
    PRT.model(modelid).input.cv.k = k;
end
if k==1 %half-half
    k=2;
    flaghh=1;
    PRT.model(modelid).input.cv.k = k;
else
    flaghh=0;
end





if isfield(in,'include_allscans') && in.include_allscans
    % use the full id matrix
    if use_nested_cv == false %TODO: make sure the use_nested_cv flag does not afect this function when it's called for the first time in prt_model
        ID = PRT.fs(fid).id_mat;
    else
        ID = in.ID;
    end
else
    % id matrix only contains samples within the CV structure
    % it is initialised in prt_init_fs. The columns contents are described
    % in PRT.fs(fid).id_col_names
    % ('group','subject','modality','condition','block','scan')
    if use_nested_cv == false
        ID = PRT.fs(fid).id_mat(PRT.model(modelid).input.samp_idx,:);
    else
        ID = in.ID;
    end
end

switch in.cv.type
    case 'loso'
        % leave-one-subject-out
        % give each subject a unique id
        [gids,d1] = unique(ID(:,1), 'last');
        [gids,d2] = unique(ID(:,1),'first');
        gc = 0;
        ns=zeros(length(gids),1);
        for g = 1:length(gids)
            ns(g)=length(unique(ID(d2(g):d1(g),2)));
            gidx = ID(:,1) == gids(g);
            ID(gidx,2) = ID(gidx,2) + gc;
            gc = gc + ns(g);
        end
        % Compute CV matrix
        if k>1 %k-fold CV
            nsf=floor(gc/k);
            % Check that the number of folds does not exceed the number of
            % subjects
            if length(unique(ID(:,2)))<2*nsf
                error('prt_model:losoSelectedWithTooLargeK',...
                    'More than 50%% of data in testing set, reduce k');
            end
            mns=mod(gc,k);
            dk=nsf*ones(1,k);
            dk(end)=dk(end)+mns;
            inds=1;
            sk=[];
            for ii=1:length(dk)
                sk=[sk,inds*ones(1,dk(ii))];
                inds=inds+1;
            end
        else %Leave-One-Subject-Out
            sk=1:gc;
        end
        snums=[];
        for g = 1:length(gids)
            snums = [snums;histc(ID(d2(g):d1(g),2),unique(ID(d2(g):d1(g),2)))];
        end
        if length(snums) == 1
            error('prt_model:losoSelectedWithOneSubject',...
                'LOSO CV selected but only one subject is included');
        end
        G = cell(length(unique(sk)),1);
        for s = 1:length(unique(sk))
            G{s} = ones(sum(snums(sk==s)),1);
        end
        CV = blkdiag(G{:}) + 1;
        if flaghh
            CV=CV(:,1);
        end
        
        
    case 'losgo'
        %modify the ID to take the structure of the classes into account
        vcl=zeros(size(ID,1),2);
        for ic=1:length(in.class)
            nsg=1;
            for ig=1:length(in.class(ic).group)
                gnames={PRT.group(:).gr_name};
                [d,ng]=ismember(in.class(ic).group(ig).gr_name,gnames);
                for is=1:length(in.class(ic).group(ig).subj)
                    inds=find(ID(:,1)==ng);
                    indss=find(ID(inds,2)==is);
                    vcl(inds(indss),1)=ic;
                    vcl(inds(indss),2)=nsg;
                    nsg=nsg+1;
                end
            end
        end
        % leave-one-subject-per-group-out
        [gids,d1] = unique(vcl(:,1), 'last');
        [gids,d2] = unique(vcl(:,1),'first');
        %compute the number of subjects per class
        ns=zeros(length(gids),1);
        for ig= 1:length(gids)
            ns(ig)=length(unique(vcl(d2(ig):d1(ig),2)));
        end
        sids=max(ns);
        if sids == 1
            error('prt_model:losgoSelectedWithOneSubject',...
                'LOSGO CV selected but only one subject is included');
        end
        [nsf]=floor(min(ns/k));
        if k==0
            CV = zeros(size(ID,1),sids);
        else
            CV = zeros(size(ID,1),k);
        end
        if k>1 && nsf==1
            disp('Performing Leave-One Subject per Group-Out')
        end
        snums=[];
        for g=1:length(ns)
            is=vcl(:,1)==g;
            if k>1 && nsf>1 %k-fold CV
                nsfg=floor(ns(g)/k);
                if nsfg<1
                    error('prt_model:losgoSelectedWithTooLargeK',...
                        ['Number of subjects in group ',num2str(g),' smaller than k']);
                elseif nsfg*2>ns
                    error('prt_model:losgoSelectedWithTooLargeK2',...
                        ['Leaving more than 50%% of subjects in group ',num2str(g),' out']);
                end
                mns=mod(ns(g),nsfg);
                dk=nsfg*ones(1,floor(length(unique(vcl(is,2)))/nsfg));
                if mns>0
                    dk(end)=dk(end)+mns;
                end
                inds=1;
                sk=[];
                for ii=1:length(dk)
                    sk=[sk,inds*ones(1,dk(ii))];
                    inds=inds+1;
                end
            else %Leave-One-Subject per Group-Out
                sk=1:ns(g);
            end
            snums = histc(vcl(is,2),unique(vcl(is,2)));
            G = cell(length(unique(sk)),1);
            for s = 1:length(unique(sk))
                G{s} = ones(sum(snums(sk==s)),1);
            end
            CV(is,1:max(sk)) = blkdiag(G{:}) + 1;
            if length(unique(sk))<size(CV,2)  %smaller group, fill with 'train'
                CV(is,length(unique(sk))+1:size(CV,2))= ...
                    ones(length(find(is)),length(length(unique(sk))+1:size(CV,2)));
            end
            if flaghh
                CV=CV(:,1);
            end
        end
        
        
    case 'lobo'
        % leave-one-block-out - limited to one single subject for the
        % moment
        % blocks already have a unique ID
        if k>1 %k-fold CV
            nsf=floor(length(unique(ID(:,5)))/k);
            mns=mod(length(unique(ID(:,5))),k);
            dk=nsf*ones(1,k);
            dk(end)=dk(end)+mns;
            inds=1;
            sk=[];
            for ii=1:length(dk)
                sk=[sk,inds*ones(1,dk(ii))];
                inds=inds+1;
            end
        else %Leave-One-Subject-Out
            % sk=1:max(ID(:,5));
            sk=1:length(unique(ID(:,5))); % TODO: Check if this change has not created problems
            nsf=1;
        end
        snums = histc(ID(:,5),unique(ID(:,5)));% how many scans per block
        if length(snums) == 1
            error('prt_model:loboSelectedWithOneSubject',...
                'LOBO CV selected but only one block is included');
        elseif max(ID(:,5))< 2*nsf
            error('prt_model:loboSelectedWithLargeK',...
                'Leaving more than 50%% of blocks out, decrease k');
        end
        G = cell(length(unique(sk)),1);
        for s = 1:length(unique(sk))
            G{s} = ones(sum(snums(sk==s)),1);
        end
        CV = blkdiag(G{:}) + 1;
        if flaghh
            CV=CV(:,1);
        end
        
    case 'locbo'
        % leave-one-condition-per-block-out
        error('leave-one-condition-per-block-out not yet implemented');
        
    case 'loro'
        % leave-one-run-out
        
        mids = unique(ID(:,3));
        
        CV = zeros(size(ID,1),length(mids));
        for m = 1:length(mids)
            midx = ID(:,3) == mids(m);
            CV(:,m) = double(midx) + 1;
        end
        
    case 'custom'
        %load matrix and check that each fold contains test and train data.
        if isfield(in.cv,'mat_file') && ~isempty(in.cv.mat_file)
            load(in.cv.mat_file)
            if ~exist('CV')
                error('No CV variable found in the mat file provided')
            else
                if size(CV,1) ~= size(ID,1)
                    error('CV does not comprise the same number of samples as selected')
                else
                    nfo = size(CV,2);
                    macv = max(CV);
                    if length(find(macv==2)) ~= nfo %test data in all folds
                        error('One (or more) fold does not contain test data')
                    else
                        [i,j]=find(CV==1);
                        if length(unique(j)) ~= nfo %train data in all folds
                            error('One (or more) fold does not contain train data')
                        else
                            lv=CV>2;
                            sv=CV<0;
                            if any(any(lv)) || any(any(sv))
                                error('Values larger than 2 or smaller than 0 found in CV')
                            end
                        end
                    end
                end
            end
        elseif isfield(PRT.model(modelid).input,'cv_mat') && ...
                ~isempty(PRT.model(modelid).input.cv_mat) %custom CV specified by GUI
            CV=PRT.model(modelid).input.cv_mat;
        else
            %custom CV with only number of folds specified
            if isfield(in.cv,'k')
                CV = ones (size(ID,1),in.cv.k);
            end
            
        end
        
        
    otherwise
        error('prt_cv:unknownTypeSpecified',...
            ['Unknown type specified for CV structure (',in.type',')']);
end

end