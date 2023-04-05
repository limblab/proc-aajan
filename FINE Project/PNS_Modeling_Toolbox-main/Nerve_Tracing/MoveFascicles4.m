function [ObjectVertices]=MoveFascicles4(ObjectList,ObjectVertices,types,varargin)

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
epi_verts=round(epi_verts.*1E6)./1E6;

%plot epineurium
hold off
plot(epi_verts(:,1),epi_verts(:,2),'r');
axis([-10 10 -10 10]);
hold on

%find epi's centroid
[epi_centroid(1),epi_centroid(2)]=centroid(epi_verts(:,1),epi_verts(:,2));
%% 1st time through, determine what needs to be moved

to_move=[];
moved_by=[];
Areas=zeros(1,length(type2));

for i=1:length(type2)
    peri_verts=ObjectVertices.(ObjectList{type2(i)});
    peri_verts=round(peri_verts.*1E6)./1E6;

    %Acquire areas to guide movement later (big fascicles win, small lose)
    Areas(i)=polyarea(peri_verts(:,1),peri_verts(:,2));

    plot(peri_verts(:,1),peri_verts(:,2),'k');

    %determine if the perineurium falls outside the epineurium
    [in] = inpolygon(peri_verts(:,1), peri_verts(:,2), ...
        epi_verts(:,1), epi_verts(:,2));

    %if the min(in) isn't 1, meaning it's 0, then part of the perineurium
    %falls outside the epineurium
    if (~min(in))
        to_move(end+1)=i;   %i=fascicle to move
        moved_by(end+1)=1;  %1=epineurium
    end


    %determine if this fascicle intersects any other fascicles
    for j=i:length(type2)
        if (j~=i)
            peri2_verts=ObjectVertices.(ObjectList{type2(j)});
            peri2_verts=round(peri2_verts.*1E6)./1E6;

            in=inpolygon(peri_verts(:,1),peri_verts(:,2),peri2_verts(:,1),peri2_verts(:,2));

            if (max(in))
                to_move(end+1)=i; %i=fascicle to move
                moved_by(end+1)=3;  %3=another fascicle moved this one

                to_move(end+1)=j; %i=fascicle to move
                moved_by(end+1)=3;  %3=another fascicle moved this one
            end
        end
    end
end

Areas=repmat(Areas,18,1);

unique_to_move=unique(to_move);
unique_moved_by=[];
for i=1:length(unique_to_move)
    temp_fasc=unique_to_move(i);
    index=find(to_move==temp_fasc);
    values=moved_by(index);
    if (values==1)
        unique_moved_by(i)=1;
    elseif (values==3)
        unique_moved_by(i)=3;
    else
        unique_moved_by(i)=2; %2=epi and another fascicle moved this one
    end
end
moved_by=unique_moved_by;
to_move=unique_to_move;

[moved_by, index]=sort(moved_by);
to_move=to_move(index);

drawnow
%% As long as there is an intersection, something needs to be moved.
iteration=0;
maxIterations=500;
while (~isempty(to_move) && iteration<maxIterations)
    iteration=iteration+1;

    while (~isempty(to_move) && (moved_by(1)==1 || moved_by(1)==2)) %fascicle was moved by epi
        temp_fasc=to_move(1);
        peri_verts=ObjectVertices.(ObjectList{type2(temp_fasc)});
        peri_verts=round(peri_verts.*1E6)./1E6;

        %ensure it's outside
        [in, on] = inpolygon(peri_verts(:,1), peri_verts(:,2), ...
            epi_verts(:,1), epi_verts(:,2));
        in(find(on==1))=1;

        if (~min(in))
            %calculate the distance to move this fascicle
            [x,y]=DetermineMovement3(peri_verts,epi_verts,'in');

            %move the fascicle
            peri_verts(:,1)=peri_verts(:,1)+x;
            peri_verts(:,2)=peri_verts(:,2)+y;
            peri_verts=round(peri_verts.*1E6)./1E6;

            ObjectVertices.(ObjectList{type2(temp_fasc)})=peri_verts;
            plot(peri_verts(:,1),peri_verts(:,2),'b');
        end
        to_move(1)=[]; %done with this fascicle, so remove from the list
        moved_by(1)=[];
    end

    to_move=zeros(length(type2),1);
    is_touching=to_move;
    %figure out how all fascicles overlap to get the global view
    X_motion=zeros(length(type2));
    Y_motion=zeros(length(type2));
    for i=1:length(type2)
        peri_verts=ObjectVertices.(ObjectList{type2(i)});
        peri_verts=round(peri_verts.*1E6)./1E6;

        for j=1:length(type2)
            if (j~=i)
                peri2_verts=ObjectVertices.(ObjectList{type2(j)});
                peri2_verts=round(peri2_verts.*1E6)./1E6;

                [in,on]=inpolygon(peri_verts(:,1),peri_verts(:,2),peri2_verts(:,1),peri2_verts(:,2));
                in(find(on==1))=1;

                if (max(in))
                    %to_adjust(end+1)=i;
                    %[X_motion(i,j),Y_motion(i,j),X_motion(j,i),Y_motion(j,i)]=DetermineMovement3(peri_verts,peri2_verts,'out');
                    to_move(i)=1;
                    to_move(j)=1;
                    is_touching(i)=is_touching(i)+1;
                end
            end
        end


        %find the centroid of the fascicle and it's distance to the
        %centroid of the epineurium
%         [f_centroid(1),f_centroid(2)]=centroid(peri_verts(:,1),peri_verts(:,2));
%         D_center(i)=sqrt((f_centroid(1)-epi_centroid(1))^2+(f_centroid(2)-epi_centroid(2))^2);
    end

    %sort based on fascicle's distance from the center of the nerve.
    %Fascicles closest to the center move first to make room for
    %fascicles that are being pushed by the epineurium (directly or
    %indirectly)
%     [D_center,index]=sort(D_center,'ascend');

%sort by how many fascicles are being touched
[is_touching, index]=sort(is_touching,'ascend');


    for ii=1:length(type2)
        temp_fasc=index(ii);
        if (to_move(temp_fasc))

            X_motion=zeros(length(type2),1);
            Y_motion=zeros(length(type2),1);

            peri_verts=ObjectVertices.(ObjectList{type2(temp_fasc)});
            peri_verts=round(peri_verts.*1E6)./1E6;

            for j=1:length(type2)
                if (j~=temp_fasc)
                    peri2_verts=ObjectVertices.(ObjectList{type2(j)});
                    peri2_verts=round(peri2_verts.*1E6)./1E6;

                    [in,on]=inpolygon(peri_verts(:,1),peri_verts(:,2),peri2_verts(:,1),peri2_verts(:,2));
                    in(find(on==1))=1;

                    if (max(in))
                        %to_adjust(end+1)=i;
                        [X_motion(j),Y_motion(j),junk,junk]=DetermineMovement3(peri_verts,peri2_verts,'out');
                    end
                end
            end

            dx=sum(X_motion);
            dy=sum(Y_motion);

            peri_verts=ObjectVertices.(ObjectList{type2(temp_fasc)});
            peri_verts=round(peri_verts.*1E6)./1E6;

            peri_verts(:,1)=peri_verts(:,1)+dx;
            peri_verts(:,2)=peri_verts(:,2)+dy;
            peri_verts=round(peri_verts.*1E6)./1E6;

            ObjectVertices.(ObjectList{type2(temp_fasc)})=peri_verts;

            to_move(temp_fasc)=0;
        end
    end
    to_move=[];



    %determine if this motion caused any new intersections and, if so, add
    %to the to_move vector
    for i=1:length(type2)
        peri_verts=ObjectVertices.(ObjectList{type2(i)});
        peri_verts=round(peri_verts.*1E6)./1E6;

        plot(peri_verts(:,1),peri_verts(:,2),'m');

        %determine if the perineurium falls outside the epineurium
        [in,on] = inpolygon(peri_verts(:,1), peri_verts(:,2), ...
            epi_verts(:,1), epi_verts(:,2));
        in(find(on==1))=1;
        %if the min(in) isn't 1, meaning it's 0, then part of the perineurium
        %falls outside the epineurium
        if (~min(in))
            to_move(end+1)=i;   %i=fascicle to move
            moved_by(end+1)=1;  %1=epineurium
        end


        %determine if this fascicle intersects any other fascicles
        for j=i:length(type2)
            if (j~=i)
                peri2_verts=ObjectVertices.(ObjectList{type2(j)});
                peri2_verts=round(peri2_verts.*1E6)./1E6;

                [in,on]=inpolygon(peri_verts(:,1),peri_verts(:,2),peri2_verts(:,1),peri2_verts(:,2));
                in(find(on==1))=1;

                if (max(in))
                    to_move(end+1)=i; %i=fascicle to move
                    moved_by(end+1)=3;  %3=another fascicle moved this one

                    to_move(end+1)=j; %i=fascicle to move
                    moved_by(end+1)=3;  %3=another fascicle moved this one
                end
            end
        end
    end


    [unique_to_move,junk1,junk2]=unique(to_move);
    unique_to_move=unique_to_move(junk2(1:length(unique_to_move)));

    unique_moved_by=[];
    for i=1:length(unique_to_move)
        temp_fasc=unique_to_move(i);
        index=find(to_move==temp_fasc);
        values=moved_by(index);
        if (values==1)
            unique_moved_by(i)=1;
        elseif (values==3)
            unique_moved_by(i)=3;
        else
            unique_moved_by(i)=2; %2=epi and another fascicle moved this one
        end
    end
    moved_by=unique_moved_by;
    to_move=unique_to_move;
end
