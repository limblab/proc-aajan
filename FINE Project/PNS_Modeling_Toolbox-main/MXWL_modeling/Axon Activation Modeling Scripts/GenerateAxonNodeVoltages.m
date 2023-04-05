% This function takes a axon-populated nerve (from GenerateNervePopulation) 
% and determines the voltages at all axon nodes based on voltage field data
% from exported Maxwell fld files
% This code uses linear superposition to determine the voltage at nodes
% for modeling multi-contact stimulation
function [fasciclesfinal, allaxons] = GenerateAxonNodeVoltages(NerveNameString, fasciclesfinal, allaxons, CathodeInput)
    %cathode input columns [contact; current (mA)]; cathode = -; anode = +
    numfascicles = length(fasciclesfinal);
    numcontacts = size(CathodeInput,1);
    currAxon=1;
    %start plot
    figure; hold on
    for i = 1:numfascicles
        %plot fascicle outline
        plot3(fasciclesfinal{1,i}.vertices(:,1),fasciclesfinal{1,i}.vertices(:,2),zeros(length(fasciclesfinal{1,i}.vertices(:,1)),1),'k','LineWidth',1.5);
        %determine aggregate V field across fascicle
        for j = 1:numcontacts
            %load all of the relevant maxwell fld files
            %this function checks for NaNs and fixes them 
            [V2d, V3d]= checkinput_4columns([NerveNameString '_VoutCathode' num2str(CathodeInput(j)) 'Fascicle' num2str(i) '.fld']); %m
            V2d(:,4) = abs(V2d(:,4)); V3d = abs(V3d); %ENSURES CORRECT POLARITY OF MAXWELL OUTPUT; default to +; cathode gains = -
            %set up x,y,z coords based on 1st loaded contact
            if j == 1
                X = V2d(:,1);
                Y = V2d(:,2);
                Z = V2d(:,3);
                V = V2d(:,4)*CathodeInput(1,2);
                Vgrd = V3d*CathodeInput(1,2);
            else
                if ~isequal([X,Y,Z],V2d(:,1:3))
                    disp(['XYZ Coordinates NOT the same. Will need to interpolate in order to add fields']);
                    beep
                    return
                else
                    V = V + V2d(:,4)*CathodeInput(j,2); %linear superposition of multiple voltage fields. each voltage field is scaled by amplitude and direction of current
                    Vgrd = Vgrd + V3d*CathodeInput(j,2);
                end
            end
        end
        %convert XYZ from m to mm
        X = X*1000; Y = Y*1000; Z = Z*1000;
        Xvec = unique(X);
        Yvec = unique(Y);
        Zvec = unique(Z);
        %interpolate V at axon node locations
        for j = 1:fasciclesfinal{1,i}.nAxons
            interpVnode=interpn(Xvec,Yvec,Zvec, Vgrd, fasciclesfinal{1,i}.axons{1,j}.nodelocation(:,1), fasciclesfinal{1,i}.axons{1,j}.nodelocation(:,2), fasciclesfinal{1,i}.axons{1,j}.nodelocation(:,3));
            fasciclesfinal{1,i}.axons{1,j}.nodeV(:,1)=interpVnode; %save to structure
            allaxons.nodeV(:,currAxon+j-1)=interpVnode;
            %add to plot
            scatter3(fasciclesfinal{1,i}.axons{1,j}.nodelocation(:,1),fasciclesfinal{1,i}.axons{1,j}.nodelocation(:,2),fasciclesfinal{1,i}.axons{1,j}.nodelocation(:,3),2,interpVnode);
        end
        drawnow
        currAxon=currAxon+fasciclesfinal{1,i}.nAxons;
    end
end