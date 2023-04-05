function ObjectVertices=ReAlignEndos(ObjectList,ObjectVertices,type2,OriginalCentroid)
for i=1:length(type2)

    peri_verts=ObjectVertices.(ObjectList{type2(i)});

    [x,y]=centroid(peri_verts(:,1),peri_verts(:,2));

    dx=x-OriginalCentroid.(ObjectList{type2(i)})(1);
    dy=y-OriginalCentroid.(ObjectList{type2(i)})(2);

    %clean up the name: convert peri->endo (if 'neurium' was included,
    %it stays in place).  Maintain case.
    periindex=strfind(ObjectList{type2(i)},'peri');
    Periindex=strfind(ObjectList{type2(i)},'Peri');
    PERIindex=strfind(ObjectList{type2(i)},'PERI');

    tempname='';
    tempname=ObjectList{type2(i)};

    if (~isempty(periindex)) %lower case
        newname='';
        newname=tempname;
        newname(periindex:periindex+3)='endo';

    elseif (~isempty(Periindex)) %Capitalized First
        newname='';
        newname=tempname;
        newname(Periindex:Periindex+3)='Endo';

    elseif (~isempty(PERIindex)) %ALL CAPS
        newname='';
        newname=tempname;
        newname(PERIindex:PERIindex+3)='ENDO';
    end

    ObjectVertices.(newname)(:,1)=ObjectVertices.(newname)(:,1)+dx;
    ObjectVertices.(newname)(:,2)=ObjectVertices.(newname)(:,2)+dy;
end