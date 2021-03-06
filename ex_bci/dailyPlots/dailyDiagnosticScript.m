addpath(genpath('../export_fig'));
copyToHive
%filepath ='/Volumes/Queen/data/pepelepew/'; % for MAC
filepath = 'Z:data\pepelepew\'; % for windows
localPath = 'D:pepelepew\';

% filestems = [{'Pe180803_s395a_dirmem_bci_discrete_'}...
%     {'Pe180806_s396a_dirmem_bci_discrete_'}...
%     {'Pe180807_s397a_dirmem_bci_discrete_'}...
%     {'Pe180808_s398a_dirmem_bci_discrete_'}...
%     {'Pe180809_s399a_dirmem_bci_discrete_'}...
%     {'Pe180810_s400a_dirmem_bci_discrete_'}...
%     {'Pe180811_s401a_dirmem_bci_discrete_'}...
%     {'Pe180812_s402a_dirmem_bci_discrete_'}...
%     {'Pe180813_s403a_dirmem_bci_discrete_'}...
%     {'Pe180815_s405a_dirmem_bci_discrete_'}...
%     {'Pe180818_s408a_dirmem_bci_discrete_'}...
%     {'Pe180819_s409a_dirmem_bci_discrete_'}...
%     {'Pe180820_s410a_dirmem_bci_discrete_'}...
%     {'Pe180821_s411a_dirmem_bci_discrete_'}...
%     {'Pe180822_s412a_dirmem_bci_discrete_'}...
%     {'Pe180824_s414a_dirmem_bci_discrete_'}...
%     {'Pe180825_s415a_dirmem_bci_discrete_'}...
%     {'Pe180826_s416a_dirmem_bci_discrete_'}...
%     {'Pe180827_s417a_dirmem_bci_discrete_'}];

% filestems =     [ {'Pe180810_s400a_dirmem_bci_discrete_'}...
%     {'Pe180811_s401a_dirmem_bci_discrete_'}...
%     {'Pe180812_s402a_dirmem_bci_discrete_'}...
%     {'Pe180813_s403a_dirmem_bci_discrete_'}...
%     {'Pe180815_s405a_dirmem_bci_discrete_'}...
%     {'Pe180818_s408a_dirmem_bci_discrete_'}...
%     {'Pe180819_s409a_dirmem_bci_discrete_'}...
%     {'Pe180820_s410a_dirmem_bci_discrete_'}...
%  filestems =  [   {'Pe180821_s411a_dirmem_bci_discrete_'}...
%     {'Pe180822_s412a_dirmem_bci_discrete_'}...
%     {'Pe180824_s414a_dirmem_bci_discrete_'}...
%     {'Pe180825_s415a_dirmem_bci_discrete_'}...
%     {'Pe180826_s416a_dirmem_bci_discrete_'}...
%     {'Pe180827_s417a_dirmem_bci_discrete_'}];
filestems = {'Pe190222_s541a_distanceStabilityBCI'};
addpath('../distinguishable_colors/');
%error('ADD PATH TO NEURAL_NET_SORT_STUFF')
set(groot,'defaultAxesColorOrder',distinguishable_colors(16))

for fileinds = 1:length(filestems)  
    filestem = filestems{fileinds};
    calfilename =[filestem,'calib_0001'];
    bcifilename =[{[filestem,'Delta2BCI_0002']}];
%     if fileinds ~= 4
%         bcifilename = [filestem,'0002'];
%     else
%         bcifilename = [filestem,'0003'];
%     end
    logfile = [{[calfilename,'_lowdHmm0_log1.txt']}];
    addpath(genpath('../'))
    if exist([filepath,bcifilename{1},'_bcistruct.mat'],'file')
        load([filepath,bcifilename{1},'_bcistruct'])
    else
        bcistruct = createBCIStruct(localPath,filepath,calfilename,bcifilename,logfile,{[calfilename,'_lowdHmm']});
        bcistruct.calibrationdata = getNS5Data(bcistruct.calibrationdata ,filepath,calfilename,'.ns5');
        bcistruct.bcidata = getNS5Data(bcistruct.bcidata ,filepath,bcifilename,'.ns5');
        bcistruct.bcidata = removeBadTrials(bcistruct.bcidata);
        save([filepath,bcifilename{end},'_bcistruct.mat'],'bcistruct')
    end
    filedate = strsplit(filestem,'_');
    newsavepath = ['C:/Users/smithlab/Dropbox/smithlabdata/bcidailyplots/',filedate{1}];
    mkdir(newsavepath)
    %dailyDiagnostic(bcistruct,[bcifilename{end},'_bcistruct.mat'],newsavepath,true,2)
    %stabilityDiagnostic(bcistruct,[bcifilename{end},'_bcistruct.mat'],newsavepath,true);
    otherDailyPlots(bcistruct,[bcifilename{end},'_bcistruct.mat'],newsavepath)
  %  aggregatePlots('180813',filestem(3:8),newsavepath,'savePlots',true,'filePath',filepath);
end


