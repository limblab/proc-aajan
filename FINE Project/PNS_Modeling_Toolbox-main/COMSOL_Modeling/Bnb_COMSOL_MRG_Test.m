%Program for the running of the branch and bound algorithm on a given
%distribution of axons and their contacts around them

%this initial run figures out viable combinations of contacts to populate
%the array of combinations of contacts that might be viable

%this helps keep functions where they should be is all
addpath('./COMSOL modeling/');
%this line adds the superdirectory to the path
addpath('../');

%depth is the number of contacts being considered simultaneously
depth = 3;
%fiber diameter in um
diameter = 10;

%the resolution of currents considered and the lower and upper bounds
lowerCurrent = -0.3;
upperCurrent = 0.3;
currentResolution = 0.2;

%number of contacts total on the electrode
numContacts = 10;

%The matrix of all considered currents on each contact
baseMatrix = [];
for i = (1:numContacts)
    for j = (lowerCurrent:currentResolution:upperCurrent)
       baseMatrix = [baseMatrix ; zeros(1, numContacts)];
       baseMatrix(end, i) = j;
    end
end

%setting up the struct for the "Working Matrix" which will hold the tree of
%currents and the associated activations that are being considered
workingActivation = [];
workingCurrents = [];


%consider base contact combinations "once over" to reduce the number of
%base cases which the algorithm will work off of
for i = (1:size(baseMatrix,1))
    
    %evaluate the activation of elements of the base matrix
    AP = return_AP_MRG_currents_in( baseMatrix(i, :), diameter );
    
    %set all non-zero values of the matrix to simply be zero
    
    AP=AP~=0;
    
    %the number of activated axons 
    totalActivation = sum(AP);
    
    %only add the current row to the working matrix if it activates any
    %axons and it does not activate more than half of the population
    if ((totalActivation ~= 0) && (totalActivation < 0.5*length(AP)))
        workingActivation = [workingActivation; AP];
        workingCurrents = [workingCurrents; baseMatrix(i,:)];

    end
    
end

%% Now we go through the main loop of the program where we will end up with a final working matrix which will be the input to the next Bnb algorithm.
% This final working matrix will be the total currents in all contacts for
% all valid conbos of N simulataneous contacts

for i = (1:depth)
    %resetting the temporary matricies
    tempActivMat = [];
    tempCurrMat = [];
   for j = (1:size(workingCurrents, 1))
       %we will apply elements from the base matrix to the working amtrix
       %to do all the updating
       for k = (1:size(baseMatrix, 1))
            activeCurrent = workingCurrents(j,:) + baseMatrix(k,:);
            % Bound a branch if you are adding current to a contact that
            % already has some or if you are recreating a current that's
            % already in the working matrix
            if (ismember(activeCurrent, workingCurrents, 'rows') || (nnz(activeCurrent) <= i)  )
                %if the continue triggers, then the model is not run and
                %the iterator is incremented
                continue; 
            end
            
            %now, since some criteria have not been met, we run the model
            AP = return_AP_MRG_currents_in( baseMatrix(i, :), diameter );   
            %set all non-zero values of the matrix to simply be zero
            AP=AP~=0;
            
            %Now we apply criteria to remove yet more branches that do not
            %work HERE IS ALL BASICALLY
            
            %The branch has survived all bounding techniques, add it to the
            %temporary matrix, add it later
            tempActivMat = [tempActivMat ; AP];
            tempCurrMat = [tempCurrMat; activeCurrent];
       end
   end
   %delete working matrix, make it the temporary matrix, yup
   workingCurrents = tempCurrMat;
   workingActivation = tempActivMat;
   %Now add to the working matrix and remove the 
end
%% dfebugging plotting activation
axons = 114;
f2 = figure(2);
hold on;

%This provides an overlay for the data so we can see fascicle borders
I = imread(pwd+"\COMSOL modeling\106Specific\"+"MatlabSizedUlnar.png"); 
imagesc([3.8e-3 10.9e-3],[0.475e-3 -2.2e-3],I); 

%This just resizes and positions the figure so it makes more sense with the
%geometry of the nerve to a person
 f2.Position =  [500 200 1300 520];

AP = workingActivation(73,:);
for i = (1:axons)
    if (AP(i)>0)
        scatter(axonXPositions(i), axonYPositions(i), 20,'red' );
    else
        scatter(axonXPositions(i), axonYPositions(i), 20,'blue' );
    end
end

hold off
title 'Axon Positions and Firing'
%making the overlay look nicer
xlim([3.8e-3 10.9e-3]);
ylim([-2.2e-3 0.475e-3]);











