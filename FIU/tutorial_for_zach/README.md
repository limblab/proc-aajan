Below is a description of everything you need to know, from obtaining raw data to training models and making plots.

Raw Data
Neural data is stored in .nev files. Joint angle data can be retrieved in two ways:
1) OpenSIM. This fancy software calculates joint angles with its internal model of the arm.
2) Directly from Jarvis, using a joint angle function that I made. This is a rough estimate of finger joint angles I made using dot products, with the assumption that those joints act as hinges and can only bend in a single plane.

The OpenSIM model produces 24 joint angles, listed below:

la_wr_sup_pro (wrist supenation/pronation)
la_wr_rd_ud (not sure what this one is called - will fill in soon)
la_wr_e_f (wrist extension/flexion)
la_cmc1_f_e (thumb CMC joint extension/flexion)
la_cmc1_opp (thumb CMC joint opposition)
la_cmc1_ad_ab (thumb CMC joint adduction/abduction)
la_mcp1_e_f (thumb MCP joint extension/flexion)
la_ip1_e_f (thumb IP joint extension/flexion)
la_mcp2_e_f (index MCP joint extension/flexion)
la_mcp2_ad_ab (index MCP joint adduction/abduction)
la_pip2_e_f (index MCP joint extension/flexion)
la_dip2_e_f (index DIP joint extension/flexion)
la_mcp3_e_f (middle MCP joint extension/flexion)
la_mcp3_rd_ud (middle MCP joint adduction/abduction)
la_pip3_e_f (middle MCP joint extension/flexion)
la_dip3_e_f (middle DIP joint extension/flexion)
la_mcp4_e_f (ring MCP joint extension/flexion)
la_mcp4_ad_ab (ring MCP joint adduction/abduction)
la_pip4_e_f (ring MCP joint extension/flexion)
la_dip4_e_f (ring DIP joint extension/flexion)
la_mcp5_e_f (pinky MCP joint extension/flexion)
la_mcp5_ad_ab (pinky MCP joint adduction/abduction)
la_pip5_e_f (pinky MCP joint extension/flexion)
la_dip5_e_f (pinky DIP joint extension/flexion)

My joint angle calculation produces 15 joint angles, listed below:

pinky_d_angle (pinky DIP joint)
pinky_m_angle (pinky MCP joint)
pinky_p_angle (pinky PIP joint)
ring_d_angle (ring DIP joint)
ring_m_angle (ring MCP joint)
ring_p_angle (ring PIP joint)
middle_d_angle (middle DIP joint)
middle_m_angle (middle MCP joint)
middle_p_angle (middle PIP joint)
index_d_angle (index DIP joint)
index_m_angle (index MCP joint)
index_p_angle (index PIP joint)
thumb_d_angle (thumb DIP joint)
thumb_m_angle (thumb MCP joint)
thumb_p_angle (thumb PIP joint)

You'll likely be interested in OpenSIM joint angles, so the rest of the readme will focus on OpenSIM.

Step 1: Conversion of raw data to XDS

If you plan on using OpenSIM joint angles, you'll need to learn how to use Xuan's Data Structure, aka XDS. Link to the github: https://github.com/limblab/xds

In order to make the .mat file with joint angle and neural data, 2 files are needed: a .nev file and a .mot file. The .nev file contains neural spike events; the .mot file is the output of the OpenSIM model containing joint angles. They must be placed in a folder and must have the exact same name (minues the extension) in order for the XDS conversion to work. Running those through XDS code will give you a .mat structure with joint angles and neural events. I needed to make some changes in order for the code to work for me, so I will upload my version of Xuan's XDS code to my github folder. 

The result of the XDS conversion will be a Matlab structure with the same name as the raw data files.

Step 2: Preprocessing XDS File (in Python)
Data is read in with the xds lab_data module.
The second and third joint angles must be converted from radians to degrees.
Neural spikes, originally binned at 1000Hz during the XDS conversion, must be binned to match the joint angle data (30Hz) using the update_bin_data method. Spikes are then smoothed using the smooth_binned_spikes method using a gaussian filter of width (2 x bin_size) in accordance with standard practice. Resulting binned and smoothed spikes are converted to firing rates by dividing by bin_size.
Oftentimes, the binned firing rates array will be longer than the joint angles. The end of the neural array must be trimmed in order to match the length of the joint angle data.
For plotting purposes, I manually examined the videos to find a continguous 20 second interval where the monkey is doing something interesting. The reason I do this is because I shuffle the datasets before saving them and randomly assign instances to training and testing sets. Doing this allows me to separate contiguous segments of data that can be tested on and visualized - namely to compare true target behavior vs predictions. I store those ranges and results in dictionaries called "good_frates_dict", "good_inputs_dict", and "good_frates_range_dict". In order to make datasets in the next step, store each of the joint angles in dictionaries so they can easily be accessed by each of the dataset classes.
To artificially create more datasets, I also randomly split the datasets by elecrode and store them in dictionaries. This is optional.

Step 3: Creating and saving datasets and dataloaders
There are two dataset classes available: MLPDataset and TCNDataset.
The MLPDataset class is used to make datasets for MLPs. Each instance in this dataset is a tuple containing input, output, and frame number. Each input/output pair corresponds to a single frame in the video.
The TCNDataset class is used to make datasets for TCNs. Each instance in this dataset is a tuple containing input, output, and frame numbers. Each input/output pair corresponds to N frames in the video, where N can be specified in the class instantiation (default = 100). 
You can create and save datasets with the create_and_save_datasets function in the data_loading.py script. This function has several inputs, most of which are used simply to make subfolders for different types dataset (e.g. fully restrained vs semirestrained, split by neuron vs non split). This code needs to be changed in order to save your datasets in the correct directories. Note that it automatically saves a train, test, and full version of the dataset. The full version of the dataset is saved for two main reasons: 1) important attributes regarding that dataset (e.g. date, target size, input type, etc.) are lost when making train/test subsets. The full version of the dataset is used in many other functions to keep track of these attributes. 2) While I never did this, the full dataset can be used to make other training/testing datasets for N-fold cross-validation. Note that the full version of the dataset does NOT retain the 20 second contiguous intervals mentioned above.
Once the datasets are saved in the appropriate location, you can load all your datasets into a single dictionary using load_datasets. You can then convert those into dataloaders using get_loaders.

Step 4: Training models
The two primary functions used to train and save models are:

plot_losses_MLP (used for MLPs)
plot_losses_TempCNN (used for TCNs)

and can be found in visualization.py. As mentioned above, since the input-output pairs in the TCN dataset are of length N frames, the TCN is a sequence-to-sequence network.


Step 5: Visualizations and making plots
I've created a variety of functions to visualize the performances of the models as well as their predictions. The most important ones, which I've used in the tutorial notebook are: 

visualization.plot_distributions
visualization.plot_compare_distributions_subset
visualization.plot_targets_and_preds_agnostic
visualization.compare_pr2_plots
visualization.plot_and_compare_ks

Descriptions of each of these can be found in the visualization.py module, and an example of how to use each of these is in the tutorial notebook.

Side notes: transfer learning

I never used a single main function to perform transfer learning - I felt like there were too many bells and whistles to for a single function to be useful. However, I've created an example of a transfer learning function for a TCN that can be used on a set of datasets that have been split by neuron that can be seen in the tutorial notebook.