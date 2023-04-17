# basic stuff 
import numpy as np
import torch

#custom modules
from train_test import train, test
from pr2 import get_pr2

def get_all_pr2(model, dataset, test_loader, conv):
    '''
    A function to get the pR^2 values by electrode for a given model.

    Args:
        model: the model used to make the predictions.
        dataset: the dataset of interest. This is used to specify the number of electrodes in the dataset to the test function.
        test_loader: the test dataloader used for testing that corresponds to dataset. Can be replaced with 
        conv (bool): set conv to True when using a TCN, False when using a MLP.

    Returns:
        Dx1 array containing the pR^2 values for each electrode in the dataset.
    '''

    criterion = torch.nn.MSELoss()
    optimizer = torch.optim.Adam(model.parameters(), lr=0.001)
    test_loss, test_R2, test_pr2, test_preds, test_targets = test(test_loader, model, optimizer, criterion, dataset.num_neural_units, conv = conv)
    pr2 = get_pr2(test_targets, test_preds, return_electrodes = True)
    return(pr2)

def get_r2_by_electrode(target, pred):
    '''
    A function to get the R^2 values by electrode for a given model.

    Args:
        target (np.array): NxD target array.
        pred (np.array): NxD predictions array.

    Returns:
        Dx1 array containing the R^2 values for each electrode in the dataset.
    '''
    r2_list = []
    for i in range(len(target.shape[1])):
        r2_list.append(r2_score(target[:,i],pred[:,i]))
    return(np.array(r2_list))