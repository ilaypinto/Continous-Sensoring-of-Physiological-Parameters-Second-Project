This is a README file for Tomer and Ilay's second project in Continous Sensoring of Physiological Parmeters.

#################
###BHQ PROJECT###
#################

Classification problem tackled: Classifing Weekdays vs. Weekends.

##############################################Important###################################################
hhentschke/measures-of-effect-size-toolbox was used for computing Cramer's V during correlations analysis.
If you want the whole code to work, make sure to download this toolbox first.
##########################################################################################################

Objects and Functions in the submission file:

The submission files consists of 'main' function, helper functions, this 'README' file, and a mat file, 
as was asked in the task instructions.

'main' is the main function of the code. Running it with the file path of the given xlsx data files as input,
outputs a confusion matrix of the classified data, using the classifier that was decided as the best classifier
during research and testing of the given data.

The mat file, is the confusion matrix obtained on our test set through the best classifier.

Helper Functions:

1) 'extract_data' extracts the data from the xlsx files, to a comfortable data set.
2) 'feat_extract_norm' extracts features from the dataset, which need a normalization process.
3) 'feat_extract_unnorm' extracts features from the dataset, which don't need a normalization process.
4) 'feat_set' creates a unifind dataset of both normed and not normed features.
5) 'corr_analysis' computes feature-feature correlations, 
    then adds a relieff process, to choose the best features. Moreover, it removes features which had over 15% Nan values.
6) 'main_workflow' was the main code which was used to test all functions and data. from this code,
    Only the relevant parts of the processs were added to the 'main' function. This code was added to show our
    work stages and logic. Both behaviors in PPV and Sensitivity of 90% can be seen in this code.


