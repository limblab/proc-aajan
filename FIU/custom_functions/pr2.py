# basic stuff 
from scipy import stats, signal, io
import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
import random
import os
import sklearn
import math
from sklearn.metrics import r2_score

# torch stuff
import torch
from torch.utils.data import Dataset, DataLoader, Subset
from torch import nn
import torch.nn.functional as F

def get_pr2(real_data, pred, lam = 0, EPS = 0.000001, return_electrodes = False):
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