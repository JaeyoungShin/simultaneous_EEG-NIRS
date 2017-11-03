# Simultaneous acquisition of EEG and NIRS during cognitive tasks for an open access dataset
Tutorial for data processing for Simultaneous acquisition of EEG and NIRS during cognitive tasks for an open access dataset

The authors would be grateful if published reports of research using this code (or a modified version, maintaining a significant portion of the original code) would cite the following article:

Shin, Jaeyoung, et al. "Simultaneous acquisition of EEG and NIRS during cognitive tasks for an open access dataset", _Scientific data (2017), under review_.

# Caution
Data processing was performed using MATLAB 2013b.
Please use MATLAB 2013b or older version. 

Please download BBCI toolbox (https://github.com/bbci/bbci_public).
The MATLAB scripts were written based on the BBCI toolbox (ver. 03 Nov. 2017).
You may run into some errors if you use later version of BBCI toolbox or MATLAB.
We do not guarantee that MATLAB scripts works properly in later version of MATLAB and BBCI toolbox.

- For NIRS data conversion, please download 'proc_BeerLambert.m' here and overwrite it to the corresponding subfolder in BBCI toolbox.
- For the use of customized values of 'CLim', please download 'visutil_getCommonRange.m' here and overwrite it to the corresponding subfolder in BBCI toolbox.
- Please download 'plot_scalpEvolutionPlusChannel.m' here and overwrite it to the corresponding subfolder in BBCI toolbox.

# Basic Data Structures
This document is from https://github.com/bbci/bbci_public/blob/master/doc/ToolboxData.markdown and partly modified.
For more details, visit BBCI toolbox.

## Table of Contents

- [`cnt`](#Cnt) - _Data structure holding the continuous signals_
- [`mrk`](#Mrk) - _Marker structure defining certain events_
- [`mnt`](#Mnt) - _Montage structure defining the electrode layout for scalp and grid plots_

## `cnt` - Continuous signals (EEG) <a id="Cnt"></a>

The structure holding continuous (i.e., not epoched) EEG signals is denoted by `cnt`.

**`cnt`** | **is a structure with the following fields:**
--------- | ---------------------------------------------
`.clab`   |   channel labels (`CELL {1 #channels}`) there may be additional information in other fields, but these are all optional
`.fs`     |   sampling rate [samples per second]
`.title`  |   task type: 'MI' - motor imagery / 'MA' - mental arithmetic
`.T`      |   length of cnt.x
`.yUnit`  |   unit of cnt.x
`.x`      |   multichannel signals (`DOUBLE [T #channels]`)

## `mrk` - Event markers (EEG) <a id="Mrk"></a>

The structure holding marker (or event) information is denoted by `mrk`. Using
this structure you can segment continuous EEG signals into epochs by the
function `proc_segmentation`.

**`mrk`**    | **is a structure with the following fields:**
------------ | ---------------------------------------------
`.time`      | defines the time points of events in msec (`DOUBLE [1 #events]`)
`.event.desc`| structure of further information; each field of `mrk.event` provides information that is specified for each event, given in arrays that index the events _in their first dimension_. This is required such that functions like `mrk_selectEvents` can work properly on those variables.
`.y`         | class labels (`DOUBLE [#classes #events]`)
`.className` | class names (`CELL {1 #classes}`)

## `mnt` - The electrode montage (EEG) <a id="Mnt"></a>

The electrode montage structure, denoted by `mnt`, holds the information of the
spatial arrangement of the electrodes on the scalp (for plotting scalp
topographies) and the arrangement of subplot axes for multi-channel plots.

**`mnt`**       | **is a structure with the following fields:**
--------------- | ---------------------------------------------
`.x`            | x-position of the electrode for scalp maps (`DOUBLE [1 +channels]`)
`.y`            | y-position of the electrode for scalp maps (`DOUBLE [1 +channels]`)
`.pos_3d`       | 3D coordinate (`DOUBLE [3 #channels]`)
`.clab`         | channel labels (`CELL {1 #channels}`)
                | **further optional fields are required for multichannel plots:**
`.box`          | positions of subplot axes for multichannel plots (`DOUBLE [2 #channels]` or `[2 #channels+1]`; the first row holds the horizontal, and the second row the vertical positions. The optional last column specifies the position of the legend
`.box_sz`       | size of subplot axes for multichannel plots (`DOUBLE [2 #channels]` or `[2 #nchannels+1]`), corresponding to `.box`. The first row holds the width, the second row the height
`.scale_box`    | position of subplot for the scale (`DOUBLE [2 1]`)
`.scale_box_sz` | size of subplot for the scale (`DOUBLE [2 1]`)

## `cnt` - Continuous signals (NIRS) <a id="Cnt"></a>

The structure holding continuous (i.e., not epoched) NIRS signals is denoted by `cnt`.

**`cnt`**     | **is a structure with the following fields:**
-----------   | ---------------------------------------------
`.fs`         |   sampling rate [samples per second]
`nSources`    |   the number of sources
`nDetectors`  |   the number of detectors
`multiplexing`|   the number of device used for data recording
`.clab`       |   channel labels (`CELL {1 #channels}`) there may be additional information in other fields, but these are all optional
`.x`          |   multichannel signals (`DOUBLE [T #channels]`)
`.wavelengths`|   wavelengths of near-infrared light (`Double [1 #wavelengths]`)
`.signal`     |   type of signal
`.title`      |   task type: 'MI' - motor imagery / 'MA' - mental arithmetic
`.yUnit`      |   unit of cnt.x

## `mrk` - Event markers (NIRS) <a id="Mrk"></a>

The structure holding marker (or event) information is denoted by `mrk`. Using
this structure you can segment continuous NIRS signals into epochs by the
function `proc_segmentation`.

The structure is same as above.

## `mnt` - The electrode montage (NIRS) <a id="Mnt"></a>

The NIRS montage structure, denoted by `mnt`, holds the information of the
spatial arrangement of sources, detectors, and physiological channels on the scalp (for plotting scalp
topographies) and the arrangement of subplot axes for multi-channel plots.

**`mnt`**  | **is a structure with the following fields:**
---------- | ---------------------------------------------
`.source`  | holds the informaiton of the spatial arrangement of sources and channel labels
`.detector`| holds the informaiton of the spatial arrangement of sources and channels labels
`.x`       | x-position of the physiological channel for scalp maps (`DOUBLE [1 +channels]`)
`.y`       | y-position of the physiological channel for scalp maps (`DOUBLE [1 +channels]`)
`.pos_3d`  | 3D coordinate (`DOUBLE [3 #channels]`)
`.clab`    | channel labels (`CELL {1 #channels}`). e.g.) source : AF7, detector : Fp1 -> clab : AF7Fp1
`sd`       | source - detector pair (`Double [#channels 2]`)             
           | **further optional fields are required for multichannel plots:**
`.box`     | positions of subplot axes for multichannel plots (`DOUBLE [2 #channels]` or `[2 #channels+1]`; the first row holds the horizontal, and the second row the vertical positions. The optional last column specifies the position of the legend
`.box_sz`       | size of subplot axes for multichannel plots (`DOUBLE [2 #channels]` or `[2 #nchannels+1]`), corresponding to `.box`. The first row holds the width, the second row the height
`.scale_box`    | position of subplot for the scale (`DOUBLE [2 1]`)
`.scale_box_sz` | size of subplot for the scale (`DOUBLE [2 1]`)
