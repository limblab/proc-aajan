function [ Vext, axonXPositions, axonYPositions ] = external_voltage_interpolated_for_diameter( datain, center_z_pos, fiberDiameter )
    %INPUT
    %datain         A csv that has all the position and voltage data (full
    %               file path
    %center_z_pos   The position (in units meters) where the center of the contacts are
    %fiberDiameter  The diameter of the axons, in units um
    %
    %OUTPUT
    % Vext              A voltage array of axons X nodes in the format needed 
    % axonXpositions    An array of the X positions in m in the same order as
    %                   Vext
    % axonYpositions    An array of the Y positions in m in the same order as
    %                   Vext

    % axons X nodes must be the dimensions of the voltage data applied by a
    % stimulus function, will be 100x221 (axonNumber X nodes)
    Vext = [];
    
    %Reading in the data from COMSOL
    %The format is X,Y,Z,Voltage
    %All the 100 axons in in this single long matrix
    voltageData = csvread(datain);
    
    %Find deltax, a diameter based value which tells us which parts of the
    %data we need
    %this equation is only valid for diameters 4um to 16um
    %deltax represents the distance between the middle of each node of
    %ranvier
    %20*deltax is the length of the entire axon being simulated in m
    deltax = (969.3*log(fiberDiameter)-1144.6) * 10^-6;
    
    %these values help to establish when a new axon is being input and
    %instantiates a counter for the upcoming loop
    oldX = 100;
    oldY = 100;
    i = 1;
    
    %must define variables
    axonXPositions = [];
    axonYPositions = [];
    singleAxon = [];
    while i <= size(voltageData,1)
        % data is organized a little awkwardly, must look at X/Y position
        % change to determine when a new axon is observed
        
        %must do this weird comparison because of weird rounding around
        %zero as we move from COMSOL to Excel/MATLAB
        if ( (abs(oldX -voltageData(i,1)) > 0.000001) || (abs(voltageData(i,2)-oldY) > 0.000001) ) 
            %update values
            oldX = voltageData(i,1);
            oldY = voltageData(i,2);
            axonXPositions = [axonXPositions; oldX];
            axonYPositions = [axonYPositions; oldY];
                   
            %start populating a temporary array with the values for a
            %single axon only
            while i <= size(voltageData,1)
                %fills a row
                singleAxon = [singleAxon; [voltageData(i,1),voltageData(i,2),voltageData(i,3),voltageData(i,4)] ]; 
                i = i+1;
                
                %If the next row is a new axon, leave the loop to then
                %process the data of that single axon
                
                %Need extra if for the last row
                if i <= size(voltageData,1)
                    % this exists to indicate that a new axon is found
                    %no need to update positions since that will happen
                    %post-break and the while loop for filling Single axon
                    %data is ended
                    
                    if ( (abs(oldX -voltageData(i,1)) > 0.000001) || (abs(voltageData(i,2)-oldY) > 0.000001) )
                        break
                    end
                end                 
            end
            
            %The while loop for filling a single axon's data is over, so
            %now we must interpolate and place that data in the Vext array
            %and reset singleAxon for the next one (should be fine for
            %last axon too)
            
            %order according to z position (length along the axon)
            singleAxon = sortrows(singleAxon,3);
            
            %appends to Vext the new interpolated voltage so in the end it
            %is the correct format of AxonsXVoltages (here it's 100x221)
            %Note, be sure that your data is not too high resolution since
            %MATLAB/Excel will round things such that there are multiple
            %voltages associated with a single position
            Vext = [Vext; interp1(singleAxon(:,3), singleAxon(:,4), (center_z_pos - 10*deltax: 20*deltax/220  :center_z_pos + 10*deltax)  )];
                        
            %reset the array for the next Axon's data
            clear singleAxon;
            singleAxon = [];
           
        end   
        i = i+1;
    end            

    
end


