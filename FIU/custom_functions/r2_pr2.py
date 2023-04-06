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

#custom modules
from train_test import train, test
from pr2 import get_pr2

def get_all_pr2(model, dataset, test_loader, conv):
    criterion = torch.nn.MSELoss()
    optimizer = torch.optim.Adam(model.parameters(), lr=0.001)
    test_loss, test_R2, test_pr2, test_preds, test_targets = test(test_loader, model, optimizer, criterion, dataset.num_neural_units, conv = conv)
    pr2 = get_pr2(test_targets, test_preds, return_electrodes = True)
    return(pr2)

def get_r2_by_electrode(target, pred):
    r2_list = []
    for i in range(len(target.shape[1])):
        r2_list.append(r2_score(target[:,i],pred[:,i]))
    return(r2_list)


def depth_of_modulation(arr):
    doms = []
    for col in range(arr.shape[1]):
        unit = arr[:,col]
        unit_sorted = sorted(unit)
        perc_90 = int(len(unit_sorted)*0.9)
        perc_5 = int(len(unit_sorted)*5)
        dom = unit_sorted[perc_90] - unit_sorted[perc_5]
        doms.append(dom)
    return(np.array(doms))