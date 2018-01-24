% This MATLAB script can be used to reproduce the result of EEG spectral power increase and decrease
%
% Please download BBCItoolbox to 'MyToolboxDir'
% Please download dataset to 'NirsMyDataDir' and 'EegMyDataDir'
% The authors would be grateful if published reports of research using this code
% (or a modified version, maintaining a significant portion of the original code) would cite the following article:
% Shin et al. "Simultaneous acquisition of EEG and NIRS during cognitive tasks for an open access dataset",
% Scientific data (2017), under review.
% NOTE: Figure may be different from that shown in Shin et al. (2017) because EOG-rejection is not performed.

clear all; clc; close all;

%%%%%%%%%%%%%%%%%%%%%%%% modify directory paths properly %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
MyToolboxDir = fullfile('C:','Users','shin','Documents','MATLAB','bbci_public-master');
WorkingDir = fullfile('C:','Users','shin','Documents','MATLAB','scientific_data');
% EegMyDataDir = fullfile('F:','scientific_data_publish','rawdata','EEG','without EOG');
EegMyDataDir = fullfile('F:','scientific_data_publish','rawdata','EEG');
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

cd(MyToolboxDir);
startup_bbci_toolbox('DataDir',EegMyDataDir,'TmpDir','/tmp/','History',0);
cd(WorkingDir);

addpath(genpath(pwd));

%% initial parameter
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
subdir_list = {'VP001-EEG','VP002-EEG','VP003-EEG','VP004-EEG','VP005-EEG','VP006-EEG','VP007-EEG','VP008-EEG','VP009-EEG','VP010-EEG','VP011-EEG','VP012-EEG','VP013-EEG','VP014-EEG','VP015-EEG','VP016-EEG','VP017-EEG','VP018-EEG','VP019-EEG','VP020-EEG','VP021-EEG','VP022-EEG','VP023-EEG','VP024-EEG','VP025-EEG','VP026-EEG'};
ival_epo = [-15 30]*1000;
ival_base  = [-5 -2]*1000;

% for ERSP calculation
fc = [1 40];
cycles = 0; 
clim = [-3 3]; 

% subplot index for EEG channels
subplotIdx = [4 12 14 13 20 22 28 30 32 38 40 46 48 50 59 58 6 16 15 24 26 34 36 42 44 52 54 60];
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

for vp = 1 : length(subdir_list)
    
    % load EEG data
    loadDir = fullfile(EegMyDataDir,subdir_list{vp});
    cd(loadDir);
    load cnt_wg; load mrk_wg; load mnt_wg;
    cd(WorkingDir);
    
    % marker selection
    mrk_BL = mrk_selectClasses(mrk_wg, 'BL');
    mrk_WG = mrk_selectClasses(mrk_wg, 'WG');
    
    % segmentation   
    ssn_BL = proc_segmentation(cnt_wg, mrk_BL, ival_epo); % 0-back
    ssn_WG = proc_segmentation(cnt_wg, mrk_WG, ival_epo); % 2-back
    
    % manipulation for EEGLAB compatible format
    ssn_BL.x1 = permute(ssn_BL.x, [2, 1, 3]); % nch x nsamples x ntrials
    ssn_WG.x1 = permute(ssn_WG.x, [2, 1, 3]); % nch x nsamples x ntrials
    
    for ch = 1 : length(mnt_wg.clab)-2 % exclude two EOG channels
        chdata_BL = ssn_BL.x1(ch,:,:);
        chdata_WG = ssn_WG.x1(ch,:,:);
        
        % BL
        [ersp_BL(:,:,ch,vp),itc,powbase,times,freqs,erspboot,itcboot] =...
            newtimef(chdata_BL, size(ssn_BL.x1,2), ival_epo, ssn_BL.fs, cycles,...
            'type','phasecoher','freqs',fc,'plotitc','off','plotersp','off',...
            'baseline', ival_base,'trialbase','full','rmerp','on');
        
        % TASK
        [ersp_WG(:,:,ch,vp),itc,powbase,times,freqs,erspboot,itcboot] =...
            newtimef(chdata_WG, size(ssn_WG.x1,2), ival_epo, ssn_WG.fs, cycles,...
            'type','phasecoher','freqs',fc,'plotitc','off','plotersp','off',...
            'baseline',ival_base,'trialbase','full','rmerp','on');
    end   
end

%% average ERSP over multiple participants
% ave_BL: [time x freq x ch x participant]
ave_BL = mean(ersp_BL,4);
ave_WG = mean(ersp_WG,4);

%% plot ERSP
clab = cnt_wg.clab;
 
figure(1)
for ch = 1 : length(clab)-2
    subplot(7,9,subplotIdx(ch));
    imagesc(times/1000,freqs,ave_BL(:,:,ch), clim); title(clab{ch});
    set(gca, 'YDir','normal'); ylim([1 40]); colormap(cmap_posneg(101));
end
colorbar('OuterPosition', [0.645 0.828 0.016 0.09]);

figure(2)
for ch = 1 : length(clab)-2
    subplot(7,9,subplotIdx(ch));
    imagesc(times/1000,freqs,ave_WG(:,:,ch), clim); title(clab{ch});
    set(gca, 'YDir','normal'); ylim([1 40]); colormap(cmap_posneg(101));
end
colorbar('OuterPosition', [0.645 0.828 0.016 0.09]);


rmpath(genpath(pwd));
