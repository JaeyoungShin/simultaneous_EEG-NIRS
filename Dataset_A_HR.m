% This MATLAB script can be used to reproduce the hemodynamic response in dataset A (Figure 6)
% Please download BBCItoolbox to 'MyToolboxDir'
% Please download dataset to 'NirsMyDataDir' and 'EegMyDataDir'
% The authors would be grateful if published reports of research using this code
% (or a modified version, maintaining a significant portion of the original code) would cite the following article:
% Shin et al. "Simultaneous acquisition of EEG and NIRS during cognitive tasks for an open access dataset",
% Scientific data (2017), under review.

clear all; clc; close all;

%%%%%%%%%%%%%%%%%%%%%%%% modify directory paths properly %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% MyToolboxDir = fullfile('C:','Users','shin','Documents','MATLAB','bbci_public-master');
MyToolboxDir = fullfile('C:','Users','shin','Documents','MATLAB','bbci_toolbox_latest_ver');
WorkingDir = fullfile('C:','Users','shin','Documents','MATLAB','scientific_data');
NirsMyDataDir = fullfile('F:','scientific_data_publish','rawdata','NIRS');
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

cd(MyToolboxDir);
startup_bbci_toolbox('DataDir',NirsMyDataDir,'TmpDir','/tmp/','History',0);
cd(WorkingDir);

addpath(genpath(pwd));

%%%%%%%%%%%%%%%%% initial parameter %%%%%%%%%%%%%%%%%
subdir_list = {'VP001-NIRS','VP002-NIRS','VP003-NIRS','VP004-NIRS','VP005-NIRS','VP006-NIRS','VP007-NIRS','VP008-NIRS','VP009-NIRS','VP010-NIRS','VP011-NIRS','VP012-NIRS','VP013-NIRS','VP014-NIRS','VP015-NIRS','VP016-NIRS','VP017-NIRS','VP018-NIRS','VP019-NIRS','VP020-NIRS','VP021-NIRS','VP022-NIRS','VP023-NIRS','VP024-NIRS','VP025-NIRS','VP026-NIRS'};
ival_epo  = [-5 60]*1000; % epoch range (unit: msec)
ival_base = [-5 -2]*1000; % baseline correction range (unit: msec)
ival_scalp = [0 10; 10 20; 20 30; 30 40; 40 60]*1000;
ylim = [-2 2]*1e-3;
load cmap_asymmetry; % see cmap_asymmetry in github
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Load NIRS data
for vp = 1 : length(subdir_list)
    
    disp([subdir_list{vp}, ' was started']);
    loadDir = fullfile(NirsMyDataDir,subdir_list{vp});
    cd(loadDir);
    load cnt_nback; load mrk_nback; load mnt_nback;
    cd(WorkingDir);
    
    % low-pass filter
    [b,a] = butter(3, 0.2/cnt_nback.deoxy.fs*2, 'low');
    cnt_nback.deoxy = proc_filtfilt(cnt_nback.deoxy, b, a);
    cnt_nback.oxy   = proc_filtfilt(cnt_nback.oxy, b, a);
    
    % segmentation
    epo.deoxy = proc_segmentation(cnt_nback.deoxy, mrk_nback, ival_epo);
    epo.oxy   = proc_segmentation(cnt_nback.oxy,   mrk_nback, ival_epo);
    
    % Add unit of x- and y-axis
    epo.deoxy.xUnit = 's';
    epo.deoxy.yUnit = 'mmol/L';
    epo.oxy.xUnit = 's';
    epo.oxy.yUnit = 'mmol/L';

    if vp == 1
        epo_all.deoxy = epo.deoxy;
        epo_all.oxy   = epo.oxy;
    else
        epo_all.deoxy = proc_appendEpochs(epo_all.deoxy, epo.deoxy);
        epo_all.oxy   = proc_appendEpochs(epo_all.oxy,   epo.oxy);
    end
end

%% Baseline correction
epo_all.deoxy = proc_baseline(epo_all.deoxy, ival_base);
epo_all.oxy   = proc_baseline(epo_all.oxy, ival_base);

%% Dimensionality correction
epo_all.deoxy.t = epo_all.deoxy.t(:,:,1);
epo_all.oxy.t = epo_all.oxy.t(:,:,1);

%% Trial-Average
epo_all.deoxy = proc_average(epo_all.deoxy, 'Stats', 1);
epo_all.oxy   = proc_average(epo_all.oxy, 'Stats', 1);

%% Plot figures
% This MATLAB script can be used to reproduce the hemodynamic response in dataset A (Figure 3)
% Please download BBCItoolbox to 'MyToolboxDir'
% Please download dataset to 'NirsMyDataDir' and 'EegMyDataDir'
% The authors would be grateful if published reports of research using this code
% (or a modified version, maintaining a significant portion of the original code) would cite the following article:
% Shin et al. "Simultaneous acquisition of EEG and NIRS during cognitive tasks for an open access dataset",
% Scientific data (2017), under review.

clear all; clc; close all;

%%%%%%%%%%%%%%%%%%%%%%%% modify directory paths properly %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% MyToolboxDir = fullfile('C:','Users','shin','Documents','MATLAB','bbci_public-master');
MyToolboxDir = fullfile('C:','Users','shin','Documents','MATLAB','bbci_toolbox_latest_ver');
WorkingDir = fullfile('C:','Users','shin','Documents','MATLAB','scientific_data');
NirsMyDataDir = fullfile('F:','scientific_data_publish','rawdata','NIRS');
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

cd(MyToolboxDir);
startup_bbci_toolbox('DataDir',NirsMyDataDir,'TmpDir','/tmp/','History',0);
cd(WorkingDir);

addpath(genpath(pwd));
load cmap_asymmetry;

%%%%%%%%%%%%%%%%% initial parameter %%%%%%%%%%%%%%%%%
subdir_list = {'VP001-NIRS','VP002-NIRS','VP003-NIRS','VP004-NIRS','VP005-NIRS','VP006-NIRS','VP007-NIRS','VP008-NIRS','VP009-NIRS','VP010-NIRS','VP011-NIRS','VP012-NIRS','VP013-NIRS','VP014-NIRS','VP015-NIRS','VP016-NIRS','VP017-NIRS','VP018-NIRS','VP019-NIRS','VP020-NIRS','VP021-NIRS','VP022-NIRS','VP023-NIRS','VP024-NIRS','VP025-NIRS','VP026-NIRS'};
ival_epo  = [-5 60]*1000; % epoch range (unit: msec)
ival_base = [-5 -2]*1000; % baseline correction range (unit: msec)
ival_scalp = [0 10; 10 20; 20 30; 30 40; 40 60]; % (unit: sec)
ylim = [-2 2]*1e-3;
classDef= {7, 8, 9; '0-back','2-back','3-back'}; % redefine name according to the text
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Load NIRS data
for vp = 1 : length(subdir_list)
    
    disp([subdir_list{vp}, ' was started']);
    loadDir = fullfile(NirsMyDataDir,subdir_list{vp});
    cd(loadDir);
    load cnt_nback; load mrk_nback; load mnt_nback;
    cd(WorkingDir);
    
    % redefine the name of class
    mrk_nback = mrk_defineClasses(mrk_nback, classDef);
    
    % low-pass filter
    [b,a] = butter(3, 0.2/cnt_nback.deoxy.fs*2, 'low');
    cnt_nback.deoxy = proc_filtfilt(cnt_nback.deoxy, b, a);
    cnt_nback.oxy   = proc_filtfilt(cnt_nback.oxy, b, a);
    
    % segmentation
    epo.deoxy = proc_segmentation(cnt_nback.deoxy, mrk_nback, ival_epo);
    epo.oxy   = proc_segmentation(cnt_nback.oxy,   mrk_nback, ival_epo);
    
    % Add unit of x- and y-axis
    epo.deoxy.xUnit = 's';
    epo.deoxy.yUnit = 'mmol/L';
    epo.oxy.xUnit = 's';
    epo.oxy.yUnit = 'mmol/L';

    if vp == 1
        epo_all.deoxy = epo.deoxy;
        epo_all.oxy   = epo.oxy;
    else
        epo_all.deoxy = proc_appendEpochs(epo_all.deoxy, epo.deoxy);
        epo_all.oxy   = proc_appendEpochs(epo_all.oxy,   epo.oxy);
    end
end

%% Baseline correction
epo_all.deoxy = proc_baseline(epo_all.deoxy, ival_base);
epo_all.oxy   = proc_baseline(epo_all.oxy, ival_base);

%% Dimensionality correction
epo_all.deoxy.t = epo_all.deoxy.t(:,:,1);
epo_all.oxy.t = epo_all.oxy.t(:,:,1);

% msec -> sec
epo_all.deoxy.t = epo_all.deoxy.t/1000;
epo_all.oxy.t   = epo_all.oxy.t/1000;

epo_all.deoxy.refIval = ival_base/1000;
epo_all.oxy.refIval = ival_base/1000;
%% Trial-Average
epo_all.deoxy = proc_average(epo_all.deoxy, 'Stats', 1);
epo_all.oxy   = proc_average(epo_all.oxy, 'Stats', 1);

%% Plot figures
fig_set(3, 'Toolsoff', 0, 'Resize', [1 2]);
plot_scalpEvolutionPlusChannel_NIRS(epo_all.deoxy, mnt_nback, {'AF7','C3h'}, ival_scalp, defopt_scalp_erp, 'GlobalCLim', 0, 'Extrapolation', 0, 'Contour', 0, 'ColorOrder', [0 216 255; 0 84 255; 95 0 255]/255, 'printival', 1, 'Colormap', cmap_asymmetry, 'yLim', ylim, 'CLim', [-1 0.75]*0.001, 'PlotStat', 'sem', 'LegendPos', 'NorthEast');

fig_set(4, 'Toolsoff', 0, 'Resize', [1 2]);
plot_scalpEvolutionPlusChannel_NIRS(epo_all.oxy, mnt_nback, {'AF7','C3h'}, ival_scalp, defopt_scalp_erp, 'GlobalCLim', 0, 'Extrapolation', 0, 'Contour', 0, 'ColorOrder', [255 167 167; 255 148 54; 255 0 0]/255,'printival', 1, 'Colormap', cmap_asymmetry, 'yLim', ylim, 'CLim', [-2 4/3]*0.001, 'PlotStat', 'sem', 'LegendPos','SouthWest');
