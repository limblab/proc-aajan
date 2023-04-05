function [tempdata, Solutions] = checkinput_4columns(filename)
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

%clear Solutions
fclose(fid);

end