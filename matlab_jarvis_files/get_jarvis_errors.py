import numpy as np

def get_jarvis_errors(path_GroundTruth, path_HybridNetPredictions):

	# GroundTruth and HybridNetPredictions have shape = (49,69)
	# 49 instances in the validation set
	# 23 keypoints, each which 3D coordinates (23x3=69)
	GroundTruth = np.genfromtxt(path_GroundTruth, delimiter=',')
	HybridNetPredictions = np.genfromtxt(path_HybridNetPredictions, delimiter=',')
	diff_matx = HybridNetPredictions-GroundTruth

	# set up landmarks - values for 3D coords of each keypoint
	pinky_t = np.array([1,2,3])
	pinky_d = np.array([4,5,6])
	pinky_m = np.array([7,8,9])
	pinky_p = np.array([10,11,12])

	ring_t = np.array([13,14,15])
	ring_d = np.array([16,17,18])
	ring_m = np.array([19,20,21])
	ring_p = np.array([22,23,24])

	middle_t = np.array([25,26,27])
	middle_d = np.array([28,29,30])
	middle_m = np.array([31,32,33])
	middle_p = np.array([34,35,36])

	index_t = np.array([37,38,39])
	index_d = np.array([40,41,42])
	index_m = np.array([43,44,45])
	index_p = np.array([46,47,48])

	thumb_t = np.array([49,50,51])
	thumb_d = np.array([52,53,54])
	thumb_m = np.array([55,56,57])
	thumb_p = np.array([58,59,60])
	
	palm = np.array([61,62,63])
	wrist_u = np.array([64,65,66])
	wrist_r = np.array([67,68,69])

	# set up differences - these will store the euclidian distances for each kepoint
	# shape = 49x1
	diff_pinky_t = np.zeros(GroundTruth.shape[0])
	diff_pinky_d = np.zeros(GroundTruth.shape[0])
	diff_pinky_m = np.zeros(GroundTruth.shape[0])
	diff_pinky_p = np.zeros(GroundTruth.shape[0])

	diff_ring_t = np.zeros(GroundTruth.shape[0])
	diff_ring_d = np.zeros(GroundTruth.shape[0])
	diff_ring_m = np.zeros(GroundTruth.shape[0])
	diff_ring_p = np.zeros(GroundTruth.shape[0])

	diff_middle_t = np.zeros(GroundTruth.shape[0])
	diff_middle_d = np.zeros(GroundTruth.shape[0])
	diff_middle_m = np.zeros(GroundTruth.shape[0])
	diff_middle_p = np.zeros(GroundTruth.shape[0])

	diff_index_t = np.zeros(GroundTruth.shape[0])
	diff_index_d = np.zeros(GroundTruth.shape[0])
	diff_index_m = np.zeros(GroundTruth.shape[0])
	diff_index_p = np.zeros(GroundTruth.shape[0])

	diff_thumb_t = np.zeros(GroundTruth.shape[0])
	diff_thumb_d = np.zeros(GroundTruth.shape[0])
	diff_thumb_m = np.zeros(GroundTruth.shape[0])
	diff_thumb_p = np.zeros(GroundTruth.shape[0])

	diff_palm = np.zeros(GroundTruth.shape[0])
	diff_wrist_u = np.zeros(GroundTruth.shape[0])
	diff_wrist_r = np.zeros(GroundTruth.shape[0])
	
	diff_matx = GroundTruth - HybridNetPredictions

	# for each instance in validation set, get the euclidian distance between GroundTruth keypoint and HybridNetPrediction keypoint
	for i in range((diff_matx.shape[0])):
		diff_pinky_t[i] = np.linalg.norm(diff_matx[i, :pinky_t[-1]])
		diff_pinky_d[i] = np.linalg.norm(diff_matx[i, pinky_t[-1]:pinky_d[-1]])
		diff_pinky_m[i] = np.linalg.norm(diff_matx[i, pinky_d[-1]:pinky_m[-1]])
		diff_pinky_p[i] = np.linalg.norm(diff_matx[i, pinky_m[-1]:pinky_p[-1]])

		diff_ring_t[i] = np.linalg.norm(diff_matx[i, pinky_p[-1]:ring_t[-1]])
		diff_ring_d[i] = np.linalg.norm(diff_matx[i, ring_t[-1]:ring_d[-1]])
		diff_ring_m[i] = np.linalg.norm(diff_matx[i, ring_d[-1]:ring_m[-1]])
		diff_ring_p[i] = np.linalg.norm(diff_matx[i, ring_m[-1]:ring_p[-1]])

		diff_middle_t[i] = np.linalg.norm(diff_matx[i, ring_p[-1]:middle_t[-1]])
		diff_middle_d[i] = np.linalg.norm(diff_matx[i, middle_t[-1]:middle_d[-1]])
		diff_middle_m[i] = np.linalg.norm(diff_matx[i, middle_d[-1]:middle_m[-1]])
		diff_middle_p[i] = np.linalg.norm(diff_matx[i, middle_m[-1]:middle_p[-1]])

		diff_index_t[i] = np.linalg.norm(diff_matx[i, middle_p[-1]:index_t[-1]])
		diff_index_d[i] = np.linalg.norm(diff_matx[i, index_t[-1]:index_d[-1]])
		diff_index_m[i] = np.linalg.norm(diff_matx[i, index_d[-1]:index_m[-1]])
		diff_index_p[i] = np.linalg.norm(diff_matx[i, index_m[-1]:index_p[-1]])

		diff_thumb_t[i] = np.linalg.norm(diff_matx[i, index_p[-1]:thumb_t[-1]])
		diff_thumb_d[i] = np.linalg.norm(diff_matx[i, thumb_t[-1]:thumb_d[-1]])
		diff_thumb_m[i] = np.linalg.norm(diff_matx[i, thumb_d[-1]:thumb_m[-1]])
		diff_thumb_p[i] = np.linalg.norm(diff_matx[i, thumb_m[-1]:thumb_p[-1]])

		diff_palm[i] = np.linalg.norm(diff_matx[i, thumb_p[-1]:palm[-1]])
		diff_wrist_u[i] = np.linalg.norm(diff_matx[i, palm[-1]:wrist_u[-1]])
		diff_wrist_r[i] = np.linalg.norm(diff_matx[i, wrist_u[-1]:wrist_r[-1]])

	# concatenate all errors
	# shape = 49x23
	all_diffs = np.c_[diff_pinky_t,diff_pinky_d,diff_pinky_m,diff_pinky_p,
						diff_ring_t,diff_ring_d,diff_ring_m,diff_ring_p,
						diff_middle_t,diff_middle_d,diff_middle_m,diff_middle_p,
						diff_index_t,diff_index_d,diff_index_m,diff_index_p,
						diff_thumb_t,diff_thumb_d,diff_thumb_m,diff_thumb_p,
						diff_palm,diff_wrist_u,diff_wrist_r]

	# get median and mean errors for each keypoint across 49 instances in validation set
	median_errors = np.median(all_diffs, axis=0)
	mean_errors = np.mean(all_diffs, axis=0)

	#should be 23x1 array
	return(median_errors, mean_errors, all_diffs)