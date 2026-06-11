prepath = '***\tutorials_v3_with_data\Multimodal_SPM_preprocessed\data\';
subpath={'\EEG\' '\MEG\'};
fname = 'mapMcbdspmeeg_run_01_sss.mat';
type = {'EEG_','MEG_'};

for i = 1:16
    disp(['Computing subject S',num2str(i)])
    for t = 1:2
        fullp = [prepath,'S',num2str(i),subpath{t},type{t}];
        filename = [fullp,fname];
        D = spm_eeg_load(filename);
        dim = D.size();
        for c = 1:dim(end)
            conn_mat = corr(D(:,:,c)',D(:,:,c)');
            mask = triu(true(size(conn_mat)),1);
            conn_mat = conn_mat(mask);
            cond = D.conditions(c);
            savename = [fullp,cond{1},'_connectivity_matrix.mat'];
            save(savename,'conn_mat');
            disp(type{t})
            disp(['Size: ',num2str(size(conn_mat))])
        end
    end
end