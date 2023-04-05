% This script makes a simple fascicle, full of axons
% It's largely based on Matt's Nerve Reshaper
% Is followed by 
% Make simple sm2

% we'll make a fascicle, diam 1mm, 
% from Matt's Nerve reshaper
% %Peri is 1.06x of Endo. 3% on each side.


points = 100; % number of vertices
Ediam = 1; % in mm
Pdiam = Ediam*1.06
Erad = Ediam/2;
Prad = Pdiam/2;

ObjectList = {'Endo1','Peri1'}

ObjectVertices.Endo1={};
ObjectVertices.Peri1={};
PVertY=[];
EVertY=[];
PVertX=[];
EVertX=[];

for k =1:points
    angle = 2*pi*(k-1)/points; % angle in radians
    EY = Erad*sin(angle);
    EX = Erad*cos(angle);
    PY = Prad*sin(angle);
    PX = Prad*cos(angle);   
    PVertY=[PVertY,PY]
    EVertY=[EVertY,EY];
    PVertX=[PVertX,PX];
    EVertX=[EVertX,EX];

end
    ObjectVertices.Endo1=[EVertX;EVertY]';
    ObjectVertices.Peri1=[PVertX;PVertY]';

WriteSM2(ObjectList,ObjectVertices,'Simplesm2')   

% There is another problem. With Every facsicle we export we need a set of
% points with in its 'bounding box' (in our case it would be +1.06/2 to
% -1.06/2 in which we want data.

% now, Matt uses a Z step of .0015, or 1.5mm
% and a Y step of 0.0001066, or 0.1066mm
% and an X step of 0.0001066, or 0.1066mm
% And he goes back to a Z of ... 0.03, or 3 cm
% And divides the XY cross section into 100 equally spaced points

% script copied/modified from Matt's WriteSM2
FileName = 'Simplepts';
FileName=[FileName, '.pts'];
fid=fopen(FileName,'w');

for x = -Pdiam/2:Pdiam/10:Pdiam/2
    for y = -Pdiam/2:Pdiam/10:Pdiam/2
        for z = 0:0.0015:0.03
            fprintf(fid,'%f15\t%f15\t%f15\n',x/1000,y/1000,z/1000); % mxwl needs this in meters
        end
    end
end
close all
fclose(fid)