
% Script to generate the PRT.mat to be used in the Multi-modal face recognition example

xstruct = PRT.group.subject;

for i = 2:16
    subj = ['S' num2str(i)];
    xstruct(i).subj_name = subj;
end

for i = 2:16
    
    scansX = extractfield(xstruct(1).modality,'scans');
    xstruct(i).modality = xstruct(1).modality;
    subj = ['S' num2str(i)];
    
    for j = 1:2
    str = scansX{j};
    xstruct(i).modality(j).scans = replace(str,'S1',subj);
    end
    
    for j = 3:6
    str = scansX{j};
    xstruct(i).modality(j).scans = [replace(str(1,:),'S1',subj); replace(str(2,:),'S1',subj); replace(str(3,:),'S1',subj)];
    end
    
end

PRT.group.subject = xstruct;

save('PRT.mat','PRT');

