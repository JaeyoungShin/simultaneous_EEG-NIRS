% This MATLAB script can be used to reproduce the result of EEG spectral power increase and decrease
%
% Please download BBCItoolbox to 'MyToolboxDir'
% Please download dataset to 'NirsMyDataDir' and 'EegMyDataDir'
% The authors would be grateful if published reports of research using this code
% (or a modified version, maintaining a significant portion of the original code) would cite the following article:
% Shin et al. "Simultaneous acquisition of EEG and NIRS during cognitive tasks for an open access dataset",
% Scientific data (2017), under review.
% NOTE: Figure may be different from that shown in Shin et al. (2017) because EOG-rejection is not performed.
%
% marker information
% [16, 48, 64, 80, 96, 112, 128, 144] = [0-back target, 2-back target, 2-back non-target, 3-back target, 3-back non-target, 0-back session start, 2-back session start, 3-back session start

clear all; clc; close all;

%%%%%%%%%%%%%%%%%%%%%%%% modify directory paths properly %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
MyToolboxDir = fullfile('C:','Users','shin','Documents','MATLAB','bbci_toolbox_latest_ver');
WorkingDir = fullfile('C:','Users','shin','Documents','MATLAB','scientific_data');
NirsMyDataDir = fullfile('F:','scientific_data_publish','rawdata','NIRS');
EegMyDataDir = fullfile('F:','scientific_data_publish','rawdata','EEG');
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

cd(MyToolboxDir);
startup_bbci_toolbox('DataDir',NirsMyDataDir,'TmpDir','/tmp/','History',0);
cd(WorkingDir);

addpath(genpath(pwd));

%% initial parameter
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
subdir_list = {'VP001-EEG','VP002-EEG','VP003-EEG','VP004-EEG','VP005-EEG','VP006-EEG','VP007-EEG','VP008-EEG','VP009-EEG','VP010-EEG','VP011-EEG','VP012-EEG','VP013-EEG','VP014-EEG','VP015-EEG','VP016-EEG','VP017-EEG','VP018-EEG','VP019-EEG','VP020-EEG','VP021-EEG','VP022-EEG','VP023-EEG','VP024-EEG','VP025-EEG','VP026-EEG'};
ival_epo = [-15 60]*1000;
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
    load cnt_nback; load mrk_nback; load mnt_nback;
    cd(WorkingDir);
    
    % marker selection
    mrk_0back = mrk_selectClasses(mrk_nback, '0-back session');
    mrk_2back = mrk_selectClasses(mrk_nback, '2-back session');
    mrk_3back = mrk_selectClasses(mrk_nback, '3-back session');
    
    % segmentation   
    ssn_0back = proc_segmentation(cnt_nback, mrk_0back, ival_epo); % 0-back
    ssn_2back = proc_segmentation(cnt_nback, mrk_2back, ival_epo); % 2-back
    ssn_3back = proc_segmentation(cnt_nback, mrk_3back, ival_epo); % 3-back
    
    % manipulation for EEGLAB compatible format
    ssn_0back.x1 = permute(ssn_0back.x, [2, 1, 3]); % nch x nsamples x ntrials
    ssn_2back.x1 = permute(ssn_2back.x, [2, 1, 3]); % nch x nsamples x ntrials
    ssn_3back.x1 = permute(ssn_3back.x, [2, 1, 3]); % nch x nsamples x ntrials
    
    for ch = 1 : length(mnt_nback.clab)-2 % exclude two EOG channels
        chdata_0back = ssn_0back.x1(ch,:,:);
        chdata_2back = ssn_2back.x1(ch,:,:);
        chdata_3back = ssn_3back.x1(ch,:,:);
        
        % 0-back
        [ersp_0back(:,:,ch,vp),itc,powbase,times,freqs,erspboot,itcboot] =...
            newtimef(chdata_0back, size(ssn_0back.x1,2), ival_epo, ssn_0back.fs, cycles,...
            'type','phasecoher','freqs',fc,'plotitc','off','plotersp','off',...
            'baseline', ival_base,'trialbase','full','rmerp','on');
        
        % 2-back
        [ersp_2back(:,:,ch,vp),itc,powbase,times,freqs,erspboot,itcboot] =...
            newtimef(chdata_2back, size(ssn_2back.x1,2), ival_epo, ssn_2back.fs, cycles,...
            'type','phasecoher','freqs',fc,'plotitc','off','plotersp','off',...
            'baseline',ival_base,'trialbase','full','rmerp','on');
        % 3-back
        [ersp_3back(:,:,ch,vp),itc,powbase,times,freqs,erspboot,itcboot] =...
            newtimef(chdata_3back, size(ssn_3back.x1,2), ival_epo, ssn_3back.fs, cycles,...
            'type','phasecoher','freqs',fc,'plotitc','off','plotersp','off',...
            'baseline',ival_base,'trialbase','full','rmerp','on');
    end   
end

%% average ERSP over multiple participants
% ave_0back: [time x freq x ch x participant]
ave_0back = mean(ersp_0back,4);
ave_2back = mean(ersp_2back,4);
ave_3back = mean(ersp_3back,4);

%% plot ERSP
clab = cnt_nback.clab;
 
figure(1)
for ch = 1 : length(clab)-2
    subplot(7,9,subplotIdx(ch));
    imagesc(times/1000,freqs,ave_0back(:,:,ch), clim); title(clab{ch});
    set(gca, 'YDir','normal'); ylim([1 40]); colormap(cmap_posneg(101));
end
colorbar('OuterPosition', [0.645 0.828 0.016 0.09]);

figure(2)
for ch = 1 : length(clab)-2
    subplot(7,9,subplotIdx(ch));
    imagesc(times/1000,freqs,ave_2back(:,:,ch), clim); title(clab{ch});
    set(gca, 'YDir','normal'); ylim([1 40]); colormap(cmap_posneg(101));
end
colorbar('OuterPosition', [0.645 0.828 0.016 0.09]);

figure(3)
for ch = 1 : length(clab)-2
    subplot(7,9,subplotIdx(ch));
    imagesc(times/1000,freqs,ave_3back(:,:,ch), clim); title(clab{ch});
    set(gca, 'YDir','normal'); ylim([1 40]); colormap(cmap_posneg(101));
end
colorbar('OuterPosition', [0.645 0.828 0.016 0.09]);

rmpath(genpath(pwd));
