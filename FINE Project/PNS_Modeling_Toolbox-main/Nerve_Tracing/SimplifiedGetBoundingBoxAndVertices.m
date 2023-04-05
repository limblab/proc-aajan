function SimplifiedGetBoundingBoxAndVertices(FileLoc,object_string,step_size,z)
%function getBoundingBoxAndVertices(Model,CuffX,CuffY,EncapsulationThickness,object_string,step_size,z)
%getBoundBox(directory,object_string,[step_size],[z])
%
%   SM2FILE is a string with the path (including file name) to the SM2 file
%   that needs to be analyzed.
%
%   OBJECT_STRING is a string that will be searched for within the file
%   that is opened.  For example, to export the bounding box for objects with
%   the string 'Endo' (endoneurium) in the name, pass 'Endo' to the
%   function.  To export all verticies of all objects in the model, pass
%   '*' to the function.  Object_string is CaSe SeNsItIvE.
%

% modified 2/24/16 PVL. Changed inputs to accept a location for the sm2
% file rather than generating it.


%This script opens the Ansoft SM2 file and obtains the bounding
%box for all objects in the ANSOFT model on the z=0 plane, and steps at
%STEP_SIZE.  STEP_SIZE can be a scalar or an array of 3 values and range
%between [0 1} (exclusive-inclusive).  A STEP_SIZE of 1 will only provide
%the voltages at the edges of the bounding box.  A STEP_SIZE of .2, for
%example, will produce the voltages at 0%, 20%, 40%, 60%, 80%, and 100% of
%the bounding box.
%
%This script also saves the information from the SM2 file in a mat file.
%Saved values include FascicleNames={} and Vertices.(FasciclesNames{})=[].
%
%If STEP_SIZE is a scalar, dx, dy, and dz will be STEP_SIZE*100% of the
%total excursion in x, y, and z of the bounding box.  If STEP_SIZE is a
%vector, it must be [dx, dy, dz].
%
%Z is a vector [z_start z_stop] indicating the start and stop z coordinate
%for the bounding box.  Z is in [mm].
%
%This script outputs files named BoundingBox_<Object_name>.pts that
%contains 3 columns (x,y,z) of points on which Ansoft is to export voltages
%for the given object.
%
%
%Recommended values:
%  object_string='Endo';
%  step_size=[1/10,1/10,1/50];
%  z=[0,0.030];
%
%CREATED: 18 November 2009


if (length(step_size)==1)
    step_size=[step_size,step_size,step_size];
end

this_path=pwd;

%SM2File=['..\..\Fascicles - sm2\' Model '\DeIdentified\Final Locations After Any Corrections\' Model ', ' CuffY 'x' CuffX ' mm, ' EncapsulationThickness ' mm encapsulation, 0.05 mm buffer.sm2'];
SM2File=FileLoc;
slashes=strfind(SM2File,'/');
SM2File(slashes)='\';
slashes=strfind(SM2File,'\');

new_path=SM2File(1:slashes(end));
SM2File(1:slashes(end))=[];

eval(['cd ' '''' new_path '''']);

eval(['fid=fopen(' '''' SM2File '''' ',' '''' 'r' '''' ');']);
if (fid>0)
    rawdata=textscan(fid,'%s','delimiter','\n');
    fclose(fid);
    
    %rawdata{1}(n) is the nth line of the file
    %verticies are in the file in a format like this:
    %B_OBJECT 545 RFEndo1seg3                                   <-- * name
    %    Color 2147548928
    %    Visible Y Selected N Model Y Hatches N Closed Y
    %    CoordSys 0 0 0
    %    BoundBox
    %     0.00367342169725457 -0.000103904292010709             <-- * xmin ymin
    %     0.00393643369725457 0.000131565707989291              <-- * xmax ymax
    %    B_VERTS 6                                              <-- * # of verticies
    %     Vert 533 544 539
    %      0.00393643369725457 1.95177079892905E-005
    %     Vert 534 539 540
    %      0.00393643369725457 -0.000103904292010709
    %     Vert 535 540 541
    %      0.00384722769725457 -0.000103904292010709
    %     Vert 536 541 542
    %      0.00369861369725457 -3.32429201070946E-006
    %     Vert 537 542 543
    %      0.00367342169725457 9.49997079892905E-005
    %     Vert 538 543 544
    %      0.00382438569725457 0.000131565707989291
    %    E_VERTS
    
    
    lines = length(rawdata{1});
    
    fid2=fopen(['FascicleNames.txt'],'w');
    FascicleNames={};
    for i=1:lines
        
        this_line=cell2mat(rawdata{1}(i));
        
        %determine if B_OBJECT is found in the line
        if(strfind(this_line,'B_OBJECT'))
            
            %does the object name match the search string?
            if (length(strfind(this_line,object_string))>0 || strcmp(object_string,'*'))
                
                %determine the object name: everything between the 2nd space
                %and the last space
                spaces=strfind(this_line,' ');
                %name=this_line(spaces(2)+1:spaces(end)-1);
                name=this_line(spaces(2)+1:end);%PVL adjust
                
                if (~exist ('ExportLocations', 'dir'))
                    mkdir('ExportLocations')
                end
                file_name=['/ExportLocations/ExportLocationsFor',name, '.pts'];
                fid=fopen([pwd,file_name],'w');
                
                fprintf(fid2,'%s\n',name);
                
                use_this_object=1;
                
            else
                use_this_object=0;
            end
        end
        
        
        if(strfind(this_line,'BoundBox'))
            
            if (use_this_object==1)
                
                xmin=0;
                xmax=0;
                ymin=0;
                ymax=0;
                
                i=i+1; %move to the next line in the file, containing the xmin and ymin bounding box values
                
                this_line=cell2mat(rawdata{1}(i));
                spaces=strfind(this_line,' ');
                
                xmin=str2num(this_line(1:spaces(1)-1));
                if (max(size(spaces))>1) % PVL adjust 2/24/16
                    ymin=str2num(this_line(spaces(1)+1:spaces(2)-1));
                else 
                    ymin=str2num(this_line(spaces(1)+1:end));
                end
                
                i=i+1; %move to the next line in the file, containing the xmax and ymax bounding box values
                this_line=cell2mat(rawdata{1}(i));
                spaces=strfind(this_line,' ');
                
                xmax=str2num(this_line(1:spaces(1)-1));
                if (max(size(spaces))>1) % PVL adjust 2/24/16
                    ymax=str2num(this_line(spaces(1)+1:spaces(2)-1));
                else
                    ymax=str2num(this_line(spaces(1)+1:end));
                end
                
                x_pts=[];
                y_pts=[];
                z_pts=[];
                
                x_pts=[xmin:(xmax-xmin)*step_size(1):xmax]/1000; % PVL mod. must be scaled by 10^-3, as MXWL expects values in m.
                y_pts=[ymin:(ymax-ymin)*step_size(2):ymax]/1000;
                z_pts=[z(1):(z(2)-z(1))*step_size(3):z(2)]; % This one was already in meters
                
                
                for x_index=1:length(x_pts)
                    for y_index=1:length(y_pts)
                        for z_index=1:length(z_pts)
                            fprintf(fid,'%.9f\t%.9f\t%.9f\n',x_pts(x_index),y_pts(y_index),z_pts(z_index));
                        end
                    end
                end
                fclose(fid);
                
            end
        elseif(strfind(this_line,'B_VERTS'))
            if (use_this_object==1)
                %How many verts are in the object?
                spaces=strfind(this_line,' ');
                verts=str2num(this_line(spaces(1)+1:end));
                
                tempverts=[];
                for j=1:verts
                    %advance 2 lines
                    i=i+2;
                    this_line=str2num(cell2mat(rawdata{1}(i)));
                    
                    tempverts(end+1,1:2)=this_line;
                end
                
                Fascicles.([name]).Vertices=tempverts.*1000; %mm
                
                %calculate a center point and radius assuming this is a regular
                %polygon
                centerpt=mean(tempverts);
                Fascicles.([name]).CenterPoint=centerpt*1000; %mm
                
                radii=sqrt((tempverts(:,1)-centerpt(1)).^2+(tempverts(:,2)-centerpt(2)).^2);
                radii=mean(radii);
                Fascicles.([name]).Radius=radii*1000; %mm
                
                Fascicles.([name]).Area=polyarea(tempverts(:,1).*1000,tempverts(:,2).*1000); %mm^2
                
                FascicleNames{end+1}=name;
            end
        end
    end
    fclose(fid2);
    
    eval('save (''FascicleDescriptions.mat'', ''FascicleNames'', ''Fascicles'')'); % PVL mod.
else
    disp('get bounding box failed')
end %end if
eval(['cd ' '''' this_path '''']);
