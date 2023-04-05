function [epi_verts]=ReshapeEpiWithElectrode(vertices1,vertices2)
%This function accepts 2 inputs:
%  vertices1 are the vertices (no repeats) of the epineurium
%  vertices2 are the vertices (no repeats) of the electrode

warning off all


%round vertices to remove machine error
epi_verts=(round(vertices1.*1E4)./1E4);
electrode_verts=(round(vertices2.*1E4)./1E4);

%polybool assumes that individual contours whose vertices are clockwise
%ordered are external contours, and that contours whose vertices are 
%counterclockwise ordered are internal contours. You can use poly2cw to 
%convert a polygonal contour to clockwise ordering

[epi_verts(:,1),epi_verts(:,2)]=poly2ccw(epi_verts(:,1),epi_verts(:,2));
[electrode_verts(:,1),electrode_verts(:,2)]=poly2cw(electrode_verts(:,1),electrode_verts(:,2));




starting_area=polyarea(epi_verts(:,1),epi_verts(:,2));

%determine which points in the epineurium are outside the electrode
[in, on] = inpolygon(epi_verts(:,1), epi_verts(:,2), ...
    electrode_verts(:,1), electrode_verts(:,2));

moved=[];
while (min(in)==0)
    clear junk1 junk2
    epi_verts=(round(epi_verts.*1E4)./1E4);

    [junk1,junk2]=polybool('intersection',epi_verts(:,1),epi_verts(:,2),electrode_verts(:,1),electrode_verts(:,2));

    epi_verts=[junk1, junk2];
    epi_verts=(round(epi_verts.*1E4)./1E4);

    %I should never need to move the electrode-moved points again
    moved=[moved;find(in==0)];
    moved=unique(moved);
    
    %something must have moved....
    %All epineurium points outside the electrode have now moved in.  This
    %has resulted in a decreased area.  Now I want to grow out the points
    %that were originally inside in an effort to minimize dArea.
    %make the simple assumption that all vertices will move to correct
    %dArea.  More likely, there's more motion in areas closer to the points
    %that are being reshaped.  I'll  find a range using a course
    %resoluation.  Of course, only do this if there are free points to
    %move.

    [in, on] = inpolygon(epi_verts(:,1), epi_verts(:,2), ...
        electrode_verts(:,1), electrode_verts(:,2));

    move=find(in==1 & on==0);  %pts that can move must be inside and not touching the electrode
    
    if (length(move)>0)
        %free points exist for moving

        ending_area=polyarea(epi_verts(:,1),epi_verts(:,2));
        dArea=starting_area-ending_area;

        epsilon=.0001;

        epi_test=epi_verts;

        while (abs(dArea/starting_area) > epsilon)
            if (dArea>0)
                epi_verts(move,:)=epi_verts(move,:).*1.01;
            else
                epi_verts(move,:)=epi_verts(move,:)./1.005;
            end
            ending_area=polyarea(epi_verts(:,1),epi_verts(:,2));
            dArea=starting_area-ending_area;
        end
        [in, on] = inpolygon(epi_verts(:,1), epi_verts(:,2), ...
            electrode_verts(:,1), electrode_verts(:,2));

        %if the culprit (outlier) is one that I already moved, then I'm not
        %going to allow myself to go through this again
        in(moved)=1;

    else
        in=1;
    end
    

end
