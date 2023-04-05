function Interpolate_Voltages_Grid_2019()
% Intended to be run after Position_Axons_Grid_Diam_Offset_2019 by
% Process_Intermediates_2019 from ...\Toolbox\Intermediate Outputs\
%
%InterpVoltages() interpolates voltages along the axons that were randomly
%distributed using PositionAxons()
%
%
% Interpolates the voltage at each position described by
% AxonPositionsRelativeToCenter
mkdir([pwd '\InterpolatedVoltages'])

%% get list of files we're parsing
% not all contacts and not all fascicles may be represented.
% Yes, this can be done much faster with real expressions. Go ahead.
Contact_Fascicle_List = [];
asdf = dir([pwd '\Maxwell_Output\']); 
for k = 1:length(asdf)
    if (length(asdf(k).name)==33) % cheap, but we're looking for a particular naming format
        if(strcmp(asdf(k).name(end-3:end),'.dat'))
            temp = asdf(k).name;
            a = find(temp=='F');
            temp_Contact_num = str2num(temp(14:(a-1)));
            a = find(temp=='.');
            b = find(temp=='r');
            temp_Fascicle_num = str2num(temp((b+1):(a-1)));
            Contact_Fascicle_List(end+1,:) = [temp_Contact_num,temp_Fascicle_num];
        end
    end
end

%load axon locations for all models
filename=['AxonPositionsRelativeToCenter.mat'];
load(filename);

total_axons=length(AxonPositionsRelativeToCenter.Endo1.X);

%open the descriptive file of the model, if it exists
filename=['FascicleDescriptions.mat'];
if (exist(filename,'file'))
    load(filename);
    
%     for row = 1:size(Contact_Fascicle_List,1)

    for temp_Contact=unique(Contact_Fascicle_List(:,1))'%1:NumberOfContacts
        for temp_Fascicle=unique(Contact_Fascicle_List(:,2))%1:length(FascicleNames)
            
            %correct locations of axons by accounting for location of
            %center point
            temp_AxonPositions=AxonPositionsRelativeToCenter.(['Endo' num2str(temp_Fascicle)]);
            center_point=Fascicles.(['Endo' num2str(temp_Fascicle)]).CenterPoint.*1000; %(um)
            
            temp_AxonPositions.X=temp_AxonPositions.X+center_point(1);
            temp_AxonPositions.Y=temp_AxonPositions.Y+center_point(2);

            
            %obtain Ansoft-exported voltages for this fascicle and
            %put in a usable matrix form
            
            % ModelName & "Contact" & IndexContactNumber & "FascicleNumber" & fascicleIndex  & ".dat"
            temp_file_in=[pwd,'\Maxwell_Output\SimpleContact',num2str(temp_Contact),'FascicleNumber',num2str(temp_Fascicle),'.dat'];
            
            % determine if the input is completely numeric.  Sometimes ANSOFT
            % puts in a value of '-NoSoln-'
            tempdata = checkinput(temp_file_in);
            
            
            %OUTPUT: [x, y, z, volts]  NOTE: z only runs from 0 to 30 (due to
            %symmetry, so I need to flip z(2:end) and voltage(2:end) and add
            %them to the beginning of the data.  UNITS ARE IN (M and volts)!
            
            %convert to [mm] and make sure all voltages are for cathodic
            %current (all negative).  This occurs because Ansoft has a tendency
            %to flip the sign on the voltages when solving starting in version
            %11.1.1.  Thus, negative current (cathodic) can still produce
            %positive voltages, but this is just wrong.
            tempdata(:,1:3)=tempdata(:,1:3).*1000;
            tempdata(:,4)=abs(tempdata(:,4)).*-1; 
            %------------------------------------------------------------------
            
            
            %------------------------------------------------------------------
            %interpolate the voltage at each z point that falls along each random
            %(x,y) line
            all_x_data = [];
            all_y_data = [];
            all_z_data = [];
            all_V_data = [];
            
            %Ansoft can report very small (1e-13) differences in location and
            %if I search for unique positions, I will report what appears to be
            %the same location but is, in fact, off by a very small amount.  I
            %do NOT want to record x and x+1e-13 as unique positions.
            
            all_x_data = tempdata(:,1);
            all_y_data = tempdata(:,2);
            all_z_data = tempdata(:,3);
            all_V_data = tempdata(:,4);
            
            all_x_data = all_x_data.*100000;
            all_y_data = all_y_data.*100000;
            all_z_data = all_z_data.*100000;
            
            all_x_data = round(all_x_data);
            all_y_data = round(all_y_data);
            all_z_data = round(all_z_data);
            
            all_x_data = all_x_data./100000;
            all_y_data = all_y_data./100000;
            all_z_data = all_z_data./100000;
            
            %find all unique positions within the known data grid
            unique_x = []; %(mm)
            unique_y = []; %(mm)
            unique_z = []; %(mm)
            
            unique_x=unique(all_x_data);
            unique_y=unique(all_y_data);
            unique_z=unique(all_z_data);
            
            unique_x = unique_x'.*1000; %(um)
            unique_y = unique_y'.*1000; %(um)
            unique_z = unique_z'.*1000; %(um)
            
            % V is a single column, so I need to reshape it
            % V MUST originally be in the format [x1y1z1,x1y1z2,...,x1y1zn...x1ynzn,x2y1z1,...xnynzn]
            
            rows = length(unique_y);
            cols = length(unique_x);
            pgs = length(unique_z);
            dummy_index = 1;
            
            V_reshaped = [];
            V_reshaped(1,1,1)=0;
            
            for this_col = 1:1:cols
                for this_row = 1:1:rows
                    for this_page = 1:1:pgs
                        V_reshaped(this_row,this_col,this_page) = all_V_data(dummy_index);  %Volts
                        dummy_index = dummy_index+1;
                    end
                end
            end
            
            %NOTE: z only runs from 0 to x (due to
            %symmetry, so I need to flip z(2:end) to run from -x to 0
            %and voltage(2:end) and add them to the beginning of the data)
            
            z_flip = -1.*(fliplr(unique_z(2:end)));
            
            unique_z = [z_flip,unique_z]; %(um)
            
            
            dummy_index = 1;
            temp_V = [];
            for this_page = pgs:-1:2
                temp_V(:,:,dummy_index)=V_reshaped(:,:,this_page);
                dummy_index = dummy_index+1;
            end
            
            V_reshaped(:,:,pgs:pgs+length(V_reshaped)-1) = V_reshaped(:,:,:);
            V_reshaped(:,:,1:pgs-1)=temp_V(:,:,:); %(Volts)
            
            
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
            Vi = [];
            
            for row=1:total_axons
                Vi(row,:) = interp3(unique_x, unique_y, unique_z, V_reshaped,  temp_AxonPositions.X(row),  temp_AxonPositions.Y(row),  temp_AxonPositions.Z(row,:), 'spline');  %(um), (um), (um), (V), (um), (um), (um))
            end
            %OUTPUT: [M,N] = SIZE(Vi) where there are M randomly chosen lines
            %and N calcualted volatages along the axons
            
            
            %save data
            InterpolatedVoltages.(['Endo' num2str(temp_Fascicle)])=Vi;
        end
        %  eval(['save ' '''' '../../../' Model '/InterpolatedVoltages/V' num2str(MirrorVersion) '/' EncapsulationThicknessString 'Encap/' CuffX{temp_X} '-' CuffY{temp_Y} '-10-' EncapsulationThickness '-0.05--' num2str(temp_Contact) '.mat' '''' ' InterpolatedVoltages']);
        


        eval('save ([pwd,''/InterpolatedVoltages/InterpolatedVoltagesContact'', num2str(temp_Contact),''.mat''], ''InterpolatedVoltages'')'); % PVL mod.
        
    end
end




