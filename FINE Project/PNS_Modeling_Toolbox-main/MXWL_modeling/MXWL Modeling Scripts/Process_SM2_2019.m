% This script process an SM2 file
% Input: SM2 name       Output: maxwell voltages and descriptive .mat
% Creates:
% - folder of export locations for maxwell to use
% - file with parameters for maxwell to read in
% - .mat file with fascicle descriptoins )fascicle descriptions
% Calls maxwell to build models and export voltages to
% - folder of export voltages

% More or less a wrapper for Matt's get_bounding_box
% and Josh's create param script
% and a modified Matt's vbs script
% PVL 6/6/16

%%
% INPUT PARAMETERS. Set name of file you want to process
sm2 = 'Simplesm2.sm2'; % Include '.sm2', but not '\' at beginning
% sm2 = 'Median19_T1_NOencapsulation FINE 1.5x10 mm'; % 

PromptForCuffDimensions=0; % If 1, enter all cuff dimensions manually
% otherwise, use preset values.(ideally we'd enumerate all combinations)
% as is, a 10x1 C-Fine 16 contact cuff

%%
% 0.extend paths
addpath(genpath(pwd))

% 1. Create the export folders and descriptive file - Matt's work
object_string='Endo';
step_size=[1/10,1/10,1/50];
z=[0,0.030]; % in meters
SimplifiedGetBoundingBoxAndVertices([pwd,'\', sm2],object_string,step_size,z );

% 2. Create maxwell param file, 'params.txt' - Josh's work


filename=['FascicleDescriptions.mat'];
load(filename);
numFasc = length(FascicleNames); % get number of fascicles


fileID = fopen('VBSparams.txt', 'w');
sm2_text = [sm2 '\r\n']; % cut off slash, add new line
fprintf(fileID, sm2_text); % start with sm2 file name

if (PromptForCuffDimensions)
   % numFasc = input('Enter number of fascicles:  '); % already known
    field = '%1.0f\r\n';
    fprintf(fileID, field, numFasc);
    
    conX = input('Enter ContactX:  ');
    field = '%.2f\r\n';
    fprintf(fileID, field, conX);
    
    conY = input('Enter ContactY:  ');
    field = '%.2f\r\n';
    fprintf(fileID, field, conY);
    
    conZ = input('Enter ContactZ:  ');
    field = '%.2f\r\n';
    fprintf(fileID, field, conZ);
    
    conD = input('Enter Contact Depth:  ');
    field = '%.2f\r\n';
    fprintf(fileID, field, conD);
    
    cuffX = input('Enter CuffX:  ');
    field = '%.2f\r\n';
    fprintf(fileID, field, cuffX);
    
    cuffY = input('Enter CuffY:  ');
    field = '%.2f\r\n';
    fprintf(fileID, field, cuffY);
    
    cuffZ = input('Enter CuffZ:  ');
    field = '%.2f\r\n';
    fprintf(fileID, field, cuffZ);
    
    cuffW = input('Enter Cuff Wall Thickness:  ');
    field = '%.2f\r\n';
    fprintf(fileID, field, cuffW);
    
    wellD = input('Enter Well Diameter:  ');
    field = '%.2f\r\n';
    fprintf(fileID, field, wellD);
    
    wellH = input('Enter Well Height:  ');
    field = '%.2f\r\n';
    fprintf(fileID, field, wellH);
    
    salX = input('Enter SalineX:  ');
    field = '%.2f\r\n';
    fprintf(fileID, field, salX);
    
    salY = input('Enter SalineY:  ');
    field = '%.2f\r\n';
    fprintf(fileID, field, salY);
    
    salZ = input('Enter SalineZ:  ');
    field = '%.2f\r\n';
    fprintf(fileID, field, salZ);
    
    nerveZ = input('Enter nerveZX:  ');
    field = '%.2f\r\n';
    fprintf(fileID, field, nerveZ);
    
    buffT = input('Enter Buffer Thickness:  ');
    field = '%.2f\r\n';
    fprintf(fileID, field, buffT);
    
    anoX = input('Enter AnodeX:  ');
    field = '%.2f\r\n';
    fprintf(fileID, field, anoX);
    
    anoY = input('Enter AnodeY:  ');
    field = '%.2f\r\n';
    fprintf(fileID, field, anoY);
    
    anoZ = input('Enter AnodeZ:  ');
    field = '%.2f\r\n';
    fprintf(fileID, field, anoZ);
    
    numCon = input('Enter Numberof Contacts:  ');
    field = '%1.0f\r\n';
    fprintf(fileID, field, numCon);
    
    encT = input('Enter Encapsulation Thickness:  ');
    field = '%.2f\r\n';
    fprintf(fileID, field, encT);
    
    inEncT = input('Enter Index Encapsulation Thickness:  ');
    field = '%1.0f\r\n';
    fprintf(fileID, field, inEncT);
else
    % A standard cuff.
    
    % units in mm, note: cuff lateral schematic in inches
    
Cuff.NumberOfFascicles=numFasc; % auto determined from descriptor file
Cuff.CuffX=10;
Cuff.CuffY=1.5;
Cuff.CuffZ=10;


Cuff.TopBufferThickness = 0.42;
Cuff.BtmBufferThickness = 0.21;

Cuff.NumberOfContactsTop=7;
Cuff.NumberOfContactsBtm=8;


Cuff.EncapsulationThickness= 0.25; % usually 0.25  Gets zero'd if next line !2
Cuff.IndexEncapsulationThickness=1;  %'   "2" triggers encapsulation

Cuff.UseDistantAnode=0; % if 1, uses saline instead of anode strips
Cuff.AnodeZ=1; % 1 mm, or whatever satisfies 4 contact's worth of area

Cuff.ContactX=1;  % This is modeled as a circle. given that is the only exposed area is defined by the well, there's no point in making the real structure so long as spacing is correct 
Cuff.ContactY=0.2032;  
Cuff.ContactZ=1; % I don't think this has any effect (modeled as regular poly based on X)
Cuff.ContactDepth=0.127; % 0.005", not 0.008" - only has to cut through 'A' layer

Cuff.NerveZ=60;
Cuff.CuffWallThickness=0.5842;
Cuff.WellDiameter=.8;       
Cuff.WellHeight=Cuff.ContactDepth+Cuff.ContactY;% well is hole contact is in. contactY + contact depth
Cuff.SalineX=200;
Cuff.SalineY=200;
Cuff.SalineZ=200;



if (Cuff.IndexEncapsulationThickness~=2) % common source of error.
    Cuff.EncapsulationThickness= 0;
end


terms = fieldnames(Cuff);
for i=1:numel(terms) % Throw everything to a file
    if (strcmp(terms{i},'IndexEncapsulationThickness') || ...
            strcmp(terms{i},'NumberOfFascicles') ||...
            strcmp(terms{i},'NumberOfContactsTop') ||...
            strcmp(terms{i},'NumberOfContactsBtm'))
        field = '%1.0f\r\n'; % These have to be integers
    else
        field = '%0.2f\r\n';
    end
    fprintf(fileID, field, Cuff.(terms{i}));
end
end

fclose(fileID);
%% OKay, by now we've generated all the files we need to run a maxwell model
% 1. Alert user
wrn = warndlg('Altering Intermediate Outputs Folder. Make sure you backed up anything you need');
waitfor(wrn)

% 2. Copy all current information to 'intermediate outputs'
tmp = mkdir ([pwd,'\Intermediate Outputs']);
movefile ('FascicleDescriptions.mat', 'Intermediate Outputs')
movefile ('VBSparams.txt', 'Intermediate Outputs')
movefile ('FascicleNames.txt', 'Intermediate Outputs')

movefile ('ExportLocations','Intermediate Outputs')
copyfile (sm2, 'Intermediate Outputs')

% 3. Get fresh copies of the vbs and frankenstein scripts in case the
% intermediate outputs folder was cleared
copyfile ([pwd, '\Modeling Support Files\Model Scripts\Frankenstein.mxwl'],'Intermediate Outputs')
copyfile ([pwd, '\Modeling Support Files\Model Scripts\Maxwell_VBS_Script.vbs'],'Intermediate Outputs')

mkdir([pwd '\Intermediate Outputs\Maxwell_Output'])

                
cd ([pwd '\Intermediate Outputs'])
system(sprintf('cscript.exe "%s"', 'Maxwell_VBS_Script.vbs'))
clear;