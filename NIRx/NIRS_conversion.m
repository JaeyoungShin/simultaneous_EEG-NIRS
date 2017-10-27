% Convert NIRS data in NIRx format to MATLAB-compatible format
%
% Please see description PDF file for more details
% Example rawdata is from VP026
% We strongly recommend you to use data in MATLAB-compatiable format uploaded separately

clear all; clc; close all;

%%%%%%%%%%%%%%%%%%%%%%%%%% please modify folder locations properly %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
BBCIToolboxDir = fullfile('C:','Users','Shin','Documents','MATLAB','bbci_public-master');
WorkingDir = pwd;
NirsMyDataDir = fullfile(WorkingDir,'rawdata','NIRS');
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

cd(BBCIToolboxDir);
startup_bbci_toolbox('DataDir',NirsMyDataDir,'TmpDir','/tmp/','History',0);
cd(WorkingDir);

index = [1,2,17,18,19,34,35,36,51,52,57,69,70,85,86,103,104,119,120,132,137,138,153,154,171,172,187,188,205,206,221,222,239,240,255,256,...
         257,258,273,274,275,290,291,292,307,308,313,325,326,341,342,359,360,375,376,388,393,394,409,410,427,428,443,444,461,462,477,478,495,496,511,512];
     
clab = {'AF7oxy','AFF5oxy','AFp7oxy','AF5hoxy','AFp3oxy','AFF3hoxy','AF1oxy','AFFzoxy','AFpzoxy','AF2oxy','AFp4oxy','FCC3oxy','C3hoxy','C5hoxy','CCP3oxy','CPP3oxy','P3hoxy','P5hoxy', ...
        'PPO3oxy','AFF4hoxy','AF6hoxy','AFF6oxy','AFp8oxy','AF8oxy','FCC4oxy','C6hoxy','C4hoxy','CCP4oxy','CPP4oxy','P6hoxy','P4hoxy','PPO4oxy','PPOzoxy','PO1oxy','PO2oxy','POOzoxy', ...
        'AF7deoxy','AFF5deoxy','AFp7deoxy','AF5hdeoxy','AFp3deoxy','AFF3hdeoxy','AF1deoxy','AFFzdeoxy','AFpzdeoxy','AF2deoxy','AFp4deoxy','FCC3deoxy','C3hdeoxy','C5hdeoxy','CCP3deoxy','CPP3deoxy','P3hdeoxy','P5hdeoxy',...
        'PPO3deoxy','AFF4hdeoxy','AF6hdeoxy','AFF6deoxy','AFp8deoxy','AF8deoxy','FCC4deoxy','C6hdeoxy','C4hdeoxy','CCP4deoxy','CPP4deoxy','P6hdeoxy','P4hdeoxy','PPO4deoxy','PPOzdeoxy','PO1deoxy','PO2deoxy','POOzdeoxy'};

%% Convert data to MATLAB-compatible format

% please see Table 5 in dataset description PDF
filename_datasetA{1}= fullfile('2016-07-11_001', 'NIRS-2016-07-11_001');
filename_datasetA{2}= fullfile('2016-07-11_002', 'NIRS-2016-07-11_002');
filename_datasetA{3}= fullfile('2016-07-11_003', 'NIRS-2016-07-11_003');
filename_datasetB{1}= fullfile('2016-07-11_004', 'NIRS-2016-07-11_004');
filename_datasetB{2}= fullfile('2016-07-11_005', 'NIRS-2016-07-11_005');
filename_datasetB{3}= fullfile('2016-07-11_006', 'NIRS-2016-07-11_006');
filename_datasetC{1}= fullfile('2016-07-11_007', 'NIRS-2016-07-11_007');
filename_datasetC{2}= fullfile('2016-07-11_008', 'NIRS-2016-07-11_008');
filename_datasetC{3}= fullfile('2016-07-11_009', 'NIRS-2016-07-11_009');
    
% if you do not want perform MBLL, set 'LB' to 0, please replace proc_BeerLambert file in BBCI toolbox folder with the updated version
% you can ignore "Warning: Sources or detectors not found/specified. Making empty montage"
[cnt1, mrk1, ~, hdr1]= file_readNIRx(filename_datasetA{1}, 'LB',1);
[cnt2, mrk2, ~, hdr2]= file_readNIRx(filename_datasetA{2}, 'LB',1);
[cnt3, mrk3, ~, hdr3]= file_readNIRx(filename_datasetA{3}, 'LB',1);
[cnt4, mrk4, ~, hdr4]= file_readNIRx(filename_datasetB{1}, 'LB',1);
[cnt5, mrk5, ~, hdr5]= file_readNIRx(filename_datasetB{2}, 'LB',1);
[cnt6, mrk6, ~, hdr6]= file_readNIRx(filename_datasetB{3}, 'LB',1);
[cnt7, mrk7, ~, hdr7]= file_readNIRx(filename_datasetC{1}, 'LB',1);
[cnt8, mrk8, ~, hdr8]= file_readNIRx(filename_datasetC{2}, 'LB',1);
[cnt9, mrk9, ~, hdr9]= file_readNIRx(filename_datasetC{3}, 'LB',1);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Meaningful data are in cnt.x(:,index); (e.g. cnt.x = cnt.clab(:,index);
% if you modify cnt.x, please modify cnt.clab too. (e.g. cnt.clab = clab);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% cnt_nback = cnt1 + cnt2 + cnt3
[cnt_nback, mrk_nback] = proc_appendCnt({cnt1, cnt2, cnt3}, {mrk1, mrk2, mrk3});

% cnt_wg = cnt4 + cnt5 + cnt6
[cnt_wg, mrk_wg] = proc_appendCnt({cnt4, cnt5, cnt6}, {mrk4, mrk5, mrk6});

% cnt_dsr = cnt7 + cnt8 + cnt9
[cnt_dsr, mrk_dsr] = proc_appendCnt({cnt7, cnt8, cnt9}, {mrk7, mrk8, mrk9});
