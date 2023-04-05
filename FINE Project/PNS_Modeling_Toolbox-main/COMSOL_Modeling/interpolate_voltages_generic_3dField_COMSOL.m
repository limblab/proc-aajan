function [ Vext, axonXPositions, axonYPositions, axonDiameters ] = interpolate_voltages_generic_3dField_COMSOL( template_voltages, center_z_pos, polygon_file, axons_per_fascicle )
    

    %INPUT
    %template_voltages  a 3d array where each "sheet" is one of the 15
    %                   contacts and their voltages at each x-y position.
    %                   For clarity, it is xPositions X yPositions X
    %                   contact of origin
    %center_z_pos       The position (in units meters) where the center of
    %                   the cuff is
    %polygon_file       The file used by COMSOL to find the borders of
    %                   fascicles
    %axons_per_fascicle How many axons you want randomly placed in each
    %                   fascicle
    
    %center is 0.0065 m by default in the generalizedFieldFile
    
    %OUTPUT
    % Vext              A voltage array of axons X nodes X template_number. This way we can add the voltages quickly in the calling function 
    % axonXpositions    An array of the X positions in m in the same order as
    %                   Vext so that each position is an axon
    % axonYpositions    An array of the Y positions in m in the same order as
    %                   Vext
    % axonDiameters     An array of the diameters in um in the same order as
    %                   Vext

    %%
    axonDiameters = [];
    % instatiate values for polygon reading
    num_verts = [];
    fascicleStruct = [];
    numPerineuriaCounter = 1;
    % read the polygon in here
    fid = fopen(pwd+"/Preparation_files/"+polygon_file);
    polygon_data = textscan(fid, '%s');
    %this loop lets us go through the file word by word
    i = 1;
    while i <= length(polygon_data{1})
        % if we see "Peri" then we are at a point of another perineurium
        if (strncmpi("Peri", polygon_data{1}(i), 4) )
            % after seeing "resTol" the next number is the number of
            % verticies
            while~(strcmp("resTol", polygon_data{1}(i)) )
                i = i+1;
            end
            i = i+1;
            %here the number of verticies is saved
            num_verts = [num_verts, cellfun(@str2num,polygon_data{1}(i))];
            %the string after tol will be the verticies
            while~(strcmp("tol", polygon_data{1}(i)) )
                i = i+1;
            end
            i = i+1;
            %the cursor is now on the x value of the first vertex
            %loop the num_verts(end) number of times
            %First one must be instantiated
            fascicleStruct(numPerineuriaCounter).xPeri = [];
            fascicleStruct(numPerineuriaCounter).yPeri = [];
            %Now the rest of the points for a given fascicle will be
            %filled
            for j = 1:num_verts(end)
                fascicleStruct(numPerineuriaCounter).xPeri = [fascicleStruct(numPerineuriaCounter).xPeri, cellfun(@str2num,polygon_data{1}(i))];
                i = i+1;
                fascicleStruct(numPerineuriaCounter).yPeri = [fascicleStruct(numPerineuriaCounter).yPeri, cellfun(@str2num,polygon_data{1}(i))];
                i = i+2;
                %now the cursor is on the next x value or it's at the end
                i = i+1;
            end
            numPerineuriaCounter = numPerineuriaCounter+1;
            %when we're here we reach the end of all the verticies    
        end
        i = i+1;
    end
    clear i;
    
    %now positionStruct has 7 different fascicles in it
    % Now we need to populate the arbitrary number of axons in each
    % fascicle
    for i = 1:length(fascicleStruct)
        %fascicleStruct holds perineurium positions and the location of
        %each axon in each fascicle
        %must seed the first value, make it the center
        fascicleStruct(i).xAxon = (min(fascicleStruct(i).xPeri)+max(fascicleStruct(i).xPeri))/2;
        fascicleStruct(i).yAxon = (min(fascicleStruct(i).yPeri)+max(fascicleStruct(i).yPeri))/2;
        for j = 2:axons_per_fascicle
            tempX = unifrnd(min(fascicleStruct(i).xPeri), max(fascicleStruct(i).xPeri));
            tempY = unifrnd(min(fascicleStruct(i).yPeri), max(fascicleStruct(i).yPeri));
            %this loop makes sure that the randomly made point is actually
            %in the fascicle
            while (~inpolygon(tempX,tempY,fascicleStruct(i).xPeri, fascicleStruct(i).yPeri ) || (ismember(tempX,fascicleStruct(i).xAxon) ) || (ismember(tempY,fascicleStruct(i).yAxon) )  )
                tempX = unifrnd(min(fascicleStruct(i).xPeri), max(fascicleStruct(i).xPeri));
                tempY = unifrnd(min(fascicleStruct(i).yPeri), max(fascicleStruct(i).yPeri));
            end
            %now tempX and tempY are in the fascicle for sure
            fascicleStruct(i).xAxon = [ fascicleStruct(i).xAxon, tempX];
            fascicleStruct(i).yAxon = [ fascicleStruct(i).yAxon, tempY];
        end   
    end
    
    %now we have axons_per_fascicle positions in each fascicle associated with eacch object in fascicleStruct. Very good
    % We now Sort the positions because that makes a later part of the
    % program much nicer (when we're looking up voltages to associate to
    % each axon)
    for i = 1:length(fascicleStruct)
        %these 3 lines just sort things using tables. It's nothing too
        %fancy. tempt is just a temp table
        tempt = table(fascicleStruct(i).xAxon', fascicleStruct(i).yAxon');
        tempt = sortrows(tempt, [1 2]);
        tempt = table2array(tempt);
        %Now assign the sorted values
        fascicleStruct(i).xAxon = tempt(:,1)';
        fascicleStruct(i).yAxon = tempt(:,2)'; 
    end
    %finally, we put all of the axon locations in a single table and sort
    %that. This makes the later step the most efficient. Everything is done
    %the same way as above
    allAxonLocations.xAxon = [];
    allAxonLocations.yAxon = [];
    for i = 1:length(fascicleStruct)
       allAxonLocations.xAxon = [allAxonLocations.xAxon,fascicleStruct(i).xAxon  ];
       allAxonLocations.yAxon = [allAxonLocations.yAxon,fascicleStruct(i).yAxon  ];
    end
    tempt = table(allAxonLocations.xAxon', allAxonLocations.yAxon');
    tempt = sortrows(tempt, [1 2]);
    tempt = table2array(tempt);
    allAxonLocations.xAxon = tempt(:,1)';
    allAxonLocations.yAxon = tempt(:,2)';
    
    %two of the outputs are now saved
    axonXPositions = allAxonLocations.xAxon;
    axonYPositions = allAxonLocations.yAxon;
    

    %% now we are done creating the scaffolding for all the random axon positions. Second section
    %__________________________________________________________________________________________

    
    %instantiate the final output
    %dimensions are axons x nodes x number of contacts
    Vext = zeros(axons_per_fascicle*length(fascicleStruct), 221, size(template_voltages, 3));    
    %instantiate single axon. Note that it must have 1 layer for each
    %template_field/ contact that we are inputting
    zValsOneAxon = [];
    voltageOneAxon = [];
    previousXValue = template_voltages(1,1,1);
    previousXIndex = 1;
    
    %for debug only
    xValsOneAxon = [];
    yValsOneAxon = [];
    
    axonNumber = length(axonXPositions);
    %this value will be used to keep track of how many axons we've seen
    axonCounter = 1;
    i = 1;
    %These values are used to keep track of the previous X adn Y values to
    %tell if a given randomly selected axon location should correpond to a
    %particular sampled point in 3d space for finding the voltage. The
    %second value is the most recently inserted one
    %[lower value, higher value]  
    previousXValues = [template_voltages(1,1,1) template_voltages(1,1,1)];
    previousYValues = [template_voltages(1,2,1) template_voltages(1,2,1)];
    
    %now we go through the random positions, compare them to the first
    %template voltage sheet
    %here is where everything being in numerical order matters
    while i <= size(template_voltages,1) && axonCounter<=axonNumber
        % data is organized a little awkwardly, must look at X/Y position
        % change to determine when a new axon is observed

        
        %When a match is seen, the next position of an axon may fall in the
        %same "bucket" of values, so we have to return to whence we came in
        %case two positions fall in the same area in the 3d matrix of
        %voltages
        if (template_voltages(i,1,1) ~= previousXValue)
            previousXValue = template_voltages(i,1,1);
            previousXIndex = i;
        end

        %This remembers the last 2 'x' and 'y' values observed. If the axon
        %position is between those two values, then we identify a desired
        %axon as being there
        if(template_voltages(i,1,1)~=previousXValues(2) )
            %Shifting for a 
            previousXValues(1) = previousXValues(2);
            %inserting the new values
            previousXValues(2) = template_voltages(i,1,1);
        end
        if(template_voltages(i,2,1)~=previousYValues(2))
            previousYValues(1) = previousYValues(2);
            previousYValues(2) = template_voltages(i,2,1);            
        end
        
        if ( (  previousXValues(1) <= axonXPositions(axonCounter) && axonXPositions(axonCounter) <= previousXValues(2))   && (  previousYValues(1) <= axonYPositions(axonCounter) && axonYPositions(axonCounter) <= previousYValues(2))) 


            % a value to keep track of x values to allow for multiple points to share close x values
            %start populating a temporary array with the values for the
            %found for the random axon
            while i <= size(template_voltages,1)
                %fills a row, do it once for each dimension, save z pos and
                %potential from contact
                for j = 1:size(template_voltages,3)
                    %save z value, voltage, and the contact it comes from
                    %last
                    zValsOneAxon = [zValsOneAxon,template_voltages(i,3,j)];
                    voltageOneAxon = [voltageOneAxon,template_voltages(i,4,j)];
                    
                    %DEBUG
                    xValsOneAxon = [xValsOneAxon,template_voltages(i,1,j)];
                    yValsOneAxon = [yValsOneAxon,template_voltages(i,2,j)];
                    %singleAxon = [singleAxon; [template_voltages(i,3,j),template_voltages(i,4,j), j ] ]; 
                end
                i = i+1;
                
                %If the next row is a new axon, leave the loop to then
                %process the data of that single axon
                
                %Need extra if for the last row
                if i <= size(template_voltages,1)                    
                    %new way to break, just if the length is enough
                    %500 is the COMSOL defined number of points in the z
                    %direction (THIS STEP CAN COUSE ISSUES)
                    %This means now lets look at the next axon
                    if (length(voltageOneAxon)>= 500*size(template_voltages,3))
                        break
                    end
                end                 
            end
            %now the data for a single axon is ready
            
            %sets diameter to be between 4 and 12 um
            fiberDiameter = unifrnd(4,12);
            deltax = (969.3*log(fiberDiameter)-1144.6) * 10^-6;
            
            %update diameters
            axonDiameters = [axonDiameters, fiberDiameter];
            
            %this random factor determines internode spacing
            interNodeOffset = unifrnd(0, 0.5*deltax);
            
            %we need this so we can look at just the values for an
            %associated contact at a time
            numContacts = size(template_voltages,3);
            %here the actual interpolation occurs, note that we index by
            %numContacts and that is what seperates each axon for each contact 
            for j = 1:numContacts
                Vext(axonCounter,:,j) =  interp1(zValsOneAxon(j:numContacts:end), voltageOneAxon(j:numContacts:end), (center_z_pos+interNodeOffset - 10*deltax: 20*deltax/220  :center_z_pos+interNodeOffset + 10*deltax)  );
            end
            

            %update axonCounter
            axonCounter = axonCounter+1;
            % allows for multiple axons to share x values, used to cause
            % issues
            i = previousXIndex;%rememberI-1;
            

            %reset the array for the next Axon's data
            zValsOneAxon = [];
            voltageOneAxon = [];
            
            %DEBUG
            xValsOneAxon = [];
            yValsOneAxon = [];
           
        end
        
        %this goes when nothing is found or is interesting
        i = i+1;
    end            

 %%   
end


