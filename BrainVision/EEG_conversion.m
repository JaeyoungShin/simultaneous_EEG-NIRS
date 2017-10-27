% Convert EEG data in BrainVison format to MATLAB-compatible format
%
% Please see description PDF file for more details
% Example rawdata is from VP026
% We strongly recommend you to use data in MATLAB-compatiable format uploaded separately
% Please download BBCI toolbox

%%%%%%%%%%%%%%%%%%%%%%%%%% please modify folder locations properly %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
BBCIToolboxDir = fullfile('C:','Users','Shin','Documents','MATLAB','bbci_public-master');
WorkingDir = pwd;
EegMyDataDir = fullfile(WorkingDir,'rawdata','EEG');
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

cd(BBCIToolboxDir);
startup_bbci_toolbox('DataDir',EegMyDataDir,'TmpDir','/tmp/','History',0);
cd(WorkingDir);
%% Convert data to MATLAB-compatible format
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
filename_datasetA = {'nback1','nback2','nback3'};
filename_datasetB = {'word1','word2','word3'};
filename_datasetC = {'gonogo1','gonogo2','gonogo3'};
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

file1 = fullfile(EegMyDataDir,filename_datasetA{1});
file2 = fullfile(EegMyDataDir,filename_datasetA{2});
file3 = fullfile(EegMyDataDir,filename_datasetA{3});
file4 = fullfile(EegMyDataDir,filename_datasetB{1});
file5 = fullfile(EegMyDataDir,filename_datasetB{2});
file6 = fullfile(EegMyDataDir,filename_datasetB{3});
file7 = fullfile(EegMyDataDir,filename_datasetC{1});
file8 = fullfile(EegMyDataDir,filename_datasetC{2});
file9 = fullfile(EegMyDataDir,filename_datasetC{3});

% dataset A
[cnt1, mrk1, hdr1] = file_readBV(file1);
[cnt2, mrk2, hdr2] = file_readBV(file2);
[cnt3, mrk3, hdr3] = file_readBV(file3);

% dataset B
[cnt4, mrk4, hdr4] = file_readBV(file4);
[cnt5, mrk5, hdr5] = file_readBV(file5);
[cnt6, mrk6, hdr6] = file_readBV(file6);

% dataset C
[cnt7, mrk7, hdr7] = file_readBV(file7);
[cnt8, mrk8, hdr8] = file_readBV(file8);
[cnt9, mrk9, hdr9] = file_readBV(file9);

% cnt_nback = cnt1 + cnt2 + cnt3
[cnt_nback, mrk_nback] = proc_appendCnt({cnt1, cnt2, cnt3}, {mrk1, mrk2, mrk3});

% cnt_wg = cnt4 + cnt5 + cnt6
[cnt_wg, mrk_wg] = proc_appendCnt({cnt4, cnt5, cnt6}, {mrk4, mrk5, mrk6});

% cnt_dsr = cnt7 + cnt8 + cnt9
[cnt_dsr, mrk_dsr] = proc_appendCnt({cnt7, cnt8, cnt9}, {mrk7, mrk8, mrk9});
