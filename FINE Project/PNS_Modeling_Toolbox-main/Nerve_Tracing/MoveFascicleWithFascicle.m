function [obj1,obj2]=MoveFascicleWithFascicle(obj1,obj2)

%polybool assumes that individual contours whose vertices are clockwise
%ordered are external contours, and that contours whose vertices are 
%counterclockwise ordered are internal contours. You can use poly2cw to 
%convert a polygonal contour to clockwise ordering

[obj1(:,1),obj1(:,2)]=poly2cw(obj1(:,1),obj1(:,2));
[obj2(:,1),obj2(:,2)]=poly2cw(obj2(:,1),obj2(:,2));

[c1(1), c1(2)]=centroid(obj1(:,1),obj1(:,2));
[c2(1), c2(2)]=centroid(obj2(:,1),obj2(:,2));

c1c2(:,1)=linspace(c1(1),c2(1),100);
c1c2(:,2)=linspace(c1(2),c2(2),100);


%find the distance from the c1 to the edge of polygon 2 along the line
%connecting the centroids
Pt1=InterX(obj2',c1c2');
% clear junk1 junk2
% [junk1,junk2]=polybool('subtraction',c1c2(:,1),c1c2(:,2),obj2(:,1),obj2(:,2));
% cutline1=[junk1, junk2];
% cutline1_distances=dist(cutline1,cutline1');
% cutline1_length=max(max(cutline1_distances));
% 

%find the distance from the c2 to the edge of polygon 1 along the line
%connecting the centroids
Pt2=InterX(obj1',c1c2');
% clear junk1 junk2
% [junk1, junk2]=polybool('subtraction',c1c2(:,1),c1c2(:,2),obj1(:,1),obj1(:,2));
% cutline2=[junk1, junk2];
% cutline2_distances=dist(cutline2,cutline2');
% cutline2_length=max(max(cutline2_distances));
% 

%find the "length of overlap" of the two polygons
% centroid_distance=sqrt((c1(1)-c2(1))^2+(c1(2)-c2(2))^2);
% overlap=centroid_distance-(cutline1_length+cutline2_length);
overlap=max(max(dist([Pt1,Pt2])));


%weigh distance move by each as a proportion of polygon size
distance1=overlap*polyarea(obj2(:,1),obj2(:,2))/(polyarea(obj1(:,1),obj1(:,2))+polyarea(obj2(:,1),obj2(:,2)));
distance2=overlap*polyarea(obj1(:,1),obj1(:,2))/(polyarea(obj1(:,1),obj1(:,2))+polyarea(obj2(:,1),obj2(:,2)));


%determine directionality that each polygon moves using atan2 where the
%centroid of the opposite polygon is centered at (0,0)
temp_c1=[c1(1)-c2(1),c1(2)-c2(2)];
theta1=atan2(temp_c1(2),temp_c1(1));

temp_c2=[c2(1)-c1(1),c2(2)-c1(2)];
theta2=atan2(temp_c2(2),temp_c2(1));

c1_offset=[cos(theta1)*distance1,sin(theta1)*distance1];
c2_offset=[cos(theta2)*distance2,sin(theta2)*distance2];


%move objects, add in a random fudge factor
obj1(:,1)=obj1(:,1)+c1_offset(1);
obj1(:,2)=obj1(:,2)+c1_offset(2);

obj2(:,1)=obj2(:,1)+c2_offset(1);
obj2(:,2)=obj2(:,2)+c2_offset(2);


%may need to be called recursively
[in] = inpolygon(obj1(:,1),obj1(:,2),obj2(:,1),obj2(:,2));


%if the fascicles still intersect, it's not just a single point, and the
%length of intersection is more than 5% of the smaller fascicle's effective
%diameter, then recursively call
min_diam=min(2*sqrt(polyarea(obj1(:,1),obj1(:,2))/pi),2*sqrt(polyarea(obj2(:,1),obj2(:,2))/pi));
max_offset=max(sqrt(sum(c1_offset.^2)),sqrt(sum(c2_offset.^2)));

recursion=0;
while ((max(in)) && (length(find(in==1))>1) && (max_offset > .05*min_diam) && (recursion<=20))
    recursion=recursion+1;

    obj1(:,1)=obj1(:,1)+c1_offset(1)/recursion;
    obj1(:,2)=obj1(:,2)+c1_offset(2)/recursion;

    obj2(:,1)=obj2(:,1)+c2_offset(1)/recursion;
    obj2(:,2)=obj2(:,2)+c2_offset(2)/recursion;


    %may need to be called recursively
    [in] = inpolygon(obj1(:,1),obj1(:,2),obj2(:,1),obj2(:,2));

end

