function Step0_PositionAndInterpolate()

FascFolders={'RadialFascDist','ClustFasc'};
%ArteryFolders={'No Artery','Artery'};
ArteryFolders={'Artery'}; %for models with swept arterial conductance, there has to be an artery
DistanceFolders=[0.5,1,2,3,4,5];
Sigma=0.34;

for layout=1:length(FascFolders)
    FascFolder=FascFolders{layout};
    clear Fascicles AxonPositionsRelativeToCenter
    
    CollectFascicleInformation=1;
    target_fasc_file=['../../FascicleLocations/For' FascFolder 'Models.mat'];
    if exist(target_fasc_file)
        load(target_fasc_file);
        CollectFascicleInformation=0;
    end
    
    CalculateAxonPositions=1;
    target_axon_file=['../../AxonPositions/For' FascFolder 'Models.mat'];
    if exist(target_axon_file)
        load(target_axon_file);
        CalculateAxonPositions=0;
    end
    
    for artery=1:length(ArteryFolders)
        ArteryFolder=ArteryFolders{artery};
        
        for distance_index=1:length(DistanceFolders)
            
            for cathode=1:4
                
                for temp_fascicle=1:20
                    target_Ve_folder=['../../ExportedVoltages/SweptArterialWall/Sigma=' num2str(Sigma) '/' FascFolder '/C-A D=' num2str(DistanceFolders(distance_index)) 'mm/' ArteryFolder '/OddSymmetry/'];
                    target_Ve_file=[target_Ve_folder 'C-A' num2str(cathode) ',F' num2str(temp_fascicle) '.fld'];
                    
                    if cathode==1 && distance_index==1 && artery==1
                        %Collect information about the fascicle, in mm
                        if CollectFascicleInformation
                            [CenterX,CenterY,Diameter,Units] = GatherFascInfo(target_Ve_file);
                            Fascicles.(['Endo' num2str(temp_fascicle)]).CenterX=CenterX;
                            Fascicles.(['Endo' num2str(temp_fascicle)]).CenterY=CenterY;
                            Fascicles.(['Endo' num2str(temp_fascicle)]).Diameter=Diameter;
                            Fascicles.(['Endo' num2str(temp_fascicle)]).Units=Units;
                        end
                        
                        %Randomly position axons (relative to the center of the
                        %fascicle, but want the same axon diameters and
                        %positions across all models
                        if CalculateAxonPositions
                            [X,Y,Z,Diameter,Units] = PositionAxons(Fascicles,temp_fascicle);
                            AxonPositionsRelativeToCenter.(['Endo' num2str(temp_fascicle)]).X=X;
                            AxonPositionsRelativeToCenter.(['Endo' num2str(temp_fascicle)]).Y=Y;
                            AxonPositionsRelativeToCenter.(['Endo' num2str(temp_fascicle)]).Z=Z;
                            AxonPositionsRelativeToCenter.(['Endo' num2str(temp_fascicle)]).Diameter=Diameter;
                            AxonPositionsRelativeToCenter.(['Endo' num2str(temp_fascicle)]).Units=Units;
                        end
                    end
                    
                    
                    %Interpolate Voltages along the axons
                    Vi.(['Endo' num2str(temp_fascicle)])=InterpolateVoltages(Fascicles,AxonPositionsRelativeToCenter,target_Ve_file,temp_fascicle);
                end
                
                %save the Node of Ranvier voltages for this model
                target_Vi_folder=['../../InterpolatedVoltages/SweptArterialWall/Sigma=' num2str(Sigma) '/' FascFolder '/C-A D=' num2str(DistanceFolders(distance_index)) 'mm/' ArteryFolder '/OddSymmetry/'];
                target_Vi_file=[target_Vi_folder 'C-A' num2str(cathode) '.mat']
                save(target_Vi_file,'Vi');
                clear Vi
            end
        end
    end
    
    %save the fascicle location data, which does not depend on C-A
    %distance, active C-A pair, or presence of an artery, but does depend on
    %fascicle number and fascicle clustering
    if ~exist(target_fasc_file,'file')
        save(target_fasc_file,'Fascicles');
    end
    
    %save the axon location data, which does not depend on C-A
    %distance, active C-A pair, or presence of an artery, but does depend on
    %fascicle number and fascicle clustering
    if ~exist(target_axon_file,'file')
        save(target_axon_file,'AxonPositionsRelativeToCenter');
    end
end
end

function [CenterX,CenterY,Diameter,Units] = GatherFascInfo(filename)
%open the target file
fid = fopen(filename,'r');

%get headerline with details about the fascicle
headerline1=fgets(fid);

%close the file
fclose(fid);

%header line format will be something like:
%Grid Output Min: [x_minmm y_minmm z_minmm] Max: [x_maxmm y_maxmm z_maxmm] Grid Size: [xmm ymm zmm]

%parse info
open_bracket=strfind(headerline1,'[');
close_bracket=strfind(headerline1,']');

locs=[];
for i=1:2
    tempstr=headerline1(open_bracket(i)+1:close_bracket(i)-1);
    mm=strfind(tempstr,'mm');
    x=tempstr(1:mm(1)-1);
    y=tempstr(mm(1)+3:mm(2)-1);
    z=tempstr(mm(2)+3:mm(3)-1);
    
    locs(i,:)=[str2num(x),str2num(y),str2num(z)];
end

CenterX=mean(locs(:,1));
CenterY=mean(locs(:,2));
Diameter=locs(2,1)-locs(1,1);
Units='mm'; %should confirm this
end

function [X,Y,Z,Diameter,Units] = PositionAxons(Fascicles,temp_fascicle)
%PositionAxons() randomly selects the location of axons within each fascicle
%and saves this data relative to the center of the fascicle
%Input:
%   Fascicles: contains the center X, center Y, and diameter of each
%   fascicle in the model

%SET THESE FIRST
total_axons=100; %per fascicle

%Axons values
num_of_nodes=81;
node_length=1; %(um)


temp_radius=rand(total_axons,1)*Fascicles.(['Endo' num2str(temp_fascicle)]).Diameter/2*.90*1000; %(mm->um)
%.90 ensures axons are inside a polyhedron-shaped fascicle that
%approximates round AND makes sure that all axons are within the
%intrafascicular grid to make sure that axons don't end up with
%interpolated voltages that are thrown off by extrafascicular voltages
%in the grid

temp_angle=rand(total_axons,1)*2*pi; %radians

X=temp_radius.*cos(temp_angle); %(um)
Y=temp_radius.*sin(temp_angle); %(um)
Z=[];

%------------------------------------------------------------------
%assign diameters
%Data from:
%   Prechtl et al 1987, Figure 5e, Rat vagal nerve
diameter_range = [2:0.2:5]; %note, all diameters <2 were grouped into 2; in (um)
occurences = [0.3, 0.17, 0.15, 0.08, 0.05, 0.04, 0.03, 0.02, 0.02, 0.02, 0.01, 0.01, 0.02, 0.03, 0.03, 0.02]; %must sum to 1
cum_occurrances=[];
for o_index = 1:length(occurences)
    cum_occurences(o_index)=sum(occurences(1:o_index));
end
occurences=cum_occurences;
occurences=round(occurences.*10000)./10000;  %make sure there aren't small numerical errors

random_diameters=[];
for i=1:total_axons
    random_diameters(i)=diameter_range(find(occurences>=rand(),1)); %choose a random number and determine where it falls in the cumulative percentage
end
%histogram(random_diameters)

%save info
Diameter=random_diameters';


%OUTPUT: random_diameters has N (typically 100) random FIBER diameters (um) that follow the
%published distrbibutions depending on fiber type.
%------------------------------------------------------------------


%------------------------------------------------------------------
%calculate the internode distance
%Generally, IL = 100*fiber diameter.  However,
%I am using the McIntyre, Richardson, and Grill Double Cable model.
%There is a node, paranode1 (MYSA), paranode2 (FLUT), and internode
%node length = 1, paranode 1 length = 3, the other two are
%functions of the fiber diameter.  The following equations were
%determined in Excel based on fitting a curve to the data presented
%in the McIntyre et al (2002) paper.  My IL = his deltax.
%This is an adaptation by fitting a curve to the data presented in this
%paper.
deltax = 2.40101843./(0.001593549+0.032342282*exp(-0.412857551*(random_diameters)))+0.815495319;
IL=deltax; %(um)
%------------------------------------------------------------------


%------------------------------------------------------------------
%create dummy NoR positions starting at 0 for Node 1
NoR_z_points=zeros(num_of_nodes,total_axons);
for col=1:total_axons
    NoR_z_points(:,col)=[0:IL(col):(num_of_nodes-1)*IL(col)]'; %(um)
end
%------------------------------------------------------------------


%------------------------------------------------------------------
%randomly calculate the offset of the center node
%offset can be between -IL/2 and IL/2
offset = [];
offset = rand(size(random_diameters)).*IL-(IL/2);  %(um)
%------------------------------------------------------------------

%------------------------------------------------------------------
%set so the midpoint is at 0
NoR_z_points=NoR_z_points-repmat(mean(NoR_z_points),num_of_nodes,1);

%subtract the random offset
NoR_z_points=NoR_z_points-repmat(offset,num_of_nodes,1);


%OUTPUT: NoR_z_points is a [num_of_nodes x num_of_random_axons] in (um)
%matrix where the nodes of ranvier are for each randomly positioned fiber


%save info
Z=NoR_z_points;
Units='um';
end

function Vi=InterpolateVoltages(Fascicles,AxonPositionsRelativeToCenter,filename,temp_fascicle)
total_axons=length(AxonPositionsRelativeToCenter.(['Endo' num2str(temp_fascicle)]).X);

center_point(1)=Fascicles.(['Endo' num2str(temp_fascicle)]).CenterX.*1000; %(mm->um) X-position
center_point(2)=Fascicles.(['Endo' num2str(temp_fascicle)]).CenterY.*1000; %(mm->um) Y-position


temp_AxonPositions=AxonPositionsRelativeToCenter.(['Endo' num2str(temp_fascicle)]); %(um)
temp_AxonPositions.X=temp_AxonPositions.X+center_point(1); %(um)
temp_AxonPositions.Y=temp_AxonPositions.Y+center_point(2); %(um)
temp_AxonPositions.Z=temp_AxonPositions.Z';                 %(um)



%obtain Ansoft-exported voltages for this fascicle and
%put in a usable matrix form
% determine if the input is completely numeric.  Sometimes ANSOFT
% puts in a value of '-NoSoln-'
tempdata = checkinput_1column(filename); %(m),(m),(m),(V)
tempdata(:,1:3)=tempdata(:,1:3)*1000; %(m->mm)
tempdata(:,4)=tempdata(:,4)*1000; %(V->mV)
tempdata(:,4)=abs(tempdata(:,4))*-1; %force positive z-space to cathode in case of sign loss/change


%models only went from 0 to 30. Need to flip the data to go from -30 to 30
%tempdata=[flipud(tempdata(2:end));tempdata]; %don't repeat z=0  
junk=tempdata(1:end,:); %copy into junk variaable
junk(junk(:,3)==0,:)=[]; %don't need z=0
junk(:,3)=junk(:,3)*-1; %negative z-space
junk(:,4)=abs(junk(:,4)); %force negative z-space to anode
tempdata=[junk;tempdata];
tempdata=sortrows(tempdata,[1 2 3]); %need to go X1,Y1,Z1-end, X1,Y2,Z1-end, ..., Xend,Yend,Z1-end

%Ansoft can report very small (1e-13) differences in location and
%if I search for unique positions, I will report what appears to be
%the same location but is, in fact, off by a very small amount.  I
%do NOT want to record x and x+1e-13 as unique positions.
tempdata(:,1:3)=(round(tempdata(:,1:3).*100000)./100000);
%at this point, tempdata is in (mm, mm, mm, mV)

% V is a single column, so I need to reshape it
% V MUST originally be in the format [x1y1z1,x1y1z2,...,x1y1zn...x1ynzn,x2y1z1,...xnynzn]
V_reshaped= permute(reshape(tempdata(:,4),length(unique(tempdata(:,3))),length(unique(tempdata(:,1))),length(unique(tempdata(:,2)))),[2,3,1]);
%V_reshaped is in mV


% x, y, z known data:
% x: unique_x
% y: unique_y
% z: unique_z
% V known data: X=1:N, Y=1:M, Z=1:P where [M,N,P]=SIZE(V):
% xi, yi, zi, is the points at which to interpolate the voltage
% xi: rand_axon_points_x
% yi: rand_axon_points_y
% zi: NoR_points
% Vi: Voltage at the interpolated locations
Vi = zeros(total_axons,length(temp_AxonPositions.Z(1,:)));
%{ 
test: 
xs=unique(tempdata(:,1));
ys=unique(tempdata(:,2));
index=find(tempdata(:,1)==xs(10) & tempdata(:,2)==ys(10))
Vi=interp3(unique(tempdata(:,1)).*1000, unique(tempdata(:,2)).*1000, unique(tempdata(:,3)).*1000, V_reshaped,  xs(10)*1000,  ys(10)*1000,  tempdata(index,3)*1000,'linear',NaN);  %(mm->um), (mm->um), (mm->um), (mV), (um), (um), (um))
figure
plot(tempdata(index,3),reshape(Vi,[],1))

make sure Vi below goes to 0 for a Diameter of 2
index2=find(AxonPositionsRelativeToCenter.Endo1.Diameter==2);
row=index2(1);
Vi= interp3(unique(tempdata(:,1)).*1000, unique(tempdata(:,2)).*1000, unique(tempdata(:,3)).*1000, V_reshaped,  temp_AxonPositions.X(row),  temp_AxonPositions.Y(row),  temp_AxonPositions.Z(row,:),'linear',NaN);  %(mm->um), (mm->um), (mm->um), (mV), (um), (um), (um))
figure
plot(temp_AxonPositions.Z(row,:),reshape(Vi,[],1));
hold on
plot([min(temp_AxonPositions.Z(row,:)) max(temp_AxonPositions.Z(row,:))],[0 0],'k-')

make sure Vi does not get NaN for a Diameter of 5
index5=find(AxonPositionsRelativeToCenter.Endo1.Diameter==5);
row=index5(1);
Vi= interp3(unique(tempdata(:,1)).*1000, unique(tempdata(:,2)).*1000, unique(tempdata(:,3)).*1000, V_reshaped,  temp_AxonPositions.X(row),  temp_AxonPositions.Y(row),  temp_AxonPositions.Z(row,:),'linear',NaN);  %(mm->um), (mm->um), (mm->um), (mV), (um), (um), (um))
figure
plot(temp_AxonPositions.Z(row,:),reshape(Vi,[],1));
hold on
plot([min(temp_AxonPositions.Z(row,:)) max(temp_AxonPositions.Z(row,:))],[0 0],'k-')

%}
for row=1:total_axons
    Vi(row,:)= interp3(unique(tempdata(:,1)).*1000, unique(tempdata(:,2)).*1000, unique(tempdata(:,3)).*1000, V_reshaped,  temp_AxonPositions.X(row),  temp_AxonPositions.Y(row),  temp_AxonPositions.Z(row,:),'linear',NaN);  %(mm->um), (mm->um), (mm->um), (mV), (um), (um), (um))
end
Vi=single(Vi);

if any(isnan(Vi(:)))
    disp('There''s a NaN in here somewhere!');
    keyboard
end

end

% ====================================================
%      begin supporting subfunctions
% ====================================================
function tempdata = checkinput_1column(filename)
%CHECKINPUT reads the ANSOFT file and determines if ANSOFT placed the error
%'No Solution' in the voltage column instead of an actual voltage.  If so,
%this function interpolates or extrapolates a voltage to put at that
%position.  It is likely that 'No Solution' occurred b/c the voltage was
%exporeted for an object that was not "solved inside" (most likely the
%silicone housing).
%
%Expected output:  [x, y, z, volts] units are in (m), (m), (m), (mV)

%UPDATED: 21 Aug 2017

fid = fopen(filename,'r');

headerline1=fgets(fid);
headerline2=fgets(fid);

%Need to use data in headerline1 and headerline2 to determine
%x,y,z,dx,dy,dz,and voltage


%deterimine if every value in column 1 is a number
alldata = [];

try
    tempdata = textscan(fid,'%n');
    tempdata=cell2mat(tempdata);
    if any(isnan(tempdata))
        disp('NaN found.  Copy code below to build 3D matrix, then run inpaint_nans3.')
        keyboard
    end

    %construct x, y, and z based on info in the headerline
    open_bracket=strfind(headerline1,'[');
    close_bracket=strfind(headerline1,']');
    
    mins=headerline1(open_bracket(1):close_bracket(1));
    maxs=headerline1(open_bracket(2):close_bracket(2));
    deltas=headerline1(open_bracket(3):close_bracket(3));
    
    spaces=strfind(mins,' ');
    minX=mins(2:spaces(1)-1);
    minY=mins(spaces(1)+1:spaces(2)-1);
    minZ=mins(spaces(2)+1:end-1);
    [minX,minY,minZ]=fixunits(minX,minY,minZ);
    
    spaces=strfind(maxs,' ');
    maxX=maxs(2:spaces(1)-1);
    maxY=maxs(spaces(1)+1:spaces(2)-1);
    maxZ=maxs(spaces(2)+1:end-1);
    [maxX,maxY,maxZ]=fixunits(maxX,maxY,maxZ);
    
    spaces=strfind(deltas,' ');
    deltaX=deltas(2:spaces(1)-1);
    deltaY=deltas(spaces(1)+1:spaces(2)-1);
    deltaZ=deltas(spaces(2)+1:end-1);
    [deltaX,deltaY,deltaZ]=fixunits(deltaX,deltaY,deltaZ);

    x=minX:deltaX:maxX;
    y=minY:deltaY:maxY;
    z=minZ:deltaZ:maxZ;
    
    Z=repmat(z(:),length(x)*length(y),1);
    Y=repmat(reshape(repmat(y(:)',length(z),1),[],1),length(x),1);
    X=reshape(repmat(x(:)',length(y)*length(z),1),[],1);
    
    if (length(X) ~= length(Y) || ...
            length(X) ~= length(Z) || ...
            length(Y) ~= length(Z) || ...
            length(X) ~= length(tempdata) || ...
            length(X) ~= length(tempdata) || ...
            length(Y) ~= length(tempdata))
        disp('Inconsistent dimensions')
        keyboard
    else
        tempdata=[X,Y,Z,tempdata];
    end
catch
    disp(['Reading ' filename ' was not successful'])
    keyboard
end

clear Solutions
fclose(fid);

end

function tempdata = checkinput_4columns(filename)
%CHECKINPUT reads the ANSOFT file and determines if ANSOFT placed the error
%'No Solution' in the voltage column instead of an actual voltage.  If so,
%this function interpolates or extrapolates a voltage to put at that
%position.  It is likely that 'No Solution' occurred b/c the voltage was
%exporeted for an object that was not "solved inside" (most likely the
%silicone housing).

%UPDATED: 23 NOV 2009

fid = fopen(filename,'r');

headerline1=fgets(fid);
headerline2=fgets(fid);


%deterimine if every value in column 4 is a number
alldata = [];

try
    tempdata = textscan(fid,'%n%n%n%n');
    tempdata=cell2mat(tempdata);
    if ~isemtpy(find(isnan(tempdata)==1))
        disp('NaN found.  Copy code below to build 3D matrix, then run inpaint_nans3.')
        keyboard
    end

catch
    fclose(fid);
    fid = fopen(filename,'r');
    
    headerline1=fgets(fid);
    headerline2=fgets(fid);
    
    
    %deterimine if every value in column 4 is a number
    alldata = [];
    alldata = textscan(fid,'%n%n%n%s','CommentStyle',{'Solution'});
    
    
    %find the number of unique x locations
    unique_x = [];
    unique_x = alldata{1};
    unique_x = unique(unique_x);
    
    %find the number of unique y locations
    unique_y = [];
    unique_y = alldata{2};
    unique_y = unique(unique_y);
    
    %find the number of unique z locations
    unique_z = [];
    unique_z = alldata{3};
    unique_z = unique(unique_z);
    z_list=alldata{3};
    
    
    %grab voltages and put them in a 3D matrix
    Solutions=[];
    for i=1:length(unique_z)
        z_plane = find(z_list==unique_z(i));
        
        for j=1:length(z_plane)
            x_index=alldata{1}(z_plane(j));
            x_index=find(unique_x==x_index);
            
            y_index=alldata{2}(z_plane(j));
            y_index=find(unique_y==y_index);
            
            z_index=alldata{3}(z_plane(j));
            z_index=find(unique_z==z_index);
            
            if (strcmp(cell2mat(alldata{4}(z_plane(j))),'No'))
                Solutions(x_index,y_index,z_index)=NaN;
            else
                Solutions(x_index,y_index,z_index)=str2num(cell2mat(alldata{4}(z_plane(j))));
            end
        end
    end
    
    Solutions=inpaint_nans3(Solutions,1);
    
    %build tempdata
    tempdata=[];
    for i=1:length(unique_x)
        for j=1:length(unique_y)
            for k=1:length(unique_z)
                tempdata(end+1,1)=unique_x(i);
                tempdata(end,2)=unique_y(j);
                tempdata(end,3)=unique_z(k);
                tempdata(end,4)=Solutions(i,j,k);
            end
        end
    end
end

clear Solutions
fclose(fid);

end

function [X,Y,Z]=fixunits(X,Y,Z)
if strcmpi(X(end-1:end),'um')
    scale=1E-6;
    X=str2num(X(1:end-2))*scale;
elseif strcmpi(X(end-1:end),'mm')
    scale=1E-3;
    X=str2num(X(1:end-2))*scale;
elseif strcmpi(X(end),'m')
    scale=1;
    X=str2num(X(1:end-1))*scale;
else
    disp('Error interpreting X scale')
    keyboard
end

if strcmpi(Y(end-1:end),'um')
    scale=1E-6;
    Y=str2num(Y(1:end-2))*scale;
elseif strcmpi(Y(end-1:end),'mm')
    scale=1E-3;
    Y=str2num(Y(1:end-2))*scale;
elseif strcmpi(Y(end),'m')
    scale=1;
    Y=str2num(Y(1:end-1))*scale;
else
    disp('Error interpreting Y scale')
    keyboard
end

if strcmpi(Z(end-1:end),'um')
    scale=1E-6;
    Z=str2num(Z(1:end-2))*scale;
elseif strcmpi(Z(end-1:end),'mm')
    scale=1E-3;
    Z=str2num(Z(1:end-2))*scale;
elseif strcmpi(Z(end),'m')
    scale=1;
    Z=str2num(Z(1:end-1))*scale;
else
    disp('Error interpreting Z scale')
    keyboard
end


end

function B=inpaint_nans3(A,method)
% INPAINT_NANS3: in-paints over nans in a 3-D array
% usage: B=INPAINT_NANS3(A)          % default method (0)
% usage: B=INPAINT_NANS3(A,method)   % specify method used
%
% Solves approximation to a boundary value problem to
% interpolate and extrapolate holes in a 3-D array.
% 
% Note that if the array is large, and there are many NaNs
% to be filled in, this may take a long time, or run into
% memory problems.
%
% arguments (input):
%   A - n1 x n2 x n3 array with some NaNs to be filled in
%
%   method - (OPTIONAL) scalar numeric flag - specifies
%       which approach (or physical metaphor to use
%       for the interpolation.) All methods are capable
%       of extrapolation, some are better than others.
%       There are also speed differences, as well as
%       accuracy differences for smooth surfaces.
%
%       method 0 uses a simple plate metaphor.
%       method 1 uses a spring metaphor.
%
%       method == 0 --> (DEFAULT) Solves the Laplacian
%         equation over the set of nan elements in the
%         array.
%         Extrapolation behavior is roughly linear.
%         
%       method == 1 --+ Uses a spring metaphor. Assumes
%         springs (with a nominal length of zero)
%         connect each node with every neighbor
%         (horizontally, vertically and diagonally)
%         Since each node tries to be like its neighbors,
%         extrapolation is roughly a constant function where
%         this is consistent with the neighboring nodes.
%
%       There are only two different methods in this code,
%       chosen as the most useful ones (IMHO) from my
%       original inpaint_nans code.
%
%
% arguments (output):
%   B - n1xn2xn3 array with NaNs replaced
%
%
% Example:
% % A linear function of 3 independent variables,
% % used to test whether inpainting will interpolate
% % the missing elements correctly.
%  [x,y,z] = ndgrid(-10:10,-10:10,-10:10);
%  W = x + y + z;
%
% % Pick a set of distinct random elements to NaN out.
%  ind = unique(ceil(rand(3000,1)*numel(W)));
%  Wnan = W;
%  Wnan(ind) = NaN;
%
% % Do inpainting
%  Winp = inpaint_nans3(Wnan,0);
%
% % Show that the inpainted values are essentially
% % within eps of the originals.
%  std(Winp(ind) - W(ind))
% ans =
%   4.3806e-15
%
%
% See also: griddatan, inpaint_nans
%
% Author: John D'Errico
% e-mail address: woodchips@rochester.rr.com
% Release: 1
% Release date: 8/21/08

% Need to know which elements are NaN, and
% what size is the array. Unroll A for the
% inpainting, although inpainting will be done
% fully in 3-d.
NA = size(A);
A = A(:);
nt = prod(NA);
k = isnan(A(:));

% list the nodes which are known, and which will
% be interpolated
nan_list=find(k);
known_list=find(~k);

% how many nans overall
nan_count=length(nan_list);

% convert NaN indices to (r,c) form
% nan_list==find(k) are the unrolled (linear) indices
% (row,column) form
[n1,n2,n3]=ind2sub(NA,nan_list);

% both forms of index for all the nan elements in one array:
% column 1 == unrolled index
% column 2 == index 1
% column 3 == index 2
% column 4 == index 3
nan_list=[nan_list,n1,n2,n3];

% supply default method
if (nargin<2) || isempty(method)
  method = 0;
elseif ~ismember(method,[0 1])
  error 'If supplied, method must be one of: {0,1}.'
end

% alternative methods
switch method
 case 0
  % The same as method == 1, except only work on those
  % elements which are NaN, or at least touch a NaN.
  
  % horizontal and vertical neighbors only
  talks_to = [-1 0 0;1 0 0;0 -1 0;0 1 0;0 0 -1;0 0 1];
  neighbors_list=identify_neighbors(NA,nan_list,talks_to);
  
  % list of all nodes we have identified
  all_list=[nan_list;neighbors_list];
  
  % generate sparse array with second partials on row
  % variable for each element in either list, but only
  % for those nodes which have a row index > 1 or < n
  L = find((all_list(:,2) > 1) & (all_list(:,2) < NA(1))); 
  nL=length(L);
  if nL>0
    fda=sparse(repmat(all_list(L,1),1,3), ...
      repmat(all_list(L,1),1,3)+repmat([-1 0 1],nL,1), ...
      repmat([1 -2 1],nL,1),nt,nt);
  else
    fda=spalloc(nt,nt,size(all_list,1)*7);
  end
  
  % 2nd partials on column index
  L = find((all_list(:,3) > 1) & (all_list(:,3) < NA(2))); 
  nL=length(L);
  if nL>0
    fda=fda+sparse(repmat(all_list(L,1),1,3), ...
      repmat(all_list(L,1),1,3)+repmat([-NA(1) 0 NA(1)],nL,1), ...
      repmat([1 -2 1],nL,1),nt,nt);
  end

  % 2nd partials on third index
  L = find((all_list(:,4) > 1) & (all_list(:,4) < NA(3))); 
  nL=length(L);
  if nL>0
    ntimesm = NA(1)*NA(2);
    fda=fda+sparse(repmat(all_list(L,1),1,3), ...
      repmat(all_list(L,1),1,3)+repmat([-ntimesm 0 ntimesm],nL,1), ...
      repmat([1 -2 1],nL,1),nt,nt);
  end
  
  % eliminate knowns
  rhs=-fda(:,known_list)*A(known_list);
  k=find(any(fda(:,nan_list(:,1)),2));
  
  % and solve...
  B=A;
  B(nan_list(:,1))=fda(k,nan_list(:,1))\rhs(k);
  
 case 1
  % Spring analogy
  % interpolating operator.
  
  % list of all springs between a node and a horizontal
  % or vertical neighbor
  hv_list=[-1 -1 0 0;1 1 0 0;-NA(1) 0 -1 0;NA(1) 0 1 0; ...
      -NA(1)*NA(2) 0 0 -1;NA(1)*NA(2) 0 0 1];
  hv_springs=[];
  for i=1:size(hv_list,1)
    hvs=nan_list+repmat(hv_list(i,:),nan_count,1);
    k=(hvs(:,2)>=1) & (hvs(:,2)<=NA(1)) & ...
      (hvs(:,3)>=1) & (hvs(:,3)<=NA(2)) & ...
      (hvs(:,4)>=1) & (hvs(:,4)<=NA(3));
    hv_springs=[hv_springs;[nan_list(k,1),hvs(k,1)]];
  end
  
  % delete replicate springs
  hv_springs=unique(sort(hv_springs,2),'rows');
  
  % build sparse matrix of connections
  nhv=size(hv_springs,1);
  springs=sparse(repmat((1:nhv)',1,2),hv_springs, ...
     repmat([1 -1],nhv,1),nhv,prod(NA));
  
  % eliminate knowns
  rhs=-springs(:,known_list)*A(known_list);
  
  % and solve...
  B=A;
  B(nan_list(:,1))=springs(:,nan_list(:,1))\rhs;
  
end

% all done, make sure that B is the same shape as
% A was when we came in.
B=reshape(B,NA);


% ====================================================
%      end of main function
% ====================================================
end

function neighbors_list=identify_neighbors(NA,nan_list,talks_to)
% identify_neighbors: identifies all the neighbors of
%   those nodes in nan_list, not including the nans
%   themselves
%
% arguments (input):
%  NA - 1x3 vector = size(A), where A is the
%      array to be interpolated
%  nan_list - array - list of every nan element in A
%      nan_list(i,1) == linear index of i'th nan element
%      nan_list(i,2) == row index of i'th nan element
%      nan_list(i,3) == column index of i'th nan element
%      nan_list(i,4) == third index of i'th nan element
%  talks_to - px2 array - defines which nodes communicate
%      with each other, i.e., which nodes are neighbors.
%
%      talks_to(i,1) - defines the offset in the row
%                      dimension of a neighbor
%      talks_to(i,2) - defines the offset in the column
%                      dimension of a neighbor
%      
%      For example, talks_to = [-1 0;0 -1;1 0;0 1]
%      means that each node talks only to its immediate
%      neighbors horizontally and vertically.
% 
% arguments(output):
%  neighbors_list - array - list of all neighbors of
%      all the nodes in nan_list

if ~isempty(nan_list)
  % use the definition of a neighbor in talks_to
  nan_count=size(nan_list,1);
  talk_count=size(talks_to,1);
  
  nn=zeros(nan_count*talk_count,3);
  j=[1,nan_count];
  for i=1:talk_count
    nn(j(1):j(2),:)=nan_list(:,2:4) + ...
        repmat(talks_to(i,:),nan_count,1);
    j=j+nan_count;
  end
  
  % drop those nodes which fall outside the bounds of the
  % original array
  L = (nn(:,1)<1) | (nn(:,1)>NA(1)) | ...
      (nn(:,2)<1) | (nn(:,2)>NA(2)) | ... 
      (nn(:,3)<1) | (nn(:,3)>NA(3));
  nn(L,:)=[];
  
  % form the same format 4 column array as nan_list
  neighbors_list=[sub2ind(NA,nn(:,1),nn(:,2),nn(:,3)),nn];
  
  % delete replicates in the neighbors list
  neighbors_list=unique(neighbors_list,'rows');
  
  % and delete those which are also in the list of NaNs.
  neighbors_list=setdiff(neighbors_list,nan_list,'rows');
  
else
  neighbors_list=[];
end
end