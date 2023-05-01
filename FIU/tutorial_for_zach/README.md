Below is a description of everything you need to know, from obtaining raw data to training models and making plots. All functions pertaining to dataset creation, training/testing, and visualization can be found in the custom_functions folder in proc-aajan/FIU.

## **Step 0: Raw Data**

Neural data is stored in .nev files. Joint angle data can be retrieved in two ways:
1) OpenSIM. This fancy software calculates joint angles with its internal model of the arm.
2) Directly from Jarvis, using a joint angle function that I made. This is a rough estimate of finger joint angles I made using dot products, with the assumption that those joints act as hinges and can only bend in a single plane.

You can find the list of joint angles used in joint_angles_list.txt.

You'll likely be interested in using OpenSIM joint angles, so the rest of the readme will focus on OpenSIM.

## **Step 1: Conversion of raw OpenSIM data to XDS (in Matlab)**

If you plan on using OpenSIM joint angles, you'll need to learn how to use Xuan's Data Structure, aka XDS. Link to the github: https://github.com/limblab/xds

In order to make the .mat file with joint angle and neural data, 3 files are needed: a .nev file, a .nsx file, and a .mot file. The .nev file contains neural spike events; the .mot file is the output of the OpenSIM model containing joint angles. They must be placed in a folder and must have the exact same name (minus the extension) in order for the XDS conversion to work. A screenshot with an example folder called "example_folder_xds" is available (note the .mat will show up after the conversion is done). 

The function you'll use to run the conversion is raw_to_xds.m in xds_matlab. I've added a file called xds_notes.txt with each of the arguments necessary to run this function. Running raw_to_xds.m will produce a structure containing neural events in the spike_counts field and kinematic data in the joint_angles field. This structure will have the same name as the raw data files. When saving the structure, ensure you add '-v7.3' as an argument - this will save it in a format readable to h5py.

## **Step 2: Preprocessing XDS File (in Python)**

Preprocessing can be broken down in the following steps:
1) Data is read in with the xds lab_data module found in the xds_python folder.
2) The second and third joint angles must be converted from radians to degrees.
3) Neural spikes, originally binned at 1000Hz during the XDS conversion, must be binned to match the joint angle data (30Hz) using the update_bin_data method. Spikes are then smoothed using the smooth_binned_spikes method using a gaussian filter of width (2 x bin_size) in accordance with standard practice. Resulting binned and smoothed spikes are converted to firing rates by dividing by bin_size.
4) Oftentimes, the binned firing rates array will be longer than the joint angles. The end of the neural array must be trimmed in order to match the length of the joint angle data.
5) For plotting purposes, I manually examined the videos to find a continguous 20 second interval where the monkey is doing something interesting. The reason I do this is because I shuffle the datasets before saving them and randomly assign instances to training and testing sets. Doing this allows me to separate contiguous segments of data that can be tested on and visualized - namely to compare true target behavior vs predictions. I store those ranges and results in dictionaries called "good_frates_dict", "good_inputs_dict", and "good_frates_range_dict". In order to make datasets in the next step, store each of the joint angles in dictionaries so they can easily be accessed by each of the dataset classes.
6) (optional) To artificially create more datasets, I also randomly split the datasets by elecrode and store them in dictionaries.

## **Step 3: Creating and saving datasets and dataloaders**

There are two dataset classes available: MLPDataset and TCNDataset. Those can be found in data_loading.py.
**Note**: I initally made really silly names for those classes and called them "OSIMDataset" and "CustomDataset". Several datasets are saved as instances of classes, and the corresponding code is necessary to load those datasets; therefore, I've left that code in data_loading.py. However, you can ignore this entirely.

The MLPDataset class is used to make datasets for MLPs. Each instance in this dataset is a tuple containing input, output, and frame number. Each input/output pair corresponds to a single frame in the video.
The TCNDataset class is used to make datasets for TCNs. Each instance in this dataset is a tuple containing input, output, and frame numbers. Each input/output pair corresponds to N frames in the video, where N can be specified in the class instantiation (default = 100). 

You can create and save datasets with the create_and_save_datasets function in the data_loading.py script. This function has several inputs, most of which are used simply to make subfolders for different types dataset (e.g. fully restrained vs semirestrained, split by neuron vs non split). This code needs to be changed in order to save your datasets in the correct directories. Note that it automatically saves a train, test, and full version of the dataset. The full version of the dataset is saved for two main reasons: 
1) Important attributes regarding that dataset (e.g. date, target size, input type, etc.) are lost when making train/test subsets. The full version of the dataset is used in many other functions to keep track of these attributes. 
2) While I never did this, the full dataset can be used to make other training/testing datasets for N-fold cross-validation. Note that the full version of the dataset does NOT retain the 20 second contiguous intervals mentioned above.
Once the datasets are saved in the appropriate location, you can load all your datasets into a single dictionary using load_datasets. You can then convert those into dataloaders using get_loaders.

## **Step 4: Training models**
The two primary functions used to train and save models are:

1) plot_losses_MLP (used for MLPs)
2) plot_losses_TempCNN (used for TCNs)

and can be found in visualization.py. As mentioned above, since the input-output pairs in the TCN dataset are of length N frames, the TCN is a sequence-to-sequence network.

## **Step 5: Visualizations and making plots**

I've created a variety of functions to visualize the performances of the models as well as their predictions. The most important ones, which I've used in the tutorial notebook are: 

1) visualization.plot_distributions
2) visualization.plot_compare_distributions_subset
3) visualization.plot_targets_and_preds_agnostic
4) visualization.compare_pr2_plots
5) visualization.plot_and_compare_ks

Descriptions of each of these can be found in the visualization.py module, and an example of how to use each of these is in the tutorial notebook.

## **Side notes: transfer learning**

I never used a single main function to perform transfer learning - I felt like there were too many bells and whistles to for a single function to be useful. However, I've created an example of a transfer learning function for a TCN that can be used on a set of datasets that have been split by neuron that can be seen in the tutorial notebook.