% This MATLAB script can be used to reproduce the result in Figure 12
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
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

cd(MyToolboxDir);
startup_bbci_toolbox('DataDir',NirsMyDataDir,'TmpDir','/tmp/','History',0);
cd(WorkingDir);

addpath(genpath(pwd));

%% initial parameter
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
subdir_list.nirs = {'VP001-NIRS','VP002-NIRS','VP003-NIRS','VP004-NIRS','VP005-NIRS','VP006-NIRS','VP007-NIRS','VP008-NIRS','VP009-NIRS','VP010-NIRS','VP011-NIRS','VP012-NIRS','VP013-NIRS','VP014-NIRS','VP015-NIRS','VP016-NIRS','VP017-NIRS','VP018-NIRS','VP019-NIRS','VP020-NIRS','VP021-NIRS','VP022-NIRS','VP023-NIRS','VP024-NIRS','VP025-NIRS','VP026-NIRS'};
subdir_list.eeg = {'VP001-EEG','VP002-EEG','VP003-EEG','VP004-EEG','VP005-EEG','VP006-EEG','VP007-EEG','VP008-EEG','VP009-EEG','VP010-EEG','VP011-EEG','VP012-EEG','VP013-EEG','VP014-EEG','VP015-EEG','VP016-EEG','VP017-EEG','VP018-EEG','VP019-EEG','VP020-EEG','VP021-EEG','VP022-EEG','VP023-EEG','VP024-EEG','VP025-EEG','VP026-EEG'};
band_freq = 0.2;
ord = 3;
ival_epo  = [-10 25]*1000; % epoch range (unit: msec)
ival_base = [-5 -2]*1000;  % baseline range (unit: msec)
step_size = 1*1000; % in msec
window_size = 5*1000; % in msec
nShift = 1;
nFold = 5;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

for vp = 1 : length(subdir_list.nirs)
    rng(vp);
    disp([subdir_list.nirs{vp}, ' was started']);
    loadDir = fullfile(NirsMyDataDir,subdir_list.nirs{vp});
    cd(loadDir);
    load cnt_vf; load mrk_vf; load mnt_vf;
    cd(WorkingDir);
    
    %% low-pass filter   
    [z,p,k] = butter(ord, band_freq/cnt_vf.deoxy.fs*2, 'low');
    [SOS,G] = zp2sos(z,p,k);
    
    cnt_vf.deoxy = proc_filtfilt(cnt_vf.deoxy, SOS, G);
    cnt_vf.oxy   = proc_filtfilt(cnt_vf.oxy,   SOS, G);
       
    %% Segmentation
    epo.deoxy = proc_segmentation(cnt_vf.deoxy, mrk_vf, ival_epo);
    epo.oxy   = proc_segmentation(cnt_vf.oxy, mrk_vf, ival_epo);

    %% baseline correction
    epo.deoxy = proc_baseline(epo.deoxy, ival_base);
    epo.oxy = proc_baseline(epo.oxy, ival_base);
   
    %% Select interval for classification
    ival_start = (ival_epo(1):step_size:ival_epo(end)-window_size)';
    ival_end = ival_start+window_size;
    ival = [ival_start, ival_end];
    nStep = length(ival);
    
    % average
    for stepIdx = 1:nStep
        ave.deoxy{stepIdx} = proc_meanAcrossTime(epo.deoxy, ival(stepIdx,:));
        ave.oxy{stepIdx}   = proc_meanAcrossTime(epo.oxy,   ival(stepIdx,:));
    end
    
    % slope
    for stepIdx = 1:nStep
        slope.deoxy{stepIdx} = proc_slopeAcrossTime(epo.deoxy, ival(stepIdx,:));
        slope.oxy{stepIdx}   = proc_slopeAcrossTime(epo.oxy,   ival(stepIdx,:));
    end
    
    clear cnt_vf mrk_vf mnt_vf
        
    %% EEG PART START
    disp([subdir_list.eeg{vp}, ' was started']);
    %% Load EOG-free data
    loadDir = fullfile(EegMyDataDir,subdir_list.eeg{vp});
    cd(loadDir);
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    load cnt_vf; load mrk_vf; load mnt_vf;
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    cd(WorkingDir);
      
    %% Select EEG channels (exclude EOG channels) for classification
    % result: cnt and mnt with EEG channels only
    cnt_vf = proc_selectChannels(cnt_vf, 'not', '*EOG'); % remove EOG channels (VEOG, HEOG)
    mnt_vf = mnt_setElectrodePositions(cnt_vf.clab);
       
    %% Segmentation
    ival_epo  = [-10 25]*1000; % epoch range (unit: msec)
    ival_base = [-5 -2]*1000; % baseline correction range (unit: msec)
    
    epo.eeg = proc_segmentation(cnt_vf, mrk_vf, ival_epo);
    epo.eeg = proc_baseline(epo.eeg,ival_base, 'trialwise', 1);
        
    %% band selection for CSP
    band_csp{vp,1} = select_bandnarrow(cnt_vf, mrk_vf, [-2 10]*1000); % band selection using 1~5 sec epoch for {'MA','WC'}
    ord = 3;
    Wp = band_csp{vp,1}/epo.eeg.fs*2;
    
    [filt_b,filt_a] = butter(ord, Wp, 'bandpass');
    epo.eeg = proc_filtfilt(epo.eeg, filt_b, filt_a);
       
    %% Select interval for classification
    for stepIdx = 1:nStep
        segment{stepIdx} = proc_selectIval(epo.eeg, ival(stepIdx,:));
    end
    
    %% nShift x nFold-cross validation

    group = epo.eeg.y;
    
    for shiftIdx = 1:nShift
        indices{shiftIdx} = crossvalind('Kfold',full(vec2ind(group)),nFold);
        fprintf('VF vs BL, Repeat: %d/%d\n',shiftIdx, nShift);
        
        for stepIdx = 1:nStep
            
            for foldIdx = 1:nFold
                clear csp_train csp_test
                test = (indices{shiftIdx} == foldIdx); train = ~test;
                
                % HbR
                x_train.deoxy.x = [squeeze(ave.deoxy{stepIdx}.x(:,:,train)); squeeze(slope.deoxy{stepIdx}.x(:,:,train))];
                x_train.deoxy.y = squeeze(ave.deoxy{stepIdx}.y(:,train));
                x_train.deoxy.clab = ave.deoxy{stepIdx}.clab;
                
                x_test.deoxy.x = [squeeze(ave.deoxy{stepIdx}.x(:,:,test)); squeeze(slope.deoxy{stepIdx}.x(:,:,test))];
                x_test.deoxy.y = squeeze(ave.deoxy{stepIdx}.y(:,test));
                x_test.deoxy.clab = ave.deoxy{stepIdx}.clab;
                
                % HbO
                x_train.oxy.x = [squeeze(ave.oxy{stepIdx}.x(:,:,train)); squeeze(slope.oxy{stepIdx}.x(:,:,train))];
                x_train.oxy.y   = squeeze(ave.oxy{stepIdx}.y(:,train));
                x_train.oxy.clab   = ave.oxy{stepIdx}.clab;
                
                x_test.oxy.x = [squeeze(ave.oxy{stepIdx}.x(:,:,test)); squeeze(slope.oxy{stepIdx}.x(:,:,test))];
                x_test.oxy.y = squeeze(ave.oxy{stepIdx}.y(:,test));
                x_test.oxy.clab = ave.oxy{stepIdx}.clab;
                
                % EEG
                x_train.eeg.x = segment{stepIdx}.x(:,:,train);
                x_train.eeg.y = segment{stepIdx}.y(:,train);
                x_train.eeg.clab = segment{stepIdx}.clab;
                
                x_test.eeg.x = segment{stepIdx}.x(:,:,test);
                x_test.eeg.y = segment{stepIdx}.y(:,test);
                x_test.eeg.clab = segment{stepIdx}.clab;
                
                
                %%%%%%%%%%%%%%%%%%%%%% For EEG only %%%%%%%%%%%%%%%%%%%%%%%%%%
                % CSP
                [csp_train, CSP_W, CSP_EIG, CSP_A] = proc_cspAuto(x_train.eeg,'patterns', floor(size(x_train.eeg.x,2)/2), 'normalize', 1,'score','medianvar','selectPolicy','equalperclass');
                csp_test = proc_linearDerivation(x_test.eeg,CSP_W);
                
                % variance and logarithm
                var_train = proc_variance(csp_train);
                var_test  = proc_variance(csp_test);
                logvar_train = proc_logarithm(var_train);
                logvar_test  = proc_logarithm(var_test);
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                
                
                % feature vector
                fv_train.deoxy.x = x_train.deoxy.x; fv_train.deoxy.y = x_train.deoxy.y; fv_train.deoxy.className = {'VF','BL'};
                fv_test.deoxy.x  = x_test.deoxy.x;  fv_test.deoxy.y  = x_test.deoxy.y;  fv_test.deoxy.className  = {'VF','BL'};
                fv_train.oxy.x   = x_train.oxy.x;   fv_train.oxy.y   = x_train.oxy.y;   fv_train.oxy.className   = {'VF','BL'};
                fv_test.oxy.x    = x_test.oxy.x;    fv_test.oxy.y    = x_test.oxy.y;    fv_test.oxy.className    = {'VF','BL'};
                fv_train.eeg.x   = logvar_train.x;   fv_train.eeg.y   = x_train.eeg.y;   fv_train.eeg.className  = {'VF','BL'};
                fv_test.eeg.x    = logvar_test.x;   fv_test.eeg.y    = x_test.eeg.y;    fv_test.eeg.className    = {'VF','BL'};
                
                % for EEG only
                fv_train.eeg.x = squeeze(fv_train.eeg.x);
                fv_test.eeg.x  = squeeze(fv_test.eeg.x);
                
                y_train  = group(:,train); % y_train for EEG == y_train for NIRS
                y_test   = vec2ind(group(:,test));  % y_test for EEG == y_test for NIRS
                
                % train classifier
                C.deoxy = train_RLDAshrink(fv_train.deoxy.x,y_train);
                C.oxy   = train_RLDAshrink(fv_train.oxy.x  ,y_train);
                C.eeg   = train_RLDAshrink(fv_train.eeg.x  ,y_train);
                
                %%%%%%%%%%%%%%%%%%%%%% train meta-classifier %%%%%%%%%%%%%%%%%%%%%%%%%
                map_train.deoxy.x = LDAmapping(C.deoxy, fv_train.deoxy.x, 'meta');
                map_train.oxy.x   = LDAmapping(C.oxy,   fv_train.oxy.x,   'meta');
                map_train.eeg.x   = LDAmapping(C.eeg,   fv_train.eeg.x,   'meta');
                
                map_test.deoxy.x  = LDAmapping(C.deoxy, fv_test.deoxy.x,  'meta');
                map_test.oxy.x    = LDAmapping(C.oxy,   fv_test.oxy.x,    'meta');
                map_test.eeg.x    = LDAmapping(C.eeg,   fv_test.eeg.x,    'meta');
                               
                % meta1: HbR+HbO / meta2: HbR+EEG / meta3: HbO+EEG / meta4: HbR+HbO+EEG
                
                fv_train.meta1.x = [map_train.deoxy.x; map_train.oxy.x];
                fv_test.meta1.x  = [map_test.deoxy.x ; map_test.oxy.x];
                
                fv_train.meta2.x = [map_train.deoxy.x; map_train.eeg.x];
                fv_test.meta2.x  = [map_test.deoxy.x ; map_test.eeg.x];
                
                fv_train.meta3.x = [map_train.oxy.x; map_train.eeg.x];
                fv_test.meta3.x  = [map_test.oxy.x ; map_test.eeg.x];
                
                fv_train.meta4.x = [map_train.deoxy.x; map_train.oxy.x; map_train.eeg.x];
                fv_test.meta4.x  = [map_test.deoxy.x ; map_test.oxy.x ; map_test.eeg.x];
                
                y_map_train = y_train;
                y_map_test  = y_test;
                
                C.meta1 = train_RLDAshrink(fv_train.meta1.x, y_map_train);
                C.meta2 = train_RLDAshrink(fv_train.meta2.x, y_map_train);
                C.meta3 = train_RLDAshrink(fv_train.meta3.x, y_map_train);
                C.meta4 = train_RLDAshrink(fv_train.meta4.x, y_map_train);
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                
                % classification
                grouphat.deoxy(foldIdx,:) = LDAmapping(C.deoxy,fv_test.deoxy.x);
                grouphat.oxy(foldIdx,:)   = LDAmapping(C.oxy,  fv_test.oxy.x);
                grouphat.eeg(foldIdx,:)   = LDAmapping(C.eeg,  fv_test.eeg.x);
                grouphat.meta1(foldIdx,:) = LDAmapping(C.meta1, fv_test.meta1.x);
                grouphat.meta2(foldIdx,:) = LDAmapping(C.meta2, fv_test.meta2.x);
                grouphat.meta3(foldIdx,:) = LDAmapping(C.meta3, fv_test.meta3.x);
                grouphat.meta4(foldIdx,:) = LDAmapping(C.meta4, fv_test.meta4.x);
                
                cmat.deoxy(:,:,foldIdx)  = confusionmat(y_test, grouphat.deoxy(foldIdx,:));
                cmat.oxy(:,:,foldIdx)    = confusionmat(y_test, grouphat.oxy(foldIdx,:));
                cmat.eeg(:,:,foldIdx)    = confusionmat(y_test, grouphat.eeg(foldIdx,:));
                cmat.meta1(:,:,foldIdx)  = confusionmat(y_test, grouphat.meta1(foldIdx,:));
                cmat.meta2(:,:,foldIdx)  = confusionmat(y_test, grouphat.meta2(foldIdx,:));
                cmat.meta3(:,:,foldIdx)  = confusionmat(y_test, grouphat.meta3(foldIdx,:));
                cmat.meta4(:,:,foldIdx)  = confusionmat(y_test, grouphat.meta4(foldIdx,:));
            end
            
            acc.deoxy(shiftIdx,stepIdx)    = trace((sum(cmat.deoxy,3))) / sum(sum(sum(cmat.deoxy,3),2),1);
            acc.oxy(shiftIdx,stepIdx)      = trace((sum(cmat.oxy,3)))   / sum(sum(sum(cmat.oxy,3),2),1);
            acc.eeg(shiftIdx,stepIdx)      = trace((sum(cmat.eeg,3)))   / sum(sum(sum(cmat.eeg,3),2),1);
            acc.meta1(shiftIdx,stepIdx)    = trace((sum(cmat.meta1,3)))  / sum(sum(sum(cmat.meta1,3),2),1);
            acc.meta2(shiftIdx,stepIdx)    = trace((sum(cmat.meta2,3)))  / sum(sum(sum(cmat.meta2,3),2),1);
            acc.meta3(shiftIdx,stepIdx)    = trace((sum(cmat.meta3,3)))  / sum(sum(sum(cmat.meta3,3),2),1);
            acc.meta4(shiftIdx,stepIdx)    = trace((sum(cmat.meta4,3)))  / sum(sum(sum(cmat.meta4,3),2),1);

        end
    end
    
    mean_acc.deoxy(vp,:) = mean(acc.deoxy,1);
    mean_acc.oxy(vp,:)   = mean(acc.oxy,1);
    mean_acc.eeg(vp,:)   = mean(acc.eeg,1);
    mean_acc.meta1(vp,:) = mean(acc.meta1,1);
    mean_acc.meta2(vp,:) = mean(acc.meta2,1);
    mean_acc.meta3(vp,:) = mean(acc.meta3,1);
    mean_acc.meta4(vp,:) = mean(acc.meta4,1);
    
end

time = ival(:,2);
figure(1)
plot(time/1000,[mean(mean_acc.eeg); mean(mean_acc.meta1); mean(mean_acc.meta4)]);
xlim([-5 25]); ylim([0.4 0.9]); 
xlabel('Time (s)');
ylabel('Classification accuracy');
