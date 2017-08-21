% This MATLAB script can be used to reproduce the result of Go/No-go task-based resopnse selection ERP
%
% Please download BBCItoolbox to 'MyToolboxDir'
% Please download dataset to 'NirsMyDataDir' and 'EegMyDataDir'
% The authors would be grateful if published reports of research using this code
% (or a modified version, maintaining a significant portion of the original code) would cite the following article:
% Shin et al. "Simultaneous acquisition of EEG and NIRS during cognitive tasks for an open access dataset",
% Scientific data (2017), under review.

clear all; clc; close all;

%%%%%%%%%%%%%%%%%%%%%%%% modify directory paths properly %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
MyToolboxDir = fullfile('C:','Users','shin','Documents','MATLAB','bbci_public-master');
WorkingDir = fullfile('C:','Users','shin','Documents','MATLAB','scientific_data');
NirsMyDataDir = fullfile('F:','scientific_data_publish','rawdata','NIRS');
EegMyDataDir = fullfile('F:','scientific_data_publish','rawdata','EEG');
StatisticDir = fullfile('F:','scientific_data_publish','statistic');
GoNogoDir = fullfile(StatisticDir,'Go-NoGo','summary');
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

cd(MyToolboxDir);
startup_bbci_toolbox('DataDir',NirsMyDataDir,'TmpDir','/tmp/','History',0);
cd(WorkingDir);

%% initial parameter
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
subdir_list = {'VP001-EEG','VP002-EEG','VP003-EEG','VP004-EEG','VP005-EEG','VP006-EEG','VP007-EEG','VP008-EEG','VP009-EEG','VP010-EEG','VP011-EEG','VP012-EEG','VP013-EEG','VP014-EEG','VP015-EEG','VP016-EEG','VP017-EEG','VP018-EEG','VP019-EEG','VP020-EEG','VP021-EEG','VP022-EEG','VP023-EEG','VP024-EEG','VP025-EEG'};
stimDef.eeg= {32, 16; 'No-Go','Go'};

ival_epo = [-0.1 1.0] * 1000;
ival_base = [-0.1 0] * 1000;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

for vp = 1 : length(subdir_list)
     disp([subdir_list{vp}, ' was started']);
     
     % correct epoch selection
    vpDir = fullfile(GoNogoDir, subdir_list{vp});
    cd(vpDir);
    load summary1; load summary2; load summary3;   
    
    summary = [summary1.result; summary2.result; summary3.result];
    summary = reshape(summary', 1, size(summary,1)*size(summary,2))';
    
    correctIdx = find(summary == 1);
    incorrectIdx = find(summary ~= 1);
     
     
    %% Load EOG-free data
    loadDir = fullfile(EegMyDataDir,subdir_list{vp});
    cd(loadDir);
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    load cnt_gonogo; load mrk_gonogo; load mnt_gonogo;
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    cd(WorkingDir);
   
    %% BPF
    [b, a] = butter(3, [1 30]/cnt_gonogo.fs*2);
    cnt_gonogo = proc_filtfilt(cnt_gonogo, b, a);
    
    %% Marker selection
    mrk_gonogo= mrk_defineClasses(mrk_gonogo, stimDef.eeg);
    
    %% Select EEG channels only (apart from EOG channels) for classification
    % result: cnt and mnt with EEG channels only
    cnt_gonogo = proc_selectChannels(cnt_gonogo, 'not','*EOG'); % remove EOG channels (VEOG, HEOG)   
    mnt_gonogo = mnt_setElectrodePositions(cnt_gonogo.clab);
    
    %% Artifact rejection based on variance criterion
    mrk = reject_varEventsAndChannels(cnt_gonogo, mrk_gonogo, ival_epo, 'verbose', 1);
    
    %% Segmentation
    epo = proc_segmentation(cnt_gonogo, mrk_gonogo, ival_epo);   
   
    %% Select epoch with correct answer
    epo = proc_selectEpochs(epo, 'not', incorrectIdx);
    disp([num2str(length(incorrectIdx)), ' epoch(s) was/were rejected due to incorrect answer']);

    if vp == 1
        epo_all = epo;
    else
        epo_all = proc_appendEpochs(epo_all, epo);
    end
    
    clear epo
end

%% Baseline correction
epo_all = proc_baseline(epo_all, ival_base);

%% Calculate the pointwise difference between class means
epo_diff = proc_classmeanDiff(epo_all, 'Stats',1); 
epo_diff = proc_baseline(epo_diff, [-100 0]);

% Merge epo_all & epo_diff
epo_all = proc_appendEpochs(epo_all, epo_diff);

% Dimentionality correction
epo_all.t = epo_all.t(:,:,1);

%% Display
epo_all.xUnit = 'ms';
epo_all.yUnit = '\muV';

clab = {'Cz','Pz'};
ival_scalps = [0 0.2; 0.2 0.4; 0.4 0.6; 0.6 0.8; 0.8 1]*1000;

fig_set(7, 'Toolsoff', 0, 'Resize', [1 2]);
H = plot_scalpEvolutionPlusChannel(epo_all, mnt_gonogo, clab, ival_scalps, defopt_scalp_erp, 'Extrapolation', 0, 'Contour', 0, 'printival', 1, 'Colormap', cmap_posneg(101), 'PlotStd', 1, 'yLim', [-1 1]*8, 'CLim', [-1 1]*5);
