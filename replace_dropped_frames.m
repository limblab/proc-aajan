%% RUN THIS SECTION TO OUTPUT NEW MP4 FILES
% The purpose of this script is to insert new frames into videos with
% dropped frames

clear
clc
% list all video and log files
logfiles = {'R:\Basic_Sciences\Phys\L_MillerLab\data\Pop_18E3\Videos\20220203\data-UChicago\cam_1_logfile.txt', 'R:\Basic_Sciences\Phys\L_MillerLab\data\Pop_18E3\Videos\20220203\data-UChicago\cam_2_logfile.txt', 'R:\Basic_Sciences\Phys\L_MillerLab\data\Pop_18E3\Videos\20220203\data-UChicago\cam_3_logfile.txt'};
vidfiles = {'R:\Basic_Sciences\Phys\L_MillerLab\data\Pop_18E3\Videos\20220203\data-UChicago\cam_1.avi', 'R:\Basic_Sciences\Phys\L_MillerLab\data\Pop_18E3\Videos\20220203\data-UChicago\cam_2.avi', 'R:\Basic_Sciences\Phys\L_MillerLab\data\Pop_18E3\Videos\20220203\data-UChicago\cam_3.avi'};
% logfiles = {'R:\Basic_Sciences\Phys\L_MillerLab\data\Pop_18E3\Videos\20210712\Data\cam_0_logfile.txt',};
% vidfiles = {'R:\Basic_Sciences\Phys\L_MillerLab\data\Pop_18E3\Videos\20210712\Data\cam_0.avi'};
% logfiles = {'R:\Basic_Sciences\Phys\L_MillerLab\data\Pop_18E3\Videos\20210712\Data\cam_1_logfile.txt','R:\Basic_Sciences\Phys\L_MillerLab\data\Pop_18E3\Videos\20210712\Data\cam_3_logfile.txt','R:\Basic_Sciences\Phys\L_MillerLab\data\Pop_18E3\Videos\20210712\Data\cam_2_logfile.txt','R:\Basic_Sciences\Phys\L_MillerLab\data\Pop_18E3\Videos\20210712\Data\cam_0_logfile.txt','R:\Basic_Sciences\Phys\L_MillerLab\data\Pop_18E3\Videos\20210814\data\cam_1_logfile.txt','R:\Basic_Sciences\Phys\L_MillerLab\data\Pop_18E3\Videos\20210814\data\cam_3_logfile.txt','R:\Basic_Sciences\Phys\L_MillerLab\data\Pop_18E3\Videos\20210814\data\cam_2_logfile.txt','R:\Basic_Sciences\Phys\L_MillerLab\data\Pop_18E3\Videos\20210814\data\cam_0_logfile.txt','R:\Basic_Sciences\Phys\L_MillerLab\data\Pop_18E3\Videos\20210816\data\cam_1_logfile.txt','R:\Basic_Sciences\Phys\L_MillerLab\data\Pop_18E3\Videos\20210816\data\cam_3_logfile.txt','R:\Basic_Sciences\Phys\L_MillerLab\data\Pop_18E3\Videos\20210816\data\cam_2_logfile.txt','R:\Basic_Sciences\Phys\L_MillerLab\data\Pop_18E3\Videos\20210816\data\cam_0_logfile.txt','R:\Basic_Sciences\Phys\L_MillerLab\data\Pop_18E3\Videos\20211105\data\cam_1_logfile.txt','R:\Basic_Sciences\Phys\L_MillerLab\data\Pop_18E3\Videos\20211105\data\cam_3_logfile.txt','R:\Basic_Sciences\Phys\L_MillerLab\data\Pop_18E3\Videos\20211105\data\cam_2_logfile.txt','R:\Basic_Sciences\Phys\L_MillerLab\data\Pop_18E3\Videos\20211105\data\cam_0_logfile.txt','R:\Basic_Sciences\Phys\L_MillerLab\data\Pop_18E3\Videos\20211108\data\cam_1_logfile.txt','R:\Basic_Sciences\Phys\L_MillerLab\data\Pop_18E3\Videos\20211108\data\cam_3_logfile.txt','R:\Basic_Sciences\Phys\L_MillerLab\data\Pop_18E3\Videos\20211108\data\cam_2_logfile.txt','R:\Basic_Sciences\Phys\L_MillerLab\data\Pop_18E3\Videos\20211108\data\cam_0_logfile.txt','R:\Basic_Sciences\Phys\L_MillerLab\data\Pop_18E3\Videos\20211111\data\cam_1_logfile.txt','R:\Basic_Sciences\Phys\L_MillerLab\data\Pop_18E3\Videos\20211111\data\cam_3_logfile.txt','R:\Basic_Sciences\Phys\L_MillerLab\data\Pop_18E3\Videos\20211111\data\cam_2_logfile.txt','R:\Basic_Sciences\Phys\L_MillerLab\data\Pop_18E3\Videos\20211111\data\cam_0_logfile.txt','R:\Basic_Sciences\Phys\L_MillerLab\data\Pop_18E3\Videos\20220203\data\UChicago/cam_1_logfile.txt','R:\Basic_Sciences\Phys\L_MillerLab\data\Pop_18E3\Videos\20220203\data\UChicago/cam_3_logfile.txt','R:\Basic_Sciences\Phys\L_MillerLab\data\Pop_18E3\Videos\20220203\data\UChicago/cam_2_logfile.txt','R:\Basic_Sciences\Phys\L_MillerLab\data\Pop_18E3\Videos\20220203\data\UChicago/cam_0_logfile.txt','R:\Basic_Sciences\Phys\L_MillerLab\data\Pop_18E3\Videos\20220210\data\Pipe/cam_1_logfile.txt','R:\Basic_Sciences\Phys\L_MillerLab\data\Pop_18E3\Videos\20220210\data\Pipe/cam_3_logfile.txt','R:\Basic_Sciences\Phys\L_MillerLab\data\Pop_18E3\Videos\20220210\data\Pipe/cam_2_logfile.txt','R:\Basic_Sciences\Phys\L_MillerLab\data\Pop_18E3\Videos\20220210\data\Pipe/cam_0_logfile.txt','R:\Basic_Sciences\Phys\L_MillerLab\data\Pop_18E3\Videos\20220210\data\UChicago/cam_1_logfile.txt','R:\Basic_Sciences\Phys\L_MillerLab\data\Pop_18E3\Videos\20220210\data\UChicago/cam_3_logfile.txt','R:\Basic_Sciences\Phys\L_MillerLab\data\Pop_18E3\Videos\20220210\data\UChicago/cam_2_logfile.txt','R:\Basic_Sciences\Phys\L_MillerLab\data\Pop_18E3\Videos\20220210\data\UChicago/cam_0_logfile.txt','R:\Basic_Sciences\Phys\L_MillerLab\data\Pop_18E3\Videos\20220224\data\cam_1_logfile.txt','R:\Basic_Sciences\Phys\L_MillerLab\data\Pop_18E3\Videos\20220224\data\cam_3_logfile.txt','R:\Basic_Sciences\Phys\L_MillerLab\data\Pop_18E3\Videos\20220224\data\cam_2_logfile.txt','R:\Basic_Sciences\Phys\L_MillerLab\data\Pop_18E3\Videos\20220224\data\cam_0_logfile.txt','R:\Basic_Sciences\Phys\L_MillerLab\data\Pop_18E3\Videos\20220309\data\cam_1_logfile.txt','R:\Basic_Sciences\Phys\L_MillerLab\data\Pop_18E3\Videos\20220309\data\cam_3_logfile.txt','R:\Basic_Sciences\Phys\L_MillerLab\data\Pop_18E3\Videos\20220309\data\cam_2_logfile.txt','R:\Basic_Sciences\Phys\L_MillerLab\data\Pop_18E3\Videos\20220309\data\cam_0_logfile.txt','R:\Basic_Sciences\Phys\L_MillerLab\data\Pop_18E3\Videos\20220309\data1\cam_1_logfile.txt','R:\Basic_Sciences\Phys\L_MillerLab\data\Pop_18E3\Videos\20220309\data1\cam_3_logfile.txt','R:\Basic_Sciences\Phys\L_MillerLab\data\Pop_18E3\Videos\20220309\data1\cam_2_logfile.txt','R:\Basic_Sciences\Phys\L_MillerLab\data\Pop_18E3\Videos\20220309\data1\cam_0_logfile.txt','R:\Basic_Sciences\Phys\L_MillerLab\data\Pop_18E3\Videos\20220405\data_pipe\cam_1_logfile.txt','R:\Basic_Sciences\Phys\L_MillerLab\data\Pop_18E3\Videos\20220405\data_pipe\cam_3_logfile.txt','R:\Basic_Sciences\Phys\L_MillerLab\data\Pop_18E3\Videos\20220405\data_pipe\cam_2_logfile.txt','R:\Basic_Sciences\Phys\L_MillerLab\data\Pop_18E3\Videos\20220405\data_pipe\cam_0_logfile.txt','R:\Basic_Sciences\Phys\L_MillerLab\data\Pop_18E3\Videos\20220405\data_uc\cam_1_logfile.txt','R:\Basic_Sciences\Phys\L_MillerLab\data\Pop_18E3\Videos\20220405\data_uc\cam_3_logfile.txt','R:\Basic_Sciences\Phys\L_MillerLab\data\Pop_18E3\Videos\20220405\data_uc\cam_2_logfile.txt','R:\Basic_Sciences\Phys\L_MillerLab\data\Pop_18E3\Videos\20220405\data_uc\cam_0_logfile.txt'};
% vidfiles = {'R:\Basic_Sciences\Phys\L_MillerLab\data\Pop_18E3\Videos\20210712\Data\cam_1.avi','R:\Basic_Sciences\Phys\L_MillerLab\data\Pop_18E3\Videos\20210712\Data\cam_3.avi','R:\Basic_Sciences\Phys\L_MillerLab\data\Pop_18E3\Videos\20210712\Data\cam_2.avi','R:\Basic_Sciences\Phys\L_MillerLab\data\Pop_18E3\Videos\20210712\Data\cam_0.avi','R:\Basic_Sciences\Phys\L_MillerLab\data\Pop_18E3\Videos\20210814\data\cam_1.avi','R:\Basic_Sciences\Phys\L_MillerLab\data\Pop_18E3\Videos\20210814\data\cam_3.avi','R:\Basic_Sciences\Phys\L_MillerLab\data\Pop_18E3\Videos\20210814\data\cam_2.avi','R:\Basic_Sciences\Phys\L_MillerLab\data\Pop_18E3\Videos\20210814\data\cam_0.avi','R:\Basic_Sciences\Phys\L_MillerLab\data\Pop_18E3\Videos\20210816\data\cam_1.avi','R:\Basic_Sciences\Phys\L_MillerLab\data\Pop_18E3\Videos\20210816\data\cam_3.avi','R:\Basic_Sciences\Phys\L_MillerLab\data\Pop_18E3\Videos\20210816\data\cam_2.avi','R:\Basic_Sciences\Phys\L_MillerLab\data\Pop_18E3\Videos\20210816\data\cam_0.avi','R:\Basic_Sciences\Phys\L_MillerLab\data\Pop_18E3\Videos\20211105\data\cam_1.avi','R:\Basic_Sciences\Phys\L_MillerLab\data\Pop_18E3\Videos\20211105\data\cam_3.avi','R:\Basic_Sciences\Phys\L_MillerLab\data\Pop_18E3\Videos\20211105\data\cam_2.avi','R:\Basic_Sciences\Phys\L_MillerLab\data\Pop_18E3\Videos\20211105\data\cam_0.avi','R:\Basic_Sciences\Phys\L_MillerLab\data\Pop_18E3\Videos\20211108\data\cam_1.avi','R:\Basic_Sciences\Phys\L_MillerLab\data\Pop_18E3\Videos\20211108\data\cam_3.avi','R:\Basic_Sciences\Phys\L_MillerLab\data\Pop_18E3\Videos\20211108\data\cam_2.avi','R:\Basic_Sciences\Phys\L_MillerLab\data\Pop_18E3\Videos\20211108\data\cam_0.avi','R:\Basic_Sciences\Phys\L_MillerLab\data\Pop_18E3\Videos\20211111\data\cam_1.avi','R:\Basic_Sciences\Phys\L_MillerLab\data\Pop_18E3\Videos\20211111\data\cam_3.avi','R:\Basic_Sciences\Phys\L_MillerLab\data\Pop_18E3\Videos\20211111\data\cam_2.avi','R:\Basic_Sciences\Phys\L_MillerLab\data\Pop_18E3\Videos\20211111\data\cam_0.avi','R:\Basic_Sciences\Phys\L_MillerLab\data\Pop_18E3\Videos\20220203\data\UChicago/cam_1.avi','R:\Basic_Sciences\Phys\L_MillerLab\data\Pop_18E3\Videos\20220203\data\UChicago/cam_3.avi','R:\Basic_Sciences\Phys\L_MillerLab\data\Pop_18E3\Videos\20220203\data\UChicago/cam_2.avi','R:\Basic_Sciences\Phys\L_MillerLab\data\Pop_18E3\Videos\20220203\data\UChicago/cam_0.avi','R:\Basic_Sciences\Phys\L_MillerLab\data\Pop_18E3\Videos\20220210\data\Pipe/cam_1.avi','R:\Basic_Sciences\Phys\L_MillerLab\data\Pop_18E3\Videos\20220210\data\Pipe/cam_3.avi','R:\Basic_Sciences\Phys\L_MillerLab\data\Pop_18E3\Videos\20220210\data\Pipe/cam_2.avi','R:\Basic_Sciences\Phys\L_MillerLab\data\Pop_18E3\Videos\20220210\data\Pipe/cam_0.avi','R:\Basic_Sciences\Phys\L_MillerLab\data\Pop_18E3\Videos\20220210\data\UChicago/cam_1.avi','R:\Basic_Sciences\Phys\L_MillerLab\data\Pop_18E3\Videos\20220210\data\UChicago/cam_3.avi','R:\Basic_Sciences\Phys\L_MillerLab\data\Pop_18E3\Videos\20220210\data\UChicago/cam_2.avi','R:\Basic_Sciences\Phys\L_MillerLab\data\Pop_18E3\Videos\20220210\data\UChicago/cam_0.avi','R:\Basic_Sciences\Phys\L_MillerLab\data\Pop_18E3\Videos\20220224\data\cam_1.avi','R:\Basic_Sciences\Phys\L_MillerLab\data\Pop_18E3\Videos\20220224\data\cam_3.avi','R:\Basic_Sciences\Phys\L_MillerLab\data\Pop_18E3\Videos\20220224\data\cam_2.avi','R:\Basic_Sciences\Phys\L_MillerLab\data\Pop_18E3\Videos\20220224\data\cam_0.avi','R:\Basic_Sciences\Phys\L_MillerLab\data\Pop_18E3\Videos\20220309\data\cam_1.avi','R:\Basic_Sciences\Phys\L_MillerLab\data\Pop_18E3\Videos\20220309\data\cam_3.avi','R:\Basic_Sciences\Phys\L_MillerLab\data\Pop_18E3\Videos\20220309\data\cam_2.avi','R:\Basic_Sciences\Phys\L_MillerLab\data\Pop_18E3\Videos\20220309\data\cam_0.avi','R:\Basic_Sciences\Phys\L_MillerLab\data\Pop_18E3\Videos\20220309\data1\cam_1.avi','R:\Basic_Sciences\Phys\L_MillerLab\data\Pop_18E3\Videos\20220309\data1\cam_3.avi','R:\Basic_Sciences\Phys\L_MillerLab\data\Pop_18E3\Videos\20220309\data1\cam_2.avi','R:\Basic_Sciences\Phys\L_MillerLab\data\Pop_18E3\Videos\20220309\data1\cam_0.avi','R:\Basic_Sciences\Phys\L_MillerLab\data\Pop_18E3\Videos\20220405\data_pipe\cam_1.avi','R:\Basic_Sciences\Phys\L_MillerLab\data\Pop_18E3\Videos\20220405\data_pipe\cam_3.avi','R:\Basic_Sciences\Phys\L_MillerLab\data\Pop_18E3\Videos\20220405\data_pipe\cam_2.avi','R:\Basic_Sciences\Phys\L_MillerLab\data\Pop_18E3\Videos\20220405\data_pipe\cam_0.avi','R:\Basic_Sciences\Phys\L_MillerLab\data\Pop_18E3\Videos\20220405\data_uc\cam_1.avi','R:\Basic_Sciences\Phys\L_MillerLab\data\Pop_18E3\Videos\20220405\data_uc\cam_3.avi','R:\Basic_Sciences\Phys\L_MillerLab\data\Pop_18E3\Videos\20220405\data_uc\cam_2.avi','R:\Basic_Sciences\Phys\L_MillerLab\data\Pop_18E3\Videos\20220405\data_uc\cam_0.avi'};
 
%loop through each file
for i = 1:length(logfiles)
    logfile = logfiles{i};
    vidfile = vidfiles{i};
    
    % nfd = array of number of frames dropped at each timestamp. 0s included
    % duplicated_frames_ind = inds where nfd is greater than 0 (therefore, where frames will be duped)
    % num_timestamps = total number of timestamps before inserting dupes
    % timestamps = timestamps in logfile before inserting dupes
    [nfd, duplicated_frames_ind, num_timestamps, timestamps] = get_num_frames_dropped(logfile);
    
    % make a new logfile by inserting missing timestamps
    log_file_str = strcat(strcat(logfile(1:end-4), '_modified.txt'));
    make_new_logfile(nfd, timestamps, log_file_str);
    
    % create VideoReader object for avi file
    v = VideoReader(vidfile);
    
    %create video writer object to create new MP4 video
    file_str = strcat(strcat(vidfile(1:end-4), '_modified'));
    vidobj = VideoWriter(file_str, 'MPEG-4');
    open(vidobj);
    
    %since video  files are too big, break up into small chunks (in this case 100 frames at a time)
    breakup = 100;
    loops = num_timestamps/breakup;
    
    %1-100, 101-200, 201-300...
    for L = 1:loops
        %define beginning and end of video segment, create 100 frame segment
        first = breakup*L-(breakup-1);
        last = breakup*L;
        nfd_short = nfd(first:last);
        
        %read in video and insert frames
        short_vid = read(v, [first,last]);
        nv = insert_frames(nfd_short, short_vid);
        
        %write out video frame by frame
        s = size(nv);
        frames = s(4); %number of frames
        for f = 1:frames
            writeVideo(vidobj, nv(:,:,:,f))
        end
    end
    close(vidobj)
    
    %write out duplicate frames to txt file
    dup_frames_file_str = strcat(strcat(vidfile(1:end-4), '_duplicate_frames.txt'));
    write_dup_frames(nfd, duplicated_frames_ind, dup_frames_file_str);
    
    %display changes to file
    disp('original video duration, quality (bits per pixel), and framecount')
    disp(v.Duration)
    disp(v.BitsPerPixel)
    disp(v.NumFrames)
    disp('new video duration, quality (bits per pixel), and framecount')
    disp(vidobj.Duration)
    disp(vidobj.VideoBitsPerPixel)
    disp(vidobj.FrameCount)
end
 
%% Functions
function [num_frames_dropped, dup_frames, num_timestamps, timestamps] = get_num_frames_dropped(file)
    %read in table and make array
    table = readtable(file);
    timestamps = table2array(table);
    
    %get differences in timestamps
    difference = diff(timestamps);
    difference(end+1) = 0.033;
    
    %get number of total timestamps (used for breaking up video and looping)
    timestamps_shape = size(timestamps);
    num_timestamps = timestamps_shape(1);
    
    %get number of frames dropped and duplicated frames indices
    num_frames_dropped = round(difference/0.033) - 1;
    dup_frames = find(num_frames_dropped>0);
end
 
function new_vid = insert_frames(num_dropped_frames, vid)
%num_dropped_frames is an array with the number of frames dropped at each time point
%vid is the matrix containing the video before insertion
 
    new_vid = vid; %make copy of video
    inds_dup_frames = find(num_dropped_frames>0); %get indeces of where at least one frame is dropped
    
    disp('missing frames size and ind')
    disp(size(inds_dup_frames))
    disp(inds_dup_frames)
    
    %iterate through indeces where frames were dropped
    c = 0;
    for i = 1:length(inds_dup_frames)
        ind = inds_dup_frames(i);
        nf = num_dropped_frames(ind);
        for j = 1:nf
            new_vid = cat(4, new_vid(:,:,:,1:ind+c), new_vid(:,:,:,ind+c), new_vid(:,:,:,ind+c+1:end));
            c = c+1;
        end
    end
    
end
 
function make_new_logfile(num_dropped_frames, timestamps, log_file_str)
    new_timestamps = timestamps;
    inds_dup_frames = find(num_dropped_frames>0);
    
    %iterate through indeces where frames were dropped
    c = 0;
    for i = 1:length(inds_dup_frames)
        ind = inds_dup_frames(i);
        nf = num_dropped_frames(ind);
        for j = 1:nf
            new_timestamps = cat(1, new_timestamps(1:ind+c,:), new_timestamps(ind+c,:)+0.0333, new_timestamps(ind+c+1:end,:));
            c = c+1;
        end
    end
    
    disp('Old log file has this many timestamps')
    disp(size(timestamps))
    disp('This many frames were dropped')
    disp(sum(num_dropped_frames))
    disp('New log file will have this many timestamps')
    disp(size(new_timestamps))
    
    fid = fopen(log_file_str,'wt');  % Note the 'wt' for writing in text mode
    fprintf(fid,'%f\n',new_timestamps);  % The format string is applied to each element of a
    fclose(fid);
end
 
function write_dup_frames(num_frames_dropped, dup_frames_arr, file_str)
    num_frames_dropped_short = num_frames_dropped(dup_frames_arr); %removes all 0s
    cs = cumsum(num_frames_dropped_short); %gets cumulative sum
    cs = cat(1, 0, cs); %inserts zero at the beginning (shifts every element by 1 place)
    cs(end) = []; %drops last element
    new_dup_frames_arr = dup_frames_arr+cs; %adds cumsum to original indeces to get new indeces
    fid = fopen(file_str,'wt');  % Note the 'wt' for writing in text mode
    fprintf(fid,'%f\n',new_dup_frames_arr);  % The format string is applied to each element of array
    fclose(fid);
end
