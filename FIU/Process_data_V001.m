clear all
close all
clc

% NBNBNB PER SESSIONE 1108 ELIMINA I PRIMI 4 MUSCLI CHE SONO TOTALMENTO PIATTI.
% eliminali anche da EMG_names

%% Load data

addpath(genpath('/Users/chiaraciucci/Library/CloudStorage/OneDrive-UniversityofPisa/Master Thesis/codes'));
%num_sess_mat = '/Users/chiaraciucci/Downloads/test/20220309_Pop_FR_001.mat';
data=importdata('/Users/chiaraciucci/Library/CloudStorage/OneDrive-UniversityofPisa/Master Thesis/Data/Pop/Cerebus_data/20210712/20210712_Pop_FR_01.mat');
base_dir='/Users/chiaraciucci/Library/CloudStorage/OneDrive-UniversityofPisa/Master Thesis/Data/Pop/Cerebus_data/20211108/';
xlabels=data.EMG_names;
xlabels = erase(xlabels,"EMG_");
T=data.raw_EMG_time_frame(3)-data.raw_EMG_time_frame(2); 
fs=1/T;

%% Check if there are problems with the EMG plotting it

% raw EMG in time domain
figure;
for musc_n=1:size(data.raw_EMG,2)

    subplot(round(size(data.raw_EMG,2)/2),2,musc_n)
    plot(data.raw_EMG_time_frame  , data.raw_EMG(:,musc_n));
    title(xlabels(musc_n));
    xlabel('Time (s)')
    ylabel('Voltage (mV)');

end

% raw EMG Power spectrum (frequency domain)

figure;
sgtitle('Power spectrum using fft');

for musc_n=1:size(data.raw_EMG,2)

    IM=fftshift(fft(data.raw_EMG(:,musc_n))); %commando to create the fft
    N=length(data.raw_EMG(:,musc_n));
    f = (-N/2:N/2-1)*(fs/N);
    subplot(round(size(data.raw_EMG,2)/2),2,musc_n)
    plot(f,abs(IM).^2/N);
    title(xlabels(musc_n));
    xlabel('frequency(Hz)');
    ylabel('Power spectrum');

end

%% Check if there are problems with the joint angles plotting it
% raw EMG in time domain
figure;
%range=(1000:2000);
range=1:length(data.joint_angle_time_frame);
for musc_n=1:size(data.joint_angles,2)

    subplot(round(size(data.joint_angles,2)/2),2,musc_n)
    plot(data.joint_angle_time_frame(range)  , data.joint_angles(range,musc_n));
%     title(data.joint_names(musc_n));
%     xlabel('Time (s)')
%     ylabel('Voltage (mV)');

end

% raw EMG Power spectrum (frequency domain)
T_ja=data.joint_angle_time_frame(3)-data.joint_angle_time_frame(2); 
fs_ja=1/T_ja;


figure;
sgtitle('Power spectrum using fft');

for musc_n=1:size(data.joint_angles,2)

      [pxx,f] = pwelch(data.joint_angles(:,musc_n),300,[],[],30);
    subplot(round(size(data.joint_angles,2)/5),5,musc_n)
    loglog((f),(pxx))
    xlabel('frequency(Hz)');
    ylabel('Power spectrum');
     title(data.joint_names(musc_n));
%     xlabel('frequency(Hz)');
%     ylabel('Power spectrum');

end


%% EMG FILTERING AND OUTLIER REMOVAL

emg_data= process_emg(data.raw_EMG,fs,data.meta.cdsName); %hp, rectify, low pass, notch
if strcmp(data.meta.cdsName,'Pop_M1_FR_2021-7-12_lab1')
    emg_data(:,12)=[];
    data.EMG_names(:,12)=[];
elseif strcmp(data.meta.cdsName,'Pop_M1_FR_2021-8-14_lab1')
    emg_data(:,10:11)=[];
    data.EMG_names(:,10:11)=[];
elseif strcmp(data.meta.cdsName,'Pop_M1_FR_2021-11-5_lab1')
    emg_data(:,1)=[];
    data.EMG_names(:,1)=[];
elseif strcmp(data.meta.cdsName,'Pop_M1_FR_2021-11-8_lab1')
    emg_data(:,1:4)=[];
    data.EMG_names(:,1:4)=[];
end %hp, rectify, low pass, notch
% (frequency of the notch have to be manually checked each session),
% outlier removal

% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% figure;
% sgtitle( ' Power spectrum using fft');
% for musc_n=1:size(data.raw_EMG,2)
% 
%     IM=fftshift(fft(emg_data(:,musc_n))); %commando to create the fft
%     N=length(emg_data(:,musc_n));
%     f = (0:N/2-1)*(fs/N);
%     subplot(round(size(data.raw_EMG,2)/2),2,musc_n)
%     plot(f,abs(IM(end/2:end-1, :)).^2/N);
%     title(data.EMG_names(musc_n));
%     xlabel('frequency(Hz)')
%     ylabel('Power spectrum');
% 
% end
% figure;
% plot(data.raw_EMG_time_frame, data.raw_EMG(:,6));
% hold on
% plot(data.raw_EMG_time_frame, emg_data(:,6));
% title(data.EMG_names(6));
% xlabel('time(s)')
% ylabel('Voltage (mV)');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%emg_data(:,1)=[]; %for session 20211105
data.EMG=emg_data;

%% EMG RESAMPLING

new_bin_size = 1/30;
[time_frames_EMG, EMG] = resample_EMG_ch(data, new_bin_size);
data.new_time_frames_EMG =time_frames_EMG;

%[EMG, time_framee,diff] = resample_EMG_camera(data,emg_data, bin_size);  %resampling
%% EMG NORMALIZATION

data.EMG = EMG./prctile(EMG,90);    

%% JA conversion to deg

data.joint_angles(:,2:3)=rad2deg(data.joint_angles(:,2:3));
data.joint_angles(end,:)=[]; %I delete the last sample so that EMG and Joint angles have the same length
data.joint_angle_time_frame(end)=[];

%% JA normalization

%data.joint_angles= data.joint_angles./prctile(data.joint_angles,90);

%% JA velocity
data.joint_velocity=diff(data.joint_angles)./data.joint_angle_time_frame(2)-data.joint_angle_time_frame(1);
fc=5;
fs_kin=30;
wn=fc/(fs_kin/2);
[b,a]=butter(4,wn,'low');
data.joint_velocity_filt=filtfilt(b,a,data.joint_velocity);


figure;
sgtitle('Power spectrum using fft');
ind=1
for musc_n=1:size(data.joint_velocity,2)

      [pxx,f] = pwelch(data.joint_velocity(:,musc_n),300,[],[],30);
    subplot(round(size(data.joint_angles,2)/5),5,ind)
    loglog(f,pxx)
    xlabel('frequency(Hz)');
    ylabel('Power spectrum');
     title(data.joint_names(ind));
%     xlabel('frequency(Hz)');
%     ylabel('Power spectrum');
ind=ind+1;

end

figure;
range=(1100:1500);
%range=1:length(data.joint_angle_time_frame)-1;
ind=1
for musc_n=21:24 %size(data.joint_velocity,2)

    subplot(2,2,ind) %round(size(data.joint_velocity,2)/2)
    plot(data.joint_angle_time_frame(range)  , data.joint_angles(range,musc_n));
    hold on
     plot(data.joint_angle_time_frame(range)  , data.joint_velocity_filt(range,musc_n));
     title(data.joint_names(musc_n));
%     xlabel('Time (s)')
     ylabel('deg/s');
ind=ind+1;

end
%%
figure;

ind=1
for musc_n=1:size(data.joint_velocity,2)
    v_median=median(data.joint_velocity_filt(:,musc_n));

     subplot(round(size(data.joint_angles,2)/5),5,ind)
    histogram( data.joint_velocity_filt(:,musc_n));
    title(strcat(data.joint_names(musc_n), num2str(v_median)));
%     xlabel('Time (s)')
     
ind=ind+1;

end

%% Neural data binning and smoothing
%[time_frames,spike_counts] = bin_spikes(data, bin_size);
% n_bins=length(data.joint_angle_time_frame);
% spike_counts = zeros(length(data.joint_angle_time_frame), length(data.unit_names));
% 
% for ii = 1:length(data.unit_names)
%     spike_counts(:,ii) = histcounts(cell2mat(data.spikes(ii)), n_bins);
% end
new_bin_size = 1/30;
[spike_counts, new_xds] = bin_spikes_camera33_EMG(data, new_bin_size);
[smoothed_spike_counts] = smooth_spike_counts(new_xds);
data.smoothed_spike_counts = smoothed_spike_counts;

%data.joint_angles(36001:end,:)=[];
%% remove the first sample of the data to equalize the number of samples with the derivative
data.EMG(1,:)=[];
data.smoothed_spike_counts(1,:)=[];
data.joint_angles(1,:)=[];
data.new_time_frames_EMG(end,:)=[];
data.joint_angle_time_frame(end,:)=[];
%% Saving the new XDS struct
if size(data.joint_angles,1) == size(data.smoothed_spike_counts,1) && size(data.joint_angles,1) == size(data.EMG  ,1)
disp('Saving');
save(strcat(base_dir, data.meta.rawFileName, '_proc'), 'data', '-v7.3');
else
    disp('Check the time length of the data');
end

