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

def train(loader, model, optimizer, criterion, scheduler, conv = False):
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
        # scheduler.step(loss)
        optimizer.step()  # update the parameters

    avg_loss_epoch = sum(batch_losses)/len(batch_losses)
    return(avg_loss_epoch)

def test(loader, model, optimizer, criterion, num_neural_units, conv = False):
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