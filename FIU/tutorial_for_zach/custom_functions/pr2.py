# basic stuff 
import numpy as np

def get_pr2(real_data, pred, EPS = 0.000001, return_electrodes = False):
    '''
    This function gets pr2 values.

    Args:
        real_data (np.array): NxD array containing real targets. 
        pred (np.array): NxD array containing real targets. 

    Returns:
        If return_electrodes = True, a Dx1 array containing the pR2 by electrode is returned.
        If return_electrodes = False, the average of the above array is returned.
    '''
    predictions = np.copy(pred)
    predictions[predictions==0]=EPS
    m = np.mean(real_data, axis = 0) #average for each neuron across all instances
    m[m==0]=EPS

    d1 = real_data/predictions #element-wise division
    d2 = real_data/m
    d1[d1==0]=EPS
    d2[d2==0]=EPS

    if (((d1<0).any()) or ((d2<0).any())):
        return(np.nan)
    else:
        a1=(real_data*np.log(d1))-(real_data-predictions)
        a2=(real_data*np.log(d2))-(real_data-m)
        sum1 = np.sum(a1, axis = 0) #sum across instances
        sum2 = np.sum(a2, axis = 0) #sum across instances

        sum2[sum2==0]=EPS
        pR2 = 1 - (sum1/sum2)
        if return_electrodes == False:
            return(np.mean(pR2))
        else:
            return(pR2)