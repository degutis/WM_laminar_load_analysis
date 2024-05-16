warning("Please see whether the path to libsvm is correct")

addpath(genpath('../../Analysis/libsvm-3.25'));
addpath(genpath('functions'));
addpath(genpath('plotting'));
%% Behavioral

behAnalysis

%% Univariate analysis

univariate_analysis('dlPFC')
univariate_analysis('COP')
univariate_analysis('dlPFC_right')
univariate_analysis('COP_right')

generateFigureUnivariate(0)
generateFigureUnivariate(1)

%% Multivariate analysis

decoding('Load','dlPFC',1)
decoding('Motor','dlPFC',0)
decoding('Load','COP',0)
decoding('Motor','COP',0)

decoding('Load','dlPFC_right',0)
decoding('Motor','dlPFC_right',0)
decoding('Load','COP_right',0)
decoding('Motor','COP_right',0)

generateFigureMultivariate_NullDist(0)
generateFigureMultivariate_NullDist(1)

generateCrossTemporalFig

%% Analyses answering reviewers

ranova_time_layer_decoding 
decoding_sanityCheck("rt_sanityCheck")
decoding_sanityCheck("onlyCorrectTrials")
generateVoxelFig