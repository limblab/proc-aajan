% This  subfunction loads and modifies a given struct (fasciclesfinal & nerve final) to
% generate and add anatomical information on sensory nerve fibers within
% the fascicle. The function assigns locations of the fibers in the
% fascicles and these locations can then be plotted to provide a visual of
% the nerve fiber. Additional anatomical information assigned to the nerve
% fiber includes diameter (based on statistical values),length, and nodal
% spacing/offset

    function [fasciclesfinal, final_nerve, allaxons] = GenerateNervePopulation(contact)
        %load mat file that contains vertices of nerve and fascicles
        load('M19T1_Encap_CircBuff FINE 1.5x10 mm ReshapeProcessedDetails.mat')
        
        %define directory to save results in
        outdir='D:\ICNerveModels\Median19Frame1Modeling\Encapsulation\Activation';
        
        %Load matrix of randomly assigned diameters (statistically determined).
        % Matrix is the length of the number of fascicles in the .mat file x nAxons
        % generated

        %Verdu 2000 - review of studies on axon density
        %average axon density of myelinated fibers reported in the 3
        %studies cited (1 tibial anterior, 2 sural nerve) for humans aged
        %40-59 is 6392 axons/mm2
        %axon density appears to depend on age, and there is high
        %variability even between fascicles in the same subject
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
        
        %load in field
        imagenameGA='M17D501Rscale';
        C1char=num2str(contact);
        defaultdir=pwd;
        imagedir='C:\Users\Emily\Documents\MATLAB\Modeling\workingfolder_project\M17D501RscaleFLD';
        cd(imagedir)
        %         cd(strcat(dname,'\',imagenameGA,'FLD'))
        vfldfile=[imagenameGA 'contact' C1char 'VoltendoALL.fld'];
        newData1=importdata(vfldfile);
        %         eval(strcat('newData1=importdata(''',imagenameGA, 'contact',C1char ,'VoltendoALL.fld'')'));
        newdata=newData1.data;
        alldataC1{1}=newdata(:,1);
        alldataC1{2}=newdata(:,2);
        alldataC1{3}=newdata(:,3);
        alldataC1{4}=newdata(:,4);
        clear newdata;
        cd(defaultdir);
        
%         %plot voltage field in space
%         z0ind=find(alldataC1{3}==0);
%         figure
%         hold on
% %         plot(alldataC1{1}(z0ind),alldataC1{2}(z0ind),'x');
%         scatter(alldataC1{1}(z0ind)*1000,alldataC1{2}(z0ind)*1000,5,alldataC1{4}(z0ind),'fill');
%         
%          for k=1:length(fasciclesfinal)
%             temp_x = fasciclesfinal{1,k}.verticies(:,1);
%             temp_y = fasciclesfinal{1,k}.verticies(:,2);
%             plot(temp_x',temp_y','k',[temp_x(1) temp_x(length(temp_x))],[temp_y(1) temp_y(length(temp_y))],'k','LineWidth',2)
% %             scatter(temp_x',temp_y','k','fill')
%          end
%         colorbar;
%         axis equal
% % 
% %                 x = final_nerve(:,1);
% %                 y = final_nerve(:,2);
% %                 plot(x',y','b',[x(1) x(length(x))], [y(1) y(length(y))],'b','LineWidth',3)
% %                 xlabel('X distance (mm)','FontSize',14)
% %                 ylabel('Y distance (mm)','FontSize',14)
% %                 scatter(alldataC1{1}(z0ind),alldataC1{2}(z0ind),5,alldataC1{4}(z0ind),'fill');
% %         axis equal
%         hold off
        
        %prep to iterate through the fascicles
        onefas=12100;
        fascount=1;
        
        %iterate through the fascicles
        allaxons.diam=[];
        allaxons.nodeX=[];
        allaxons.nodeY=[];
        
        currAxon=1;
        
        for i = 1:length(fasciclesfinal)
            
            %calculate the number of axons in the fascicle
            fasc_area=polyarea(fasciclesfinal{1,i}.verticies(:,1),fasciclesfinal{1,i}.verticies(:,2));
            nAxons=round(dAxons*fasc_area);
            fasciclesfinal{1,i}.nAxons=nAxons;
            fasciclesfinal{1,i}.fasc_area=fasc_area;
            
            %select the correct segments of the .fld file
            GridXC1=alldataC1{1}(fascount:(fascount+(onefas-1)));
            GridXC1=GridXC1*1000;
            GridXC1=unique(GridXC1);
            
            GridYC1=alldataC1{2}(fascount:(fascount+(onefas-1)));
            GridYC1=GridYC1*1000;
            GridYC1=unique(GridYC1);
            
            GridZC1=alldataC1{3}(fascount:(fascount+(onefas-1)));
            GridZC1=GridZC1*1000;
            GridZC1=unique(GridZC1);
            
            VGridC1=alldataC1{4}(fascount:(fascount+(onefas-1)));
            VGridC1=-1*abs(VGridC1); %MAKE SURE POLARITY IS CORRECT IN SUBSEQUENT MANIPULATIONS
            VGridC1=reshape(VGridC1,10,length(VGridC1)/10);
            VGridC1=reshape(VGridC1,10,10,length(GridZC1));
            
%             VGridC1=reshape(length(GridXC1),length(GridYC1),length(GridZC1));
            
            
            
%             %plot the fascicle
            temp_x = fasciclesfinal{1,i}.verticies(:,1);
            temp_y = fasciclesfinal{1,i}.verticies(:,2);
            
            %determine minimum distance to epineurium
            fvertall=repmat(fasciclesfinal{1,i}.verticies,40,1);
            nvertall=reshape(repmat(reshape(final_nerve,80,1),1,size(fasciclesfinal{1,i}.verticies,1))',size(fasciclesfinal{1,i}.verticies,1)*40,2);
            vertdist=sqrt((fvertall(:,1)-nvertall(:,1)).^2 + (fvertall(:,2)-nvertall(:,2)).^2);
            fasciclesfinal{1,i}.epidistance=min(vertdist);
            
%                         plot(temp_x',temp_y','b',[temp_x(1) temp_x(length(temp_x))],[temp_y(1) temp_y(length(temp_y))],'b','LineWidth',2)
%             
            %calculate the fascicle "centroid" and store in struct
            fasciclesfinal{1,i}.centroid = [min(temp_x) + (max(temp_x) - min(temp_x))/2 min(temp_y) + (max(temp_y)- min(temp_y))/2];
            
%             %generate random axons within the fascicle, plot and store their
%             %information
%             xc = fasciclesfinal{1,i}.centroid(1);
%             yc = fasciclesfinal{1,i}.centroid(2);
%             
%             %for now, generate random points within a fascicle using polar coordinates.
%             %   %The radius will be in range of the minimum distance from the centroid to
%             %   %an edge
%             %calculate the distance of each vertex to the centroid
%             hyp=sqrt(((temp_x-xc).^2)+((temp_y-yc).^2));
%             radius=min(hyp); %take the minimum distance as the radius of the circle
%             %             radius = min([min(temp_x) - xc, min(temp_y) - yc]);
%             theta = 2*pi*rand(1,nAxons);
%             r = sqrt(rand(1,nAxons))*radius;
%             x = xc + r.*cos(theta);
%             y = yc + r.*sin(theta);
            
            %randomly distribute the axons in the fascicle
            
            %first determine where the voltage field data and restrict all
            %axons to be inside of bounds of voltage field within fascicle
            %to avoid edge effects
            allX=repmat(GridXC1,length(GridYC1),1);
            allY=sort(repmat(GridYC1,length(GridXC1),1));
            %find which grid points are inside fascicle
            [IN, ON] =inpolygon(allX,allY,temp_x,temp_y);
            IN(ON==1)=0;
            newx=allX(IN);
            newy=allY(IN);
            %make a new boundary
            bpts=convhull(newx,newy);
            temp_x=newx(bpts);
            temp_y=newy(bpts);
            
            
            %then distribute the axons
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
%             allaxons.diam=[allaxons.diam 10*ones(1,nAxons)];
                
            
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
%                 fasciclesfinal{1,i}.axons{1,j}.nodeOffset = 0;
                
                nodeOffset = fasciclesfinal{1,i}.axons{1,j}.nodeOffset;
                
                
                fasciclesfinal{1,i}.axons{1,j}.halflength = (-1 * (L_axon / 2)); % Why is this it negative?determine and store half offset- Why is this needed?
                
                %calculate Z points for each node
                Ztemp=[(fasciclesfinal{1,i}.axons{1,j}.halflength+nodeOffset):nodeSpace:(abs(fasciclesfinal{1,i}.axons{1,j}.halflength)+nodeOffset)]';
                %organize node coordinates into one field
                fasciclesfinal{1,i}.axons{1,j}.nodelocation(:,1)=x(j).*ones(length(Ztemp),1);
                fasciclesfinal{1,i}.axons{1,j}.nodelocation(:,2)=y(j).*ones(length(Ztemp),1);
                fasciclesfinal{1,i}.axons{1,j}.nodelocation(:,3)=Ztemp;
                
                allaxons.nodeZ(:,currAxon+j-1)=Ztemp;
                
                %interpolate to find the voltages at the node coodinates
                IVARVC=interpn(GridYC1,GridXC1,GridZC1, VGridC1, fasciclesfinal{1,i}.axons{1,j}.nodelocation(:,2), fasciclesfinal{1,i}.axons{1,j}.nodelocation(:,1), fasciclesfinal{1,i}.axons{1,j}.nodelocation(:,3));
                fasciclesfinal{1,i}.axons{1,j}.nodeV(:,1)=IVARVC; %save to structure
                
                %save out to axon matrix
                allaxons.nodeV(:,currAxon+j-1)=IVARVC;
            end
            %set new index for next fascicle
            fascount=fascount+onefas;
            currAxon=currAxon+nAxons;
        end
        
        uniquenum=555;
        filename=[outdir '\fascicle_axon_map' imagenameGA 'pop' num2str(uniquenum) '.mat'];
        save(filename,'fasciclesfinal');
    end