% This  subfunction creates a struct (fasciclesfinal). A nerve is created 
% from fascicle coordinate data and populated with axons based on 
% anatomical information on sensory nerve fibers within
% the fascicle. The function assigns locations of the fibers in the
% fascicles and these locations can then be plotted to provide a visual of
% the nerve fiber. Additional anatomical information assigned to the nerve
% fiber includes diameter (based on statistical values),length, and nodal
% spacing/offset

    function [fasciclesfinal, allaxons] = GenerateNervePopulation(NerveNameString)
        % NOTE: FASICICLES RUN THROUGH RESHAPE ALGORITHM ARE APPROXIMNATED
        % AS ROUND --> LEADS TO LOTS OF SIMPLIFICATIONS IN THIS CODE THAT
        % ONLY HOLD TRUE FOR ROUND FASCICLES
        
        %define directory to save results in
        %load mat file that contains vertices of nerve and fascicles
        fasc_coords = load([NerveNameString '_fasccoord.txt']); %in mm
        numfascicles = length(fasc_coords)/6; %(x,y,r for both endo and peri)
        fasc_coords = reshape(fasc_coords,[6,numfascicles])'; %1 row/fascicle; columns = [endoX endoY endoR periX periY periR]
        
        disp(['Don''t forget to account for any manual shifting of fascicles in Maxwell to deal with edges'])
        if strcmp(NerveNameString, 'M19T1') == 1
            fasc_coords(6,[2,5]) = fasc_coords(6,[2,5]) + 0.04685;
            fasc_coords(9,[2,5]) = fasc_coords(9,[2,5]) + 0.04435;
            fasc_coords(12,[2,5]) = fasc_coords(12,[2,5]) + 0.04922;
        end
        %initialize output variables
        fasciclesfinal= [];
        
        %Load matrix of randomly assigned diameters (statistically determined).
        % Matrix is the length of the number of fascicles in the .mat file x nAxons
        % generated

        %Verdu 2000 - review of studies on axon density
        %average axon density of myelinated fibers reported in the 3
        %studies cited (1 tibial anterior, 2 sural nerve) for humans aged
        %40-59 is 6392 axons/mm2
        %axon density appears to depend on age, and there is high
        %variability even between fascicles in the same subject
        circ_theta = linspace(0,2*pi,36)';
        dAxons=6392; %axons/mm2 
        
        %Determining and assigning the diameter value based on statistical values.
        %The data is from research done by H.S.D. Garven et al. in the Scottish Medical Journal 7:250-265, 1962
        % these diamters pertain to the human posterior tibial nerve. Note, fibers <4 um were grouped into the 4 um group
        % These diameter values are confirmed to be able to be used for sensory afferents (kandel &
        %schwartz-Principles of neuroscience)
        
        diameter_range = [5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15]; %(um)
        occurrences = [476, 472, 811, 1359, 1932, 1236, 501, 174, 17, 4, 4]; %%distribution of diameters--> can find in text book
        
        %Normalize occurences
        occurrences= occurrences./sum(occurrences);
        %iterate through the fascicles
        allaxons.diam=[];
        allaxons.nodeX=[];
        allaxons.nodeY=[];
        
        currAxon=1;
        
        %start plotting
        figure; hold on
        load([NerveNameString '_CircBuff FINE 1.5x10 mm ReshapeProcessedDetails.mat']);
        plot(handles.output.FINE.CurrentVertices(:,1),handles.output.FINE.CurrentVertices(:,2),'k','LineWidth',2);
        title([NerveNameString ' fasciclemap']);
        
        for i = 1:numfascicles 
            %calculate the number of axons in the fascicle
            fasc_area = pi*fasc_coords(i,3)^2; %mm^2 axon are all inside ENDOneurium
            nAxons=round(dAxons*fasc_area);
            fasciclesfinal{1,i}.nAxons=nAxons;
            fasciclesfinal{1,i}.fasc_area=fasc_area;
            
            %plot fascicle boundaries;
            fasciclesfinal{1,i}.vertices = [fasc_coords(i,3).*cos(circ_theta)+fasc_coords(i,1),fasc_coords(i,3).*sin(circ_theta)+fasc_coords(i,2)]; %endoneurium
            plot(fasciclesfinal{1,i}.vertices(:,1),fasciclesfinal{1,i}.vertices(:,2),'k','LineWidth',1.5);
            PeriVertices = [fasc_coords(i,6).*cos(circ_theta)+fasc_coords(i,4),fasc_coords(i,6).*sin(circ_theta)+fasc_coords(i,5)];
            plot(PeriVertices(:,1),PeriVertices(:,2),'k','LineWidth',1.5);
            
            %store the fascicle centroid 
            fasciclesfinal{1,i}.centroid = fasc_coords(i,1:2); %mm
            
            %generate random axons within the fascicle, plot and store their
            %information
            xc = fasciclesfinal{1,i}.centroid(1);
            yc = fasciclesfinal{1,i}.centroid(2);
            
            %randomly distribute the axons in the fascicle
            %first determine where the voltage field data and restrict all
            %axons to be inside of bounds of voltage field within fascicle
            %to avoid edge effects
            %can open an arbitrary V fld file just to get x,y coordinates.
            %Will NOT actually use any voltages in this function
            Vflddata = importdata([NerveNameString '_VoutCathode1Fascicle' num2str(i) '.fld']); %m
            Vflddata.data(:,1:3) = Vflddata.data(:,1:3)*1000; %convert to mm
            VX = Vflddata.data(:,1);
            VY = Vflddata.data(:,2);
            %find which grid points are inside fascicle
            [IN, ON] =inpolygon(VX,VY,fasciclesfinal{1,i}.vertices(:,1),fasciclesfinal{1,i}.vertices(:,2));
            IN(ON==1)=0;
            newx=VX(IN);
            newy=VY(IN);
            %make a new boundary
            bpts=convhull(newx,newy);
            temp_x=newx(bpts);
            temp_y=newy(bpts);
            
            
            %then distribute the axons (due to redrawing the boundary to
            %account for Vfield interpolation issue, fascicle is no longer
            %perfectly circular
            x=[];
            y=[];
            while (length(x)<nAxons)
            genx=rand(1,nAxons)*(max(temp_x)-min(temp_x))+min(temp_x);
            geny=rand(1,nAxons)*(max(temp_y)-min(temp_y))+min(temp_y);
            [IN, ON]=inpolygon(genx,geny,temp_x,temp_y);
            IN(ON==1)=0;
            x=[x genx(IN)];
            y=[y geny(IN)];
            end
            x=x(1,1:nAxons);
            y=y(1,1:nAxons);
            
            %save out to axon matrix
            allaxons.nodeX=[allaxons.nodeX repmat(x,21,1)];
            allaxons.nodeY=[allaxons.nodeY repmat(y,21,1)];
            
            %select diameters randomly from the diameter ranges expected,
            %with weightings given by "occurrences"
            allaxons.diam=[allaxons.diam randsample(diameter_range, nAxons, true, occurrences)];
            %to make all axons have a diameter of 10 um!!!!!
            %allaxons.diam=[allaxons.diam 10*ones(1,nAxons)];
                
            
            %store axon information into struct; this includes location and
            %randomly generated axon diameter according to statistical values
            for j = 1:nAxons
                fasciclesfinal{1,i}.axons{1,j}.location(1,1) = x(j);
                fasciclesfinal{1,i}.axons{1,j}.location(1,2) = y(j);
%                 fasciclesfinal{1,i}.axons{1,j}.diameter = randsample(diameter_range, 1, true, occurrences);
                fasciclesfinal{1,i}.axons{1,j}.diameter=allaxons.diam(currAxon+j-1);
                
                diam = fasciclesfinal{1,i}.axons{1,j}.diameter; %single diameter for a single fiber
                
                %determine nodalspacing based on diameter
                nodeSpace = 100 * diam /1000; % ask emily about this equation--> 10 * Diam || Diam/ 10(?) (Confirm--> Kendall & Schwartz)
                %determine length of total axon
                fasciclesfinal{1,i}.axons{1,j}.length = 20*nodeSpace; %determine and store axon length - should be 20 so that you have 21 nodes!!
                L_axon = fasciclesfinal{1,i}.axons{1,j}.length;
                
                %determine the sign of the nodeOffset
                if rand(1,1)>0.5
                    sign=1;
                else
                    sign=-1;
                end
                %calculate nodeOffset: -nodeSpace/2<nodeOffset<nodeSpace/2
                fasciclesfinal{1,i}.axons{1,j}.nodeOffset = sign*rand(1,1) * nodeSpace/2; %store nodal offset variable into struct
                % to make the node offsets all 0!!!
                % fasciclesfinal{1,i}.axons{1,j}.nodeOffset = 0;
                nodeOffset = fasciclesfinal{1,i}.axons{1,j}.nodeOffset;
                
                
                fasciclesfinal{1,i}.axons{1,j}.halflength = (-1 * (L_axon / 2)); % Why is this it negative?determine and store half offset- Why is this needed?
                
                %calculate Z points for each node
                Ztemp=[(fasciclesfinal{1,i}.axons{1,j}.halflength+nodeOffset):nodeSpace:(abs(fasciclesfinal{1,i}.axons{1,j}.halflength)+nodeOffset)]';
                %organize node coordinates into one field
                fasciclesfinal{1,i}.axons{1,j}.nodelocation(:,1)=x(j).*ones(length(Ztemp),1);
                fasciclesfinal{1,i}.axons{1,j}.nodelocation(:,2)=y(j).*ones(length(Ztemp),1);
                fasciclesfinal{1,i}.axons{1,j}.nodelocation(:,3)=Ztemp;
                
                allaxons.nodeZ(:,currAxon+j-1)=Ztemp;
                
            end
            currAxon=currAxon+nAxons;
        end
        
        %plot axons (scatter point size = f(diameter)
        scatter_point_colors = varycolor(length(diameter_range));
        for i = 1:length(diameter_range)
            axoninds = find(allaxons.diam == diameter_range(i));
            scatter(allaxons.nodeX(1,axoninds),allaxons.nodeY(1,axoninds),2,'MarkerEdgeColor',scatter_point_colors(i,:));
        end
        axis equal 
        drawnow
        filename=[NerveNameString '_fascicle_axon_map_noV.mat'];
        %save(filename,'fasciclesfinal');
    end