path = '/Volumes/L_MillerLab/data/Pop_18E3/Videos'
dates = ["20210712","20210814","20210816","20211105","20211108","20211111","20220203","20220210","20220224","20220309","20220405"]

% for ind = = (1:length(dates))    
% strcat(path, dates(i))
% end

test_path = "/Volumes/L_MillerLab/data/Pop_18E3/Videos/20210712/Data/cam_0.avi"
info = mmfileinfo(test_path);
info.Video

% obj = VideoReader(test_path)
% a = read(obj)
% frames = get(obj, 'numberOfFrames')
% for k = 1:frames-1
% I(k).cdata = a(:,:,:,k)
% I(k).colormap = []
% end
% 
% implay(I)




% 
% get(movieObj) % display all information about movie
% nFrames = movieObj.NumberOfFrames; %shows 310 in my case
% for iFrame=1:10
%     I = read(movieObj,iFrame); % get one RGB image
%     imshow(I,[]); % Display image
% end