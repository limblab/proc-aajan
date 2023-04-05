function [] = PlotSecondSpatialDifference(Vext, axonXPosition, axonYPosition, polygon_file )
%all information for creating this function can be found in Izad's master's
%thesis:
%https://etd.ohiolink.edu/apexprod/rws_etd/send_file/send?accession=case1232751033&disposition=inline

%INPUT
% Vext:             The external voltage field in mV
%                   The external voltage is in form Axons X NodeVoltages
% axonXPositions:   The X-coordinates of the axons
% axonYPositions:   The Y-coordinates of the axons
% polygon_file:     Where the borders of fascicles come from


%OUTPUT
% It is going to make a plot of the surface of the maximum of the second spatial
% difference along each axon. This is meant to visualize how different
% contact locations and currents affect the surface of activation

%the voltages at all of the nodes of ranvier only. These are what matter
%for the Izad method
nodeVoltages = Vext(:, 1:11:end)';

% This calculates the second spatial derivative
D2V = diff(nodeVoltages,2);

%NOTE, The maximum of D2V along the axon is the most important value (a max
%will determine if an AP happens or not) so that's all we need to plot on
%the surface (we cannot plot the entire line, must do max of each collumn)
maxDifferences = max(D2V);

%places an overlay to contextualize the data
% I = imread(pwd+"\106Specific\"+"MatlabSizedUlnar.png"); 
%  imagesc([3.8e-3 3.8e-3],[8e-4 -8e-4],I);
hold on

%Plotting all the data together

[xq, yq] = meshgrid(min(axonXPosition):(max(axonXPosition)-min(axonXPosition))/300:max(axonXPosition) , ...
                         min(axonYPosition):(max(axonYPosition)-min(axonYPosition))/300:max(axonYPosition) );

finalSurfaceSpatialDifference = griddata(axonXPosition, axonYPosition, maxDifferences, xq, yq);

%here we remove all points that are not in fascicles by setting them to nan

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


    
    %now that all the fascicle borders are loaded in, we just need to check
    %if each position is in any fascicle
% %go through each position on the final grid
for i = 1:length(xq)
    %must go through x and y
    for j = 1:length(yq)
        %how we keep track of if a position is in any fascicle
        inAnyFascicle = 0;
        %go through each fascicle
        for k = 1:length(fascicleStruct)
            %These positions work nicely for finding where axons lie in
            %fascicles
            if (inpolygon(xq(i,j),yq(i,j), fascicleStruct(k).xPeri, fascicleStruct(k).yPeri))
                inAnyFascicle = 1;
            end
        end
        if (inAnyFascicle == 0)
            %This line removes points from the surface that do not
            %correspond to the location of a fascicle
            finalSurfaceSpatialDifference(i,j) = nan;
        end
    end
end
%Just plotting the end result with all the Nan we want
s = surf(xq, yq, finalSurfaceSpatialDifference);
s.EdgeColor = 'none';                    
                     
title('Second Spatial Difference of the Voltage Along Each Axon')
hold off
end

