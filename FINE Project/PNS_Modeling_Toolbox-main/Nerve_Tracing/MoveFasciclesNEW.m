function [ObjectVertices]=MoveFasciclesNEW(ObjectList,ObjectVertices,types,varargin)

warning off all

%parse types
%type 1: Epineurium
%type 2: Perineurium
%type 3: Endoneurium
type1=find(types==1);
type2=find(types==2);
type3=find(types==3);


%parse epineurium vetices
epi_verts=ObjectVertices.(ObjectList{type1});

%plot epineurium
plot(epi_verts(:,1),epi_verts(:,2),'r');
axis([-10 10 -10 10]);
plot(ObjectVertices.Epineurium(:,1),ObjectVertices.Epineurium(:,2),'r');

%% FASCICLES MOVED BY THE EPINEURIUM
%the epineurium
%determine which fascicles intersect the epineurium and how they should
%move
Epi_moved=zeros(length(type2),1);
Epi_X_motion=zeros(length(type2),1);
Epi_Y_motion=zeros(length(type2),1);
Epi_Overlap=zeros(length(type2),1);  %<-- may not use this
for i=1:length(type2)
    peri_verts=ObjectVertices.(ObjectList{type2(i)});
    plot(peri_verts(:,1),peri_verts(:,2),'k');


    %determine if the perineurium falls outside the epineurium
    [in] = inpolygon(peri_verts(:,1), peri_verts(:,2), ...
        epi_verts(:,1), epi_verts(:,2));

    %if the min(in) isn't 1, meaning it's 0, then part of the perineurium
    %falls outside the epineurium
    if (~min(in))
        % fprintf('\t\ti=%d, calling MoveFascicleWithEpineurium\n',i);
        [Epi_X_motion(i),Epi_Y_motion(i),Epi_Overlap(i)]=DetermineMovementNEW(peri_verts,epi_verts,'in');
        %ObjectVertices.(ObjectList{type2(i)})=MoveFascicleWithEpineurium(epi_verts,peri_verts);
        Epi_moved(i)=1;
    end
end

%move all fascicles that intersect the epineurium
%start by moving fascicles that lie the farthest outside the epineurium
values=sqrt(Epi_X_motion.^2+Epi_Y_motion.^2);
[values, order]=sort(values,1,'descend');



Fascicles_Intersect=zeros(length(type2));
X_motion=zeros(length(type2));
Y_motion=zeros(length(type2));
PercentOverlap=zeros(length(type2)); 

for index=1:length(type2)
    i=order(index);
    if (values(index)>0)  %fascicle needs to move
        ObjectVertices.(ObjectList{type2(i)})(:,1)=ObjectVertices.(ObjectList{type2(i)})(:,1)+Epi_X_motion(i);
        ObjectVertices.(ObjectList{type2(i)})(:,2)=ObjectVertices.(ObjectList{type2(i)})(:,2)+Epi_Y_motion(i);

        %determine if this fascicle now intersects any other fascicles and move
        %them.  This will NOT account for effect of area because it assumes
        %that if the epi forced the fascicle in, then the fascicle can not move
        %against the epi.  This could be more sophisticated to allow for
        %sliding perpendicular to the epi's line of motion, but that's for
        %someone else to figure out.
        peri1_verts=ObjectVertices.(ObjectList{type2(i)});
        for j=1:length(type2)
            if (j~=i && Epi_moved(j)~=1)
                peri2_verts=ObjectVertices.(ObjectList{type2(j)});

                in=inpolygon(peri1_verts(:,1),peri1_verts(:,2),peri2_verts(:,1),peri2_verts(:,2));

                if (max(in))
                    Fascicles_Intersect(i,j)=1;
                    [X_motion(j,i),Y_motion(j,i),PercentOverlap(j,i),X_motion(i,j),Y_motion(i,j),PercentOverlap(i,j)]=DetermineMovementNEW(peri1_verts,peri2_verts,'out');

                    %assume no motion in the epi-pushed fascicle and all
                    %motion in the fascicle-pushed fascicle
                    X_motion(i,j)=X_motion(i,j)*2;
                    Y_motion(i,j)=Y_motion(i,j)*2;
                    X_motion(j,i)=0;
                    Y_motion(j,i)=0;
                end
            end
        end
    end
end

%start by moving fascicles that have the fewest fascicles pushing on
%them as this just makes things easier to move in the long run
values=sum(Fascicles_Intersect);
[values, order]=sort(values);

% %start by moving the fascicles that are most overlapped
% values=max(PercentOverlap);
% [values order]=sort(values,'descend');

for index=1:length(type2)
    i=order(index);
    if (sum(Fascicles_Intersect(:,i))>0)  %one or more fascicles pushed on this fascicle
        dx=sum(X_motion(:,i));
        dy=sum(Y_motion(:,i));

        ObjectVertices.(ObjectList{type2(i)})(:,1)=ObjectVertices.(ObjectList{type2(i)})(:,1)+dx;
        ObjectVertices.(ObjectList{type2(i)})(:,2)=ObjectVertices.(ObjectList{type2(i)})(:,2)+dy;
    end
end

    

%% FASCICLES MOVED BY OTHER FASCICLES
%determine which fascicles intersect with others and how they should move
Fascicles_Intersect=zeros(length(type2));
X_motion=zeros(length(type2));
Y_motion=zeros(length(type2));
PercentOverlap=zeros(length(type2));  %<-- may not use this
Areas=zeros(length(type2),1);
for i=1:length(type2)
    peri1_verts=ObjectVertices.(ObjectList{type2(i)});
    Areas(i)=polyarea(peri1_verts(:,1),peri1_verts(:,2));
    for j=1:length(type2)
        if (j~=i)
            peri2_verts=ObjectVertices.(ObjectList{type2(j)});

            in=inpolygon(peri1_verts(:,1),peri1_verts(:,2),peri2_verts(:,1),peri2_verts(:,2));

            if (max(in))
                Fascicles_Intersect(i,j)=1;
                [X_motion(j,i),Y_motion(j,i),PercentOverlap(j,i),X_motion(i,j),Y_motion(i,j),PercentOverlap(i,j)]=DetermineMovementNEW(peri1_verts,peri2_verts,'out');
                if (max(max(abs(PercentOverlap)))>.5)
                    matt=1
                end
            end
        end
    end
end

iteration=0;
while (max(max(Fascicles_Intersect)) && iteration<50)
    iteration=iteration+1;
    %fprintf('\t\t\titeration=%d\n',iteration);

%     %start by moving fascicles that have the fewest fascicles pushing on
%     %them
%     values=sum(Fascicles_Intersect);
%     [values, order]=sort(values);

   %start by moving the fascicles that have the farthest to move
   values=max(sqrt(X_motion.^2+Y_motion.^2));
   [values,order]=sort(values,'descend');

%start by moving the fascicles that are most overlapped
% if (max(max(abs(PercentOverlap)))>1)
%     matt=1
% end
% values=max(PercentOverlap);
% [values order]=sort(values,'descend');
% 
% if max(values)>.5
%     matt=1
% end

    for index=1:length(type2)
        i=order(index);
        if (sum(Fascicles_Intersect(:,i))>0)  %one or more fascicles pushed on this fascicle
            temp_fascicles=find(Fascicles_Intersect(:,i)==1);
            total_areas=sum(Areas(temp_fascicles))+Areas(i);
            dx=sum(Areas./total_areas.*X_motion(:,i));
            dy=sum(Areas./total_areas.*Y_motion(:,i));

            ObjectVertices.(ObjectList{type2(i)})(:,1)=ObjectVertices.(ObjectList{type2(i)})(:,1)+dx;
            ObjectVertices.(ObjectList{type2(i)})(:,2)=ObjectVertices.(ObjectList{type2(i)})(:,2)+dy;
        end
    end


    %see if fascicles that moved caused new intersections
    Fascicles_Intersect=zeros(length(type2));
    X_motion=zeros(length(type2));
    Y_motion=zeros(length(type2));
    PercentOverlap=zeros(length(type2));  
    for i=1:length(type2)
        peri1_verts=ObjectVertices.(ObjectList{type2(i)});
        for j=1:length(type2)
            if (j~=i)
                peri2_verts=ObjectVertices.(ObjectList{type2(j)});

                in=inpolygon(peri1_verts(:,1),peri1_verts(:,2),peri2_verts(:,1),peri2_verts(:,2));

                if (max(in))
                    Fascicles_Intersect(i,j)=1;
                    [X_motion(j,i),Y_motion(j,i),PercentOverlap(j,i),X_motion(i,j),Y_motion(i,j),PercentOverlap(i,j)]=DetermineMovementNEW(peri1_verts,peri2_verts,'out');
                    if (max(max(abs(PercentOverlap)))>1)
                        matt=1
                    end
                end
            end
        end
    end
end
