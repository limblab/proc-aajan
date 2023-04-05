plot_linklengthss('/Volumes/fsmresfiles/Basic_Sciences/Phys/L_MillerLab/limblab/User_folders/Aajan/Jarvis_results/data3D_20210712.csv','20210712')

function [fig, linklengths] = plot_linklengthss(filepath,date)
% This takes in the CSV file of Jarvis' full video predictions and
% generates a series of histograms for each linklenght we're interested in

% Inputs:
%   filepath - ie '/Users/ercrg/LimbLab/data/Pop_18E3/DPZ/results/data3D_20210712.csv'
%   date - only included to title the figure. There's probably a better way to parse the file name for the date
%
% eg

data = readmatrix(filepath);
%% set up landmarks

pinky_t = [1 2 3];
pinky_d = [4 5 6];
pinky_m = [7 8 9];
pinky_p = [10 11 12];

ring_t = [13 14 15];
ring_d = [16 17 18];
ring_m = [19 20 21];
ring_p = [22 23 24];

middle_t = [25 26 27];
middle_d = [28 29 30];
middle_m = [31 32 33];
middle_p = [34 35 36];

index_t = [37 38 39];
index_d = [40 41 42];
index_m = [43 44 45];
index_p = [46 47 48];

thumb_t = [49 50 51];
thumb_d = [52 53 54];
thumb_m = [55 56 57];
thumb_p = [58 59 60];

wrist_r = [67 68 69];

%% setup distances

pinky_td = zeros(size(data,1), 1);
pinky_dm = zeros(size(data,1), 1);
pinky_mp = zeros(size(data,1), 1);
pinky_p_wrist = zeros(size(data,1), 1);

ring_td = zeros(size(data,1), 1);
ring_dm = zeros(size(data,1), 1);
ring_mp = zeros(size(data,1), 1);
ring_p_wrist = zeros(size(data,1), 1);

middle_td = zeros(size(data,1), 1);
middle_dm = zeros(size(data,1), 1);
middle_mp = zeros(size(data,1), 1);
middle_p_wrist = zeros(size(data,1), 1);

index_td = zeros(size(data,1), 1);
index_dm = zeros(size(data,1), 1);
index_mp = zeros(size(data,1), 1);
index_p_wrist = zeros(size(data,1), 1);

thumb_td = zeros(size(data,1), 1);
thumb_dm = zeros(size(data,1), 1);
thumb_mp = zeros(size(data,1), 1);
thumb_p_wrist = zeros(size(data,1), 1);

%% get distances

for frame = 1:size(data,1)
    pinky_td(frame) = sqrt((data(frame,pinky_d(1))-data(frame,pinky_t(1)))^2 + (data(frame,pinky_d(2))-data(frame,pinky_t(2)))^2 + (data(frame,pinky_d(3))-data(frame,pinky_t(3)))^2);
    pinky_dm(frame) = sqrt((data(frame,pinky_m(1))-data(frame,pinky_d(1)))^2 + (data(frame,pinky_m(2))-data(frame,pinky_d(2)))^2 + (data(frame,pinky_m(3))-data(frame,pinky_d(3)))^2);
    pinky_mp(frame) = sqrt((data(frame,pinky_p(1))-data(frame,pinky_m(1)))^2 + (data(frame,pinky_p(2))-data(frame,pinky_m(2)))^2 + (data(frame,pinky_p(3))-data(frame,pinky_m(3)))^2);
    pinky_p_wrist(frame) = sqrt((data(frame,wrist_r(1))-data(frame,pinky_p(1)))^2 + (data(frame,wrist_r(2))-data(frame,pinky_p(2)))^2 + (data(frame,wrist_r(3))-data(frame,pinky_p(3)))^2);

    ring_td(frame) = sqrt((data(frame,ring_d(1))-data(frame,ring_t(1)))^2 + (data(frame,ring_d(2))-data(frame,ring_t(2)))^2 + (data(frame,ring_d(3))-data(frame,ring_t(3)))^2);
    ring_dm(frame) = sqrt((data(frame,ring_m(1))-data(frame,ring_d(1)))^2 + (data(frame,ring_m(2))-data(frame,ring_d(2)))^2 + (data(frame,ring_m(3))-data(frame,ring_d(3)))^2);
    ring_mp(frame) = sqrt((data(frame,ring_p(1))-data(frame,ring_m(1)))^2 + (data(frame,ring_p(2))-data(frame,ring_m(2)))^2 + (data(frame,ring_p(3))-data(frame,ring_m(3)))^2);
    ring_p_wrist(frame) = sqrt((data(frame,wrist_r(1))-data(frame,ring_p(1)))^2 + (data(frame,wrist_r(2))-data(frame,ring_p(2)))^2 + (data(frame,wrist_r(3))-data(frame,ring_p(3)))^2);

    middle_td(frame) = sqrt((data(frame,middle_d(1))-data(frame,middle_t(1)))^2 + (data(frame,middle_d(2))-data(frame,middle_t(2)))^2 + (data(frame,middle_d(3))-data(frame,middle_t(3)))^2);
    middle_dm(frame) = sqrt((data(frame,middle_m(1))-data(frame,middle_d(1)))^2 + (data(frame,middle_m(2))-data(frame,middle_d(2)))^2 + (data(frame,middle_m(3))-data(frame,middle_d(3)))^2);
    middle_mp(frame) = sqrt((data(frame,middle_p(1))-data(frame,middle_m(1)))^2 + (data(frame,middle_p(2))-data(frame,middle_m(2)))^2 + (data(frame,middle_p(3))-data(frame,middle_m(3)))^2);
    middle_p_wrist(frame) = sqrt((data(frame,wrist_r(1))-data(frame,middle_p(1)))^2 + (data(frame,wrist_r(2))-data(frame,middle_p(2)))^2 + (data(frame,wrist_r(3))-data(frame,middle_p(3)))^2);

    index_td(frame) = sqrt((data(frame,index_d(1))-data(frame,index_t(1)))^2 + (data(frame,index_d(2))-data(frame,index_t(2)))^2 + (data(frame,index_d(3))-data(frame,index_t(3)))^2);
    index_dm(frame) = sqrt((data(frame,index_m(1))-data(frame,index_d(1)))^2 + (data(frame,index_m(2))-data(frame,index_d(2)))^2 + (data(frame,index_m(3))-data(frame,index_d(3)))^2);
    index_mp(frame) = sqrt((data(frame,index_p(1))-data(frame,index_m(1)))^2 + (data(frame,index_p(2))-data(frame,index_m(2)))^2 + (data(frame,index_p(3))-data(frame,index_m(3)))^2);
    index_p_wrist(frame) = sqrt((data(frame,wrist_r(1))-data(frame,index_p(1)))^2 + (data(frame,wrist_r(2))-data(frame,index_p(2)))^2 + (data(frame,wrist_r(3))-data(frame,index_p(3)))^2);

    thumb_td(frame) = sqrt((data(frame,thumb_d(1))-data(frame,thumb_t(1)))^2 + (data(frame,thumb_d(2))-data(frame,thumb_t(2)))^2 + (data(frame,thumb_d(3))-data(frame,thumb_t(3)))^2);
    thumb_dm(frame) = sqrt((data(frame,thumb_m(1))-data(frame,thumb_d(1)))^2 + (data(frame,thumb_m(2))-data(frame,thumb_d(2)))^2 + (data(frame,thumb_m(3))-data(frame,thumb_d(3)))^2);
    thumb_mp(frame) = sqrt((data(frame,thumb_p(1))-data(frame,thumb_m(1)))^2 + (data(frame,thumb_p(2))-data(frame,thumb_m(2)))^2 + (data(frame,thumb_p(3))-data(frame,thumb_m(3)))^2);
    thumb_p_wrist(frame) = sqrt((data(frame,wrist_r(1))-data(frame,thumb_p(1)))^2 + (data(frame,wrist_r(2))-data(frame,thumb_p(2)))^2 + (data(frame,wrist_r(3))-data(frame,thumb_p(3)))^2);

end

linklengths = cat(2, pinky_td, pinky_dm, pinky_mp, pinky_p_wrist, ring_td, ring_dm, ring_mp, ring_p_wrist, middle_td, middle_dm, middle_mp, middle_p_wrist, index_td, index_dm, index_mp, index_p_wrist, thumb_td, thumb_dm, thumb_mp, thumb_p_wrist);
%% plot

fig = figure;

%pinky
subplot(5,4,1)
histogram(linklengths(:,1))
title('Pinky T - D')
xline(11.23, 'r', 'LineWidth', 1)

subplot(5,4,2)
histogram(linklengths(:,2))
title('Pinky D - M')
xline(21.33, 'r', 'LineWidth', 1)

subplot(5,4,3)
histogram(linklengths(:,3))
title('Pinky M - P')
xline(28.46, 'r', 'LineWidth', 1)

subplot(5,4,4)
histogram(linklengths(:,4))
title('Pinky P - Wrist R')
xline(45.1, 'r', 'LineWidth', 1)

% ring
subplot(5,4,5)
histogram(linklengths(:,5))
title('Ring T - D')
xline(15.21, 'r', 'LineWidth', 1)

subplot(5,4,6)
histogram(linklengths(:,6))
title('Ring D - M')
xline(20.75, 'r', 'LineWidth', 1)

subplot(5,4,7)
histogram(linklengths(:,7))
title('Ring M - P')
xline(36.22, 'r', 'LineWidth', 1)

subplot(5,4,8)
histogram(linklengths(:,8))
title('Ring P - Wrist R')
xline(45.51, 'r', 'LineWidth', 1)

% middle
subplot(5,4,9)
histogram(linklengths(:,9))
title('Middle T - D')
xline(14.75, 'r', 'LineWidth', 1)

subplot(5,4,10)
histogram(linklengths(:,10))
title('Middle D - M')
xline(22.93, 'r', 'LineWidth', 1)

subplot(5,4,11)
histogram(linklengths(:,11))
title('Middle M - P')
xline(33.84, 'r', 'LineWidth', 1)

subplot(5,4,12)
histogram(linklengths(:,12))
title('Middle P - Wrist R')
xline(44.77, 'r', 'LineWidth', 1)

% index
subplot(5,4,13)
histogram(linklengths(:,13))
title('Index T - D')
xline(11.48, 'r', 'LineWidth', 1)

subplot(5,4,14)
histogram(linklengths(:,14))
title('Index D - M')
xline(19.28, 'r', 'LineWidth', 1)

subplot(5,4,15)
histogram(linklengths(:,15))
title('Index M - P')
xline(32.16, 'r', 'LineWidth', 1)

subplot(5,4,16)
histogram(linklengths(:,16))
title('Index P - Wrist R')
xline(44.36, 'r', 'LineWidth', 1)

% thumb
subplot(5,4,17)
histogram(linklengths(:,17))
title('Thumb T - D')
xline(13.26, 'r', 'LineWidth', 1)

subplot(5,4,18)
histogram(linklengths(:,18))
title('Thumb D - M')
xline(17.19, 'r', 'LineWidth', 1)

subplot(5,4,19)
histogram(linklengths(:,19))
title('Thumb M - P')
xline(20.23, 'r', 'LineWidth', 1)

subplot(5,4,20)
histogram(linklengths(:,20))
title('Thumb P - Wrist R')
xline(21.61, 'r', 'LineWidth', 1)

sgtitle(strcat('Pop Linklengths - ', string(date)))

end