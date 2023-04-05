files = dir('*.fig');

for file = files'
    disp(file.name)
    fig = openfig(file.name);
    h = gcf; %current figure handle
    axesObjs = get(h, 'Children');  %axes handles
    dataObjs = get(axesObjs, 'Children'); %handles t
    for i=1:3
        X = get(dataObjs{12,1}(i), 'XData');
        Y = get(dataObjs{12,1}(i), 'YData');
        disp(size(X))
    end
    close(fig)
end
%%
fig = openfig('Axillary500uA.fig');
h = gcf; %current figure handle
axesObjs = get(h, 'Children');  %axes handles
dataObjs = get(axesObjs, 'Children'); %handles t
for i=2:2:6
    X = get(dataObjs{12,1}(i), 'XData');
    Y = get(dataObjs{12,1}(i), 'YData');
    disp(size(X))
end