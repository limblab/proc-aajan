%%%%%%%%%%%%PLOT XCORRS OF INDIVIDUAL NEURONS AND INVIDIDUAL JOINTS%%%%%%%%%%%%%%%
%%IMPORT DATA%%
angle_data_nans_removed = readtable('/Users/aajanquail/Downloads/joint_angles_nans_removed.csv');
neural_data_struct_nans_removed = load(['/Users/aajanquail/Downloads/20210712_units_smoothed_nans_removed.mat']);
angle_data_nans_removed = table2array(angle_data_nans_removed);

%%
%EXTRACT ANGLE DATA BY KEYPOINT
ring_dip_joint_angles = angle_data_nans_removed(:,4);
ring_pip_joint_angles = angle_data_nans_removed(:,5);
middle_dip_joint_angles = angle_data_nans_removed(:,7);
middle_pip_joint_angles = angle_data_nans_removed(:,8);
%%
%SPLIT EACH KEYPOINT INTO SEGMENTS GIVEN BY ERIC
ring_dip_joint_angles_s1 = ring_dip_joint_angles(690:989);
ring_dip_joint_angles_s2 = ring_dip_joint_angles(2130:2429);
ring_dip_joint_angles_s3 = ring_dip_joint_angles(4770:5069);
ring_dip_joint_angles_s4 = ring_dip_joint_angles(10890:11189);
ring_dip_joint_angles_s5 = ring_dip_joint_angles(12510:12809);
ring_dip_joint_angles_s6 = ring_dip_joint_angles(13080:13379);
ring_dip_joint_angles_s7 = ring_dip_joint_angles(16140:16439);
ring_dip_joint_angles_s8 = ring_dip_joint_angles(22050:22349);
ring_dip_joint_angles_s9 = ring_dip_joint_angles(26580:26879);
ring_dip_joint_angles_s10 = ring_dip_joint_angles(29160:29459);

ring_pip_joint_angles_s1 = ring_pip_joint_angles(690:989);
ring_pip_joint_angles_s2 = ring_pip_joint_angles(2130:2429);
ring_pip_joint_angles_s3 = ring_pip_joint_angles(4770:5069);
ring_pip_joint_angles_s4 = ring_pip_joint_angles(10890:11189);
ring_pip_joint_angles_s5 = ring_pip_joint_angles(12510:12809);
ring_pip_joint_angles_s6 = ring_pip_joint_angles(13080:13379);
ring_pip_joint_angles_s7 = ring_pip_joint_angles(16140:16439);
ring_pip_joint_angles_s8 = ring_pip_joint_angles(22050:22349);
ring_pip_joint_angles_s9 = ring_pip_joint_angles(26580:26879);
ring_pip_joint_angles_s10 = ring_pip_joint_angles(29160:29459);

middle_dip_joint_angles_s1 = middle_dip_joint_angles(690:989);
middle_dip_joint_angles_s2 = middle_dip_joint_angles(2130:2429);
middle_dip_joint_angles_s3 = middle_dip_joint_angles(4770:5069);
middle_dip_joint_angles_s4 = middle_dip_joint_angles(10890:11189);
middle_dip_joint_angles_s5 = middle_dip_joint_angles(12510:12809);
middle_dip_joint_angles_s6 = middle_dip_joint_angles(13080:13379);
middle_dip_joint_angles_s7 = middle_dip_joint_angles(16140:16439);
middle_dip_joint_angles_s8 = middle_dip_joint_angles(22050:22349);
middle_dip_joint_angles_s9 = middle_dip_joint_angles(26580:26879);
middle_dip_joint_angles_s10 = middle_dip_joint_angles(29160:29459);

middle_pip_joint_angles_s1 = middle_pip_joint_angles(690:989);
middle_pip_joint_angles_s2 = middle_pip_joint_angles(2130:2429);
middle_pip_joint_angles_s3 = middle_pip_joint_angles(4770:5069);
middle_pip_joint_angles_s4 = middle_pip_joint_angles(10890:11189);
middle_pip_joint_angles_s5 = middle_pip_joint_angles(12510:12809);
middle_pip_joint_angles_s6 = middle_pip_joint_angles(13080:13379);
middle_pip_joint_angles_s7 = middle_pip_joint_angles(16140:16439);
middle_pip_joint_angles_s8 = middle_pip_joint_angles(22050:22349);
middle_pip_joint_angles_s9 = middle_pip_joint_angles(26580:26879);
middle_pip_joint_angles_s10 = middle_pip_joint_angles(29160:29459);

%%
%A COUPLE "BAD" SEGMENTS
middle_pip_joint_angles_s1_BAD = middle_pip_joint_angles(2430:4769);
middle_pip_joint_angles_s2_BAD = middle_pip_joint_angles(11190:12509);
middle_dip_joint_angles_s1_BAD = middle_dip_joint_angles(2430:4769);
middle_dip_joint_angles_s2_BAD = middle_dip_joint_angles(11190:12509);
ring_dip_joint_angles_s1_BAD = ring_dip_joint_angles(2430:4769);
ring_dip_joint_angles_s2_BAD = ring_dip_joint_angles(11190:12509);
ring_pip_joint_angles_s1_BAD = ring_pip_joint_angles(2430:4769);
ring_pip_joint_angles_s2_BAD = ring_pip_joint_angles(11190:12509);
%%
%GET TOP 5 MODULATING ELECTRODES (GIVEN BY HENRY)
% 'elec86_1' - 105
% 'elec96_1' - 101
% 'elec51_1' - 81
% 'elec79_3' - 122
% 'elec40_1' - 133

elec86_1 = neural_data_struct_nans_removed.neural_data_nans_removed(105,:);
elec96_1 = neural_data_struct_nans_removed.neural_data_nans_removed(101,:);
elec51_1 = neural_data_struct_nans_removed.neural_data_nans_removed(81,:);
elec79_3 = neural_data_struct_nans_removed.neural_data_nans_removed(122,:);
elec40_1 = neural_data_struct_nans_removed.neural_data_nans_removed(133,:);
%%
%SPLIT ELECTRODE DATA ACCORDING TO SEGMENTS SUGGESTED BY ERIC
elec86_1_s1 = elec86_1(690:989);
elec86_1_s2 = elec86_1(2130:2429);
elec86_1_s3 = elec86_1(4770:5069);
elec86_1_s4 = elec86_1(10890:11189);
elec86_1_s5 = elec86_1(12510:12809);
elec86_1_s6 = elec86_1(13080:13379);
elec86_1_s7 = elec86_1(16140:16439);
elec86_1_s8 = elec86_1(22050:22349);
elec86_1_s9 = elec86_1(26580:26879);
elec86_1_s10 = elec86_1(29160:29459);

elec96_1_s1 = elec96_1(690:989);
elec96_1_s2 = elec96_1(2130:2429);
elec96_1_s3 = elec96_1(4770:5069);
elec96_1_s4 = elec96_1(10890:11189);
elec96_1_s5 = elec96_1(12510:12809);
elec96_1_s6 = elec96_1(13080:13379);
elec96_1_s7 = elec96_1(16140:16439);
elec96_1_s8 = elec96_1(22050:22349);
elec96_1_s9 = elec96_1(26580:26879);
elec96_1_s10 = elec96_1(29160:29459);

elec51_1_s1 = elec51_1(690:989);
elec51_1_s2 = elec51_1(2130:2429);
elec51_1_s3 = elec51_1(4770:5069);
elec51_1_s4 = elec51_1(10890:11189);
elec51_1_s5 = elec51_1(12510:12809);
elec51_1_s6 = elec51_1(13080:13379);
elec51_1_s7 = elec51_1(16140:16439);
elec51_1_s8 = elec51_1(22050:22349);
elec51_1_s9 = elec51_1(26580:26879);
elec51_1_s10 = elec51_1(29160:29459);

elec79_3_s1 = elec79_3(690:989);
elec79_3_s2 = elec79_3(2130:2429);
elec79_3_s3 = elec79_3(4770:5069);
elec79_3_s4 = elec79_3(10890:11189);
elec79_3_s5 = elec79_3(12510:12809);
elec79_3_s6 = elec79_3(13080:13379);
elec79_3_s7 = elec79_3(16140:16439);
elec79_3_s8 = elec79_3(22050:22349);
elec79_3_s9 = elec79_3(26580:26879);
elec79_3_s10 = elec79_3(29160:29459);

elec40_1_s1 = elec40_1(690:989);
elec40_1_s2 = elec40_1(2130:2429);
elec40_1_s3 = elec40_1(4770:5069);
elec40_1_s4 = elec40_1(10890:11189);
elec40_1_s5 = elec40_1(12510:12809);
elec40_1_s6 = elec40_1(13080:13379);
elec40_1_s7 = elec40_1(16140:16439);
elec40_1_s8 = elec40_1(22050:22349);
elec40_1_s9 = elec40_1(26580:26879);
elec40_1_s10 = elec40_1(29160:29459);
%%
%A COUPLE "BAD" SEGMENTS
elec86_1_s1_BAD = elec86_1(2430:4769);
elec86_1_s2_BAD = elec86_1(11190:12509);
elec96_1_s1_BAD = elec96_1(2430:4769);
elec96_1_s2_BAD = elec96_1(11190:12509);
elec51_1_s1_BAD = elec51_1(2430:4769);
elec51_1_s2_BAD = elec51_1(11190:12509);
elec79_3_s1_BAD = elec79_3(2430:4769);
elec79_3_s2_BAD = elec79_3(11190:12509);
elec40_1_s1_BAD = elec40_1(2430:4769);
elec40_1_s2_BAD = elec40_1(11190:12509);

%%
segments = {{690,989},{2130,2429},{4770,5069},{10890,11189},{12510,12809},{13080,13379},{16140,16439},{22050,22349},{26580,26879},{29160,29459}};
electrodes = {elec86_1,elec96_1,elec51_1,elec79_3,elec40_1};
angles = {ring_dip_joint_angles,ring_pip_joint_angles,middle_dip_joint_angles,middle_pip_joint_angles};
electrode_nums = {86,96,51,79,40};
angle_names = {'Ring DIP', 'Ring PIP', 'Middle DIP', 'Middle PIP'};
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

for i = 1:length(angles)
    angle = angles{i};
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
    figure
    [elec_autocorr,x] = xcorr(elec, 150, 'coeff');
    plot(x,elec_autocorr)
    xlabel('Time')
    ylabel('AutoCorrelation')
    tit_str = strcat('Elec',num2str(elec_num), ' Autocorrelation Whole DataStream');
    title(tit_str)
    saveas(gcf,strcat(tit_str,'.png'))
end

for i = 1:length(angles)
    angle = angles{i};
    angle_name = angle_names{i};
    figure
    [angle_autocorr,x] = xcorr(angle, 150, 'coeff');
    x = x/30;
    plot(x,angle_autocorr)
    xlabel('Time')
    ylabel('AutoCorrelation')
    tit_str = strcat(angle_name, ' Angle Autocorrelation Whole DataStream');
    title(tit_str)
    saveas(gcf,strcat(tit_str,'.png'))
end
%%
for i = 1:length(angles)
    angle = angles{i};
    angle_name = angle_names{i};
    figure
    plot(angle)
    xlabel('Time')
    ylabel('Angle')
    tit_str = strcat(angle_name, ' Whole Datastream');
    title(tit_str)
    saveas(gcf,strcat(tit_str,'.fig'))
end
%%

for i = 1:length(electrodes)
    elec = electrodes{i};
    elec_num = electrode_nums{i};
    trailing_mean = [];
    for j = 1:(length(elec)-599) 
        elec_s = elec(j:j+599);
        m = mean(elec_s);
        trailing_mean = [trailing_mean m];
    end
    figure
    hold on
    plot(elec)
    plot(trailing_mean,'LineWidth',3)
    xlabel('Time')
    ylabel('Electrode')
    tit_str = strcat('Elec', num2str(elec_num), ' vs Leading 20s second avg');
    title(tit_str)
    legend('Electrode','Electrode Leading 20s Avg.')
    saveas(gcf,strcat(tit_str,'.png'))
end

%%

for i = 1:length(angles)
    angle = angles{i};
    angle_name = angle_names{i};
    trailing_mean = [];
    for j = 1:(length(angle)-599) 
        angle_s = angle(j:j+599);
        m = mean(angle_s);
        trailing_mean = [trailing_mean m];
    end
    figure
    hold on
    plot(angle)
    plot(trailing_mean,'LineWidth',3)
    xlabel('Time')
    ylabel('Angle')
    tit_str = strcat(angle_name, ' vs Leading 20 second avg');
    title(tit_str)
    legend('Angle','Angle Trailing 20 Avg.')
    saveas(gcf,strcat(tit_str,'.png'))
end

%%

for i = 1:length(electrodes)
    elec = electrodes{i};
    elec_num = electrode_nums{i};
    for k = 1:length(angles)
        angle = angles{k};
        angle_name = angle_names{k};
        disp(angle_name)
        trailing_mean_electrode = [];
        trailing_mean_angle = [];
        for l = 1:(length(angle)-599) 
            elec_s = elec(l:l+599);
            angle_s = angle(l:l+599);
            m_elec = mean(elec_s);
            m_ang = mean(angle_s);
            trailing_mean_electrode = [trailing_mean_electrode m_elec];
            trailing_mean_angle = [trailing_mean_angle m_ang];
        end
        figure
        plot(trailing_mean_electrode-trailing_mean_angle)
        xlabel('Time')
        ylabel('Difference')
        tit_str = strcat('Difference in Leading 20s Avearge between Elec', num2str(elec_num), ' and  ', angle_name);
        title(tit_str)
%         saveas(gcf,strcat(tit_str,'.png'))
    end
end

%%
%%%%%%%%%PLOTTING CROSS CORRELATIONS FOR EACH SEGMENT%%%%%%%%%%%%%
%ELEC 86 - MILDDLE PIP 
[elec86_middle_pip_angle_xcorr_s1, x3] = xcorr(elec86_1_s1, middle_pip_joint_angles_s1, 150, 'coeff');
x3=x3/30;
elec86_middle_pip_angle_xcorr_s2 = xcorr(elec86_1_s2, middle_pip_joint_angles_s2, 150, 'coeff');
elec86_middle_pip_angle_xcorr_s3 = xcorr(elec86_1_s3, middle_pip_joint_angles_s3, 150, 'coeff');
elec86_middle_pip_angle_xcorr_s4 = xcorr(elec86_1_s4, middle_pip_joint_angles_s4, 150, 'coeff');
elec86_middle_pip_angle_xcorr_s5 = xcorr(elec86_1_s5, middle_pip_joint_angles_s5, 150, 'coeff');
elec86_middle_pip_angle_xcorr_s6 = xcorr(elec86_1_s6, middle_pip_joint_angles_s6, 150, 'coeff');
elec86_middle_pip_angle_xcorr_s7 = xcorr(elec86_1_s7, middle_pip_joint_angles_s7, 150, 'coeff');
elec86_middle_pip_angle_xcorr_s8 = xcorr(elec86_1_s8, middle_pip_joint_angles_s8, 150, 'coeff');
elec86_middle_pip_angle_xcorr_s9 = xcorr(elec86_1_s9, middle_pip_joint_angles_s9, 150, 'coeff');
elec86_middle_pip_angle_xcorr_s10 = xcorr(elec86_1_s10, middle_pip_joint_angles_s10, 150, 'coeff');

figure
hold on
plot(x3, elec86_middle_pip_angle_xcorr_s1)
plot(x3, elec86_middle_pip_angle_xcorr_s2)
plot(x3, elec86_middle_pip_angle_xcorr_s3)
plot(x3, elec86_middle_pip_angle_xcorr_s4)
plot(x3, elec86_middle_pip_angle_xcorr_s5)
plot(x3, elec86_middle_pip_angle_xcorr_s6)
plot(x3, elec86_middle_pip_angle_xcorr_s7)
plot(x3, elec86_middle_pip_angle_xcorr_s8)
plot(x3, elec86_middle_pip_angle_xcorr_s9)
plot(x3, elec86_middle_pip_angle_xcorr_s10)
xlabel('Time')
ylabel('Cross-Correlation')
title('Elec86-Middle PIP Angle XCorrelation (All Segments)')
legend('Segment 1','Segment 2','Segment 3','Segment 4','Segment 5','Segment 6','Segment 7','Segment 8','Segment 9','Segment 10')
%%
%ELEC 96 - MILDDLE PIP

[elec96_middle_pip_angle_xcorr_s1, x3] = xcorr(elec96_1_s1, middle_pip_joint_angles_s1, 150, 'coeff');
x3=x3/30;
elec96_middle_pip_angle_xcorr_s2 = xcorr(elec96_1_s2, middle_pip_joint_angles_s2, 150, 'coeff');
elec96_middle_pip_angle_xcorr_s3 = xcorr(elec96_1_s3, middle_pip_joint_angles_s3, 150, 'coeff');
elec96_middle_pip_angle_xcorr_s4 = xcorr(elec96_1_s4, middle_pip_joint_angles_s4, 150, 'coeff');
elec96_middle_pip_angle_xcorr_s5 = xcorr(elec96_1_s5, middle_pip_joint_angles_s5, 150, 'coeff');
elec96_middle_pip_angle_xcorr_s6 = xcorr(elec96_1_s6, middle_pip_joint_angles_s6, 150, 'coeff');
elec96_middle_pip_angle_xcorr_s7 = xcorr(elec96_1_s7, middle_pip_joint_angles_s7, 150, 'coeff');
elec96_middle_pip_angle_xcorr_s8 = xcorr(elec96_1_s8, middle_pip_joint_angles_s8, 150, 'coeff');
elec96_middle_pip_angle_xcorr_s9 = xcorr(elec96_1_s9, middle_pip_joint_angles_s9, 150, 'coeff');
elec96_middle_pip_angle_xcorr_s10 = xcorr(elec96_1_s10, middle_pip_joint_angles_s10, 150, 'coeff');

figure
hold on
plot(x3, elec96_middle_pip_angle_xcorr_s1)
plot(x3, elec96_middle_pip_angle_xcorr_s2)
plot(x3, elec96_middle_pip_angle_xcorr_s3)
plot(x3, elec96_middle_pip_angle_xcorr_s4)
plot(x3, elec96_middle_pip_angle_xcorr_s5)
plot(x3, elec96_middle_pip_angle_xcorr_s6)
plot(x3, elec96_middle_pip_angle_xcorr_s7)
plot(x3, elec96_middle_pip_angle_xcorr_s8)
plot(x3, elec96_middle_pip_angle_xcorr_s9)
plot(x3, elec96_middle_pip_angle_xcorr_s10)
xlabel('Time')
ylabel('Cross-Correlation')
title('Elec96-Middle PIP Angle XCorrelation (All Segments)')
legend('Segment 1','Segment 2','Segment 3','Segment 4','Segment 5','Segment 6','Segment 7','Segment 8','Segment 9','Segment 10')

%%
%ELEC 51 - MILDDLE PIP

[elec51_middle_pip_angle_xcorr_s1, x3] = xcorr(elec51_1_s1, middle_pip_joint_angles_s1, 150, 'coeff');
x3=x3/30;
elec51_middle_pip_angle_xcorr_s2 = xcorr(elec51_1_s2, middle_pip_joint_angles_s2, 150, 'coeff');
elec51_middle_pip_angle_xcorr_s3 = xcorr(elec51_1_s3, middle_pip_joint_angles_s3, 150, 'coeff');
elec51_middle_pip_angle_xcorr_s4 = xcorr(elec51_1_s4, middle_pip_joint_angles_s4, 150, 'coeff');
elec51_middle_pip_angle_xcorr_s5 = xcorr(elec51_1_s5, middle_pip_joint_angles_s5, 150, 'coeff');
elec51_middle_pip_angle_xcorr_s6 = xcorr(elec51_1_s6, middle_pip_joint_angles_s6, 150, 'coeff');
elec51_middle_pip_angle_xcorr_s7 = xcorr(elec51_1_s7, middle_pip_joint_angles_s7, 150, 'coeff');
elec51_middle_pip_angle_xcorr_s8 = xcorr(elec51_1_s8, middle_pip_joint_angles_s8, 150, 'coeff');
elec51_middle_pip_angle_xcorr_s9 = xcorr(elec51_1_s9, middle_pip_joint_angles_s9, 150, 'coeff');
elec51_middle_pip_angle_xcorr_s10 = xcorr(elec51_1_s10, middle_pip_joint_angles_s10, 150, 'coeff');

figure
hold on
plot(x3, elec51_middle_pip_angle_xcorr_s1)
plot(x3, elec51_middle_pip_angle_xcorr_s2)
plot(x3, elec51_middle_pip_angle_xcorr_s3)
plot(x3, elec51_middle_pip_angle_xcorr_s4)
plot(x3, elec51_middle_pip_angle_xcorr_s5)
plot(x3, elec51_middle_pip_angle_xcorr_s6)
plot(x3, elec51_middle_pip_angle_xcorr_s7)
plot(x3, elec51_middle_pip_angle_xcorr_s8)
plot(x3, elec51_middle_pip_angle_xcorr_s9)
plot(x3, elec51_middle_pip_angle_xcorr_s10)
xlabel('Time')
ylabel('Cross-Correlation')
title('Elec51-Middle PIP Angle XCorrelation (All Segments)')
legend('Segment 1','Segment 2','Segment 3','Segment 4','Segment 5','Segment 6','Segment 7','Segment 8','Segment 9','Segment 10')
%%
%ELEC 40 - MILDDLE PIP

[elec40_middle_pip_angle_xcorr_s1, x3] = xcorr(elec40_1_s1, middle_pip_joint_angles_s1, 150, 'coeff');
x3=x3/30;
elec40_middle_pip_angle_xcorr_s2 = xcorr(elec40_1_s2, middle_pip_joint_angles_s2, 150, 'coeff');
elec40_middle_pip_angle_xcorr_s3 = xcorr(elec40_1_s3, middle_pip_joint_angles_s3, 150, 'coeff');
elec40_middle_pip_angle_xcorr_s4 = xcorr(elec40_1_s4, middle_pip_joint_angles_s4, 150, 'coeff');
elec40_middle_pip_angle_xcorr_s5 = xcorr(elec40_1_s5, middle_pip_joint_angles_s5, 150, 'coeff');
elec40_middle_pip_angle_xcorr_s6 = xcorr(elec40_1_s6, middle_pip_joint_angles_s6, 150, 'coeff');
elec40_middle_pip_angle_xcorr_s7 = xcorr(elec40_1_s7, middle_pip_joint_angles_s7, 150, 'coeff');
elec40_middle_pip_angle_xcorr_s8 = xcorr(elec40_1_s8, middle_pip_joint_angles_s8, 150, 'coeff');
elec40_middle_pip_angle_xcorr_s9 = xcorr(elec40_1_s9, middle_pip_joint_angles_s9, 150, 'coeff');
elec40_middle_pip_angle_xcorr_s10 = xcorr(elec40_1_s10, middle_pip_joint_angles_s10, 150, 'coeff');

figure
hold on
plot(x3, elec40_middle_pip_angle_xcorr_s1)
plot(x3, elec40_middle_pip_angle_xcorr_s2)
plot(x3, elec40_middle_pip_angle_xcorr_s3)
plot(x3, elec40_middle_pip_angle_xcorr_s4)
plot(x3, elec40_middle_pip_angle_xcorr_s5)
plot(x3, elec40_middle_pip_angle_xcorr_s6)
plot(x3, elec40_middle_pip_angle_xcorr_s7)
plot(x3, elec40_middle_pip_angle_xcorr_s8)
plot(x3, elec40_middle_pip_angle_xcorr_s9)
plot(x3, elec40_middle_pip_angle_xcorr_s10)
xlabel('Time')
ylabel('Cross-Correlation')
title('Elec40-Middle PIP Angle XCorrelation (All Segments)')
legend('Segment 1','Segment 2','Segment 3','Segment 4','Segment 5','Segment 6','Segment 7','Segment 8','Segment 9','Segment 10')

%%
%ELEC 86 - RING PIP

[elec86_ring_pip_angle_xcorr_s1, x3] = xcorr(elec86_1_s1, ring_pip_joint_angles_s1, 150, 'coeff');
x3=x3/30;
elec86_ring_pip_angle_xcorr_s2 = xcorr(elec86_1_s2, ring_pip_joint_angles_s2, 150, 'coeff');
elec86_ring_pip_angle_xcorr_s3 = xcorr(elec86_1_s3, ring_pip_joint_angles_s3, 150, 'coeff');
elec86_ring_pip_angle_xcorr_s4 = xcorr(elec86_1_s4, ring_pip_joint_angles_s4, 150, 'coeff');
elec86_ring_pip_angle_xcorr_s5 = xcorr(elec86_1_s5, ring_pip_joint_angles_s5, 150, 'coeff');
elec86_ring_pip_angle_xcorr_s6 = xcorr(elec86_1_s6, ring_pip_joint_angles_s6, 150, 'coeff');
elec86_ring_pip_angle_xcorr_s7 = xcorr(elec86_1_s7, ring_pip_joint_angles_s7, 150, 'coeff');
elec86_ring_pip_angle_xcorr_s8 = xcorr(elec86_1_s8, ring_pip_joint_angles_s8, 150, 'coeff');
elec86_ring_pip_angle_xcorr_s9 = xcorr(elec86_1_s9, ring_pip_joint_angles_s9, 150, 'coeff');
elec86_ring_pip_angle_xcorr_s10 = xcorr(elec86_1_s10, ring_pip_joint_angles_s10, 150, 'coeff');

figure
hold on
plot(x3, elec86_ring_pip_angle_xcorr_s1)
plot(x3, elec86_ring_pip_angle_xcorr_s2)
plot(x3, elec86_ring_pip_angle_xcorr_s3)
plot(x3, elec86_ring_pip_angle_xcorr_s4)
plot(x3, elec86_ring_pip_angle_xcorr_s5)
plot(x3, elec86_ring_pip_angle_xcorr_s6)
plot(x3, elec86_ring_pip_angle_xcorr_s7)
plot(x3, elec86_ring_pip_angle_xcorr_s8)
plot(x3, elec86_ring_pip_angle_xcorr_s9)
plot(x3, elec86_ring_pip_angle_xcorr_s10)
xlabel('Time')
ylabel('Cross-Correlation')
title('Elec86-Ring PIP Angle XCorrelation (All Segments)')
legend('Segment 1','Segment 2','Segment 3','Segment 4','Segment 5','Segment 6','Segment 7','Segment 8','Segment 9','Segment 10')

%%
%ELEC 96 - RING PIP

[elec96_ring_pip_angle_xcorr_s1, x3] = xcorr(elec96_1_s1, ring_pip_joint_angles_s1, 150, 'coeff');
x3=x3/30;
elec96_ring_pip_angle_xcorr_s2 = xcorr(elec96_1_s2, ring_pip_joint_angles_s2, 150, 'coeff');
elec96_ring_pip_angle_xcorr_s3 = xcorr(elec96_1_s3, ring_pip_joint_angles_s3, 150, 'coeff');
elec96_ring_pip_angle_xcorr_s4 = xcorr(elec96_1_s4, ring_pip_joint_angles_s4, 150, 'coeff');
elec96_ring_pip_angle_xcorr_s5 = xcorr(elec96_1_s5, ring_pip_joint_angles_s5, 150, 'coeff');
elec96_ring_pip_angle_xcorr_s6 = xcorr(elec96_1_s6, ring_pip_joint_angles_s6, 150, 'coeff');
elec96_ring_pip_angle_xcorr_s7 = xcorr(elec96_1_s7, ring_pip_joint_angles_s7, 150, 'coeff');
elec96_ring_pip_angle_xcorr_s8 = xcorr(elec96_1_s8, ring_pip_joint_angles_s8, 150, 'coeff');
elec96_ring_pip_angle_xcorr_s9 = xcorr(elec96_1_s9, ring_pip_joint_angles_s9, 150, 'coeff');
elec96_ring_pip_angle_xcorr_s10 = xcorr(elec96_1_s10, ring_pip_joint_angles_s10, 150, 'coeff');

figure
hold on
plot(x3, elec96_ring_pip_angle_xcorr_s1)
plot(x3, elec96_ring_pip_angle_xcorr_s2)
plot(x3, elec96_ring_pip_angle_xcorr_s3)
plot(x3, elec96_ring_pip_angle_xcorr_s4)
plot(x3, elec96_ring_pip_angle_xcorr_s5)
plot(x3, elec96_ring_pip_angle_xcorr_s6)
plot(x3, elec96_ring_pip_angle_xcorr_s7)
plot(x3, elec96_ring_pip_angle_xcorr_s8)
plot(x3, elec96_ring_pip_angle_xcorr_s9)
plot(x3, elec96_ring_pip_angle_xcorr_s10)
xlabel('Time')
ylabel('Cross-Correlation')
title('Elec96-Ring PIP Angle XCorrelation (All Segments)')
legend('Segment 1','Segment 2','Segment 3','Segment 4','Segment 5','Segment 6','Segment 7','Segment 8','Segment 9','Segment 10')

%%
%ELEC 51 - RING PIP

[elec51_ring_pip_angle_xcorr_s1, x3] = xcorr(elec51_1_s1, ring_pip_joint_angles_s1, 150, 'coeff');
x3=x3/30;
elec51_ring_pip_angle_xcorr_s2 = xcorr(elec51_1_s2, ring_pip_joint_angles_s2, 150, 'coeff');
elec51_ring_pip_angle_xcorr_s3 = xcorr(elec51_1_s3, ring_pip_joint_angles_s3, 150, 'coeff');
elec51_ring_pip_angle_xcorr_s4 = xcorr(elec51_1_s4, ring_pip_joint_angles_s4, 150, 'coeff');
elec51_ring_pip_angle_xcorr_s5 = xcorr(elec51_1_s5, ring_pip_joint_angles_s5, 150, 'coeff');
elec51_ring_pip_angle_xcorr_s6 = xcorr(elec51_1_s6, ring_pip_joint_angles_s6, 150, 'coeff');
elec51_ring_pip_angle_xcorr_s7 = xcorr(elec51_1_s7, ring_pip_joint_angles_s7, 150, 'coeff');
elec51_ring_pip_angle_xcorr_s8 = xcorr(elec51_1_s8, ring_pip_joint_angles_s8, 150, 'coeff');
elec51_ring_pip_angle_xcorr_s9 = xcorr(elec51_1_s9, ring_pip_joint_angles_s9, 150, 'coeff');
elec51_ring_pip_angle_xcorr_s10 = xcorr(elec51_1_s10, ring_pip_joint_angles_s10, 150, 'coeff');

figure
hold on
plot(x3, elec51_ring_pip_angle_xcorr_s1)
plot(x3, elec51_ring_pip_angle_xcorr_s2)
plot(x3, elec51_ring_pip_angle_xcorr_s3)
plot(x3, elec51_ring_pip_angle_xcorr_s4)
plot(x3, elec51_ring_pip_angle_xcorr_s5)
plot(x3, elec51_ring_pip_angle_xcorr_s6)
plot(x3, elec51_ring_pip_angle_xcorr_s7)
plot(x3, elec51_ring_pip_angle_xcorr_s8)
plot(x3, elec51_ring_pip_angle_xcorr_s9)
plot(x3, elec51_ring_pip_angle_xcorr_s10)
xlabel('Time')
ylabel('Cross-Correlation')
title('Elec51-Ring PIP Angle XCorrelation (All Segments)')
legend('Segment 1','Segment 2','Segment 3','Segment 4','Segment 5','Segment 6','Segment 7','Segment 8','Segment 9','Segment 10')
%%
%ELEC 40 - RING PIP

[elec40_ring_pip_angle_xcorr_s1, x3] = xcorr(elec40_1_s1, ring_pip_joint_angles_s1, 150, 'coeff');
x3=x3/30;
elec40_ring_pip_angle_xcorr_s2 = xcorr(elec40_1_s2, ring_pip_joint_angles_s2, 150, 'coeff');
elec40_ring_pip_angle_xcorr_s3 = xcorr(elec40_1_s3, ring_pip_joint_angles_s3, 150, 'coeff');
elec40_ring_pip_angle_xcorr_s4 = xcorr(elec40_1_s4, ring_pip_joint_angles_s4, 150, 'coeff');
elec40_ring_pip_angle_xcorr_s5 = xcorr(elec40_1_s5, ring_pip_joint_angles_s5, 150, 'coeff');
elec40_ring_pip_angle_xcorr_s6 = xcorr(elec40_1_s6, ring_pip_joint_angles_s6, 150, 'coeff');
elec40_ring_pip_angle_xcorr_s7 = xcorr(elec40_1_s7, ring_pip_joint_angles_s7, 150, 'coeff');
elec40_ring_pip_angle_xcorr_s8 = xcorr(elec40_1_s8, ring_pip_joint_angles_s8, 150, 'coeff');
elec40_ring_pip_angle_xcorr_s9 = xcorr(elec40_1_s9, ring_pip_joint_angles_s9, 150, 'coeff');
elec40_ring_pip_angle_xcorr_s10 = xcorr(elec40_1_s10, ring_pip_joint_angles_s10, 150, 'coeff');

figure
hold on
plot(x3, elec40_ring_pip_angle_xcorr_s1)
plot(x3, elec40_ring_pip_angle_xcorr_s2)
plot(x3, elec40_ring_pip_angle_xcorr_s3)
plot(x3, elec40_ring_pip_angle_xcorr_s4)
plot(x3, elec40_ring_pip_angle_xcorr_s5)
plot(x3, elec40_ring_pip_angle_xcorr_s6)
plot(x3, elec40_ring_pip_angle_xcorr_s7)
plot(x3, elec40_ring_pip_angle_xcorr_s8)
plot(x3, elec40_ring_pip_angle_xcorr_s9)
plot(x3, elec40_ring_pip_angle_xcorr_s10)
xlabel('Time')
ylabel('Cross-Correlation')
title('Elec40-Ring PIP Angle XCorrelation (All Segments)')
legend('Segment 1','Segment 2','Segment 3','Segment 4','Segment 5','Segment 6','Segment 7','Segment 8','Segment 9','Segment 10')

%%
%ELEC 86 - RING DIP

[elec86_ring_dip_angle_xcorr_s1, x3] = xcorr(elec86_1_s1, ring_dip_joint_angles_s1, 150, 'coeff');
x3=x3/30;
elec86_ring_dip_angle_xcorr_s2 = xcorr(elec86_1_s2, ring_dip_joint_angles_s2, 150, 'coeff');
elec86_ring_dip_angle_xcorr_s3 = xcorr(elec86_1_s3, ring_dip_joint_angles_s3, 150, 'coeff');
elec86_ring_dip_angle_xcorr_s4 = xcorr(elec86_1_s4, ring_dip_joint_angles_s4, 150, 'coeff');
elec86_ring_dip_angle_xcorr_s5 = xcorr(elec86_1_s5, ring_dip_joint_angles_s5, 150, 'coeff');
elec86_ring_dip_angle_xcorr_s6 = xcorr(elec86_1_s6, ring_dip_joint_angles_s6, 150, 'coeff');
elec86_ring_dip_angle_xcorr_s7 = xcorr(elec86_1_s7, ring_dip_joint_angles_s7, 150, 'coeff');
elec86_ring_dip_angle_xcorr_s8 = xcorr(elec86_1_s8, ring_dip_joint_angles_s8, 150, 'coeff');
elec86_ring_dip_angle_xcorr_s9 = xcorr(elec86_1_s9, ring_dip_joint_angles_s9, 150, 'coeff');
elec86_ring_dip_angle_xcorr_s10 = xcorr(elec86_1_s10, ring_dip_joint_angles_s10, 150, 'coeff');

figure
hold on
plot(x3, elec86_ring_dip_angle_xcorr_s1)
plot(x3, elec86_ring_dip_angle_xcorr_s2)
plot(x3, elec86_ring_dip_angle_xcorr_s3)
plot(x3, elec86_ring_dip_angle_xcorr_s4)
plot(x3, elec86_ring_dip_angle_xcorr_s5)
plot(x3, elec86_ring_dip_angle_xcorr_s6)
plot(x3, elec86_ring_dip_angle_xcorr_s7)
plot(x3, elec86_ring_dip_angle_xcorr_s8)
plot(x3, elec86_ring_dip_angle_xcorr_s9)
plot(x3, elec86_ring_dip_angle_xcorr_s10)
xlabel('Time')
ylabel('Cross-Correlation')
title('Elec86-Ring DIP Angle XCorrelation (All Segments)')
legend('Segment 1','Segment 2','Segment 3','Segment 4','Segment 5','Segment 6','Segment 7','Segment 8','Segment 9','Segment 10')

%%
%ELEC 96 - RING DIP

[elec96_ring_dip_angle_xcorr_s1, x3] = xcorr(elec96_1_s1, ring_dip_joint_angles_s1, 150, 'coeff');
x3=x3/30;
elec96_ring_dip_angle_xcorr_s2 = xcorr(elec96_1_s2, ring_dip_joint_angles_s2, 150, 'coeff');
elec96_ring_dip_angle_xcorr_s3 = xcorr(elec96_1_s3, ring_dip_joint_angles_s3, 150, 'coeff');
elec96_ring_dip_angle_xcorr_s4 = xcorr(elec96_1_s4, ring_dip_joint_angles_s4, 150, 'coeff');
elec96_ring_dip_angle_xcorr_s5 = xcorr(elec96_1_s5, ring_dip_joint_angles_s5, 150, 'coeff');
elec96_ring_dip_angle_xcorr_s6 = xcorr(elec96_1_s6, ring_dip_joint_angles_s6, 150, 'coeff');
elec96_ring_dip_angle_xcorr_s7 = xcorr(elec96_1_s7, ring_dip_joint_angles_s7, 150, 'coeff');
elec96_ring_dip_angle_xcorr_s8 = xcorr(elec96_1_s8, ring_dip_joint_angles_s8, 150, 'coeff');
elec96_ring_dip_angle_xcorr_s9 = xcorr(elec96_1_s9, ring_dip_joint_angles_s9, 150, 'coeff');
elec96_ring_dip_angle_xcorr_s10 = xcorr(elec96_1_s10, ring_dip_joint_angles_s10, 150, 'coeff');

figure
hold on
plot(x3, elec96_ring_dip_angle_xcorr_s1)
plot(x3, elec96_ring_dip_angle_xcorr_s2)
plot(x3, elec96_ring_dip_angle_xcorr_s3)
plot(x3, elec96_ring_dip_angle_xcorr_s4)
plot(x3, elec96_ring_dip_angle_xcorr_s5)
plot(x3, elec96_ring_dip_angle_xcorr_s6)
plot(x3, elec96_ring_dip_angle_xcorr_s7)
plot(x3, elec96_ring_dip_angle_xcorr_s8)
plot(x3, elec96_ring_dip_angle_xcorr_s9)
plot(x3, elec96_ring_dip_angle_xcorr_s10)
xlabel('Time')
ylabel('Cross-Correlation')
title('Elec96-Ring DIP Angle XCorrelation (All Segments)')
legend('Segment 1','Segment 2','Segment 3','Segment 4','Segment 5','Segment 6','Segment 7','Segment 8','Segment 9','Segment 10')

%%
%ELEC 51 - RING DIP

[elec51_ring_dip_angle_xcorr_s1, x3] = xcorr(elec51_1_s1, ring_dip_joint_angles_s1, 150, 'coeff');
x3=x3/30;
elec51_ring_dip_angle_xcorr_s2 = xcorr(elec51_1_s2, ring_dip_joint_angles_s2, 150, 'coeff');
elec51_ring_dip_angle_xcorr_s3 = xcorr(elec51_1_s3, ring_dip_joint_angles_s3, 150, 'coeff');
elec51_ring_dip_angle_xcorr_s4 = xcorr(elec51_1_s4, ring_dip_joint_angles_s4, 150, 'coeff');
elec51_ring_dip_angle_xcorr_s5 = xcorr(elec51_1_s5, ring_dip_joint_angles_s5, 150, 'coeff');
elec51_ring_dip_angle_xcorr_s6 = xcorr(elec51_1_s6, ring_dip_joint_angles_s6, 150, 'coeff');
elec51_ring_dip_angle_xcorr_s7 = xcorr(elec51_1_s7, ring_dip_joint_angles_s7, 150, 'coeff');
elec51_ring_dip_angle_xcorr_s8 = xcorr(elec51_1_s8, ring_dip_joint_angles_s8, 150, 'coeff');
elec51_ring_dip_angle_xcorr_s9 = xcorr(elec51_1_s9, ring_dip_joint_angles_s9, 150, 'coeff');
elec51_ring_dip_angle_xcorr_s10 = xcorr(elec51_1_s10, ring_dip_joint_angles_s10, 150, 'coeff');

figure
hold on
plot(x3, elec51_ring_dip_angle_xcorr_s1)
plot(x3, elec51_ring_dip_angle_xcorr_s2)
plot(x3, elec51_ring_dip_angle_xcorr_s3)
plot(x3, elec51_ring_dip_angle_xcorr_s4)
plot(x3, elec51_ring_dip_angle_xcorr_s5)
plot(x3, elec51_ring_dip_angle_xcorr_s6)
plot(x3, elec51_ring_dip_angle_xcorr_s7)
plot(x3, elec51_ring_dip_angle_xcorr_s8)
plot(x3, elec51_ring_dip_angle_xcorr_s9)
plot(x3, elec51_ring_dip_angle_xcorr_s10)
xlabel('Time')
ylabel('Cross-Correlation')
title('Elec51-Ring DIP Angle XCorrelation (All Segments)')
legend('Segment 1','Segment 2','Segment 3','Segment 4','Segment 5','Segment 6','Segment 7','Segment 8','Segment 9','Segment 10')
%%
%ELEC 40 - RING DIP

[elec40_ring_dip_angle_xcorr_s1, x3] = xcorr(elec40_1_s1, ring_dip_joint_angles_s1, 150, 'coeff');
x3=x3/30;
elec40_ring_dip_angle_xcorr_s2 = xcorr(elec40_1_s2, ring_dip_joint_angles_s2, 150, 'coeff');
elec40_ring_dip_angle_xcorr_s3 = xcorr(elec40_1_s3, ring_dip_joint_angles_s3, 150, 'coeff');
elec40_ring_dip_angle_xcorr_s4 = xcorr(elec40_1_s4, ring_dip_joint_angles_s4, 150, 'coeff');
elec40_ring_dip_angle_xcorr_s5 = xcorr(elec40_1_s5, ring_dip_joint_angles_s5, 150, 'coeff');
elec40_ring_dip_angle_xcorr_s6 = xcorr(elec40_1_s6, ring_dip_joint_angles_s6, 150, 'coeff');
elec40_ring_dip_angle_xcorr_s7 = xcorr(elec40_1_s7, ring_dip_joint_angles_s7, 150, 'coeff');
elec40_ring_dip_angle_xcorr_s8 = xcorr(elec40_1_s8, ring_dip_joint_angles_s8, 150, 'coeff');
elec40_ring_dip_angle_xcorr_s9 = xcorr(elec40_1_s9, ring_dip_joint_angles_s9, 150, 'coeff');
elec40_ring_dip_angle_xcorr_s10 = xcorr(elec40_1_s10, ring_dip_joint_angles_s10, 150, 'coeff');

figure
hold on
plot(x3, elec40_ring_dip_angle_xcorr_s1)
plot(x3, elec40_ring_dip_angle_xcorr_s2)
plot(x3, elec40_ring_dip_angle_xcorr_s3)
plot(x3, elec40_ring_dip_angle_xcorr_s4)
plot(x3, elec40_ring_dip_angle_xcorr_s5)
plot(x3, elec40_ring_dip_angle_xcorr_s6)
plot(x3, elec40_ring_dip_angle_xcorr_s7)
plot(x3, elec40_ring_dip_angle_xcorr_s8)
plot(x3, elec40_ring_dip_angle_xcorr_s9)
plot(x3, elec40_ring_dip_angle_xcorr_s10)
xlabel('Time')
ylabel('Cross-Correlation')
title('Elec40-Ring DIP Angle XCorrelation (All Segments)')
legend('Segment 1','Segment 2','Segment 3','Segment 4','Segment 5','Segment 6','Segment 7','Segment 8','Segment 9','Segment 10')

%%
%ELEC 86 - MIDDLE DIP

[elec86_middle_dip_angle_xcorr_s1, x3] = xcorr(elec86_1_s1, middle_dip_joint_angles_s1, 150, 'coeff');
x3=x3/30;
elec86_middle_dip_angle_xcorr_s2 = xcorr(elec86_1_s2, middle_dip_joint_angles_s2, 150, 'coeff');
elec86_middle_dip_angle_xcorr_s3 = xcorr(elec86_1_s3, middle_dip_joint_angles_s3, 150, 'coeff');
elec86_middle_dip_angle_xcorr_s4 = xcorr(elec86_1_s4, middle_dip_joint_angles_s4, 150, 'coeff');
elec86_middle_dip_angle_xcorr_s5 = xcorr(elec86_1_s5, middle_dip_joint_angles_s5, 150, 'coeff');
elec86_middle_dip_angle_xcorr_s6 = xcorr(elec86_1_s6, middle_dip_joint_angles_s6, 150, 'coeff');
elec86_middle_dip_angle_xcorr_s7 = xcorr(elec86_1_s7, middle_dip_joint_angles_s7, 150, 'coeff');
elec86_middle_dip_angle_xcorr_s8 = xcorr(elec86_1_s8, middle_dip_joint_angles_s8, 150, 'coeff');
elec86_middle_dip_angle_xcorr_s9 = xcorr(elec86_1_s9, middle_dip_joint_angles_s9, 150, 'coeff');
elec86_middle_dip_angle_xcorr_s10 = xcorr(elec86_1_s10, middle_dip_joint_angles_s10, 150, 'coeff');

figure
hold on
plot(x3, elec86_middle_dip_angle_xcorr_s1)
plot(x3, elec86_middle_dip_angle_xcorr_s2)
plot(x3, elec86_middle_dip_angle_xcorr_s3)
plot(x3, elec86_middle_dip_angle_xcorr_s4)
plot(x3, elec86_middle_dip_angle_xcorr_s5)
plot(x3, elec86_middle_dip_angle_xcorr_s6)
plot(x3, elec86_middle_dip_angle_xcorr_s7)
plot(x3, elec86_middle_dip_angle_xcorr_s8)
plot(x3, elec86_middle_dip_angle_xcorr_s9)
plot(x3, elec86_middle_dip_angle_xcorr_s10)
xlabel('Time')
ylabel('Cross-Correlation')
title('Elec86-Middle DIP Angle XCorrelation (All Segments)')
legend('Segment 1','Segment 2','Segment 3','Segment 4','Segment 5','Segment 6','Segment 7','Segment 8','Segment 9','Segment 10')

%%
%ELEC 96 - MIDDLE DIP

[elec96_middle_dip_angle_xcorr_s1, x3] = xcorr(elec96_1_s1, middle_dip_joint_angles_s1, 150, 'coeff');
x3=x3/30;
elec96_middle_dip_angle_xcorr_s2 = xcorr(elec96_1_s2, middle_dip_joint_angles_s2, 150, 'coeff');
elec96_middle_dip_angle_xcorr_s3 = xcorr(elec96_1_s3, middle_dip_joint_angles_s3, 150, 'coeff');
elec96_middle_dip_angle_xcorr_s4 = xcorr(elec96_1_s4, middle_dip_joint_angles_s4, 150, 'coeff');
elec96_middle_dip_angle_xcorr_s5 = xcorr(elec96_1_s5, middle_dip_joint_angles_s5, 150, 'coeff');
elec96_middle_dip_angle_xcorr_s6 = xcorr(elec96_1_s6, middle_dip_joint_angles_s6, 150, 'coeff');
elec96_middle_dip_angle_xcorr_s7 = xcorr(elec96_1_s7, middle_dip_joint_angles_s7, 150, 'coeff');
elec96_middle_dip_angle_xcorr_s8 = xcorr(elec96_1_s8, middle_dip_joint_angles_s8, 150, 'coeff');
elec96_middle_dip_angle_xcorr_s9 = xcorr(elec96_1_s9, middle_dip_joint_angles_s9, 150, 'coeff');
elec96_middle_dip_angle_xcorr_s10 = xcorr(elec96_1_s10, middle_dip_joint_angles_s10, 150, 'coeff');

figure
hold on
plot(x3, elec96_middle_dip_angle_xcorr_s1)
plot(x3, elec96_middle_dip_angle_xcorr_s2)
plot(x3, elec96_middle_dip_angle_xcorr_s3)
plot(x3, elec96_middle_dip_angle_xcorr_s4)
plot(x3, elec96_middle_dip_angle_xcorr_s5)
plot(x3, elec96_middle_dip_angle_xcorr_s6)
plot(x3, elec96_middle_dip_angle_xcorr_s7)
plot(x3, elec96_middle_dip_angle_xcorr_s8)
plot(x3, elec96_middle_dip_angle_xcorr_s9)
plot(x3, elec96_middle_dip_angle_xcorr_s10)
xlabel('Time')
ylabel('Cross-Correlation')
title('Elec96-Middle DIP Angle XCorrelation (All Segments)')
legend('Segment 1','Segment 2','Segment 3','Segment 4','Segment 5','Segment 6','Segment 7','Segment 8','Segment 9','Segment 10')

%%
%ELEC 51 - MIDDLE DIP

[elec51_middle_dip_angle_xcorr_s1, x3] = xcorr(elec51_1_s1, middle_dip_joint_angles_s1, 150, 'coeff');
x3=x3/30;
elec51_middle_dip_angle_xcorr_s2 = xcorr(elec51_1_s2, middle_dip_joint_angles_s2, 150, 'coeff');
elec51_middle_dip_angle_xcorr_s3 = xcorr(elec51_1_s3, middle_dip_joint_angles_s3, 150, 'coeff');
elec51_middle_dip_angle_xcorr_s4 = xcorr(elec51_1_s4, middle_dip_joint_angles_s4, 150, 'coeff');
elec51_middle_dip_angle_xcorr_s5 = xcorr(elec51_1_s5, middle_dip_joint_angles_s5, 150, 'coeff');
elec51_middle_dip_angle_xcorr_s6 = xcorr(elec51_1_s6, middle_dip_joint_angles_s6, 150, 'coeff');
elec51_middle_dip_angle_xcorr_s7 = xcorr(elec51_1_s7, middle_dip_joint_angles_s7, 150, 'coeff');
elec51_middle_dip_angle_xcorr_s8 = xcorr(elec51_1_s8, middle_dip_joint_angles_s8, 150, 'coeff');
elec51_middle_dip_angle_xcorr_s9 = xcorr(elec51_1_s9, middle_dip_joint_angles_s9, 150, 'coeff');
elec51_middle_dip_angle_xcorr_s10 = xcorr(elec51_1_s10, middle_dip_joint_angles_s10, 150, 'coeff');

figure
hold on
plot(x3, elec51_middle_dip_angle_xcorr_s1)
plot(x3, elec51_middle_dip_angle_xcorr_s2)
plot(x3, elec51_middle_dip_angle_xcorr_s3)
plot(x3, elec51_middle_dip_angle_xcorr_s4)
plot(x3, elec51_middle_dip_angle_xcorr_s5)
plot(x3, elec51_middle_dip_angle_xcorr_s6)
plot(x3, elec51_middle_dip_angle_xcorr_s7)
plot(x3, elec51_middle_dip_angle_xcorr_s8)
plot(x3, elec51_middle_dip_angle_xcorr_s9)
plot(x3, elec51_middle_dip_angle_xcorr_s10)
xlabel('Time')
ylabel('Cross-Correlation')
title('Elec51-Middle DIP Angle XCorrelation (All Segments)')
legend('Segment 1','Segment 2','Segment 3','Segment 4','Segment 5','Segment 6','Segment 7','Segment 8','Segment 9','Segment 10')
%%
%ELEC 40 - MIDDLE DIP

[elec40_middle_dip_angle_xcorr_s1, x3] = xcorr(elec40_1_s1, middle_dip_joint_angles_s1, 150, 'coeff');
x3=x3/30;
elec40_middle_dip_angle_xcorr_s2 = xcorr(elec40_1_s2, middle_dip_joint_angles_s2, 150, 'coeff');
elec40_middle_dip_angle_xcorr_s3 = xcorr(elec40_1_s3, middle_dip_joint_angles_s3, 150, 'coeff');
elec40_middle_dip_angle_xcorr_s4 = xcorr(elec40_1_s4, middle_dip_joint_angles_s4, 150, 'coeff');
elec40_middle_dip_angle_xcorr_s5 = xcorr(elec40_1_s5, middle_dip_joint_angles_s5, 150, 'coeff');
elec40_middle_dip_angle_xcorr_s6 = xcorr(elec40_1_s6, middle_dip_joint_angles_s6, 150, 'coeff');
elec40_middle_dip_angle_xcorr_s7 = xcorr(elec40_1_s7, middle_dip_joint_angles_s7, 150, 'coeff');
elec40_middle_dip_angle_xcorr_s8 = xcorr(elec40_1_s8, middle_dip_joint_angles_s8, 150, 'coeff');
elec40_middle_dip_angle_xcorr_s9 = xcorr(elec40_1_s9, middle_dip_joint_angles_s9, 150, 'coeff');
elec40_middle_dip_angle_xcorr_s10 = xcorr(elec40_1_s10, middle_dip_joint_angles_s10, 150, 'coeff');

figure
hold on
plot(x3, elec40_middle_dip_angle_xcorr_s1)
plot(x3, elec40_middle_dip_angle_xcorr_s2)
plot(x3, elec40_middle_dip_angle_xcorr_s3)
plot(x3, elec40_middle_dip_angle_xcorr_s4)
plot(x3, elec40_middle_dip_angle_xcorr_s5)
plot(x3, elec40_middle_dip_angle_xcorr_s6)
plot(x3, elec40_middle_dip_angle_xcorr_s7)
plot(x3, elec40_middle_dip_angle_xcorr_s8)
plot(x3, elec40_middle_dip_angle_xcorr_s9)
plot(x3, elec40_middle_dip_angle_xcorr_s10)
xlabel('Time')
ylabel('Cross-Correlation')
title('Elec40-Middle DIP Angle XCorrelation (All Segments)')
legend('Segment 1','Segment 2','Segment 3','Segment 4','Segment 5','Segment 6','Segment 7','Segment 8','Segment 9','Segment 10')

%%
%%%%%%%%%%%PLOTTING CROSS CORRELATIONS FOR WHOLE DATA STREAM%%%%%%%%%%%%%%%%
[elec86_middle_dip_angle_xcorr, x4] = xcorr(elec86_1, middle_dip_joint_angles, 600, 'coeff');
x4=x4/30;
[elec86_middle_pip_angle_xcorr, x4] = xcorr(elec86_1, middle_pip_joint_angles, 600, 'coeff');
[elec86_ring_pip_angle_xcorr, x4] = xcorr(elec86_1, ring_pip_joint_angles, 600, 'coeff');
[elec86_ring_dip_angle_xcorr, x4] = xcorr(elec86_1, ring_dip_joint_angles, 600, 'coeff');

figure
hold on
plot(x4, elec86_middle_dip_angle_xcorr)
plot(x4, elec86_middle_pip_angle_xcorr)
plot(x4, elec86_ring_pip_angle_xcorr)
plot(x4, elec86_ring_dip_angle_xcorr)
xlabel('Time')
ylabel('Cross-Correlation')
title('Elec86-Hinge Angle XCorrelation (Whole Datastream)')
legend('Middle DIP', 'Middle PIP', 'Ring PIP', 'Ring DIP')
%%
[elec96_middle_dip_angle_xcorr, x4] = xcorr(elec96_1, middle_dip_joint_angles, 600, 'coeff');
x4=x4/30;
[elec96_middle_pip_angle_xcorr, x4] = xcorr(elec96_1, middle_pip_joint_angles, 600, 'coeff');
[elec96_ring_pip_angle_xcorr, x4] = xcorr(elec96_1, ring_pip_joint_angles, 600, 'coeff');
[elec96_ring_dip_angle_xcorr, x4] = xcorr(elec96_1, ring_dip_joint_angles, 600, 'coeff');

figure
hold on
plot(x4, elec96_middle_dip_angle_xcorr)
plot(x4, elec96_middle_pip_angle_xcorr)
plot(x4, elec96_ring_pip_angle_xcorr)
plot(x4, elec96_ring_dip_angle_xcorr)
xlabel('Time')
ylabel('Cross-Correlation')
title('Elec96-Hinge Angle XCorrelation (Whole Datastream)')
legend('Middle DIP', 'Middle PIP', 'Ring PIP', 'Ring DIP')
%%
[elec51_middle_dip_angle_xcorr, x4] = xcorr(elec51_1, middle_dip_joint_angles, 600, 'coeff');
x4=x4/30;
[elec51_middle_pip_angle_xcorr, x4] = xcorr(elec51_1, middle_pip_joint_angles, 600, 'coeff');
[elec51_ring_pip_angle_xcorr, x4] = xcorr(elec51_1, ring_pip_joint_angles, 600, 'coeff');
[elec51_ring_dip_angle_xcorr, x4] = xcorr(elec51_1, ring_dip_joint_angles, 600, 'coeff');

figure
hold on
plot(x4, elec51_middle_dip_angle_xcorr)
plot(x4, elec51_middle_pip_angle_xcorr)
plot(x4, elec51_ring_pip_angle_xcorr)
plot(x4, elec51_ring_dip_angle_xcorr)
xlabel('Time')
ylabel('Cross-Correlation')
title('Elec51-Hinge Angle XCorrelation (Whole Datastream)')
legend('Middle DIP', 'Middle PIP', 'Ring PIP', 'Ring DIP')
%%
[elec79_middle_dip_angle_xcorr, x4] = xcorr(elec79_3, middle_dip_joint_angles, 600, 'coeff');
x4=x4/30;
[elec79_middle_pip_angle_xcorr, x4] = xcorr(elec79_3, middle_pip_joint_angles, 600, 'coeff');
[elec79_ring_pip_angle_xcorr, x4] = xcorr(elec79_3, ring_pip_joint_angles, 600, 'coeff');
[elec79_ring_dip_angle_xcorr, x4] = xcorr(elec79_3, ring_dip_joint_angles, 600, 'coeff');

figure
hold on
plot(x4, elec79_middle_dip_angle_xcorr)
plot(x4, elec79_middle_pip_angle_xcorr)
plot(x4, elec79_ring_pip_angle_xcorr)
plot(x4, elec79_ring_dip_angle_xcorr)
xlabel('Time')
ylabel('Cross-Correlation')
title('Elec79-Hinge Angle XCorrelation (Whole Datastream)')
legend('Middle DIP', 'Middle PIP', 'Ring PIP', 'Ring DIP')
%%
[elec40_middle_dip_angle_xcorr, x4] = xcorr(elec40_1, middle_dip_joint_angles, 600, 'coeff');
x4=x4/30;
[elec40_middle_pip_angle_xcorr, x4] = xcorr(elec40_1, middle_pip_joint_angles, 600, 'coeff');
[elec40_ring_pip_angle_xcorr, x4] = xcorr(elec40_1, ring_pip_joint_angles, 600, 'coeff');
[elec40_ring_dip_angle_xcorr, x4] = xcorr(elec40_1, ring_dip_joint_angles, 600, 'coeff');

figure
hold on
plot(x4, elec40_middle_dip_angle_xcorr)
plot(x4, elec40_middle_pip_angle_xcorr)
plot(x4, elec40_ring_pip_angle_xcorr)
plot(x4, elec40_ring_dip_angle_xcorr)
xlabel('Time')
ylabel('Cross-Correlation')
title('Elec40-Hinge Angle XCorrelation (Whole Datastream)')
legend('Middle DIP', 'Middle PIP', 'Ring PIP', 'Ring DIP')
%%
elec40_middle_dip_angle_avg_xcorr = (elec40_middle_dip_angle_xcorr_s1+elec40_middle_dip_angle_xcorr_s2+elec40_middle_dip_angle_xcorr_s3+elec40_middle_dip_angle_xcorr_s4+elec40_middle_dip_angle_xcorr_s5+elec40_middle_dip_angle_xcorr_s6+elec40_middle_dip_angle_xcorr_s7+elec40_middle_dip_angle_xcorr_s8+elec40_middle_dip_angle_xcorr_s9+elec40_middle_dip_angle_xcorr_s10)/10;
elec40_middle_pip_angle_avg_xcorr = (elec40_middle_pip_angle_xcorr_s1+elec40_middle_pip_angle_xcorr_s2+elec40_middle_pip_angle_xcorr_s3+elec40_middle_pip_angle_xcorr_s4+elec40_middle_pip_angle_xcorr_s5+elec40_middle_pip_angle_xcorr_s6+elec40_middle_pip_angle_xcorr_s7+elec40_middle_pip_angle_xcorr_s8+elec40_middle_pip_angle_xcorr_s9+elec40_middle_pip_angle_xcorr_s10)/10;
elec40_ring_dip_angle_avg_xcorr = (elec40_ring_dip_angle_xcorr_s1+elec40_ring_dip_angle_xcorr_s2+elec40_ring_dip_angle_xcorr_s3+elec40_ring_dip_angle_xcorr_s4+elec40_ring_dip_angle_xcorr_s5+elec40_ring_dip_angle_xcorr_s6+elec40_ring_dip_angle_xcorr_s7+elec40_ring_dip_angle_xcorr_s8+elec40_ring_dip_angle_xcorr_s9+elec40_ring_dip_angle_xcorr_s10)/10;
elec40_ring_pip_angle_avg_xcorr = (elec40_ring_pip_angle_xcorr_s1+elec40_ring_pip_angle_xcorr_s2+elec40_ring_pip_angle_xcorr_s3+elec40_ring_pip_angle_xcorr_s4+elec40_ring_pip_angle_xcorr_s5+elec40_ring_pip_angle_xcorr_s6+elec40_ring_pip_angle_xcorr_s7+elec40_ring_pip_angle_xcorr_s8+elec40_ring_pip_angle_xcorr_s9+elec40_ring_pip_angle_xcorr_s10)/10;


figure
plot(x3, elec40_middle_dip_angle_avg_xcorr)
title('Elec40-Middle DIP Angle XCorrelation (Average Across Segments)')
xlabel('Time')
ylabel('Cross-Correlation')
figure
plot(x3, elec40_middle_pip_angle_avg_xcorr)
title('Elec40-Middle PIP Angle XCorrelation (Average Across Segments)')
xlabel('Time')
ylabel('Cross-Correlation')
figure
plot(x3, elec40_ring_dip_angle_avg_xcorr)
title('Elec40-Ring DIP Angle XCorrelation (Average Across Segments)')
xlabel('Time')
ylabel('Cross-Correlation')
figure
plot(x3, elec40_ring_pip_angle_avg_xcorr)
title('Elec40-Ring PIP Angle XCorrelation (Average Across Segments)')
xlabel('Time')
ylabel('Cross-Correlation')

%%

middle_dip_middle_pip_angle_xcorr_s1 = xcorr(middle_dip_joint_angles_s1, middle_pip_joint_angles_s1, 150, 'coeff');
middle_dip_middle_pip_angle_xcorr_s2 = xcorr(middle_dip_joint_angles_s2, middle_pip_joint_angles_s2, 150, 'coeff');
middle_dip_middle_pip_angle_xcorr_s3 = xcorr(middle_dip_joint_angles_s3, middle_pip_joint_angles_s3, 150, 'coeff');
middle_dip_middle_pip_angle_xcorr_s4 = xcorr(middle_dip_joint_angles_s4, middle_pip_joint_angles_s4, 150, 'coeff');
middle_dip_middle_pip_angle_xcorr_s5 = xcorr(middle_dip_joint_angles_s5, middle_pip_joint_angles_s5, 150, 'coeff');
middle_dip_middle_pip_angle_xcorr_s6 = xcorr(middle_dip_joint_angles_s6, middle_pip_joint_angles_s6, 150, 'coeff');
middle_dip_middle_pip_angle_xcorr_s7 = xcorr(middle_dip_joint_angles_s7, middle_pip_joint_angles_s7, 150, 'coeff');
middle_dip_middle_pip_angle_xcorr_s8 = xcorr(middle_dip_joint_angles_s8, middle_pip_joint_angles_s8, 150, 'coeff');
middle_dip_middle_pip_angle_xcorr_s9 = xcorr(middle_dip_joint_angles_s9, middle_pip_joint_angles_s9, 150, 'coeff');
middle_dip_middle_pip_angle_xcorr_s10 = xcorr(middle_dip_joint_angles_s10, middle_pip_joint_angles_s10, 150, 'coeff');

%%

figure
hold on
plot(x3, middle_dip_middle_pip_angle_xcorr_s1)
plot(x3, middle_dip_middle_pip_angle_xcorr_s2)
plot(x3, middle_dip_middle_pip_angle_xcorr_s3)
plot(x3, middle_dip_middle_pip_angle_xcorr_s4)
plot(x3, middle_dip_middle_pip_angle_xcorr_s5)
plot(x3, middle_dip_middle_pip_angle_xcorr_s6)
plot(x3, middle_dip_middle_pip_angle_xcorr_s7)
plot(x3, middle_dip_middle_pip_angle_xcorr_s8)
plot(x3, middle_dip_middle_pip_angle_xcorr_s9)
plot(x3, middle_dip_middle_pip_angle_xcorr_s10)
xlabel('Time')
ylabel('Cross-Correlation')
title('Middle DIP-Middle PIP Angle XCorrelation (All Segments)')
legend('Segment 1','Segment 2','Segment 3','Segment 4','Segment 5','Segment 6','Segment 7','Segment 8','Segment 9','Segment 10')
%%
middle_dip_ring_pip_angle_xcorr_s1 = xcorr(middle_dip_joint_angles_s1, ring_pip_joint_angles_s1, 150, 'coeff');
middle_dip_ring_pip_angle_xcorr_s2 = xcorr(middle_dip_joint_angles_s2, ring_pip_joint_angles_s2, 150, 'coeff');
middle_dip_ring_pip_angle_xcorr_s3 = xcorr(middle_dip_joint_angles_s3, ring_pip_joint_angles_s3, 150, 'coeff');
middle_dip_ring_pip_angle_xcorr_s4 = xcorr(middle_dip_joint_angles_s4, ring_pip_joint_angles_s4, 150, 'coeff');
middle_dip_ring_pip_angle_xcorr_s5 = xcorr(middle_dip_joint_angles_s5, ring_pip_joint_angles_s5, 150, 'coeff');
middle_dip_ring_pip_angle_xcorr_s6 = xcorr(middle_dip_joint_angles_s6, ring_pip_joint_angles_s6, 150, 'coeff');
middle_dip_ring_pip_angle_xcorr_s7 = xcorr(middle_dip_joint_angles_s7, ring_pip_joint_angles_s7, 150, 'coeff');
middle_dip_ring_pip_angle_xcorr_s8 = xcorr(middle_dip_joint_angles_s8, ring_pip_joint_angles_s8, 150, 'coeff');
middle_dip_ring_pip_angle_xcorr_s9 = xcorr(middle_dip_joint_angles_s9, ring_pip_joint_angles_s9, 150, 'coeff');
middle_dip_ring_pip_angle_xcorr_s10 = xcorr(middle_dip_joint_angles_s10, ring_pip_joint_angles_s10, 150, 'coeff');

figure
hold on
plot(x3, middle_dip_ring_pip_angle_xcorr_s1)
plot(x3, middle_dip_ring_pip_angle_xcorr_s2)
plot(x3, middle_dip_ring_pip_angle_xcorr_s3)
plot(x3, middle_dip_ring_pip_angle_xcorr_s4)
plot(x3, middle_dip_ring_pip_angle_xcorr_s5)
plot(x3, middle_dip_ring_pip_angle_xcorr_s6)
plot(x3, middle_dip_ring_pip_angle_xcorr_s7)
plot(x3, middle_dip_ring_pip_angle_xcorr_s8)
plot(x3, middle_dip_ring_pip_angle_xcorr_s9)
plot(x3, middle_dip_ring_pip_angle_xcorr_s10)
xlabel('Time')
ylabel('Cross-Correlation')
title('Middle DIP-Ring PIP Angle XCorrelation (All Segments)')
legend('Segment 1','Segment 2','Segment 3','Segment 4','Segment 5','Segment 6','Segment 7','Segment 8','Segment 9','Segment 10')
%%
middle_dip_ring_dip_angle_xcorr_s1 = xcorr(middle_dip_joint_angles_s1, ring_dip_joint_angles_s1, 150, 'coeff');
middle_dip_ring_dip_angle_xcorr_s2 = xcorr(middle_dip_joint_angles_s2, ring_dip_joint_angles_s2, 150, 'coeff');
middle_dip_ring_dip_angle_xcorr_s3 = xcorr(middle_dip_joint_angles_s3, ring_dip_joint_angles_s3, 150, 'coeff');
middle_dip_ring_dip_angle_xcorr_s4 = xcorr(middle_dip_joint_angles_s4, ring_dip_joint_angles_s4, 150, 'coeff');
middle_dip_ring_dip_angle_xcorr_s5 = xcorr(middle_dip_joint_angles_s5, ring_dip_joint_angles_s5, 150, 'coeff');
middle_dip_ring_dip_angle_xcorr_s6 = xcorr(middle_dip_joint_angles_s6, ring_dip_joint_angles_s6, 150, 'coeff');
middle_dip_ring_dip_angle_xcorr_s7 = xcorr(middle_dip_joint_angles_s7, ring_dip_joint_angles_s7, 150, 'coeff');
middle_dip_ring_dip_angle_xcorr_s8 = xcorr(middle_dip_joint_angles_s8, ring_dip_joint_angles_s8, 150, 'coeff');
middle_dip_ring_dip_angle_xcorr_s9 = xcorr(middle_dip_joint_angles_s9, ring_dip_joint_angles_s9, 150, 'coeff');
middle_dip_ring_dip_angle_xcorr_s10 = xcorr(middle_dip_joint_angles_s10, ring_dip_joint_angles_s10, 150, 'coeff');

figure
hold on
plot(x3, middle_dip_ring_dip_angle_xcorr_s1)
plot(x3, middle_dip_ring_dip_angle_xcorr_s2)
plot(x3, middle_dip_ring_dip_angle_xcorr_s3)
plot(x3, middle_dip_ring_dip_angle_xcorr_s4)
plot(x3, middle_dip_ring_dip_angle_xcorr_s5)
plot(x3, middle_dip_ring_dip_angle_xcorr_s6)
plot(x3, middle_dip_ring_dip_angle_xcorr_s7)
plot(x3, middle_dip_ring_dip_angle_xcorr_s8)
plot(x3, middle_dip_ring_dip_angle_xcorr_s9)
plot(x3, middle_dip_ring_dip_angle_xcorr_s10)
xlabel('Time')
ylabel('Cross-Correlation')
title('Middle DIP-Ring DIP Angle XCorrelation (All Segments)')
legend('Segment 1','Segment 2','Segment 3','Segment 4','Segment 5','Segment 6','Segment 7','Segment 8','Segment 9','Segment 10')
%%
middle_dip_middle_dip_angle_xcorr_s1 = xcorr(middle_dip_joint_angles_s1, middle_dip_joint_angles_s1, 150, 'coeff');
middle_dip_middle_dip_angle_xcorr_s2 = xcorr(middle_dip_joint_angles_s2, middle_dip_joint_angles_s2, 150, 'coeff');
middle_dip_middle_dip_angle_xcorr_s3 = xcorr(middle_dip_joint_angles_s3, middle_dip_joint_angles_s3, 150, 'coeff');
middle_dip_middle_dip_angle_xcorr_s4 = xcorr(middle_dip_joint_angles_s4, middle_dip_joint_angles_s4, 150, 'coeff');
middle_dip_middle_dip_angle_xcorr_s5 = xcorr(middle_dip_joint_angles_s5, middle_dip_joint_angles_s5, 150, 'coeff');
middle_dip_middle_dip_angle_xcorr_s6 = xcorr(middle_dip_joint_angles_s6, middle_dip_joint_angles_s6, 150, 'coeff');
middle_dip_middle_dip_angle_xcorr_s7 = xcorr(middle_dip_joint_angles_s7, middle_dip_joint_angles_s7, 150, 'coeff');
middle_dip_middle_dip_angle_xcorr_s8 = xcorr(middle_dip_joint_angles_s8, middle_dip_joint_angles_s8, 150, 'coeff');
middle_dip_middle_dip_angle_xcorr_s9 = xcorr(middle_dip_joint_angles_s9, middle_dip_joint_angles_s9, 150, 'coeff');
middle_dip_middle_dip_angle_xcorr_s10 = xcorr(middle_dip_joint_angles_s10, middle_dip_joint_angles_s10, 150, 'coeff');

figure
hold on
plot(x3, middle_dip_middle_dip_angle_xcorr_s1)
plot(x3, middle_dip_middle_dip_angle_xcorr_s2)
plot(x3, middle_dip_middle_dip_angle_xcorr_s3)
plot(x3, middle_dip_middle_dip_angle_xcorr_s4)
plot(x3, middle_dip_middle_dip_angle_xcorr_s5)
plot(x3, middle_dip_middle_dip_angle_xcorr_s6)
plot(x3, middle_dip_middle_dip_angle_xcorr_s7)
plot(x3, middle_dip_middle_dip_angle_xcorr_s8)
plot(x3, middle_dip_middle_dip_angle_xcorr_s9)
plot(x3, middle_dip_middle_dip_angle_xcorr_s10)
xlabel('Time')
ylabel('Cross-Correlation')
title('Middle DIP-Middle DIP Angle AutoCorrelation (All Segments)')
legend('Segment 1','Segment 2','Segment 3','Segment 4','Segment 5','Segment 6','Segment 7','Segment 8','Segment 9','Segment 10')
%%
middle_dip_middle_dip_angle_avg_xcorr = (middle_dip_middle_dip_angle_xcorr_s1+middle_dip_middle_dip_angle_xcorr_s2+middle_dip_middle_dip_angle_xcorr_s3+middle_dip_middle_dip_angle_xcorr_s4+middle_dip_middle_dip_angle_xcorr_s5+middle_dip_middle_dip_angle_xcorr_s6+middle_dip_middle_dip_angle_xcorr_s7+middle_dip_middle_dip_angle_xcorr_s8+middle_dip_middle_dip_angle_xcorr_s9+middle_dip_middle_dip_angle_xcorr_s10)/10;
middle_dip_middle_pip_angle_avg_xcorr = (middle_dip_middle_pip_angle_xcorr_s1+middle_dip_middle_pip_angle_xcorr_s2+middle_dip_middle_pip_angle_xcorr_s3+middle_dip_middle_pip_angle_xcorr_s4+middle_dip_middle_pip_angle_xcorr_s5+middle_dip_middle_pip_angle_xcorr_s6+middle_dip_middle_pip_angle_xcorr_s7+middle_dip_middle_pip_angle_xcorr_s8+middle_dip_middle_pip_angle_xcorr_s9+middle_dip_middle_pip_angle_xcorr_s10)/10;
middle_dip_ring_dip_angle_avg_xcorr = (middle_dip_ring_dip_angle_xcorr_s1+middle_dip_ring_dip_angle_xcorr_s2+middle_dip_ring_dip_angle_xcorr_s3+middle_dip_ring_dip_angle_xcorr_s4+middle_dip_ring_dip_angle_xcorr_s5+middle_dip_ring_dip_angle_xcorr_s6+middle_dip_ring_dip_angle_xcorr_s7+middle_dip_ring_dip_angle_xcorr_s8+middle_dip_ring_dip_angle_xcorr_s9+middle_dip_ring_dip_angle_xcorr_s10)/10;
middle_dip_ring_pip_angle_avg_xcorr = (middle_dip_ring_pip_angle_xcorr_s1+middle_dip_ring_pip_angle_xcorr_s2+middle_dip_ring_pip_angle_xcorr_s3+middle_dip_ring_pip_angle_xcorr_s4+middle_dip_ring_pip_angle_xcorr_s5+middle_dip_ring_pip_angle_xcorr_s6+middle_dip_ring_pip_angle_xcorr_s7+middle_dip_ring_pip_angle_xcorr_s8+middle_dip_ring_pip_angle_xcorr_s9+middle_dip_ring_pip_angle_xcorr_s10)/10;


figure
plot(x3, middle_dip_middle_dip_angle_avg_xcorr)
title('Middle DIP-Middle DIP Angle AutoCorrelation (Average Across Segments)')
xlabel('Time')
ylabel('Cross-Correlation')
figure
plot(x3, middle_dip_middle_pip_angle_avg_xcorr)
title('Middle DIP-Middle PIP Angle XCorrelation (Average Across Segments)')
xlabel('Time')
ylabel('Cross-Correlation')
figure
plot(x3, middle_dip_ring_dip_angle_avg_xcorr)
title('Middle DIP-Ring DIP Angle XCorrelation (Average Across Segments)')
xlabel('Time')
ylabel('Cross-Correlation')
figure
plot(x3, middle_dip_ring_pip_angle_avg_xcorr)
title('Middle DIP-Ring PIP Angle XCorrelation (Average Across Segments)')
xlabel('Time')
ylabel('Cross-Correlation')

%%

[elec86_middle_pip_angle_xcorr_s1_BAD, xbad1] = xcorr(elec86_1_s1_BAD, middle_pip_joint_angles_s1_BAD, 150, 'coeff');
xbad1=xbad1/30;
[elec86_middle_dip_angle_xcorr_s1_BAD, xbad1] = xcorr(elec86_1_s1_BAD, middle_dip_joint_angles_s1_BAD, 150, 'coeff');
[elec86_ring_pip_angle_xcorr_s1_BAD, xbad1] = xcorr(elec86_1_s1_BAD, ring_pip_joint_angles_s1_BAD, 150, 'coeff');
[elec86_ring_dip_angle_xcorr_s1_BAD, xbad1] = xcorr(elec86_1_s1_BAD, ring_dip_joint_angles_s1_BAD, 150, 'coeff');
[elec96_middle_pip_angle_xcorr_s1_BAD, xbad1] = xcorr(elec96_1_s1_BAD, middle_pip_joint_angles_s1_BAD, 150, 'coeff');
[elec96_middle_dip_angle_xcorr_s1_BAD, xbad1] = xcorr(elec96_1_s1_BAD, middle_dip_joint_angles_s1_BAD, 150, 'coeff');
[elec96_ring_pip_angle_xcorr_s1_BAD, xbad1] = xcorr(elec96_1_s1_BAD, ring_pip_joint_angles_s1_BAD, 150, 'coeff');
[elec96_ring_dip_angle_xcorr_s1_BAD, xbad1] = xcorr(elec96_1_s1_BAD, ring_dip_joint_angles_s1_BAD, 150, 'coeff');
[elec51_middle_pip_angle_xcorr_s1_BAD, xbad1] = xcorr(elec51_1_s1_BAD, middle_pip_joint_angles_s1_BAD, 150, 'coeff');
[elec51_middle_dip_angle_xcorr_s1_BAD, xbad1] = xcorr(elec51_1_s1_BAD, middle_dip_joint_angles_s1_BAD, 150, 'coeff');
[elec51_ring_pip_angle_xcorr_s1_BAD, xbad1] = xcorr(elec51_1_s1_BAD, ring_pip_joint_angles_s1_BAD, 150, 'coeff');
[elec51_ring_dip_angle_xcorr_s1_BAD, xbad1] = xcorr(elec51_1_s1_BAD, ring_dip_joint_angles_s1_BAD, 150, 'coeff');
[elec79_middle_pip_angle_xcorr_s1_BAD, xbad1] = xcorr(elec79_3_s1_BAD, middle_pip_joint_angles_s1_BAD, 150, 'coeff');
[elec79_middle_dip_angle_xcorr_s1_BAD, xbad1] = xcorr(elec79_3_s1_BAD, middle_dip_joint_angles_s1_BAD, 150, 'coeff');
[elec79_ring_pip_angle_xcorr_s1_BAD, xbad1] = xcorr(elec79_3_s1_BAD, ring_pip_joint_angles_s1_BAD, 150, 'coeff');
[elec79_ring_dip_angle_xcorr_s1_BAD, xbad1] = xcorr(elec79_3_s1_BAD, ring_dip_joint_angles_s1_BAD, 150, 'coeff');
[elec40_middle_pip_angle_xcorr_s1_BAD, xbad1] = xcorr(elec40_1_s1_BAD, middle_pip_joint_angles_s1_BAD, 150, 'coeff');
[elec40_middle_dip_angle_xcorr_s1_BAD, xbad1] = xcorr(elec40_1_s1_BAD, middle_dip_joint_angles_s1_BAD, 150, 'coeff');
[elec40_ring_pip_angle_xcorr_s1_BAD, xbad1] = xcorr(elec40_1_s1_BAD, ring_pip_joint_angles_s1_BAD, 150, 'coeff');
[elec40_ring_dip_angle_xcorr_s1_BAD, xbad1] = xcorr(elec40_1_s1_BAD, ring_dip_joint_angles_s1_BAD, 150, 'coeff');

[elec86_middle_pip_angle_xcorr_s2_BAD, xbad2] = xcorr(elec86_1_s2_BAD, middle_pip_joint_angles_s2_BAD, 150, 'coeff');
xbad2=xbad2/30;
[elec86_middle_dip_angle_xcorr_s2_BAD, xbad2] = xcorr(elec86_1_s2_BAD, middle_dip_joint_angles_s2_BAD, 150, 'coeff');
[elec86_ring_pip_angle_xcorr_s2_BAD, xbad2] = xcorr(elec86_1_s2_BAD, ring_pip_joint_angles_s2_BAD, 150, 'coeff');
[elec86_ring_dip_angle_xcorr_s2_BAD, xbad2] = xcorr(elec86_1_s2_BAD, ring_dip_joint_angles_s2_BAD, 150, 'coeff');
[elec96_middle_pip_angle_xcorr_s2_BAD, xbad2] = xcorr(elec96_1_s2_BAD, middle_pip_joint_angles_s2_BAD, 150, 'coeff');
[elec96_middle_dip_angle_xcorr_s2_BAD, xbad2] = xcorr(elec96_1_s2_BAD, middle_dip_joint_angles_s2_BAD, 150, 'coeff');
[elec96_ring_pip_angle_xcorr_s2_BAD, xbad2] = xcorr(elec96_1_s2_BAD, ring_pip_joint_angles_s2_BAD, 150, 'coeff');
[elec96_ring_dip_angle_xcorr_s2_BAD, xbad2] = xcorr(elec96_1_s2_BAD, ring_dip_joint_angles_s2_BAD, 150, 'coeff');
[elec51_middle_pip_angle_xcorr_s2_BAD, xbad2] = xcorr(elec51_1_s2_BAD, middle_pip_joint_angles_s2_BAD, 150, 'coeff');
[elec51_middle_dip_angle_xcorr_s2_BAD, xbad2] = xcorr(elec51_1_s2_BAD, middle_dip_joint_angles_s2_BAD, 150, 'coeff');
[elec51_ring_pip_angle_xcorr_s2_BAD, xbad2] = xcorr(elec51_1_s2_BAD, ring_pip_joint_angles_s2_BAD, 150, 'coeff');
[elec51_ring_dip_angle_xcorr_s2_BAD, xbad2] = xcorr(elec51_1_s2_BAD, ring_dip_joint_angles_s2_BAD, 150, 'coeff');
[elec79_middle_pip_angle_xcorr_s2_BAD, xbad2] = xcorr(elec79_3_s2_BAD, middle_pip_joint_angles_s2_BAD, 150, 'coeff');
[elec79_middle_dip_angle_xcorr_s2_BAD, xbad2] = xcorr(elec79_3_s2_BAD, middle_dip_joint_angles_s2_BAD, 150, 'coeff');
[elec79_ring_pip_angle_xcorr_s2_BAD, xbad2] = xcorr(elec79_3_s2_BAD, ring_pip_joint_angles_s2_BAD, 150, 'coeff');
[elec79_ring_dip_angle_xcorr_s2_BAD, xbad2] = xcorr(elec79_3_s2_BAD, ring_dip_joint_angles_s2_BAD, 150, 'coeff');
[elec40_middle_pip_angle_xcorr_s2_BAD, xbad2] = xcorr(elec40_1_s2_BAD, middle_pip_joint_angles_s2_BAD, 150, 'coeff');
[elec40_middle_dip_angle_xcorr_s2_BAD, xbad2] = xcorr(elec40_1_s2_BAD, middle_dip_joint_angles_s2_BAD, 150, 'coeff');
[elec40_ring_pip_angle_xcorr_s2_BAD, xbad2] = xcorr(elec40_1_s2_BAD, ring_pip_joint_angles_s2_BAD, 150, 'coeff');
[elec40_ring_dip_angle_xcorr_s2_BAD, xbad2] = xcorr(elec40_1_s2_BAD, ring_dip_joint_angles_s2_BAD, 150, 'coeff');
