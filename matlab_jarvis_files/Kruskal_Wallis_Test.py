import numpy as np

# Information on the Kruskal-Wallis Test: https://en.wikipedia.org/wiki/Kruskal%E2%80%93Wallis_one-way_analysis_of_variance

def null_hypothesis_test(arr1,arr2):
	# assert arr1.shape == arr2.shape, "Arrays do not have the same shape."

	n1, n2 = arr1.shape[0], arr2.shape[0]
	rank1, rank2 = np.zeros(n1), np.zeros(n2)
	x = sorted(list(np.concatenate((arr1,arr2))))
	n = len(x)
	df = 1
	rank_variance = ((n**2)-1)/n

	rank_tracker = 1
	for el in x:
		if el in arr1:
			ind = np.where(arr1==el)[0][0]
			rank1[ind] = rank_tracker
		else:
			ind = np.where(arr2==el)[0][0]
			rank2[ind] = rank_tracker

		rank_tracker +=1

	mean_rank_sum1 = np.mean(rank1)
	mean_rank_sum2 = np.mean(rank1)
	expected_mean_rank_sum = (n+1)/2

	H = ((n-1)/n)*(1/rank_variance)*(n1*((mean_rank_sum1-expected_mean_rank_sum)**2)+n2*((mean_rank_sum1-expected_mean_rank_sum)**2))
	reject_null_hypothesis = (H>3.841)
	return(reject_null_hypothesis)


def kw_test(arr1, arr2):
	# assert arr1.shape == arr2.shape, "Arrays do not have the same shape."

	kw_results = []
	for i in range(arr1.shape[1]):
		kw_results.append(null_hypothesis_test(arr1[:,i],arr2[:,i]))

	return(kw_results)