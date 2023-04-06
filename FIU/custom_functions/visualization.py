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

# torch stuff
import torch
from torch.utils.data import Dataset, DataLoader, Subset
from torch import nn
import torch.nn.functional as F

#custom modules
from train_test import train, test
from pr2 import get_pr2

def plot_losses_MLP(dataset, train_loader, test_loader, learning_rate, num_layers, add_relu = False, adapt_lr = True, save = True, numepochs = 301):
    model = FCNet(input_dim=dataset.input_dim, output_dim=dataset.num_neural_units, \
                  num_layers=num_layers, hidden_layer_dim=112, add_relu = add_relu)

    criterion = torch.nn.MSELoss()
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

    directory = '/content/drive/My Drive/Miller_Lab/FIU/MLP/Pop_FR_OpenSIM/'
    if add_relu == True:
        model_name = 'MLP_{}_{}_{}_layers_reluadded'.format(dataset.date,dataset.inp_type,model.num_layers)
    else:
        model_name = 'MLP_{}_{}_{}_layers'.format(dataset.date,dataset.inp_type,model.num_layers)
    if save == True:
        torch.save(model.state_dict(), directory+model_name)

    return(model)

def plot_losses_TempCNN(dataset, train_loader, test_loader, learning_rate, num_conv_layers, add_relu = True, causal = True, adapt_lr = True, save = True, l2_reg = 0, numepochs = 301):
    date = dataset.date

    num_readout_layers, kernel_size, num_kernels = 1, 5, 2
    model = TempConvNet(dataset.input_dim, dataset.num_neural_units, num_conv_layers, \
                        num_readout_layers, kernel_size, num_kernels, add_relu = add_relu, causal=causal)

    criterion = torch.nn.MSELoss()
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
    plt.title('Losses - Date: {}, Model: {}, Conv Layers: {}'.format(date, model.name, model.num_conv_layers))
    plt.xlabel('Epochs')
    plt.ylabel('Loss')
    plt.legend(['Train Losses', 'Test Losses'])
    plt.show()

    directory = '/content/drive/My Drive/Miller_Lab/FIU/Temporal_CNN/Pop_FR_OpenSIM/'
    if add_relu == True:
        model_name = 'TempCNN_{}_{}_{}_convlayers_reluadded'.format(dataset.date,dataset.input_type,model.num_conv_layers)
    else:
        model_name = 'TempCNN_{}_{}_{}_convlayers'.format(dataset.date,dataset.input_type,model.num_conv_layers)
    if save == True:
        torch.save(model.state_dict(), directory+model_name)

    return(model)

def plot_targets_and_preds(targets, preds, rng, electrodes_list, fig_shape):
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

def plot_targets_and_preds_agnostic(model, good_inp, good_out, electrodes_list, conv):
    print('Learning Rate: {}'.format(0.001))
    with torch.no_grad():
        if conv == True:
            good_inp = torch.from_numpy(good_inp.T).float().unsqueeze(0)
            pred_good_section = model(good_inp)
        else:
            pred_good_section = model(torch.from_numpy(good_inp).float())
        output_good_section = torch.from_numpy(good_out).float()
        plot_targets_and_preds(output_good_section, pred_good_section.squeeze(), 600, electrodes_list, fig_shape = (len(electrodes_list),1))

def plot_targets_and_preds_tcnn(model, good_inp, good_out):
    print('Learning Rate: {}'.format(0.001))
    with torch.no_grad():
        good_inp = torch.from_numpy(good_inp.T).float().unsqueeze(0)
        pred_good_section = model(good_inp)
        output_good_section = torch.from_numpy(good_out).float()
        plot_targets_and_preds(output_good_section, pred_good_section.squeeze(), 600, electrodes_list = [18, 32, 57, 58, 78], fig_shape = (5,1))

def plot_top_5_electrodes(model, good_inp, good_out, electrodes_list):
    with torch.no_grad():
        pred_good_section = model(torch.from_numpy(good_inp).float())
        output_good_section = torch.from_numpy(good_out).float()
        plot_targets_and_preds(output_good_section, pred_good_section, 600, electrodes_list, fig_shape = (5,1))

def plot_distributions(model, dataset, test_loader, conv, nrows=12, ncols=8, bins = 20, density = False):
    criterion = torch.nn.MSELoss()
    optimizer = torch.optim.Adam(model.parameters(), lr=0.001)
    test_loss, test_R2, test_pr2, test_preds, test_targets = test(test_loader, model, optimizer, criterion, dataset.num_neural_units, conv = conv)

    f, ax = plt.subplots(nrows, ncols)
    f.subplots_adjust(top=0.97)
    f.set_size_inches(30, 35)
    test_target_dist_lst = []
    test_pred_dist_lst = []
    pr2 = get_pr2(test_targets, test_preds, return_electrodes = True)
    for k in range(nrows*ncols):
        pr2_elec = round(pr2[k], 3)
        assert test_targets[:,k].shape == test_preds[:,k].shape
        r2 = round(r2_score(test_targets[:,k], test_preds[:,k]),3)
        # print('Electrode {} - Target Shape: {}, Pred Shape: {}'.format(k, test_targets[:,k].shape, test_preds[:,k].shape))
        i = k-(int(k/ncols)*ncols)
        j = int(k/ncols)
        ax[j][i].hist(test_targets[:,k], bins = bins, alpha = 0.4, label = 'Targets')
        test_target_dist = np.histogram(test_targets[:,k], bins=bins, density=density)
        ax[j][i].hist(test_preds[:,k], bins = test_target_dist[1], alpha = 0.4, label = 'Predictions')
        test_pred_dist = np.histogram(test_preds[:,k], bins=test_target_dist[1], density=density)
        test_target_dist_lst.append(test_target_dist)
        test_pred_dist_lst.append(test_pred_dist)
        # kld = calc_kld(test_target_dist, test_pred_dist)
        ax[j][i].set_xlabel('Firing Rate')
        ax[j][i].set_ylabel('Count')
        ax[j][i].set_title('Electrode {}\nR2: {}, pR2: {:.3f}'.format(k, r2, pr2_elec))
        ax[j][i].legend()
    plt.tight_layout()
    plt.show()

    return(test_target_dist_lst, test_pred_dist_lst)

def plot_distributions_subset(mlp_model, mlp_dataset, mlp_test_loader, tcn_model, tcn_dataset, tcn_test_loader, electrode_subset, nrows, ncols=2, bins = 20, density = False):
    criterion = torch.nn.MSELoss()
    optimizer_mlp = torch.optim.Adam(mlp_model.parameters(), lr=0.001)
    optimizer_tcn = torch.optim.Adam(tcn_model.parameters(), lr=0.001)
    mlp_test_loss, mlp_test_R2, mlp_test_pr2, mlp_test_preds, mlp_test_targets = test(mlp_test_loader, mlp_model, optimizer_mlp, criterion, mlp_dataset.num_neural_units, conv = False)
    tcn_test_loss, tcn_test_R2, tcn_test_pr2, tcn_test_preds, tcn_test_targets = test(tcn_test_loader, tcn_model, optimizer_tcn, criterion, tcn_dataset.num_neural_units, conv = True)

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

def plot_electrodes_subset(mlp_model, mlp_dataset, mlp_test_loader, tcn_model, tcn_dataset, tcn_test_loader, electrode_subset, rng, nrows, ncols=2, bins = 20, density = False):
    criterion = torch.nn.MSELoss()
    optimizer_mlp = torch.optim.Adam(mlp_model.parameters(), lr=0.001)
    optimizer_tcn = torch.optim.Adam(tcn_model.parameters(), lr=0.001)
    mlp_test_loss, mlp_test_R2, mlp_test_pr2, mlp_test_preds, mlp_test_targets = test(mlp_test_loader, mlp_model, optimizer_mlp, criterion, mlp_dataset.num_neural_units, conv = True)
    tcn_test_loss, tcn_test_R2, tcn_test_pr2, tcn_test_preds, tcn_test_targets = test(tcn_test_loader, tcn_model, optimizer_tcn, criterion, tcn_dataset.num_neural_units, conv = True)

    f, ax = plt.subplots(nrows, ncols)
    f.subplots_adjust(top=0.97)
    f.set_size_inches(30, nrows*3)
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

        ax[ind][0].plot(mlp_test_targets[rng[0]:rng[1],k], label = 'Targets')
        ax[ind][0].plot(mlp_test_preds[rng[0]:rng[1],k], label = 'Predictions')

        ax[ind][1].plot(tcn_test_targets[rng[0]:rng[1],k], label = 'Targets')
        ax[ind][1].plot(tcn_test_preds[rng[0]:rng[1],k], label = 'Predictions')

        ax[ind][0].set_xlabel('Frames')
        ax[ind][0].set_ylabel('Firing Rate')
        ax[ind][0].set_title('MLP Electrode {}\nR2: {}, pR2: {:.3f}'.format(k, mlp_r2, mlp_pr2_elec))
        ax[ind][0].legend()

        ax[ind][1].set_xlabel('Frames')
        ax[ind][1].set_ylabel('Firing Rate')
        ax[ind][1].set_title('TCN Electrode {}\nR2: {}, pR2: {:.3f}'.format(k, tcn_r2, tcn_pr2_elec))
        ax[ind][1].legend()
    plt.tight_layout()
    plt.show()

def plot_pr2(model, dataset, test_loader, bins = 20):
    criterion = torch.nn.MSELoss()
    optimizer = torch.optim.Adam(model.parameters(), lr=0.001)
    test_loss, test_R2, test_pr2, test_preds, test_targets = test(test_loader, model, optimizer, criterion, dataset.num_neural_units, conv = True)
    pr2_by_elec = get_pr2(test_targets, test_preds,return_electrodes=True)

    plt.hist(pr2_by_elec, bins = bins)
    plt.title('{} pR^2 Test Distribution'.format(dataset.date))
    plt.show()
    return(pr2_by_elec)

def plot_r2(model, dataset, test_loader, bins = 20):
    criterion = torch.nn.MSELoss()
    optimizer = torch.optim.Adam(model.parameters(), lr=0.001)
    test_loss, test_R2, test_pr2, test_preds, test_targets = test(test_loader, model, optimizer, criterion, dataset.num_neural_units, conv = True)

    r2_elect = []

    for k in range(test_targets.shape[1]):
        r2 = round(r2_score(test_targets[:,k], test_preds[:,k]),3)
        r2_elect.append(r2)
    plt.hist(r2_elect, bins = bins)
    plt.title('{} R^2 Test Distribution'.format(dataset.date))
    plt.show()
    return(r2_elect)

def plot_mean_std_comparison(model, dataset, test_loader, bins = 20):
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

def plot_r2_comparison(model_1, model_2, dataset, test_loader, bins = 20):
    criterion = torch.nn.MSELoss()
    optimizer = torch.optim.Adam(model.parameters(), lr=0.001)
    test_loss_1, test_R2_1, test_pr2_1, test_preds_1, test_targets_1 = test(test_loader, model_1, optimizer, criterion, dataset.num_neural_units, conv = True)
    test_loss_2, test_R2_2, test_pr2_2, test_preds_2, test_targets_2 = test(test_loader, model_2, optimizer, criterion, dataset.num_neural_units, conv = True)

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

def get_psd(model, dataset, test_loader, nperseg, nrows=12, ncols=8):
    criterion = torch.nn.MSELoss()
    optimizer = torch.optim.Adam(model.parameters(), lr=0.001)
    test_loss, test_R2, test_pr2, test_preds, test_targets = test(test_loader, model, optimizer, criterion, dataset.num_neural_units, conv = True)

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

def plot_corrmatx_pairwisecorr(model, dataset, test_loader):
    criterion = torch.nn.MSELoss()
    optimizer = torch.optim.Adam(model.parameters(), lr=0.001)
    test_loss, test_R2, test_pr2, test_preds, test_targets = test(test_loader, model, optimizer, criterion, dataset.num_neural_units, conv = True)
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
    lower_tri_corrcoef = round(np.corrcoef(lower_tri_target,lower_tri_pred)[0][1],3)
    plt.title('Pairwise Correlation, r = {}'.format(lower_tri_corrcoef))
    plt.show()