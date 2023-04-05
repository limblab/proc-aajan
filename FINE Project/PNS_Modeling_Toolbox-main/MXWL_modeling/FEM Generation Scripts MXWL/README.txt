16 channel with anode strip CFINE.mxwl and associated folder is the base CFINE model used to generate all of the FEMs. 

S107ModelsFromTXT.vbs is supposed to be run from maxwell. It opens the CFINE file, adds the nerve cross-section, and runs the FEM for stim through each individual contact;
This code assumes that you have already reshaped the nerve using MAS's reshape algorithm, and have exported the results into a txt file that consists of centroid XY coordinates and Radius for the Endo and Perineuriums. (Order, EndoX; EndoY; EndoR; PeriX; PeriY; PeriR; repeat for all fascicles)
BEFORE RUNNING THIS, you will need to generate the nerve cross section in maxwell and make sure the reshape algorithm didn't result in any fascicles intersection with one another or the nerve boundary. If they have, you will need to manually shift stuff to get rid of the intersections, and define these shifts in the vbs file.

ExportVoltagesAll.vbs takes the results from the finished FEMs and exports it into .fld files that can then be used in MATLAB to look at individual axon/fascicle/nerve stimulation 

Folder OldFEMValues_BAD_DONOTUSE has S107 FEM models/results using incorrect Perineurium resistivity. This data is kept b/c it was used to generate the results for an SfN poster

S107_Median19Frame1Modeling and S107Ulnar20Frame34Modeling have correct S107 FEM results for 4 models. 
The cross-section was created from ultrasound video Median19, 1st frame. 2 possible interpretations were used - 1 with 20 fascicles, and 1 with 14 fascicles.  (frame saved as a PNG)
The cross-section was created from ultrasound video Ulnar20, 34th frame. (frame saved as a PNG)

Each model has the GUI saved output from the Reshape algorithm (not used, but saved just in case);
M19T1_X_E_fasccoords.txt is the txt file with X,Y,R for Endo and Perineurium
Each contact activated is saved as an indiviual model + folder
the voltages for each fascicle for each active contact are saved as a separate fld file (20 or 13 fascicles x 15 contacts = lots of files)

Folder ActivationModeling has the matlab scripts to look at activation of all axons in the nerve for any combination of cathodes and anodes using the above defined fld files. 
These are base/template/example functions. Some values will need to be changed for each model. and all of the functions will need to be copied into the folder with the fld files. 
First run GenerateVnodeFiles.m - this will create a nerve (and define the locations of all axons in it using GenerateNervePopulation) and interpolate voltages from the fld files to the axon nodes.
Make sure that if you shifted any fascicles manually in the vbs script, you also define that shift in GenerateNervePopulation.m
ApplyStim_Izad is the function that actually determines 1) which axons are activated and 2) how many. PA and PW can be vectors. and example of how it's called is shown in SfN2016_PlotActivation.m

SOM contains all of the files/folders to run a self-organizing map. 
subfolder LH_2D_create has the files for defining the surface of the hand (POH and BOH sandwiched together). You will need the LH2dverteces, LH2dedges, and LH2dLookupFull.mat files (the rest is just generating the full table. not necessary, but don't delete... it took mult days on the cluster to generate)
subfolder LH_3D_create has the files to create a actual 3D hand model (as opposed to 2 figures sandwiched on one another). Using this would require figureing out how to wrap experimental sensory locations back onto the 3D hand (undo a projection operation)
subfolder SOM-Toolbox-master was downloaded fromhttp://www.cis.hut.fi/projects/somtoolbox/documentation/; 
http:// www.cis.hut.fi/projects/somtoolbox/package/papers/techrep.pdf
som_master.zip has the original SOM functions (if you ever want to customize your own SOM) 

regarding the SOM-Toolbox-master/.../som folder
The function BasicLocToAxonPopMapping.m takes does an inital matching of regions of the hand to axon populations (matches experimental data to ActivationModel outputs). This function can be used to visualize this basic/starting mapping. It also generates the .mat file that the SOM bases its initializaiton on
The functions Experinit was added. runSOM,som_batchtrain and som_unit_dists were modified to implement the hand SOM
***NOTE: Depending on which subject/nerve are doing, will need to change code in som_experinit.mat (specifically lines 242-245: load appropriate axondata and initial mapping
To actually run a SOM with whatever settings of interest you have, use the function RunSOM.m 