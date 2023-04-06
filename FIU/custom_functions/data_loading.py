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


class OSIMDataset(Dataset):
    def __init__(self, date, inp_type, good_range, shuffle = False):
        self.date = date
        self.inp_type = inp_type
        index = dates_list.index(date)
        inp_types = ['Joint Angles','Joint Velocities','Joint Angles and Velocities']
        if inp_type == 'Joint Angles':
            input = joint_angles_list[index]
        elif inp_type == 'Joint Velocities':
            input = velocities_list[index]
        elif inp_type == 'Joint Angles and Velocities':
            input = angles_and_velocities_list[index]
        else:
            print('Invalid Input Type')
            assert inp_type in inp_types
        neuraldata = firing_rates_list[index]
        self.inputs = input
        self.input_type = inp_type
        self.input_dim = self.inputs.shape[-1]
        self.num_neural_units = neuraldata.shape[-1]
        self.neuraloutputs = neuraldata
        self.sample_nums = np.arange(len(self.inputs))
        self.inputs = np.delete(self.inputs, np.arange(good_range[0],good_range[1]), 0)
        self.neuraloutputs = np.delete(self.neuraloutputs, np.arange(good_range[0],good_range[1]), 0)

        def shuffle_data(inputs, targets, samp_nums):
            assert len(inputs) == len(targets)
            p = np.random.permutation(len(inputs))
            return(inputs[p], targets[p], samp_nums[p])

        if shuffle == True:
            self.inputs, self.neuraloutputs, self.sample_nums = \
              shuffle_data(self.inputs, self.neuraloutputs, self.sample_nums)

    def __len__(self):
        assert len(self.inputs) == len(self.neuraloutputs)
        return len(self.inputs)

    def __getitem__(self, idx):
        input = torch.from_numpy(self.inputs[idx])
        neuraloutput = torch.from_numpy(self.neuraloutputs[idx])
        sample_num = self.sample_nums[idx]
        return input.float(), neuraloutput.float(), sample_num

class CustomDataset(Dataset):
    def __init__(self, date, inp_type, shuffle = True, time_delay = False, good_range = (3000, 3600)):
        self.date = date
        self.input_type = inp_type
        index = dates_list.index(date)
        inp_types = ['Joint Angles','Joint Velocities','Joint Angles and Velocities']
        if inp_type == 'Joint Angles':
            input = joint_angles_list[index]
        elif inp_type == 'Joint Velocities':
            input = velocities_list[index]
        elif inp_type == 'Joint Angles and Velocities':
            input = angles_and_velocities_list[index]
        else:
            print('Invalid Input Type')
            assert inp_type in inp_types
        neuraldata = firing_rates_list[index]
        num_instances = neuraldata.shape[0]
        remainder = num_instances%100
        round_num_instances = num_instances-remainder

        if time_delay == False:
            self.inputs = input[:round_num_instances] #make dataset divisible by 100
            neuraldata = neuraldata[:round_num_instances] #make dataset divisible by 100
        else:
            self.inputs = input[4:round_num_instances+4] #make dataset divisible by 100; shift by 4
            neuraldata = neuraldata[:round_num_instances] #make dataset divisible by 100
        
        # remove the "good" section for testing
        self.inputs = np.delete(self.inputs, np.arange(good_range[0],good_range[1]), 0)
        neuraldata = np.delete(neuraldata, np.arange(good_range[0],good_range[1]), 0)

        self.input_dim = self.inputs.shape[-1]
        self.num_neural_units = neuraldata.shape[1]
        self.inputs = self.inputs.reshape((-1, 100, self.input_dim), order = 'C')
        self.neuraloutputs = neuraldata.reshape((-1, 100, self.num_neural_units), order = 'C') #I checked. We want order C
        self.sample_nums = np.arange(len(self.inputs)).astype(int)
        
        def shuffle_data(inputs, targets, samp_nums):
            assert len(inputs) == len(targets)
            p = np.random.permutation(len(inputs))
            return(inputs[p], targets[p], samp_nums[p])

        if shuffle == True:
            self.inputs, self.neuraloutputs, self.sample_nums =\
             shuffle_data(self.inputs, self.neuraloutputs, self.sample_nums)

    def __len__(self):
        assert len(self.inputs) == len(self.neuraloutputs)
        return len(self.inputs)

    def __getitem__(self, idx):
        input = torch.from_numpy(self.inputs[idx])
        neuraloutput = torch.from_numpy(self.neuraloutputs[idx])
        return input.float().t(), neuraloutput.float(), self.sample_nums #input is transposed for convenience - better for Conv1D

import __main__
setattr(__main__, "OSIMDataset", OSIMDataset)
setattr(__main__, "CustomDataset", CustomDataset)

def create_and_save_datasets(dataset, tcnn = False, new_tcnn = False):
    num_instances = len(dataset)
    train_split = int(num_instances*0.8)

    osim_train_dataset = Subset(dataset, np.arange(num_instances)[:train_split])
    osim_test_dataset = Subset(dataset, np.arange(num_instances)[train_split:])

    base_dir = '/content/drive/My Drive/Miller_Lab/FIU/PopFRData/processed_shuffled_opensim_datasets/'
    if tcnn == True:
        base_dir = '/content/drive/My Drive/Miller_Lab/FIU/PopFRData/tcnn_processed_shuffled_opensim_datasets/'
    full_dir = os.path.join(base_dir,dataset.date,dataset.input_type)
    if new_tcnn == True:
        clipped_dataset = Subset(dataset, np.arange(num_instances-dataset.kinematic_signal_length))
        p = np.random.permutation(num_instances)
        osim_train_dataset = Subset(clipped_dataset, p[:train_split])
        osim_test_dataset = Subset(clipped_dataset, p[train_split:])
        base_dir = '/content/drive/My Drive/Miller_Lab/FIU/PopFRData/tcnn_new_processed_shuffled_opensim_datasets/'
        full_dir = os.path.join(base_dir,dataset.date,dataset.input_type,str(dataset.kinematic_signal_length))

    if os.path.exists(full_dir) == False:
        os.makedirs(full_dir)
        torch.save(dataset, os.path.join(full_dir,'Full.pt'))
        torch.save(osim_train_dataset, os.path.join(full_dir,'Train.pt'))
        torch.save(osim_test_dataset, os.path.join(full_dir,'Test.pt'))
        if new_tcnn == True:
            torch.save(clipped_dataset, os.path.join(full_dir,'Clipped.pt'))

def load_datasets(base_dir, split_neurons = False, new_tcnn = False):
    print(split_neurons)
    dataset_dict = {}
    for date in os.listdir(base_dir):
        dataset_dict[date] = {}
        for inp_type in os.listdir(os.path.join(base_dir,date)):
            dataset_dict[date][inp_type] = {}
            for dataset_type in os.listdir(os.path.join(base_dir,date,inp_type)):
                if new_tcnn == False:
                    if split_neurons == False:
                        dataset_dict[date][inp_type][dataset_type[:-3]] = torch.load(os.path.join(base_dir,date,inp_type,dataset_type))
                    else:
                        dataset_dict[date][inp_type][dataset_type] = {}
                        for split in os.listdir(os.path.join(base_dir,date,inp_type,dataset_type)):
                            dataset_dict[date][inp_type][dataset_type][split[:-3]] = torch.load(os.path.join(base_dir,date,inp_type,dataset_type,split))
                else:
                    for kinematic_signal_length in os.listdir(os.path.join(base_dir,date,inp_type)):
                        dataset_dict[date][inp_type][kinematic_signal_length] = {}
                        for dataset_type in os.listdir(os.path.join(base_dir,date,inp_type,str(kinematic_signal_length))):
                            dataset_dict[date][inp_type][kinematic_signal_length][dataset_type[:-3]] = torch.load(os.path.join(base_dir,date,inp_type,str(kinematic_signal_length),dataset_type))
    return dataset_dict

def get_loaders(dataset_dict, batch_size, split_neurons = False, new_tcnn = False):
    loader_dict = {}
    for date in dataset_dict:
        loader_dict[date] = {}
        for inp_type in dataset_dict[date]:
            loader_dict[date][inp_type] = {}
            if new_tcnn == False:
                for dataset_type in dataset_dict[date][inp_type]:
                    if split_neurons == False:
                        loader = torch.utils.data.DataLoader(dataset_dict[date][inp_type][dataset_type], batch_size=batch_size, pin_memory=True, sampler=None)
                        loader_dict[date][inp_type][dataset_type] = loader
                    else:
                        loader_dict[date][inp_type][dataset_type] = {}
                        for split_num in dataset_dict[date][inp_type][dataset_type]:
                            loader = torch.utils.data.DataLoader(dataset_dict[date][inp_type][dataset_type][split_num], batch_size=batch_size, pin_memory=True, sampler=None)
                            loader_dict[date][inp_type][dataset_type][split_num] = loader
            else:
                for kinematic_signal_length in dataset_dict[date][inp_type]:
                    loader_dict[date][inp_type][kinematic_signal_length] = {}
                    for dataset_type in dataset_dict[date][inp_type][kinematic_signal_length]:
                        loader = torch.utils.data.DataLoader(dataset_dict[date][inp_type][kinematic_signal_length][dataset_type], batch_size=batch_size, pin_memory=True, sampler=None)
                        loader_dict[date][inp_type][kinematic_signal_length][dataset_type] = loader
    return loader_dict

def convert_osim_dataset_to_array(dataset):
    inp_list = []
    out_list = []
    for i in range(len(dataset)):
        inp, out = dataset[i][0], dataset[i][1]
        inp_list.append(inp)
        out_list.append(out)
    return(np.vstack(inp_list), np.vstack(out_list))