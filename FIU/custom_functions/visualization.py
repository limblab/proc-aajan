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
import seaborn as sn
import time
from scipy.stats import ks_2samp
import itertools
from sklearn.decomposition import PCA

# torch stuff
import torch
from torch.utils.data import Dataset, DataLoader, Subset
from torch import nn
import torch.nn.functional as F

#custom modules
from models import FCNet, TempConvNet
from train_test import train, test, MMDLoss
from pr2 import get_pr2
import r2_pr2
import data_loading


################################ PRIMARY FUNCTIONS ################################

def plot_losses_MLP(dataset, train_loader, test_loader, learning_rate, num_layers, hidden_layer_dim = 112, add_relu = True, adapt_lr = True, save = True, numepochs = 101, split = 'NonSplit', loss_type = 'mse_loss', restraint_type='fullyrestrained'):
    '''
    Trains a MLP, plots the train and test loss curves, and saves the model in the directory specified.
    
    Args:
        dataset (torch.utils.data.Dataset): full dataset corresponding to the train and test dataloaders.
        train_loader (torch.utils.data.DataLoader): training data used to train model.
        test_loader (torch.utils.data.DataLoader): testing data used to test model.
        learning_rate (float): the initial learning rate 
        num_layers (int): the number of fully connected layers in the model 
        add_relu (bool): this gives you the option of adding a relu layer at the end. The default is True since we're trying to predict non-negative firing rates.
        save (bool): when True, the model is saved in the specified directory.
        adapt_lr (bool): when True, the learning rate will change according to the learning rate scheduler below. When False, a constant learning rate is used.
        split (str): 'SplitNeurons' or 'NonSplit'. Used only for saving different models in different directories. 
        loss_type (str): 'mse_loss' or 'mmd_loss'. MMD loss minimizes the Maximum Mean Discrepancy between the targets and predictions.
        restraint_type (str): 'fullyrestrained' or 'semirestrained'. Used only for saving different models in different directories.

    Returns:
        Trained MLP model.
    '''

    model = FCNet(input_dim=dataset.input_dim, output_dim=dataset.num_neural_units, \
                  num_layers=num_layers, hidden_layer_dim=hidden_layer_dim, add_relu = add_relu)

    if loss_type == 'mse_loss':
        criterion = torch.nn.MSELoss()
    elif loss_type == 'mmd_loss':
        criterion = MMDLoss(sigma=1.0)

    optimizer = torch.optim.Adam(model.parameters(), lr=learning_rate)
    scheduler = torch.optim.lr_scheduler.ReduceLROnPlateau(optimizer, factor=0.8, patience=8, min_lr=0.00005)
    total_params = sum(p.numel() for p in model.parameters())

    print('{}, full dataset'.format(model.name))
    print('Num Layers: {}, Hidden Layer Dimensionality: {}, Total Parameters: {}'\
        .format(model.num_layers, model.hidden_layer_dim, total_params))

    train_losses = []
    val_losses = []
    test_losses = []
    start = time.time()
    for epoch in range(numepochs):
        lr = scheduler.optimizer.param_groups[0]['lr']
        train_loss = train(train_loader, model, optimizer, criterion, scheduler)
        _, train_R2, train_pr2, train_preds, train_targets = test(train_loader, model, optimizer, criterion, dataset.num_neural_units)
        test_loss, test_R2, test_pr2, test_preds, test_targets = test(test_loader, model, optimizer, criterion, dataset.num_neural_units)
        if adapt_lr == True:
            scheduler.step(test_loss)
        if epoch % 50==0:
            print('Epoch: {:03d}, LR: {:7f}, Train Loss: {:7f}, Test Loss: {:7f}. Train R2: {:.7f}, Test R2: {:.7f}, Train pR2: {:.7f}, Test pR2: {:.7f}'\
                  .format(epoch, lr, train_loss, test_loss, train_R2, test_R2, train_pr2, test_pr2))
        train_losses.append(train_loss)
        test_losses.append(test_loss)
    end = time.time()
    print('Time to train model: {}'.format(end-start))

    plt.plot(train_losses)
    plt.plot(test_losses)
    plt.title('Losses - Date: {}, Model: {}, Layers: {}'.format(dataset.date, model.name, model.num_layers))
    plt.xlabel('Epochs')
    plt.ylabel('Loss')
    plt.legend(['Train Losses', 'Test Losses'])
    plt.show()


    directory = '/content/drive/My Drive/Miller_Lab/FIU/MLP/Pop_FR_OpenSIM/{}/{}/{}/{}/'.format(split,restraint_type,loss_type,dataset.date)
    if split == 'NonSplit':
        model_name = 'MLP_{}_{}_{}_layers_reluadded'.format(dataset.date,dataset.input_type,model.num_layers)
    elif split == 'SplitNeurons':
        model_name = '{}/MLP_{}_{}_layers'.format(dataset.split_num,dataset.input_type,model.num_layers)
    if save == True:
        if os.path.exists(directory) == False:
            os.makedirs(directory)
        torch.save(model.state_dict(), directory+model_name)

    return(model)

def plot_losses_TempCNN(dataset, train_loader, test_loader, learning_rate, num_conv_layers, kernel_size = 5, add_relu = True, causal = True, adapt_lr = True, save = True, l2_reg = 0, numepochs = 301, training_type = 'Standard', split = 'NonSplit', instance_length=100, loss_type = 'mse_loss',restraint_type='fullyrestrained'):
    '''
    Trains a TCN, plots the train and test loss curves, and saves the model in the directory specified.
    
    Args:
        dataset (torch.utils.data.Dataset): full dataset corresponding to the train and test dataloaders.
        train_loader (torch.utils.data.DataLoader): training data used to train model.
        test_loader (torch.utils.data.DataLoader): testing data used to test model.
        learning_rate (float): the initial learning rate
        num_conv_layers (int): the number of convolutional connected layers in the model
        kernel_size (int): length of the kernel
        add_relu (bool): this gives you the option of adding a relu layer at the end. The default is True since we're trying to predict non-negative firing rates.
        causal (bool): when True, the convolutional layers are guaranteed to be causal, and padding is appended to the end of the input. when false, padding is appended to both the beginning and end of the input.
        adapt_lr (bool): when True, the learning rate will change according to the learning rate scheduler below. when False, a constant learning rate is used.
        save (bool): when True, the model is saved in the specified directory.
        l2_reg (int): gives you the option of regularizing the model with L2
        loss_type (str): mse_loss or mmd_loss. MMD loss minimizes the Maximum Mean Discrepancy between the targets and predictions.
        restraint_type (str): this is only used for saving purposes. keeps fullyrestrained and semirestrained models separate and easy to find.

    Returns:
        Trained TCN model.
    '''

    num_readout_layers, kernel_size, num_kernels = 1, kernel_size, 2
    model = TempConvNet(dataset.input_dim, dataset.num_neural_units, num_conv_layers, \
                        num_readout_layers, kernel_size, num_kernels, add_relu = add_relu, causal=causal)
    
    if loss_type == 'mse_loss':
        criterion = torch.nn.MSELoss()
    elif loss_type == 'mmd_loss':
        criterion = MMDLoss(sigma=1.0)
    print(criterion)
    optimizer = torch.optim.Adam(model.parameters(), lr=learning_rate)
    if l2_reg > 0:
        optimizer = torch.optim.Adam(model.parameters(), lr=learning_rate, weight_decay=l2_reg)
    scheduler = torch.optim.lr_scheduler.ReduceLROnPlateau(optimizer, factor=0.8, patience=8, min_lr=0.00005)
    total_params = sum(p.numel() for p in model.parameters())

    print('{}, full dataset'.format(model.name))
    print('Num Conv Layers: {}, Kernel Size: {}, Total Parameters: {}'\
        .format(model.num_conv_layers, model.kernel_size, total_params))

    train_losses = []
    val_losses = []
    test_losses = []
    start = time.time()
    for epoch in range(numepochs):
        lr = scheduler.optimizer.param_groups[0]['lr']
        train_loss = train(train_loader, model, optimizer, criterion, scheduler)
        _, train_R2, train_pr2, train_preds, train_targets = test(train_loader, model, optimizer, criterion, dataset.num_neural_units, conv = True)
        test_loss, test_R2, test_pr2, test_preds, test_targets = test(test_loader, model, optimizer, criterion, dataset.num_neural_units, conv = True)
        if adapt_lr == True: 
            scheduler.step(test_loss)
        if epoch % 50==0:
            print('Epoch: {:03d}, LR: {:7f}, Train Loss: {:7f}, Test Loss: {:7f}. Train R2: {:.7f}, Test R2: {:.7f}, Train pR2: {:.7f}, Test pR2: {:.7f}'\
                  .format(epoch, lr, train_loss, test_loss, train_R2, test_R2, train_pr2, test_pr2))
        train_losses.append(train_loss)
        test_losses.append(test_loss)
    end = time.time()
    print('Time to train model: {}'.format(end-start))

    plt.plot(train_losses)
    plt.plot(test_losses)
    plt.title('Losses - Date: {}, Model: {}, Conv Layers: {}'.format(dataset.date, model.name, model.num_conv_layers))
    plt.xlabel('Epochs')
    plt.ylabel('Loss')
    plt.legend(['Train Losses', 'Test Losses'])
    plt.show()


    directory = '/content/drive/My Drive/Miller_Lab/FIU/Temporal_CNN/Pop_FR_OpenSIM/{}/{}/instance_length_{}/{}/{}/{}/'.format(training_type,split,instance_length,restraint_type,loss_type,dataset.date)
    if split == 'NonSplit':
        model_name = 'TempCNN_{}_{}_{}_convlayers_reluadded'.format(dataset.date,dataset.input_type,model.num_conv_layers)
    elif split == 'SplitNeurons':
        model_name = '{}/TempCNN_{}_{}_convlayers_reluadded'.format(dataset.split_num,dataset.input_type,model.num_conv_layers)
    print(directory+model_name)
    if save == True:
        if os.path.exists(directory) == False:
            os.makedirs(directory)
        torch.save(model.state_dict(), directory+model_name)

    return(model)

def plot_losses_transfer_learning_TCN(dataset_dict, loader_dict, num_permutations, init_lr, lr_factor, num_epochs = 101):
    '''
    Trains multiple TCNs in transfer learning. The model is trained in the following way:
    
    A set of random permutations of dates and splits is created.
    All permutations for the splits are flattened into a list - since I made 3 splits, this makes a list of 18 integers.
    A subset of 18 permutations for dates is chosen.
    The learning rate begins at init_lr for all layers, and then decreased for the core of the model (i.e. the convolutional layers) by a factor of lr_factor each time the split number changes.
    The transfer layer is alwyas trained with an initial learning rate of init_lr.

    Below is an example of how the models are trained:
        Split 0, Date Permutation 0 (e.g. '20210712', '20220309', '20210710', '20211105', '20210814'), transfer layer lr = 0.001, core initial learning rate = 0.001
        Split 1, Date Permutation 1 (e.g. '20210710', '20211105', '20210814', '20210712', '20220309'), transfer layer lr = 0.001, core initial learning rate = 0.001*lr_factor
        Split 2, Date Permutation 2 (e.g. '20210814', '20210712', '20220309', '20210710', '20211105'), transfer layer lr = 0.001, core initial learning rate = 0.001*(lr_factor^2)
        Split 1, Date Permutation 3 (e.g. '20220309', '20210712', '20211105', '20210710', '20210814'), transfer layer lr = 0.001, core initial learning rate = 0.001*(lr_factor^3)
        Split 2, Date Permutation 3 (e.g. '20211105', '20210710', '20210712', '20210814', '20220309'), transfer layer lr = 0.001, core initial learning rate = 0.001*(lr_factor^4)
        Split 0, Date Permutation 3 (e.g. '20220309', '20211105', '20210814', '20210712', '20210710'), transfer layer lr = 0.001, core initial learning rate = 0.001*(lr_factor^5)
        etc...
    After 18 rounds, the final learning rate for the core layers is 0.001*(lr_factor^18). For lr_factor = 0.7, this equates to 1.6e-6.

    Args:
        dataset_dict (dict): a dictionary containing datasets that are split by electrode.
        loader_dict (dict): a dictionary containing train and test loaders that are also split by electrode.
        init_lr (float): the initial learning rate for the convolutional layers.
        lr_factor (float): the factor by which the initial learning rate is decayed every permutation.
        num_epochs (int): number of epochs each model is trained each permutation.

    Returns:
        A dictionary containing all the models for each date/split.
    '''
    device = torch.device('cuda' if torch.cuda.is_available() else 'cpu')

    all_dataset_permutations = list(itertools.permutations(dataset_dict))
    split_perms = list(itertools.permutations(['0','1','2']))
    split_list = [item for tuple in split_perms for item in tuple]

    perm_nums = np.random.randint(low=0, high=len(all_dataset_permutations), size=num_permutations)
    perm_nums[0]=0

    losses = {'All Losses': {},'By Dataset': {}}
    losses['All Losses'][lr_factor] = {'Train': [], 'Test': []}
    losses['By Dataset'][lr_factor] = {'Train': {},'Test': {}}
    for date in loader_dict.keys():
        for train_test_str in losses['By Dataset'][lr_factor].keys():
            losses['By Dataset'][lr_factor][train_test_str][date] = {'0':[],'1':[],'2':[]}

    models = {}
    for date in dataset_dict.keys():
        models[date] = {}
        for input_type in dataset_dict[date].keys():
            models[date][input_type] = {}
    
    date0 = list(loader_dict.keys())[0]
    output_dim = dataset_dict[date0]['Joint Angles']['0']['Full'].num_neural_units
    model = TempConvNet(24, output_dim, 3, 1, 5, 2, add_relu = True, causal=True).to(device)

    # get randomly initialized linear layers

    linear_layers = {}
    for date in dataset_dict.keys():
        linear_layers[date] = {}
        for split in split_list:
            output_dim = dataset_dict[date]['Joint Angles'][split]['Full'].num_neural_units
            m = TempConvNet(24, output_dim, 3, 1, 5, 2, add_relu = True, causal=True).to(device)
            linear_layers[date][split] = m.net[-2]

    for iteration, (split, perm_num) in enumerate(zip(split_list, perm_nums)):
        perm = all_dataset_permutations[perm_num]
        for i, date in enumerate(perm):
            print(date, split)
            
            model.net[-2] = linear_layers[date][split]

            train_loader, test_loader, full_dataset = \
                loader_dict[date]['Joint Angles'][split]['Train'], \
                loader_dict[date]['Joint Angles'][split]['Test'], \
                dataset_dict[date]['Joint Angles'][split]['Full']

            print(date, split, model.net[-2],full_dataset.num_neural_units)

            lr = init_lr*(lr_factor**(iteration))
            criterion = torch.nn.MSELoss()
            optimizer = torch.optim.Adam([
                {'params': model.net[0].parameters(), 'lr': lr},
                {'params': model.net[2].parameters(), 'lr': lr},
                {'params': model.net[4].parameters(), 'lr': lr},
                {'params': model.net[6].parameters(), 'lr': 0.001}])
            scheduler = torch.optim.lr_scheduler.ReduceLROnPlateau(optimizer, factor=0.8, patience=8, min_lr=0.0)   
            total_params = sum(p.numel() for p in model.parameters())

            print('Date: {}, Split: {}, Initial LR: {} '.format(date,split,lr))
            print('Num Conv Layers: {}, Total Parameters: {}'\
                .format(model.num_conv_layers, total_params))

            start = time.time()
            for epoch in range(num_epochs):
                lr = scheduler.optimizer.param_groups[0]['lr']
                train_loss = train(train_loader, model, optimizer, criterion, scheduler, conv = True)
                _, train_R2, train_pr2, train_preds, train_targets = test(train_loader, model, optimizer, criterion, full_dataset.num_neural_units, conv = True)
                test_loss, test_R2, test_pr2, test_preds, test_targets = test(test_loader, model, optimizer, criterion, full_dataset.num_neural_units, conv = True)
                scheduler.step(test_loss)
                if epoch % 50==0:
                  print('Epoch: {:03d}, LR: {:7f}, Train Loss: {:7f}, Test Loss: {:7f}. Train R2: {:.7f}, Test R2: {:.7f}, Train pR2: {:.7f}, Test pR2: {:.7f}'\
                      .format(epoch, lr, train_loss, test_loss, train_R2, test_R2, train_pr2, test_pr2))

                losses['All Losses'][lr_factor]['Train'].append(train_loss)
                losses['All Losses'][lr_factor]['Test'].append(test_loss)
                losses['By Dataset'][lr_factor]['Train'][date][split].append(train_loss)
                losses['By Dataset'][lr_factor]['Test'][date][split].append(test_loss)

            end = time.time()
            print('Time to train model: {}'.format(end-start))
            plt.plot(losses['By Dataset'][lr_factor]['Train'][date][split])
            plt.plot(losses['By Dataset'][lr_factor]['Test'][date][split])
            plt.title('Losses - Date: {}, Split: {}, Num Conv Layers: {}'.format(date, split, model.num_conv_layers))
            plt.xlabel('Epochs')
            plt.ylabel('Loss')
            plt.legend(['Train Losses', 'Test Losses'])
            plt.show()

            # replace linear layer with most recently trained
            linear_layers[date][split] = model.net[-2]

            models[date]['Joint Angles'][split] = model

    return(models)

def plot_and_compare_ks(model_1_name, model1, dataset1, test_loader1, conv1, model_2_name, model2, dataset2, test_loader2, conv2, restraint_type, exclude_bad_neurons = False, bins = 20, split = False):
    '''
    Plots a two histograms of the Kolomogrov-Smirnov statistic for each electrode - one histogram for each trained model. 
    Orange and blue vertical lines correspond to the mean of each distribution.

    Args:
        model_1_name, model_2_name (str): names of the trained models being compared (e.g. 'MLP', 'TCN')
        model1, model2 (FCNet or TempConvNet): trained models whose pR^2 values being compared. 
        dataset1, dataset2 (torch.utils.data.Dataset): full datasets corresponding to the test_loaders.
        test_loader_1, test_loader_2 (torch.utils.data.DataLoader): dataloaders with the test sets of interest.
        conv1, conv2 (bools): True for TempCNN, False for MLP.
        restraint_type (str): fullyrestrained or semirestrained.
        bins (int): number of bins for histogram.
    '''
    criterion = torch.nn.MSELoss()
    optimizer1 = torch.optim.Adam(model1.parameters(), lr=0.001)
    optimizer2 = torch.optim.Adam(model2.parameters(), lr=0.001)
    test_loss_1, test_R2_1, test_pr2_1, test_preds_1, test_targets_1 = test(test_loader1, model1, optimizer1, criterion, dataset1.num_neural_units, conv = conv1)
    test_loss_2, test_R2_2, test_pr2_2, test_preds_2, test_targets_2 = test(test_loader2, model2, optimizer2, criterion, dataset2.num_neural_units, conv = conv2)

    ks_elect_1 = []
    ks_elect_2 = []
    pr2_by_neuron_model1 = r2_pr2.get_all_pr2(model1, dataset1, test_loader1, conv = conv1)
    pr2_by_neuron_model2 = r2_pr2.get_all_pr2(model2, dataset2, test_loader2, conv = conv2)

    for k in range(test_targets_1.shape[1]):
        ks_1 = ks_2samp(test_targets_1[:,k], test_preds_1[:,k]).statistic
        ks_2 = ks_2samp(test_targets_2[:,k], test_preds_2[:,k]).statistic
        ks_elect_1.append(ks_1)
        ks_elect_2.append(ks_2)

    ks_elect_1 = np.array(ks_elect_1)
    ks_elect_2 = np.array(ks_elect_2)

    if exclude_bad_neurons == True:
        ks_elect_1, ks_elect_2 = ks_elect_1[pr2_by_neuron_model2>0], ks_elect_2[pr2_by_neuron_model2>0]

    test_target_dist = np.histogram(ks_elect_1, bins=bins)
    plt.hist(ks_elect_1, bins = bins, alpha = 0.4, label = model_1_name)
    plt.hist(ks_elect_2, bins = test_target_dist[1], alpha = 0.4, label = model_2_name)
    plt.axvline(x=np.mean(ks_elect_1), color = 'blue')
    plt.axvline(x=np.mean(ks_elect_2), color = 'orange')
    if split == True:
        plt.title('{} Split {} K-S Test Distribution by Electrode\n{}'.format(dataset1.date, dataset1.split_num, restraint_type))
    else:
        plt.title('{} K-S Test Distribution by Electrode\n{}'.format(dataset1.date, restraint_type))
    plt.xlabel('KS Statistic')
    plt.ylabel('Count')
    plt.legend()
    plt.show()
    return(np.mean(ks_elect_1),np.mean(ks_elect_2))

def compare_pr2_plots(model_1_name, model1, dataset1, test_loader1, conv1, model_2_name, model2, dataset2, test_loader2, conv2, restraint_type, exclude_bad_neurons = False, frac = 0.5, max_dom = 101, split = False):
    '''
    Plots a scatterplot of the pR^2 values of two models. This is one of my most often-used functions for comparing models.
    Values on the x-axis correspond to model1, values on the y-axis correspond to model2.

    Args:
        model_1_name, model_2_name (str): names of the trained models being compared (e.g. 'MLP', 'TCN')
        model1, model2: trained models whose pR^2 values being compared. 
        dataset1, dataset2: full datasets corresponding to the test_loaders.
        test_loader_1, test_loader_2: dataloaders with the test sets of interest.
        conv1, conv2 (bools): True for TempCNN, False for MLP.
        restraint_type (str): fullyrestrained or semirestrained.
        exclude_bad_neurons (bool): when False, all electrodes are plotted. when True, a subset of "good" electrodes are plotted. Good electrodes are those where model2's pR^2 values are greater than 0.
                                    There's probably a better way to do this, but I haven't thought of anything.
        max_dom (int): used soled for standardizing color bars across plots from different datasets. I standardize them manually, but you could find a better way to do it.
    '''

    pr2_by_neuron_model1 = r2_pr2.get_all_pr2(model1, dataset1, test_loader1, conv = conv1)
    pr2_by_neuron_model2 = r2_pr2.get_all_pr2(model2, dataset2, test_loader2, conv = conv2)

    dataset_array_output = data_loading.convert_osim_dataset_to_array(dataset2)
    dom = depth_of_modulation(dataset_array_output[1])
    sorted_indices = np.argsort(dom)[::-1]
    num_inds = int(len(dom)*frac)
    top_indices = sorted_indices[:num_inds]

    if exclude_bad_neurons == False:
        dom = np.append(dom, np.array([0,max_dom]))
        pr2_model1_copy, pr2_model2_copy = np.copy(pr2_by_neuron_model1), np.copy(pr2_by_neuron_model2)
        pr2_model1_copy = np.append(pr2_model1_copy, np.array([0.001,0.001]))
        pr2_model2_copy = np.append(pr2_model2_copy, np.array([0.5,0.5]))
    else: 
        pr2_model1_copy, pr2_model2_copy = np.copy(pr2_by_neuron_model1), np.copy(pr2_by_neuron_model2)
        dom = dom[top_indices]
        dom = np.append(dom, np.array([0,max_dom]))
        pr2_model1_copy, pr2_model2_copy = pr2_model1_copy[top_indices], pr2_model2_copy[top_indices]
        pr2_model1_copy = np.append(pr2_model1_copy, np.array([-1,-1]))
        pr2_model2_copy = np.append(pr2_model2_copy, np.array([-1,-1]))

    print('{} average pR2: {}'.format(model_1_name, np.mean(pr2_model1_copy)))
    print('{} average pR2: {}'.format(model_2_name, np.mean(pr2_model2_copy)))

    plt.scatter(pr2_model2_copy,pr2_model1_copy,c=dom, cmap=plt.cm.viridis)
    plt.xlabel('{} PR2'.format(model_2_name))
    plt.ylabel('{} PR2'.format(model_1_name))
    if split == True:
        plt.title('PR2 Comparison by Electrode - {} Split {}\n{}'.format(dataset2.date, dataset2.split_num, restraint_type))
    else:
        plt.title('PR2 Comparison by Electrode - {}\n{}'.format(dataset2.date, restraint_type))
    cbar = plt.colorbar()
    cbar.set_label('Depth of Modulation', labelpad=20, rotation=270)
    mn,mx = np.min(pr2_model1_copy), np.max(pr2_model1_copy)
    if exclude_bad_neurons ==False:
        plt.xlim([mn-2, mx+1])
        plt.ylim([mn-2, mx+1])
    else:
        plt.xlim([-0.1, mx+0.15])
        plt.ylim([-0.1, mx+0.15])
        plt.plot(np.array([-2,1]),np.array([-2,1]))
    plt.tight_layout()
    plt.show()

def plot_distributions(model, dataset, test_loader, conv, nrows=12, ncols=8, bins = 20, size1 = 30, size2 = 35, density = False):
    '''
    Plots distributions of targets and predictions in histograms subplot.

    Args:
        model: trained model used to generate predictions.
        dataset: the full dataset corresponding to test_loader. 
        test_loader: dataloader with the test set of interest.
        conv (bool): True for TempCNN, False for MLP.
        nrows, ncols (int): number of rows and columns in subplots.
        bins (int): number of bins for the histogram.
        size1, size2 (int): specifies dimensions of the subplot.
    '''
    criterion = torch.nn.MSELoss()
    optimizer = torch.optim.Adam(model.parameters(), lr=0.001)
    test_loss, test_R2, test_pr2, test_preds, test_targets = test(test_loader, model, optimizer, criterion, dataset.num_neural_units, conv = conv)

    dataset_array_output = data_loading.convert_osim_dataset_to_array(dataset)
    dom = depth_of_modulation(dataset_array_output[1])

    f, ax = plt.subplots(nrows, ncols)
    f.subplots_adjust(top=0.97)
    f.set_size_inches(size1, size2)
    test_target_dist_lst = []
    test_pred_dist_lst = []
    pr2 = get_pr2(test_targets, test_preds, return_electrodes = True)
    for k in range(nrows*ncols):
        dom_elec = round(dom[k], 2)
        pr2_elec = round(pr2[k], 3)
        assert test_targets[:,k].shape == test_preds[:,k].shape
        r2_elec = round(r2_score(test_targets[:,k], test_preds[:,k]),3)
        i = k-(int(k/ncols)*ncols)
        j = int(k/ncols)
        ax[j][i].hist(test_targets[:,k], bins = bins, alpha = 0.4)
        test_target_dist = np.histogram(test_targets[:,k], bins=bins, density=density)
        ax[j][i].hist(test_preds[:,k], bins = test_target_dist[1], alpha = 0.4)
        test_pred_dist = np.histogram(test_preds[:,k], bins=test_target_dist[1], density=density)
        test_target_dist_lst.append(test_target_dist)
        test_pred_dist_lst.append(test_pred_dist)
        # kld = calc_kld(test_target_dist, test_pred_dist)
        ax[j][i].set_xlabel('Firing Rate')
        ax[j][i].set_ylabel('Count')
        ax[j][i].set_title('Electrode {}\nDOM: {:.3f}\nR2: {}, pR2: {:.3f}'.format(k, dom_elec, r2_elec, pr2_elec))
    f.legend(labels=['Targets', 'Predictions'], loc='center left', bbox_to_anchor=(1, 0.5))
    plt.tight_layout()
    plt.show()

    return(test_target_dist_lst, test_pred_dist_lst)

def plot_compare_electrodes_subset(date, mlp_model, mlp_good_range_arrays, tcn_model, tcn_good_range_arrays, electrode_subset):
    '''
    Plots the targets and predictions for a subset of electrodes for a TCN and MLP side-by-side in two columns.

    Args:
        mlp_model, tcn_model (FCNet, TempConvNet): Trained MLP and TCN models used to generate predictions.
        mlp_good_range_arrays, tcn_good_range_arrays (tuple): tuple containing input and output arrays of good range in dataset.
        electrode_subset (list): list of electrode indices to be plotted.
    '''
    inp_mlp = torch.from_numpy(tcn_good_range_arrays[0]).float()
    mlp_test_targets = tcn_good_range_arrays[1]
    inp_tcn = torch.from_numpy(tcn_good_range_arrays[0]).float().t().unsqueeze(0)
    tcn_test_targets = tcn_good_range_arrays[1]
    if date in ['20210712', '20210710', '20211105']:
        mlp_test_targets *= 30

    with torch.no_grad():
        mlp_test_preds = mlp_model(inp_mlp)
        tcn_test_preds = tcn_model(inp_tcn).squeeze(0)

    if date == '20211105':
        mlp_test_preds /= 30

    nrows, ncols = len(electrode_subset), 1
    f, ax = plt.subplots(nrows, ncols)
    f.subplots_adjust(top=0.97)
    f.set_size_inches(20, nrows*3)
    test_target_dist_lst = []
    test_pred_dist_lst = []
    mlp_pr2 = get_pr2(mlp_test_targets, mlp_test_preds, return_electrodes = True)
    tcn_pr2 = get_pr2(tcn_test_targets, tcn_test_preds, return_electrodes = True)
    for ind, k in enumerate(electrode_subset):
        mlp_pr2_elec = round(mlp_pr2[k], 3)
        tcn_pr2_elec = round(tcn_pr2[k], 3)

        mlp_r2 = round(r2_score(mlp_test_targets[:,k], mlp_test_preds[:,k]),3)
        tcn_r2 = round(r2_score(tcn_test_targets[:,k], tcn_test_preds[:,k]),3)

        ax[ind].plot(mlp_test_targets[:,k], label = 'Targets')
        ax[ind].plot(mlp_test_preds[:,k], label = 'MLP Predictions')
        ax[ind].plot(tcn_test_preds[:,k], label = 'TCN Predictions')

        ax[ind].set_xlabel('Frames')
        ax[ind].set_ylabel('Firing Rate')
        ax[ind].set_title('{} Electrode {}\nMLP pR2: {:.3f}, TCN pR2 {:.3f}'.format(date, k, mlp_pr2_elec, tcn_pr2_elec))
        ax[ind].legend(bbox_to_anchor=(1, 0.5), loc = 'center left')
    plt.tight_layout()
    plt.show()

def plot_targets_and_preds_agnostic(model, good_inp, good_out, electrodes_list, conv):
    '''
    Plots the predictions and targets for 

    Args:
        model (FCNet or TempConvNet): trained model used to generate predictions.
        good_inp (np.array): an array containing . 
            ***Note: I typically utilize the array parsed out of the dataset at the beginning where the monkey is doing something interesting.
        conv (bool): True for TempCNN, False for MLP.
    '''
    with torch.no_grad():
        if conv == True:
            good_inp = torch.from_numpy(good_inp.T).float().unsqueeze(0)
            pred_good_section = model(good_inp)
        else:
            pred_good_section = model(torch.from_numpy(good_inp).float())
        output_good_section = torch.from_numpy(good_out).float()
        plot_targets_and_preds(output_good_section, pred_good_section.squeeze(), 600, electrodes_list, fig_shape = (len(electrodes_list),1))

################################ AUXILLIARY/LESS IMPORTANT FUNCTIONS ################################

def depth_of_modulation(arr, top = 0.95, bottom = 0.05, return_top_n = 0):
    '''
    Calculates the depth of modulation (DOM) by electrode of a set of targets.
    Calculated by finding the difference value of the signal between the "top" and "bottom" percentile values.

    Args:
        targets (np.array): NxD target array.
        top (float): percentile value used to determine the range of the signal used for the DOM calculation.
        bottom (float): percentile value used to determine the range of the signal used for the DOM calculation.

    Returns:
        Dx1 array containing the DOM for each electrode in the dataset.
    '''
    doms = []
    for col in range(arr.shape[1]):
        unit = arr[:,col]
        unit_sorted = sorted(unit)
        top_perc = int(len(unit_sorted)*top)
        bottom_perc = int(len(unit_sorted)*bottom)
        dom = unit_sorted[top_perc] - unit_sorted[bottom_perc]
        doms.append(dom)
    dom = np.array(doms)
    if return_top_n == 0:
        return(dom)
    else:
        sorted_indices = np.argsort(dom)[::-1]
        top_indices = sorted_indices[:return_top_n]
        dom = dom[top_indices]
        return(dom, top_indices)

def plot_mean_std_comparison(model, dataset, test_loader, conv, bins = 20):
    '''
    Plots the distributions of the means and standard deviations of the predictions of a model and corresponding targets.

    Args:
        model: trained model used to generate predictions.
        dataset: full dataset corresponding to test_loader.
        test_loader: dataloader containing test set of interest.
        conv (bool): True for TempCNN, False for MLP.
    '''
    criterion = torch.nn.MSELoss()
    optimizer = torch.optim.Adam(model.parameters(), lr=0.001)
    test_loss, test_R2, test_pr2, test_preds, test_targets = test(test_loader, model, optimizer, criterion, dataset.num_neural_units, conv = True)

    mean_target = []
    mean_pred = []
    std_target = []
    std_pred = []

    for k in range(test_targets.shape[1]):
        mean_target_elect = round(np.mean(test_targets[:,k]),3)
        mean_pred_elect = round(np.mean(test_preds[:,k]),3)
        std_target_elect = round(np.std(test_targets[:,k]),3)
        std_pred_elect = round(np.std(test_preds[:,k]),3)
        
        mean_target.append(mean_target_elect)
        mean_pred.append(mean_pred_elect)
        std_target.append(std_target_elect)
        std_pred.append(std_pred_elect)

    f, ax = plt.subplots(1, 2)
    ax[0].hist(mean_target, bins = bins, alpha = 0.4, label = 'Targets')
    ax[0].hist(mean_pred, bins = bins, alpha = 0.4, label = 'Predictions')
    ax[0].axvline(x=np.mean(mean_target), color = 'blue')
    ax[0].axvline(x=np.mean(mean_pred), color = 'orange')
    ax[0].set_xlabel('Mean')
    ax[0].set_ylabel('Count')
    ax[0].set_title('{} Targets vs. Predictions Mean'.format(dataset.date), fontsize="10")
    ax[0].legend()
    ax[1].hist(std_target, bins = bins, alpha = 0.4, label = 'Targets')
    ax[1].hist(std_pred, bins = bins, alpha = 0.4, label = 'Predictions')
    ax[1].axvline(x=np.mean(std_target), color = 'blue')
    ax[1].axvline(x=np.mean(std_pred), color = 'orange')
    ax[1].set_xlabel('STD')
    ax[1].set_ylabel('Count')
    ax[1].set_title('{} Targets vs. Predictions STD'.format(dataset.date), fontsize="10")
    ax[1].legend()
    plt.tight_layout()
    plt.show()
    # return(r2_elect)

def plot_corrmatx_pairwisecorr(model, dataset, test_loader, conv):
    '''
    Finds the pairwise correlations between electrodes within the predictions and the actual dataset, then plots those pairwise correlations on a scatterplot.
    One dot on the scatterplot represents a single pairwise correlation (e.g. between electrodes 1 and 37). 
    Its value on the x-axis is the is the pairwise correlation in the predictions, Its value on the x-axis is the is the pairwise correlation in the targets.
    A high correlation in this scatterplot indicates the behavior of the predictions more or less mimics that of the targets.
    
    Args:
        model: trained model used to generate predictions.
        dataset: full dataset corresponding to test_loader.
        test_loader: dataloader containing test set of interest.
        conv (bool): True for TempCNN, False for MLP.
    '''
    criterion = torch.nn.MSELoss()
    optimizer = torch.optim.Adam(model.parameters(), lr=0.001)
    test_loss, test_R2, test_pr2, test_preds, test_targets = test(test_loader, model, optimizer, criterion, dataset.num_neural_units, conv = conv)
    for i in range(test_preds.shape[1]):
        if np.var(test_preds[:,i]) <= 1e-10:
            test_preds[-1,i] += 1e-6
    target_corrcoef = np.corrcoef(test_targets.T)
    pred_corrcoef = np.corrcoef(test_preds.T)

    sn.heatmap(target_corrcoef)
    plt.title('Target Correlation Matrix')
    plt.show()
    sn.heatmap(pred_corrcoef)
    plt.title('Prediction Correlation Matrix')
    plt.show()

    lower_tri_target = np.tril(target_corrcoef, -1).flatten()
    lower_tri_pred = np.tril(pred_corrcoef, -1).flatten()
    lower_tri_target = lower_tri_target[lower_tri_target!=0]
    lower_tri_pred = lower_tri_pred[lower_tri_pred!=0]

    plt.scatter(lower_tri_pred,lower_tri_target)
    plt.xlabel('Predictions Pairwise Correlations')
    plt.ylabel('Targets Pairwise Correlations')
    lower_tri_corrcoef = round(np.corrcoef(lower_tri_target,lower_tri_pred)[0][1],3)
    plt.title('Pairwise Correlation, r = {}'.format(lower_tri_corrcoef))
    plt.show()

def plot_targets_and_preds(targets, preds, rng, electrodes_list, fig_shape):
    '''
    Plots the predictions of a network against the real targets for a subset of electrodes.
    
    Args:
        targets (np.array): a NxD array containing all the targets from a dataset. n = # of instances, d = number of electrodes.
        predictions (np.array): a NxD array containing all the predictions from a model. n = # of instances, d = number of electrodes.
        rng (int): a specified length in the time dimension.
        electrodes_list (list): the list of electrode indices to plot.
        fig_shape (tuple): the shape of the subplot figure.
    '''
    nrows,ncols=fig_shape[0], fig_shape[1]
    assert len(electrodes_list) == nrows*ncols
    f, ax = plt.subplots(nrows, ncols)
    f.subplots_adjust(top=1.2)
    f.set_size_inches(20, nrows*2)
    t = nrows*ncols
    for k in range(len(electrodes_list)):
        ax[k].plot(targets[:rng,electrodes_list[k]], label = 'Target')
        ax[k].plot(preds[:rng,electrodes_list[k]], label = 'Prediction')
        ax[k].set_xlabel('Frame/Instance #')
        ax[k].set_ylabel('Smoothed Firing Rates')
        ax[k].set_title('Electrode {}'.format(electrodes_list[k]))
        ax[k].legend()
    plt.tight_layout()
    plt.show()

def get_psd(model, dataset, test_loader, nperseg, conv, nrows=12, ncols=8):
    '''
    Plots power spectrum of the predictions of a model vs. the corresponding targets.

    Args:
        model
        dataset: full dataset corres
        test_loader: test dataloader
        nperseg (int): number of samples per segment used to calculated the PSD.
        conv (bool): True for TempCNN, False for MLP.
        nrows, ncols (int): number of rows/cols for the subplot. Should correspond to the number of electrodes.
    '''
    criterion = torch.nn.MSELoss()
    optimizer = torch.optim.Adam(model.parameters(), lr=0.001)
    test_loss, test_R2, test_pr2, test_preds, test_targets = test(test_loader, model, optimizer, criterion, dataset.num_neural_units, conv = conv)

    f, ax = plt.subplots(nrows, ncols)
    f.subplots_adjust(top=0.97)
    f.set_size_inches(25, 25)
    for k in range(nrows*ncols):
        if k == 0:
            print(test_targets[:,k].shape)
        freq_targets, psd_targets = signal.welch(test_targets[:,k], fs=30, nperseg=nperseg)
        freq_targets, psd_targets = freq_targets[np.argsort(freq_targets)], psd_targets[np.argsort(freq_targets)]
        freq_preds, psd_preds = signal.welch(test_preds[:,k], fs=30, nperseg=nperseg)
        freq_preds, psd_preds = freq_preds[np.argsort(freq_preds)], psd_preds[np.argsort(freq_preds)]
        i = k-(int(k/ncols)*ncols)
        j = int(k/ncols)
        ax[j][i].plot(freq_targets,abs(psd_targets), label = 'Targets')
        ax[j][i].plot(freq_preds, abs(psd_preds), label = 'Predictions')
        ax[j][i].set_xlabel('Frequency')
        ax[j][i].set_ylabel('PSD')
        ax[j][i].set_title('Electrode {}'.format(k))
        ax[j][i].legend()
    plt.tight_layout()
    plt.show()

def plot_r2_comparison(model_1, model_2, dataset_1, dataset_2, test_loader_1, test_loader_2, conv_1, conv_2, bins = 20):
    '''
    Plots R^2 histograms for two models on a single plot.

    Args:
        model_1, model_2: trained models whose R^2 distributions you want to compare.
        dataset_1, dataset_2: full datasets corresponding to test_loaders. 
        test_loader_1, test_loader_2: dataloaders with the test sets of interest.
        conv_1, conv_2 (bools): True for TempCNN, False for MLP.
        bins: number of bins for the histogram.
    '''
    criterion = torch.nn.MSELoss()
    optimizer = torch.optim.Adam(model.parameters(), lr=0.001)
    test_loss_1, test_R2_1, test_pr2_1, test_preds_1, test_targets_1 = test(test_loader_1, model_1, optimizer, criterion, dataset_1.num_neural_units, conv = conv_1)
    test_loss_2, test_R2_2, test_pr2_2, test_preds_2, test_targets_2 = test(test_loader_2, model_2, optimizer, criterion, dataset_2.num_neural_units, conv = conv_2)

    r2_elect_1 = []
    r2_elect_2 = []

    for k in range(test_targets.shape[1]):
        r2_1 = round(r2_score(test_targets_1[:,k], test_preds_1[:,k]),3)
        r2_elect_1.append(r2_1)
        r2_2 = round(r2_score(test_targets_2[:,k], test_preds_2[:,k]),3)
        r2_elect_2.append(r2_2)
    plt.hist(r2_elect_1, bins = bins, alpha = 0.4)
    plt.hist(r2_elect_2, bins = bins, alpha = 0.4)
    plt.title('{} R^2 Test Distribution Comparison\nStandard vs. Transfer Learning'.format(dataset.date))
    plt.show()
    # return(r2_elect)


def plot_pr2(model, dataset, test_loader, conv, bins = 20):
    '''
    Plots a histogram of the distribution of pR^2 values between the predictions of a given model and the corresponding targets of the dataset.
    
    Args:
        model: trained model used to generate predictions.
        dataset: the full dataset corresponding to test_loader. 
        test_loader: dataloader with the test set of interest.
        conv (bool): True for TempCNN, False for MLP.
        bins (int): number of bins for the histogram.

    Returns:
        Dx1 array of pR^2 values.
    '''
    criterion = torch.nn.MSELoss()
    optimizer = torch.optim.Adam(model.parameters(), lr=0.001)
    test_loss, test_R2, test_pr2, test_preds, test_targets = test(test_loader, model, optimizer, criterion, dataset.num_neural_units, conv = conv)
    pr2_by_elec = get_pr2(test_targets, test_preds,return_electrodes=True)

    plt.hist(pr2_by_elec, bins = bins)
    plt.title('{} pR^2 Test Distribution'.format(dataset.date))
    plt.show()
    return(pr2_by_elec)

def plot_r2(model, dataset, test_loader, conv, bins = 20):
    '''
    Plots a histogram of the distribution of R^2 values between the predictions of a given model and the corresponding targets of the dataset.
    
    Args:
        model: trained model used to generate predictions.
        dataset: the full dataset corresponding to test_loader. 
        test_loader: dataloader with the test set of interest.
        conv (bool): True for TempCNN, False for MLP.
        bins (int): number of bins for the histogram.

    Returns:
        Dx1 array of R^2 values.
    '''
    criterion = torch.nn.MSELoss()
    optimizer = torch.optim.Adam(model.parameters(), lr=0.001)
    test_loss, test_R2, test_pr2, test_preds, test_targets = test(test_loader, model, optimizer, criterion, dataset.num_neural_units, conv = conv)

    r2_elect = []

    for k in range(test_targets.shape[1]):
        r2 = round(r2_score(test_targets[:,k], test_preds[:,k]),3)
        r2_elect.append(r2)
    plt.hist(r2_elect, bins = bins)
    plt.title('{} R^2 Test Distribution'.format(dataset.date))
    plt.show()
    return(np.array(r2_elect))

def plot_pc1_distribution(model, dataset, test_loader, conv, include_preds = True, bins = 200):
    '''
    Plots a histogram of the distribution of the first principal component of firing rates of a dataset. By default, it also plots predictions of a model over the real data.

    Args:
        model: Trained model used to generate predictions.
        dataset: Full datasets corresponding to test_loaders.
        test_loader: dataloader containing data from the test sets of interest.
        conv (bool): True for TCN, False for MLP.
        include_preds (bool): If True, histogram of predictions is plotted.
        bins (int): number of bins used for histogram(s).
    '''
    criterion = torch.nn.MSELoss()
    optimizer = torch.optim.Adam(model.parameters(), lr=0.001)
    test_loss, test_R2, test_pr2, test_preds, test_targets = test(test_loader, model, optimizer, criterion, dataset.num_neural_units, conv = conv)

    pca_targets = PCA(n_components=1)
    pca_preds = PCA(n_components=1)
    test_targets_features = pca_targets.fit_transform(test_targets)
    test_preds_features = pca_preds.fit_transform(test_preds)

    plt.hist(test_targets_features, alpha = 0.4, bins = bins, label = 'Targets')
    test_target_dist = np.histogram(test_targets_features, bins=bins)
    if include_preds == True:
        plt.hist(test_preds_features, alpha = 0.4, bins = test_target_dist[1], label = 'Predictions')
    
    plt.title('{} {} Firing Rate PC1 Distribution'.format(dataset.date, model.name))
    plt.xlabel('Firing Rate PC1')
    plt.ylabel('Count')
    plt.legend()

    plt.tight_layout()
    plt.show()

def plot_compare_distributions_subset(mlp_model, mlp_dataset, mlp_test_loader, tcn_model, tcn_dataset, tcn_test_loader, electrode_subset, bins = 20, density = False):
    '''
    Plots the distributions (histograms) of predictions and targets for a MLP and a TCN for a subset of electrodes side-by-side in two columns.

    Args: 
        mlp_model, tcn_model: Trained MLP and TCN models used to generate predictions.
        mlp_dataset, tcn_dataset: Full datasets corresponding to test_loaders.
        mlp_test_loader, tcn_test_loader: dataloaders containing data from the test sets of interest.
        electrode_subset (list): indices of electrodes of you want to plot.
        bins (int): number of bins in the histograms.
    '''

    criterion = torch.nn.MSELoss()
    optimizer_mlp = torch.optim.Adam(mlp_model.parameters(), lr=0.001)
    optimizer_tcn = torch.optim.Adam(tcn_model.parameters(), lr=0.001)
    mlp_test_loss, mlp_test_R2, mlp_test_pr2, mlp_test_preds, mlp_test_targets = test(mlp_test_loader, mlp_model, optimizer_mlp, criterion, mlp_dataset.num_neural_units, conv = False)
    tcn_test_loss, tcn_test_R2, tcn_test_pr2, tcn_test_preds, tcn_test_targets = test(tcn_test_loader, tcn_model, optimizer_tcn, criterion, tcn_dataset.num_neural_units, conv = True)

    nrows, ncols = len(electrode_subset), 2
    f, ax = plt.subplots(nrows, ncols)
    f.subplots_adjust(top=0.97)
    f.set_size_inches(10, nrows*3)
    test_target_dist_lst = []
    test_pred_dist_lst = []
    mlp_pr2 = get_pr2(mlp_test_targets, mlp_test_preds, return_electrodes = True)
    tcn_pr2 = get_pr2(tcn_test_targets, tcn_test_preds, return_electrodes = True)
    for ind, k in enumerate(electrode_subset):
        mlp_pr2_elec = round(mlp_pr2[k], 3)
        tcn_pr2_elec = round(tcn_pr2[k], 3)
        # assert test_targets[:,k].shape == test_preds[:,k].shape
        mlp_r2 = round(r2_score(mlp_test_targets[:,k], mlp_test_preds[:,k]),3)
        tcn_r2 = round(r2_score(tcn_test_targets[:,k], tcn_test_preds[:,k]),3)

        ax[ind][0].hist(mlp_test_targets[:,k], bins = bins, alpha = 0.4, label = 'Targets')
        mlp_test_target_dist = np.histogram(mlp_test_targets[:,k], bins=bins, density=density)
        ax[ind][0].hist(mlp_test_preds[:,k], bins = mlp_test_target_dist[1], alpha = 0.4, label = 'Predictions')

        ax[ind][1].hist(tcn_test_targets[:,k], bins = bins, alpha = 0.4, label = 'Targets')
        tcn_test_target_dist = np.histogram(tcn_test_targets[:,k], bins=bins, density=density)
        ax[ind][1].hist(tcn_test_preds[:,k], bins = tcn_test_target_dist[1], alpha = 0.4, label = 'Predictions')

        ax[ind][0].set_xlabel('Firing Rate')
        ax[ind][0].set_ylabel('Count')
        ax[ind][0].set_title('MLP Electrode {}\nR2: {}, pR2: {:.3f}'.format(k, mlp_r2, mlp_pr2_elec))
        ax[ind][0].legend()

        ax[ind][1].set_xlabel('Firing Rate')
        ax[ind][1].set_ylabel('Count')
        ax[ind][1].set_title('TCN Electrode {}\nR2: {}, pR2: {:.3f}'.format(k, tcn_r2, tcn_pr2_elec))
        ax[ind][1].legend()
    plt.tight_layout()
    plt.show()