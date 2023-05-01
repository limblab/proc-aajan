# basic stuff 
import numpy as np
import random
import os

# torch stuff
import torch
from torch.utils.data import Dataset, DataLoader, Subset

class MLPDataset(Dataset):
    '''
    Dataset class used for MLP.
    
    Args:
        date (str): The date of the recording of the dataset, e.g. '20210712'.
        inp_type (str): The type of input. Examples of possible values are in the __init__ function.
        inp_dict (dict): dictionary containing the kinematic inputs.
        target_dict (dict): dictionary containing neural targets.
        good_range (tuple): The upper and lower bounds of the range you want to snip out of the dataset before shuffling. Primarily used for plotting.
        split_neurons (bool): True if the dataset is split by electrode, False otherwise.
        split_number (int): an index used to keep track of the split number of the dataset when split_neurons = True.
        shuffle (bool): set to True if you want the dataset to be shuffled.
        time_delay (bool): set to True if you want the network to delay the kinematic data with respect to the neural data by 4 frames (~133ms).
    '''
    def __init__(self, date, inp_type, inp_dict, target_dict, good_range_dict, split_neurons = False, split_num = 0, shuffle = False, time_delay = False):
        self.date = date
        self.input_type = inp_type
        inp_types = ['Joint Angles','Joint Velocities','Joint Angles and Velocities']
        assert inp_type in inp_types
        input = inp_dict[date]
        if split_neurons == False:
            neuraldata = target_dict[date]
        else:
            neuraldata = target_dict[date][split_num]
            self.split_num = split_num
            
        self.inputs = input
        self.input_dim = self.inputs.shape[-1]
        self.num_neural_units = neuraldata.shape[-1]
        self.neuraloutputs = neuraldata
        self.sample_nums = np.arange(len(self.inputs))
        self.inputs = np.delete(self.inputs, np.arange(good_range_dict[date][0],good_range_dict[date][1]), 0)
        self.neuraloutputs = np.delete(self.neuraloutputs, np.arange(good_range_dict[date][0],good_range_dict[date][1]), 0)

        def shuffle_data(inputs, targets, samp_nums):
            assert len(inputs) == len(targets)
            p = np.random.permutation(len(inputs))
            return(inputs[p], targets[p], samp_nums[p])

        if time_delay == True:
            self.inputs = self.inputs[4:]
            self.neuraloutputs = self.neuraloutputs[:-4]

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

class TCNDataset(Dataset):
    '''
    Dataset class used for MLP.
    
    Args:
        date (str): The date of the recording of the dataset, e.g. '20210712'.
        inp_type (str): The type of input. Examples of possible values are in the __init__ function.
        inp_dict (dict): dictionary containing the kinematic inputs.
        target_dict (dict): dictionary containing neural targets.
        good_range (tuple): The upper and lower bounds of the range you want to snip out of the dataset before shuffling. Primarily used for plotting.
        split_neurons (bool): True if the dataset is split by electrode, False otherwise.
        split_number (int): an index used to keep track of the split number of the dataset when split_neurons = True.
        shuffle (bool): set to True if you want the dataset to be shuffled.
        time_delay (bool): set to True if you want the network to delay the kinematic data with respect to the neural data by 4 frames (~133ms).
        instance_length (int): the length in frames of each instance in the dataset. ~33ms/frame corresponds to 100 frames being ~3.3s.
    '''
    def __init__(self, date, inp_type, inp_dict, target_dict, good_range, split_neurons = False, split_num = 0, shuffle = True, time_delay = True, instance_length = 100):
        self.date = date
        self.input_type = inp_type
        inp_types = ['Joint Angles','Joint Velocities','Joint Angles and Velocities']
        assert inp_type in inp_types
        input = inp_dict[date]
        if split_neurons == False:
            neuraldata = target_dict[date]
        else:
            neuraldata = target_dict[date][split_num]
            self.split_num = split_num

        # remove the "good" section for testing
        self.inputs = np.delete(input, np.arange(good_range[0],good_range[1]), 0)
        self.neuraloutputs = np.delete(neuraldata, np.arange(good_range[0],good_range[1]), 0)

        num_instances = self.neuraloutputs.shape[0]
        remainder = num_instances%instance_length
        round_num_instances = num_instances-remainder

        if time_delay == False:
            self.inputs = self.inputs[:round_num_instances] #make dataset divisible by instance_length
            self.neuraloutputs = self.neuraloutputs[:round_num_instances] #make dataset divisible by instance_length
        elif remainder>4:
            self.inputs = self.inputs[4:round_num_instances+4] #make dataset divisible by instance_length; shift by 4
            self.neuraloutputs = self.neuraloutputs[:round_num_instances] #make dataset divisible by instance_length
        else:
            round_num_instances = round_num_instances - instance_length
            self.inputs = self.inputs[4:round_num_instances+4] #make dataset divisible by instance_length; shift by 4
            self.neuraloutputs = self.neuraloutputs[:round_num_instances] #make dataset divisible by instance_length

        self.input_dim = self.inputs.shape[-1]
        self.num_neural_units = neuraldata.shape[1]
        self.inputs = self.inputs.reshape((-1, instance_length, self.input_dim), order = 'C')
        self.neuraloutputs = self.neuraloutputs.reshape((-1, instance_length, self.num_neural_units), order = 'C') #I checked. We want order C
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
        sample_num = self.sample_nums[idx]
        return input.float().t(), neuraloutput.float(), sample_num #input is transposed for convenience - better for Conv1D

class OSIMDataset(Dataset):
    '''
    Dataset class used for MLP.
    
    Args:
        date (str): The date of the recording of the dataset, e.g. '20210712'.
        inp_type (str): The type of input. Examples of possible values are in the __init__ function.
        inp_dict (dict): dictionary containing the kinematic inputs.
        target_dict (dict): dictionary containing neural targets.
        good_range (tuple): The upper and lower bounds of the range you want to snip out of the dataset before shuffling. Primarily used for plotting.
        split_neurons (bool): True if the dataset is split by electrode, False otherwise.
        split_number (int): an index used to keep track of the split number of the dataset when split_neurons = True.
        shuffle (bool): set to True if you want the dataset to be shuffled.
        time_delay (bool): set to True if you want the network to delay the kinematic data with respect to the neural data by 4 frames (~133ms).
    '''
    def __init__(self, date, inp_type, inp_dict, target_dict, good_range, split_neurons = False, split_num = 0, shuffle = False, time_delay = False):
        self.date = date
        self.input_type = inp_type
        inp_types = ['Joint Angles','Joint Velocities','Joint Angles and Velocities']
        assert inp_type in inp_types
        input = inp_dict[date]
        if split_neurons == False:
            neuraldata = target_dict[date]
        else:
            neuraldata = target_dict[date][split_num]
            self.split_num = split_num
            
        self.inputs = input
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

        if time_delay == True:
            self.inputs = self.inputs[4:]
            self.neuraloutputs = self.neuraloutputs[:-4]

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
    '''
    Dataset class used for MLP.
    
    Args:
        date (str): The date of the recording of the dataset, e.g. '20210712'.
        inp_type (str): The type of input. Examples of possible values are in the __init__ function.
        inp_dict (dict): dictionary containing the kinematic inputs.
        target_dict (dict): dictionary containing neural targets.
        good_range (tuple): The upper and lower bounds of the range you want to snip out of the dataset before shuffling. Primarily used for plotting.
        split_neurons (bool): True if the dataset is split by electrode, False otherwise.
        split_number (int): an index used to keep track of the split number of the dataset when split_neurons = True.
        shuffle (bool): set to True if you want the dataset to be shuffled.
        time_delay (bool): set to True if you want the network to delay the kinematic data with respect to the neural data by 4 frames (~133ms).
        instance_length (int): the length in frames of each instance in the dataset. ~33ms/frame corresponds to 100 frames being ~3.3s.
    '''
    def __init__(self, date, inp_type, inp_dict, target_dict, good_range, split_neurons = False, split_num = 0, shuffle = True, time_delay = True, instance_length = 100):
        self.date = date
        self.input_type = inp_type
        inp_types = ['Joint Angles','Joint Velocities','Joint Angles and Velocities']
        assert inp_type in inp_types
        input = inp_dict[date]
        if split_neurons == False:
            neuraldata = target_dict[date]
        else:
            neuraldata = target_dict[date][split_num]
            self.split_num = split_num

        # remove the "good" section for testing
        self.inputs = np.delete(input, np.arange(good_range[0],good_range[1]), 0)
        self.neuraloutputs = np.delete(neuraldata, np.arange(good_range[0],good_range[1]), 0)

        num_instances = self.neuraloutputs.shape[0]
        remainder = num_instances%instance_length
        round_num_instances = num_instances-remainder

        if time_delay == False:
            self.inputs = self.inputs[:round_num_instances] #make dataset divisible by instance_length
            self.neuraloutputs = self.neuraloutputs[:round_num_instances] #make dataset divisible by instance_length
        elif remainder>4:
            self.inputs = self.inputs[4:round_num_instances+4] #make dataset divisible by instance_length; shift by 4
            self.neuraloutputs = self.neuraloutputs[:round_num_instances] #make dataset divisible by instance_length
        else:
            round_num_instances = round_num_instances - instance_length
            self.inputs = self.inputs[4:round_num_instances+4] #make dataset divisible by instance_length; shift by 4
            self.neuraloutputs = self.neuraloutputs[:round_num_instances] #make dataset divisible by instance_length

        self.input_dim = self.inputs.shape[-1]
        self.num_neural_units = neuraldata.shape[1]
        self.inputs = self.inputs.reshape((-1, instance_length, self.input_dim), order = 'C')
        self.neuraloutputs = self.neuraloutputs.reshape((-1, instance_length, self.num_neural_units), order = 'C') #I checked. We want order C
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
setattr(__main__, "MLPDataset", MLPDataset)
setattr(__main__, "TCNDataset", TCNDataset)
setattr(__main__, "OSIMDataset", OSIMDataset)
setattr(__main__, "CustomDataset", CustomDataset)

def create_and_save_datasets(dataset, good_dict, tcnn = False, instance_length = 100, split_neurons = False, split_num = 0, restraint_type = 'fullyrestrained'):
    '''
    Creates and saves full, train, test, and good range datasets as .pt files in the specified directory.
    Train and test datasets are of type torch.utils.data.Subset, and therefore lose important attributes of the original full dataset.
    The full dataset is saved to: a) feed in to different functions that require attributes of the full dataset, and b) cross-validation (I haven't done this, but could be done in the future).
    
    Args:
        dataset (torch.utils.data.Dataset): the full MLPDataset or TCNDataset you want to save.
        good_dict (dict): a dictionary containing the range of frames where the monkey is doing something interesting. This is clipped out of the full dataset and is saved for plotting later on.
        tcnn (bool): True for TCNDataset, false for MLPDataset. Used only to create directories.
        instance_length (int): the length of each instance in a TCNDataset. Ignored for MLPDataset. Used only to create directories.
        split_neurons (bool): True if you are splitting the dataset by electrode. Used only to create directories.
        split_num (int): the split number of the dataset. Only relevant if split_neurons is True. Used only to create directories.
        restraint_type (str): fullyrestrained or semirestrained. Used only to create directories.
    '''
    num_instances = len(dataset)
    train_split = int(num_instances*0.8)

    osim_train_dataset = Subset(dataset, np.arange(num_instances)[:train_split])
    osim_test_dataset = Subset(dataset, np.arange(num_instances)[train_split:])

    base_dir = '/content/drive/My Drive/Miller_Lab/FIU/PopFRData/processed_shuffled_opensim_datasets/{}'.format(restraint_type)
    if tcnn == True:
        base_dir = '/content/drive/My Drive/Miller_Lab/FIU/PopFRData/tcnn_processed_shuffled_opensim_datasets/instance_length_{}/{}'.format(instance_length,restraint_type)
    full_dir = os.path.join(base_dir,dataset.date,dataset.input_type)
    if ((tcnn == True) and (split_neurons == True)):
        base_dir = '/content/drive/My Drive/Miller_Lab/FIU/PopFRData/tcnn_processed_shuffled_opensim_datasets_splitneurons/instance_length_{}/{}'.format(instance_length,restraint_type)
        full_dir = os.path.join(base_dir,dataset.date,dataset.input_type,str(split_num))
    if ((tcnn == False) and (split_neurons == True)):
        base_dir = '/content/drive/My Drive/Miller_Lab/FIU/PopFRData/tutorial/processed_shuffled_opensim_datasets_splitneurons/{}'.format(restraint_type)
        full_dir = os.path.join(base_dir,dataset.date,dataset.input_type,str(split_num))

    if os.path.exists(full_dir) == False:
        os.makedirs(full_dir)
        torch.save(dataset, os.path.join(full_dir,'Full.pt'))
        torch.save(osim_train_dataset, os.path.join(full_dir,'Train.pt'))
        torch.save(osim_test_dataset, os.path.join(full_dir,'Test.pt'))
        torch.save(good_dict[dataset.date], os.path.join(full_dir,'GoodRange.pt'))

def load_datasets(base_dir, split_neurons = False):
    '''
    Loads saved datasets into a dictionary. As is, the keys of the dictionary are date, input type, and dataset type (Full/Train/Test/Good Range).

    Args:
        base_dir (str): The base directory where all datasets exist.
        split_neurons (bool): True if you're loading a dataset split by electrode.
    Returns: 
        a dictionary containing all datasets.
    '''

    dataset_dict = {}
    for date in os.listdir(base_dir):
        dataset_dict[date] = {}
        for inp_type in os.listdir(os.path.join(base_dir,date)):
            dataset_dict[date][inp_type] = {}
            for dataset_type in os.listdir(os.path.join(base_dir,date,inp_type)):
                if split_neurons == False:
                    dataset_dict[date][inp_type][dataset_type[:-3]] = torch.load(os.path.join(base_dir,date,inp_type,dataset_type))
                else:
                    dataset_dict[date][inp_type][dataset_type] = {}
                    for split in os.listdir(os.path.join(base_dir,date,inp_type,dataset_type)):
                        dataset_dict[date][inp_type][dataset_type][split[:-3]] = torch.load(os.path.join(base_dir,date,inp_type,dataset_type,split))
    return dataset_dict

def get_loaders(dataset_dict, batch_size, split_neurons = False):
    '''
    Makes a dictionary of dataloaders using the dataset_dict generated from the load_datasets function.

    Args:
        dataset_dict (dict): the dictionary containing datasets.
        batch_size (int): batch size of the dataloaders.
        split_neurons (bool): True if the dataset is split by electrode.
    Returns:
        a dictionary with the same structure as dataset_dict containing all dataloaders.
    '''
    loader_dict = {}
    for date in dataset_dict:
        loader_dict[date] = {}
        for inp_type in dataset_dict[date]:
            loader_dict[date][inp_type] = {}
            for dataset_type in dataset_dict[date][inp_type]:
                if split_neurons == False:
                    loader = torch.utils.data.DataLoader(dataset_dict[date][inp_type][dataset_type], batch_size=batch_size, pin_memory=True, sampler=None)
                    loader_dict[date][inp_type][dataset_type] = loader
                else:
                    loader_dict[date][inp_type][dataset_type] = {}
                    for split_num in dataset_dict[date][inp_type][dataset_type]:
                        loader = torch.utils.data.DataLoader(dataset_dict[date][inp_type][dataset_type][split_num], batch_size=batch_size, pin_memory=True, sampler=None)
                        loader_dict[date][inp_type][dataset_type][split_num] = loader
    return loader_dict

def convert_osim_dataset_to_array(dataset):
    '''
    Converts a MLPDataset back into an array.

    Args:
        dataset: a dataset from the MLPDataset class.
    Returns:
        A tuple of np.arrays with input and target data.
    '''
    inp_list = []
    out_list = []
    for i in range(len(dataset)):
        inp, out = dataset[i][0], dataset[i][1]
        inp_list.append(inp)
        out_list.append(out)
    return(np.vstack(inp_list), np.vstack(out_list))