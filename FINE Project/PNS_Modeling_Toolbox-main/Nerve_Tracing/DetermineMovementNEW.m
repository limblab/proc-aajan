function [X1,Y1,PercentOverlap1,varargout]=DetermineMovementNEW(obj1,obj2,location)
% if one object is an epineurium, then obj2 must be the epineurium and
% location must be set to "in".  if both objects are perineurium, then
% location must be set to "out"

if strcmp(lower(location),'out')

    %find the centroids of the 2 fascicles
    [c1(1), c1(2)]=centroid(obj1(:,1),obj1(:,2));
    [c2(1), c2(2)]=centroid(obj2(:,1),obj2(:,2));

    %create a line connecting the two centroids
    c1c2(:,1)=linspace(c1(1),c2(1),100);
    c1c2(:,2)=linspace(c1(2),c2(2),100);

    %find the intersection of the line connecting the two centroids and the
    %2nd fascicle
    Pt1=InterX(obj2',c1c2');


    %find the intersection of the line connecting the two centroids and the
    %1st fascicle
    Pt2=InterX(obj1',c1c2');


    %find the "length of overlap" of the two fascicles
    overlap=max(max(dist([Pt1,Pt2])));


    %determine directionality that each polygon moves using atan2 where the
    %centroid of the opposite polygon is centered at (0,0)
    temp_c1=[c1(1)-c2(1),c1(2)-c2(2)];
    theta1=atan2(temp_c1(2),temp_c1(1));

    temp_c2=[c2(1)-c1(1),c2(2)-c1(2)];
    theta2=atan2(temp_c2(2),temp_c2(1));

    %dertermine x and y motion of fascicles
    X1=cos(theta1)*overlap;
    Y1=sin(theta1)*overlap;

    X2=cos(theta2)*overlap;
    Y2=sin(theta2)*overlap;

    %Throw in some "jitter"
    X1=X1*(1+rand*.50);
    Y1=Y1*(1+rand*.50);
    X2=X2*(1+rand*.50);
    Y2=Y2*(1+rand*.50);
    
%     %Determine Percent Overlap of each other
%     clear junk
% %     [junk(:,1),junk(:,2)]=polybool('intersection',obj1(:,1),obj1(:,2),obj2(:,1),obj2(:,2));
%     junk=[0 0];
%     PercentOverlap1=polyarea(junk(:,1),junk(:,2))/polyarea(obj1(:,1),obj1(:,2));
%     PercentOverlap2=polyarea(junk(:,1),junk(:,2))/polyarea(obj2(:,1),obj2(:,2));
%     
%     if (isnan(PercentOverlap1) || isnan(PercentOverlap2))
%         PercentOverlap1=0;
%         PercentOverlap2=0;
%     end
PercentOverlap1=0;
PercentOverlap2=0;

elseif strcmp(lower(location),'in')

    %obj1 MUST be epineurium
    %obj2 MUST be the fascicle

    %determine centroid of fascicle
    [c1(1), c1(2)]=centroid(obj1(:,1),obj1(:,2));


    %determine centroid of fascicle if a portion of it is removed by the
    %epineurium that intersects the fascicle
    clear junk1 junk2
    [junk1, junk2]=polybool('intersection',obj1(:,1),obj1(:,2),obj2(:,1),obj2(:,2));
    cut_obj2=[junk1, junk2];
    [cut_c1(1), cut_c1(2)]=centroid(cut_obj2(:,1),cut_obj2(:,2));


    %determine the direction the fascicle needs to move by comparing the
    %centroids, having moved the centroid of the original fascicle to (0,0)
    temp_cut_c1=[cut_c1(1)-c1(1), cut_c1(2)-c1(2)];
    theta1=atan2(temp_cut_c1(2),temp_cut_c1(1));


    %make an imaginary line that goes way out into space along this angle
    c2(1)=c1(1)+cos(theta1+pi)*500;
    c2(2)=c1(2)+sin(theta1+pi)*500;


    %make a line between these two points
    c1c2(:,1)=linspace(c1(1),c2(1),100);
    c1c2(:,2)=linspace(c1(2),c2(2),100);
    %c1c2=double(c1c2);

    %find the distance between point c2 and the edge of the fascicle
    PtOnFasc=InterX(obj1',c1c2');

    %find the distance bmaetween point c2 and the edge of the epineurium
    PtOnEpi=InterX(obj2',c1c2');

    %find the "length of overlap" of the epineurium with the fascicle
    overlap=max(max(dist([PtOnFasc,PtOnEpi])));


    %fascicle x and y movement
    X1=cos(theta1)*overlap;
    Y1=sin(theta1)*overlap;

    %Epi doesn't move
    X2=0;
    Y2=0;


    %Throw in some "jitter"
    X1=X1*(1+rand*.50);
    Y1=Y1*(1+rand*.50);
    
    
    %Determine Percent of fascicle outside the epi
%     clear junk
%     [junk(:,1),junk(:,2)]=polybool('subtraction',obj1(:,1),obj1(:,2),obj2(:,1),obj2(:,2));
%     PercentOverlap1=polyarea(junk(:,1),junk(:,2))/polyarea(obj1(:,1),obj1(:,2));
%     PercentOverlap2=0;
%     
%     if (isnan(PercentOverlap1))
%         PercentOverlap1=0;
%     end
PercentOverlap1=0;
PercentOverlap2=0;

else
    fprintf('Error in location variable in DetermineMovement.m\n');
end


nout = max(nargout,1)-3;
if (nout>0)
    varargout(1)={X2};
    varargout(2)={Y2};
    varargout(3)={PercentOverlap2};
end

if (abs(PercentOverlap1)>1 || abs(PercentOverlap2)>1)
    matt=1
end