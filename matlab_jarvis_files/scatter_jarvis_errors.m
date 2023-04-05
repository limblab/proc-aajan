% This one could definitely use some work to optimize and modularize.
% Essentially getting the median erros from 2 models and plotting them
% against each other to compare performance.

% See get_jarvis_errors for more info
path_GroundTruth_x = '/Volumes/fsmresfiles/Basic_Sciences/Phys/L_MillerLab/limblab/User_folders/Aajan/Jarvis_results/Aajan-MonkeyHand-PretrainedWeights-20220512/points_GroundTruth.csv';
path_HybridNetPredictions_x = '/Volumes/fsmresfiles/Basic_Sciences/Phys/L_MillerLab/limblab/User_folders/Aajan/Jarvis_results/Aajan-MonkeyHand-PretrainedWeights-20220512/points_HybridNet.csv';
path_GroundTruth_y = '/Volumes/fsmresfiles/Basic_Sciences/Phys/L_MillerLab/data/DPZ/JarvisProjects/projects/Pooled20220425/analysis/Validation_Predictions_20220426-140951/points_GroundTruth.csv';
path_HybridNetPredictions_y = '/Volumes/fsmresfiles/Basic_Sciences/Phys/L_MillerLab/data/DPZ/JarvisProjects/projects/Pooled20220425/analysis/Validation_Predictions_20220426-140951/points_HybridNet.csv';

median_errors_x = get_jarvis_errors(path_GroundTruth_x, path_HybridNetPredictions_x);
median_errors_y = get_jarvis_errors(path_GroundTruth_y, path_HybridNetPredictions_y);

figure; hold on
scatter(median_errors_x, median_errors_y, 'filled')
xlabel('Median Error (mm) - model x') % these can be any way you describe the models, ie
ylabel('Median Error (mm) - model y') % 'model 3003' or '2000 training frames' etc
plot([0 max(max(median_errors_25),max(median_errors_50))], [0 max(max(median_errors_25),max(median_errors_50))])
title('Median Error from Ground Truth')