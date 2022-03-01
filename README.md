# Object Location Representations



This repository contains the analysis code that goes with the manuscript ["The spatiotemporal neural dynamics of object location representations in the human brain"](https://rdcu.be/cHGOY). 

All analyses were conducted using Matlab R2018b and were also tested on Matlab2016a, Matlab2017b, Matlab2020b and MAtlab R2021a. Additionally, it has been tested on the following operating systems: CentOS Linux, MacOS Mojave version 10.14.6, MacOS Catalina version 10.15.7, MacOS Big Sur version 11.1 and Windows 10.

The fMRI, EEG and DNN data as well as the experimental stimuli can be downloaded [here](https://osf.io/7zswn/?view_only=db183dde8f4b406aaba5dfc0dd0ae67d).


## Requirements

- Matlab software
- The code depends on functions from the libsvm-3.11 toolbox, but these are provided in the folder /Code/LibsvmFunctions, thus no installation of the toolbox is required.
- the searchlight analysis requires some functions from the SPM toolbox which can be downloaded [here](https://www.fil.ion.ucl.ac.uk/spm/software/spm12/)

## Start analysis and plot result

To run the demo, simply run the script Start_Analysis.m in the main folder and follow the prompts in the command window. You will be given the option to run 1) the ROI classification (whole sample) 2) the EEG time-resolved classification (demo subjet) or 3) the EEG time-generalization (demo subjet), respectively for the classification of object location across categories (1) or vice versa (2).


## Durations

To change the parameters for the EEG analyses, change the values of the variables "steps" and "permutations" in the script Start_Analysis.m (for details see script comments).

Durations can vary slightly depending on computing resources. 

### 1) Time-resolved EEG classification: 

Fast parameters (default): ~37 seconds. The fast parameters downsample the EEG time course with a 10 ms resolution and 5 permutations. The result gives a close approximation to the result with original parameters.

Original parameters: ~2 hours. 100 permutations with 1 ms resolution.


### 2) EEG time-generalization:

Fast parameters (default): ~4 minutes. The fast parameters use 5 permutations. The result gives a close approximation to the result with original parameters.

Original parameters: ~85 minutes. 100 permutations with 10 ms resolution. 

Both fast and original version downsample the time points to a 10 ms resolution for speed and efficiency.


### 3) ROI classification:

~ 2 minutes


## Figures

Please be aware that results can differ slightly from time to time because of the random assignment of trials to training and testing bins.

The following single subject or group averaged result figures in this demo correspond to the following group-averaged figures in the manuscript: \
Category_ROI.fig --> Fig. 6b \
Category_Timecourse.fig --> Fig. 6c \
Category_TimeGeneralization.fig --> Fig. 6g \
Location_ROI.fig --> Fig. 3b \
Location_Timecourse.fig --> Fig. 5a \
Location_TimeGeneralization.fig --> Fig. 5e
