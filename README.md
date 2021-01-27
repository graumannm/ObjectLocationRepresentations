# Object Location Representations



This repository contains the analysis code that goes with the manuscript "The spatiotemporal neural dynamics of object location representations in the human brain". 

All analyses were conducted using Matlab 2018b and were also tested on Matlab2016a and Matlab2020b. Additionally, it has been tested on the following operating systems: CentOS Linux, MacOS Big Sur version 11.1, Windows 10.



## Requirements

- Matlab software
- The code depends on functions from the libsvm-3.11 toolbox, but these are provided in the folder /Code/LibsvmFunctions, thus no installation of the toolbox is required.


## Start analysis and plot result

To run the demo, simply run the script Start_Analysis.m in the main folder and follow the prompts in the command window. You will be given the option to run 1) the EEG time-resolved classification 2) the EEG time-generalization or 3) the ROI classification, respectively for the classification of object location across categories or vice versa.


## Durations

To change the parameters for the EEG analyses, change the values of the variables "steps" and "permutations" in the script Start_Analysis.m (for details see script comments).


1) Time-resolved EEG classification: 

Fast parameters (default): ~37 seconds. The fast parameters downsample the EEG time course with a 10 ms resolution and 5 permutations. The result gives a close approximation to the original parameters.

Original parameters: ~2 hours.100 permutations with 1 ms resolution.


2) EEG time-generalization:

Fast parameters (default): ~4 minutes. The fast parameters use 5 permutations. The result gives a close approximation to the original parameters.

Original parameters: ~85 minutes. 100 permutations with 1 ms resolution.

Both fast and original version downsample the time points to a 10 ms resolution for speed and efficiency.


3) ROI classification:

~3 seconds


## Figures

The folder Figures/ contains the results figures for running each of the above analyses for the given subjects with the original parameters used in the manuscript for the single demo subjects. Please be aware that single subject results can differ slightly from time to time because of the random assignment of trials to training and testing bins.

The following single subject results figures in this demo correspond to the following group-averaged figures in the manuscript:
Category_ROI.fig --> Fig. 4b
Category_Timecourse.fig --> Fig. 4c
Category_TimeGeneralization.fig --> Fig. 4f
Location_ROI.fig --> Fig. 2d
Location_Timecourse.fig --> Fig. 3a
Location_TimeGeneralization.fig --> Fig. 3d
