import numpy as np
import matplotlib.pyplot as plt
from matlab_jarvis_files import get_jarvis_errors as gje

def scatter(path_GroundTruth_x, path_HybridNetPredictions_x, path_GroundTruth_y, path_HybridNetPredictions_y, label_xaxis, label_yaxis):
	median_errors_x, mean_errors_x, all_errors_x = gje.get_jarvis_errors(path_GroundTruth_x, path_HybridNetPredictions_x)
	median_errors_y, mean_errors_y, all_errors_y  = gje.get_jarvis_errors(path_GroundTruth_y, path_HybridNetPredictions_y)

	mn, mx = int(np.amin(np.c_[median_errors_x, median_errors_y])), int(np.amax(np.c_[median_errors_x, median_errors_y]))
	
	plt.scatter(median_errors_x, median_errors_y)
	plt.plot(np.arange(mn, mx+1), np.arange(mn,mx+1), color = 'red')
	plt.xlabel(label_xaxis)
	plt.ylabel(label_yaxis)
	plt.show()