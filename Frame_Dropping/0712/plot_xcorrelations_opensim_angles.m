data = readtable('/Volumes/L_MillerLab/limblab/User_folders/Eric/OpenSim/20210712_data3D_trimmed.mot','Filetype','Text');
non_nan_inds = readtable('/Users/aajanquail/Downloads/l_not_nan.csv');
opensim_angle_data = table2array(data);
non_nan_inds = table2array(non_nan_inds);
opensim_angle_data_nans_removed = opensim_angle_data(non_nan_inds+1,28:end);
figure
plot(opensim_angle_data_nans_removed(:,end))
opensim_angle_data_nans_removed = opensim_angle_data_nans_removed - mean(opensim_angle_data_nans_removed);
figure
plot(opensim_angle_data_nans_removed(:,end))
neural_data_struct_nans_removed = load(['/Users/aajanquail/Downloads/20210712_units_smoothed_nans_removed.mat']);

%%
elec86_1 = neural_data_struct_nans_removed.neural_data_nans_removed(105,:);
elec96_1 = neural_data_struct_nans_removed.neural_data_nans_removed(101,:);
elec51_1 = neural_data_struct_nans_removed.neural_data_nans_removed(81,:);
elec79_3 = neural_data_struct_nans_removed.neural_data_nans_removed(122,:);
elec40_1 = neural_data_struct_nans_removed.neural_data_nans_removed(133,:);

elec86_1 = elec86_1 - mean(elec86_1);
elec96_1 = elec96_1 - mean(elec96_1);
elec51_1 = elec51_1 - mean(elec51_1);
elec79_3 = elec79_3 - mean(elec79_3);
elec40_1 = elec40_1 - mean(elec40_1);

electrodes = {elec86_1,elec96_1,elec51_1,elec79_3,elec40_1};
electrode_nums = {86,96,51,79,40};

angle_names = {'Thumb CMC e-f','Thumb CMC opp','Thumb CMC ad-ab','Thumb MCP e-f','Thumb IP e-f','Index MCP e-f','Index MCP ad-ab','Index PIP e-f','Index DIP e-f','Middle MCP e-f','Middle MCP ad-ab','Middle PIP e-f','Middle DIP e-f','Ring MCP e-f','Ring MCP ad-ab','Ring PIP e-f','Ring DIP e-f','Pinky MCP e-f','Pinky MCP ad-ab','Pinky PIP e-f','Pinky DIP e-f'};

segments = {{690,989},{2130,2429},{4770,5069},{10890,11189},{12510,12809},{13080,13379},{16140,16439},{22050,22349},{26580,26879},{29160,29459}};
%%

for j = 1:size(opensim_angle_data_nans_removed,2)
    angle_name = angle_names{j};
    joint_angle = opensim_angle_data_nans_removed(:,j);
    figure
    hold on
    for i = 1:length(electrodes)
        electrode = electrodes{i};
        elec_num = electrode_nums{i};
        disp(elec_num);
        [neur_angle_xcorr,x] = xcorr(electrode, joint_angle, 150, 'coeff');
        x = x/30;
        plot(x,neur_angle_xcorr)
    end
    xlabel('Time (s)')
    ylabel('Neuron - Angle Xcorr')
    tit_str = strcat('Elec-', angle_name, ' xcorrelation (Whole Datastream)');
    legend('Elec86','Elec96','Elec51','Elec79','Elec40')
    title(tit_str)
    saveas(gcf,strcat(tit_str,'.png'))
end
%%
angle_names = {'Thumb CMC e-f','Thumb CMC opp','Thumb CMC ad-ab','Thumb MCP e-f','Thumb IP e-f','Index MCP e-f','Index MCP ad-ab','Index PIP e-f','Index DIP e-f','Middle MCP e-f','Middle MCP ad-ab','Middle PIP e-f','Middle DIP e-f','Ring MCP e-f','Ring MCP ad-ab','Ring PIP e-f','Ring DIP e-f','Pinky MCP e-f','Pinky MCP ad-ab','Pinky PIP e-f','Pinky DIP e-f'};

for j = 1:size(opensim_angle_data_nans_removed,2)
    angle_name = angle_names{j};
    joint_angle = opensim_angle_data_nans_removed(:,j);
    figure
    [opensim_angle_autocorr,x] = xcorr(joint_angle, 150, 'coeff');
    x = x/30;
    plot(x,opensim_angle_autocorr)
    xlabel('Time (s')
    ylabel('Angle Autocorr')
    tit_str = strcat(angle_name, ' autocorrelation (Whole Datastream)');
    title(tit_str)
    saveas(gcf,strcat(tit_str,'.png'))
end

%%
for i = 1:length(electrodes)
    electrode = electrodes{i};
    elec_num = electrode_nums{i};
    [electrode_autocorr,x] = xcorr(electrode, 150, 'coeff');
    x = x/30;
    figure
    plot(x,electrode_autocorr)
    xlabel('Time (s')
    ylabel('Electrode Autocorr')
    tit_str = strcat('Elec', num2str(elec_num), ' autocorrelation (Whole Datastream)');
    title(tit_str)
    saveas(gcf,strcat(tit_str,'.png'))
end
%%






%%
for i = 1:length(electrodes)
    elec = electrodes{i};
    elec_num = electrode_nums{i};
    figure
    hold on
    for j = 1:length(segments)
        start = segments{j}{1};
        fin = segments{j}{2};
        elec_s = elec(start:fin);
        [elec_autocorr,x] = xcorr(elec_s, 150, 'coeff');
        x=x/30;
        plot(x,elec_autocorr)
    end
    xlabel('Time')
    ylabel('AutoCorrelation')
    tit_str = strcat('Elec',num2str(elec_num), ' Autocorrelation by Segment');
    title(tit_str)
    legend('Segment 1','Segment 2','Segment 3','Segment 4','Segment 5','Segment 6','Segment 7','Segment 8','Segment 9','Segment 10')
    saveas(gcf,strcat(tit_str,'.png'))
end
%%
for i = 1:size(opensim_angle_data_nans_removed,2)
    angle = opensim_angle_data_nans_removed(:,i);
    angle_name = angle_names{i};
    figure
    hold on
    for j = 1:length(segments)
        start = segments{j}{1};
        fin = segments{j}{2};
        angle_s = angle(start:fin);
        [angle_autocorr,x] = xcorr(angle_s, 150, 'coeff');
        plot(x,angle_autocorr)
    end
    xlabel('Time')
    ylabel('AutoCorrelation')
    tit_str = strcat(angle_name, ' Angle Autocorrelation by Segment');
    title(tit_str)
    legend('Segment 1','Segment 2','Segment 3','Segment 4','Segment 5','Segment 6','Segment 7','Segment 8','Segment 9','Segment 10')
    saveas(gcf,strcat(tit_str,'.png'))
end

%%
for i = 1:length(electrodes)
    elec = electrodes{i};
    elec_num = electrode_nums{i};
    for k = 1:size(opensim_angle_data_nans_removed,2)
        angle = opensim_angle_data_nans_removed(:,k);
        angle_name = angle_names{k};
        figure
        hold on
        for j = 1:length(segments)
            start = segments{j}{1};
            fin = segments{j}{2};
            elec_s = elec(start:fin);
            angle_s = angle(start:fin);
            [elec_angle_xcorr_seg,x] = xcorr(elec_s, angle_s, 150, 'coeff');
            x=x/30;
            plot(x,elec_angle_xcorr_seg)
        end
        xlabel('Time')
        ylabel('Electrode-Angle Correlation')
        tit_str = strcat('Elec',num2str(elec_num), '-',angle_name, ' Xcorrelation by Segment');
        title(tit_str)
        legend('Segment 1','Segment 2','Segment 3','Segment 4','Segment 5','Segment 6','Segment 7','Segment 8','Segment 9','Segment 10')
        saveas(gcf,strcat(tit_str,'.png'))
        close
    end
end
