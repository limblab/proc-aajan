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

#custome
from pr2 import get_pr2

device = torch.device('cuda' if torch.cuda.is_available() else 'cpu')

class RBFKernel(nn.Module):
    def __init__(self, sigma):
        super(RBFKernel, self).__init__()
        self.sigma = sigma

    def forward(self, X, Y):
        """
        Computes the RBF kernel matrix between two sets of vectors X and Y.

        Args:
            X: A PyTorch tensor of shape (m, d), where m is the number of vectors and d is the dimensionality of each vector.
            Y: A PyTorch tensor of shape (n, d), where n is the number of vectors and d is the dimensionality of each vector.

        Returns:
            A PyTorch tensor of shape (m, n) containing the RBF kernel matrix.
        """
        M, N = X.shape[0], Y.shape[0]
        X2 = torch.sum(X**2, dim=2).view(M, -1, 1)
        Y2 = torch.sum(Y**2, dim=2).view(N, -1, 1)
        XY = torch.matmul(X, torch.transpose(Y, 1, 2))
        dist = X2 + Y2 - 2*XY
        return torch.exp(-dist/(2*self.sigma**2))

class MMDLoss(nn.Module):
    def __init__(self, sigma):
        super(MMDLoss, self).__init__()
        self.sigma = sigma
        self.rbf_kernel = RBFKernel(sigma)

    def forward(self, x, y):
        """
        Computes the Maximum Mean Discrepancy (MMD) between two distributions x and y.

        Args:
            x: A PyTorch tensor of shape (m, d), where m is the number of samples and d is the dimensionality of each sample.
            y: A PyTorch tensor of shape (n, d), where n is the number of samples and d is the dimensionality of each sample.

        Returns:
            A scalar tensor representing the MMD between the two distributions.
        """
        xx = self.rbf_kernel(x, x)
        xy = self.rbf_kernel(x, y)
        yy = self.rbf_kernel(y, y)
        mmd = torch.mean(xx) + torch.mean(yy) - 2*torch.mean(xy)
        return mmd

def train(loader, model, optimizer, criterion, scheduler, conv = False):
    '''
    Training function for any model.

    Args:
        loader: data loader where each instance a tuple with input/target/sample numbers.
        model: model to be tested.
        optimizer: optimizer algorithm used to calculate the gradient.
        criterion: loss function.
        num_neural_units (int): the number of electrodes and dimensionality of the target data.
        conv (bool): Set to False when testing a MLP, True when testing a TCN.
    Returns:
        avg_loss_epoch (float): average loss per epoch.
    '''
    model.train()
    batch_losses = []

    for i, (input, target, sample_num) in enumerate(loader):
        optimizer.zero_grad() #clear gradient
        input = input.to(device, dtype=torch.float)
        target = target.to(device, dtype=torch.float)
        
        pred = model(input)
        loss = criterion(pred, target)  # calculate loss
        mean_batch_loss = loss.item()
        batch_losses.append(mean_batch_loss)

        loss.backward()  # one backward pass
        optimizer.step()  # update the parameters

    avg_loss_epoch = sum(batch_losses)/len(batch_losses)
    return(avg_loss_epoch)

def test(loader, model, optimizer, criterion, num_neural_units, conv = False):
    '''
    Testing function for any model.

    Args:
        loader: data loader where each instance a tuple with input/target/sample numbers.
        model: model to be tested.
        criterion: loss function.
        num_neural_units (int): the number of electrodes and dimensionality of the target data.
        conv (bool): Set to False when testing a MLP, True when testing a TCN.

    Returns:
        avg_loss_epoch (float): average loss per epoch.
        r2_tot_batch (float): r2 for the entire dataset.
        pr2_tot_batch (float): pr2 for the entire dataset.
        pred_tot (np.array): NxD array containing all the predictions of the model.
        output_tot (np.array): NxD array containing all the targets of the dataset.
    '''
    model.eval()
    batch_losses = []
    pred_tot = []
    output_tot = []

    with torch.no_grad():
        for i, (input, target, sample_num) in enumerate(loader):
            input = input.to(device, dtype=torch.float)
            target = target.to(device, dtype=torch.float)
            pred = model(input)

            loss = criterion(pred, target)  
            mean_batch_loss = loss.item()
            batch_losses.append(mean_batch_loss)
            
            pred_tot += pred
            output_tot += target

    avg_loss_epoch = sum(batch_losses)/len(batch_losses)
    pred_tot = torch.stack(pred_tot).detach().numpy()
    output_tot = torch.stack(output_tot).detach().numpy()
    if conv == True:
        pred_tot = pred_tot.reshape(-1,num_neural_units)
        output_tot = output_tot.reshape(-1,num_neural_units)
    r2_tot_batch = r2_score(output_tot, pred_tot, multioutput='variance_weighted')
    pr2_tot_batch = get_pr2(output_tot, pred_tot)
    
    return(avg_loss_epoch, r2_tot_batch, pr2_tot_batch, pred_tot, output_tot)