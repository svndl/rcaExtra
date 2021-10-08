# rcaExtra - sweep extension (BETA)
This repository contains a fork of [svndl/rcaExtra](https://github.com/svndl/rcaExtra), which hosts the **rcaExtra** toolbox written by [Alexandra Yakovleva](https://github.com/leksea) for MATLAB at Stanford University. The toolbox is intended as a front-end for Reliable Components Analysis (RCA) to be used with EEG/fMRI/MEG. It is currently designed to make use of the RCA core toolbox [dmochow/rca](https://github.com/dmochow/rca) written by [Jacek P. Dmochowski](https://github.com/dmochow).

## About this fork
This fork is intended to hosts extensions to cover sweep EEG experiments with the rcaExtra toolbox, as the original rcaExtra only covers steady-state time- and frequency-domain EEG data. I'm keeping this as a fork for now, with the aim of merging the extensions into the main svndl/rcaExtra once the code is deemed clean and stable enough. The extension is intended to be fully compatible with the original rcaExtra toolbox.
The active branch is `feature_sweep`. The `main` branch of this repository will be kept in sync with upstream `svndl/rcaExtra` repository.

## Requirements for using the toolbox
At the present moment, this toolbox depends on the following MATLAB toolboxes:
* [dmochow/rca](https://github.com/dmochow/rca) - core RCA toolbox
* [svndl/mrC](https://github.com/svndl/mrC) - dependency for plotting scalp topographies

Make sure to have the two required repositories cloned and on your MATLAB path. Be careful to remove any reference to the original rcaExtra from your MATLAB path before using this version in order to avoid conflicts.

## Basic usage
As for the original rcaExtra toolbox, beginning the analyses involves creating *at least* two scripts, for now contained in the `examples` project subfolder:
* A main analysis frontend, usually prefixed with `main_`
* A loading function, usually prefixed with `loadExperimentInfo_`

The main frontend function is used to set the required parameters and arguments and to call the proper analysis routines. The loading function is used to specify and control lower-level details about the data, such as participants ID exclusions, xDiva exports subfolder names for loading the data and some other secondary parameter. You can find a generic loading function template generator in `common/rcaExtra_genStructureTemplate()`. This function also contains descriptions of the main required parameters. In case of custom, non-standard data export organization, it is possible to provide a custom low-level data loader to handle such cases.

The idea is to have different main analyses frontends and loading functions for different projects or re-analyses of a given project. 

After setting these two required components up, the analyses should be started by calling the `main_` frontend function, and specifying the **EEG source data location** and the **RCA output data location**: the EEG source data location should be the root folder of your exports (i.e. the folder which contains each participants' xDiva data export subfolders). The output location will be populated with a few subfolder: `RCA/`, containing data structures pertinent to RCA results; `FIG/`, containing exported diagnostics plot (needs to be fixed and tweaked); and `MAT/`, which is populated with the participants loaded data.

### Averaging RCA results
After the core RCA computations are complete, it will be possible to review the results by averaging the data. This is a **separate step** for now.
As of now, the main averaging function for sweeps is `rcaExtra_computeSweepAverages()` which takes an *individual* condition RCA result data structure and returns the same structure populated with averages. If you performed RCA on data containing multiple conditions, you should just map `rcaExtra_computeSweepAverages()` to each condition's result data structure. For example, if you have your RCA results in a cell array with one element per condition, and each element being an RCA result data structure, you can use MATLAB's cellfun:
```matlab
myRCAAverages = cellfun(@(x) rcaExtra_computeSweepAverages(x), myRCAresults);
```
which will call the sweep average function on each individual condition's RCA result structure.

### Visualizing sweep topographies, amplitudes and phases
I've included an interim "summary plot" function, which you can find in the `plotting/` project subfolders, named `rcaExtra_plotSweepProjAmplitudesSummary_beta()`. It is used to visualize topographies, amplitudes and phases for each RC and frequency. Currently, it uses the projected amplitudes and the high noise estimates for the noise ceiling; the error bars around the amplitude data points is currently a re-computed standard error of the means across participants' projected amplitudes. I'm working to also implement asymmetric error bars as estimated through circular statistics (such as Tcirc). This function (which is an active work in progress) will take the following mandatory argument: an **individual RC_averages** structure for a given condition (as output from the aforementioned averaging procedure) pertaining to a single condition. The function also accepts a few optional arguments, such as the number of RCs and frequencies you want to see in the summary plot (**warning**, this is only for debugging, as it is definitely not the same thing as running RCA on a different number of RCs or frequencies), or whether to lock all the amplitude ordinate axes for easier visual comparison, and the phase-to-amplitude vertical relative aspect ratio. 
This function is being actively worked on, so you have my apologies for any sudden breaking change (which will eventually be reported in this README).

## TODOs
* Diagnostics/sanity check: Writing a function to extract a re-projected single channel as a sanity check for the underlying RCA computations
* `rcaExtra_plotSweepProjAmplitudesSummary_beta()`: this function is a temporary summary plot for swept data. It will plot sweep amplitudes and phases for each reliable component and frequency. **Error estimations in these plots needs to be fixed: at the moment, it will just re-calculate the standard error of the means of the individual participants' sweeps and use that as error estimates around the signal amplitudes.**
* Diagnostics/sanity check: fix the diagnostic RCA plots produced by the `rca` toolbox
* Incorporate mrC's `plotOnEgi()` plotting function into the repository: it makes sense to integrate the topography plotting capabilities from `mrC`, as it is currently a requirement only because of this plotting function
* Write proper comments and documentation about new code
* Clean up warnings and messages produced by RCA backbone

## Changes compared to the upstream svndl/rcaExtra toolbox
I've been trying to minimize any changes to the toolbox as a whole while implementing sweep functionality. The changes consist mainly of the addition of a dedicated `sweep` subfolder, containing functions aimed at the sweep RCA analyses. 
A list the changes made to the common rcaExtra infrastructure will be provided at a later time.
