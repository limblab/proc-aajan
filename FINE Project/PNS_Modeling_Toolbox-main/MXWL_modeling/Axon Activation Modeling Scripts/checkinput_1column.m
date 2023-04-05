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

