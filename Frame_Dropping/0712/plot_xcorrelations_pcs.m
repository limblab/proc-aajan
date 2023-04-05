%%
%%%%%%%IMPORT DATA%%%%%%%%
neural_pc1_struct = load(['/Users/aajanquail/Downloads/20210712_neural_pc1.mat']);
filtered_hinge_angle_pc1_struct = load(['/Users/aajanquail/Downloads/20210712_filtered_hinge_angle_pc1.mat']);
filtered_hinge_velocity_pc1_struct = load(['/Users/aajanquail/Downloads/20210712_filtered_hinge_velocity_pc1.mat']);
neural_pc1_struct_og = load(['/Users/aajanquail/Downloads/20210712_neural_pc1_og.mat']);
filtered_hinge_angle_pc1_struct_og = load(['/Users/aajanquail/Downloads/20210712_filtered_hinge_angle_pc1_og.mat']);
filtered_hinge_velocity_pc1_struct_og = load(['/Users/aajanquail/Downloads/20210712_filtered_hinge_velocity_pc1_og.mat']);

neural_pc1 = neural_pc1_struct.neural_pc1;
filtered_hinge_angle_pc1 = filtered_hinge_angle_pc1_struct.filtered_hinge_angle_pc1;
filtered_hinge_velocity_pc1 = filtered_hinge_velocity_pc1_struct.filtered_hinge_velocity_pc1;
neural_pc1_og = neural_pc1_struct_og.neural_pc1_og;
filtered_hinge_angle_pc1_og = filtered_hinge_angle_pc1_struct_og.filtered_hinge_angle_pc1_og;
filtered_hinge_velocity_pc1_og = filtered_hinge_velocity_pc1_struct_og.filtered_hinge_velocity_pc1_og;

%%
%%%%%%%%PLOT AUTO-CORRELATIONS%%%%%%%%%%

[auto1, x1] = xcorr(neural_pc1, 600, 'coeff');
auto2 = xcorr(filtered_hinge_angle_pc1, 600, 'coeff');
auto3 = xcorr(filtered_hinge_velocity_pc1, 600, 'coeff');
auto4 = xcorr(neural_pc1_og, 600, 'coeff');
auto5 = xcorr(filtered_hinge_angle_pc1_og, 600, 'coeff');
auto6 = xcorr(filtered_hinge_velocity_pc1_og, 600, 'coeff');
x1 = x1/30;

figure
plot(x1, auto1)
xlabel('Time')
ylabel('AutoCorrelation')
title('Neural PC1 Autocorr (Concatenated Eric Segments)')
figure
plot(x1, auto2)
xlabel('Time')
ylabel('AutoCorrelation')
title('Filtered Hinge Angle Autocorr (Concatenated Eric Segments)')
figure
plot(x1, auto3)
xlabel('Time')
ylabel('AutoCorrelation')
title('Filtered Hinge Velocity Autocorr (Concatenated Eric Segments)')
figure
plot(x1, auto4)
xlabel('Time')
ylabel('AutoCorrelation')
title('Neural PC1 Autocorr (Aajan Segment)')
figure
plot(x1, auto5)
xlabel('Time')
ylabel('AutoCorrelation')
title('Filtered Hinge Angle Autocorr (Aajan Segment)')
figure
plot(x1, auto6)
xlabel('Time')
ylabel('AutoCorrelation')
title('Filtered Hinge Velocity Autocorr (Aajan Segment)')

%%
%%%%%%%%PLOT CROSS CORRELATIONS FOR ERIC'S CONCATENATED SEGMENTS AND AAJAN
%%%%%%%%SEGMENT%%%%%%%%%%%%%

[xcorr1,x2] = xcorr(neural_pc1, filtered_hinge_angle_pc1, 150, 'coeff');
xcorr2 = xcorr(neural_pc1, filtered_hinge_velocity_pc1, 150, 'coeff');
xcorr3 = xcorr(neural_pc1_og, filtered_hinge_angle_pc1_og, 150, 'coeff');
xcorr4 = xcorr(neural_pc1_og, filtered_hinge_velocity_pc1_og, 150, 'coeff');
x2 = x2/30;

figure
plot(x2,xcorr1)
title('Neural PC1-Hinge Angle PC1 XCorr (Concatenated Eric Segments)')
xlabel('Time')
ylabel('Cross-Correlation')
figure
plot(x2,xcorr2)
title('Neural PC1-Hinge Velocity PC1 XCorr (Concatenated Eric Segments)')
xlabel('Time')
ylabel('Cross-Correlation')
figure
plot(x2,xcorr3)
title('Neural PC1-Hinge Angle PC1 XCorr (Aajan Segment)')
xlabel('Time')
ylabel('Cross-Correlation')
figure
plot(x2,xcorr4)
title('Neural PC1-Hinge Velocity PC1 XCorr (Aajan Segment)')
xlabel('Time')
ylabel('Cross-Correlation')

%%
%%%%%%%DIVIDE UP ERIC SEGMENTS%%%%%%%%%%%%%%%

neural_pc1_s1 = neural_pc1(1:299);
neural_pc1_s2 = neural_pc1(300:598);
neural_pc1_s3 = neural_pc1(599:897);
neural_pc1_s4 = neural_pc1(898:1196);
neural_pc1_s5 = neural_pc1(1197:1495);
neural_pc1_s6 = neural_pc1(1496:1794);
neural_pc1_s7 = neural_pc1(1795:2093);
neural_pc1_s8 = neural_pc1(2094:2392);
neural_pc1_s9 = neural_pc1(2393:2691);
neural_pc1_s10 = neural_pc1(2692:end);

filtered_hinge_angle_pc1_s1 = filtered_hinge_angle_pc1(1:299);
filtered_hinge_angle_pc1_s2 = filtered_hinge_angle_pc1(300:598);
filtered_hinge_angle_pc1_s3 = filtered_hinge_angle_pc1(599:897);
filtered_hinge_angle_pc1_s4 = filtered_hinge_angle_pc1(898:1196);
filtered_hinge_angle_pc1_s5 = filtered_hinge_angle_pc1(1197:1495);
filtered_hinge_angle_pc1_s6 = filtered_hinge_angle_pc1(1496:1794);
filtered_hinge_angle_pc1_s7 = filtered_hinge_angle_pc1(1795:2093);
filtered_hinge_angle_pc1_s8 = filtered_hinge_angle_pc1(2094:2392);
filtered_hinge_angle_pc1_s9 = filtered_hinge_angle_pc1(2393:2691);
filtered_hinge_angle_pc1_s10 = filtered_hinge_angle_pc1(2692:end);

filtered_hinge_velocity_pc1_s1 = filtered_hinge_velocity_pc1(1:299);
filtered_hinge_velocity_pc1_s2 = filtered_hinge_velocity_pc1(300:598);
filtered_hinge_velocity_pc1_s3 = filtered_hinge_velocity_pc1(599:897);
filtered_hinge_velocity_pc1_s4 = filtered_hinge_velocity_pc1(898:1196);
filtered_hinge_velocity_pc1_s5 = filtered_hinge_velocity_pc1(1197:1495);
filtered_hinge_velocity_pc1_s6 = filtered_hinge_velocity_pc1(1496:1794);
filtered_hinge_velocity_pc1_s7 = filtered_hinge_velocity_pc1(1795:2093);
filtered_hinge_velocity_pc1_s8 = filtered_hinge_velocity_pc1(2094:2392);
filtered_hinge_velocity_pc1_s9 = filtered_hinge_velocity_pc1(2393:2691);
filtered_hinge_velocity_pc1_s10 = filtered_hinge_velocity_pc1(2692:end);

%%
%%%%%%%%%%%%%GET XCORRELATIONS FOR EACH ERIC SEGMENT%%%%%%%%%%%%%%%

[neural_angle_xcorr_s1, x3] = xcorr(neural_pc1_s1, filtered_hinge_angle_pc1_s1, 150, 'coeff');
x3 = x3/30;
neural_angle_xcorr_s2 = xcorr(neural_pc1_s2, filtered_hinge_angle_pc1_s2, 150, 'coeff');
neural_angle_xcorr_s3 = xcorr(neural_pc1_s3, filtered_hinge_angle_pc1_s3, 150, 'coeff');
neural_angle_xcorr_s4 = xcorr(neural_pc1_s4, filtered_hinge_angle_pc1_s4, 150, 'coeff');
neural_angle_xcorr_s5 = xcorr(neural_pc1_s5, filtered_hinge_angle_pc1_s5, 150, 'coeff');
neural_angle_xcorr_s6 = xcorr(neural_pc1_s6, filtered_hinge_angle_pc1_s6, 150, 'coeff');
neural_angle_xcorr_s7 = xcorr(neural_pc1_s7, filtered_hinge_angle_pc1_s7, 150, 'coeff');
neural_angle_xcorr_s8 = xcorr(neural_pc1_s8, filtered_hinge_angle_pc1_s8, 150, 'coeff');
neural_angle_xcorr_s9 = xcorr(neural_pc1_s9, filtered_hinge_angle_pc1_s9, 150, 'coeff');
neural_angle_xcorr_s10 = xcorr(neural_pc1_s10, filtered_hinge_angle_pc1_s10, 150, 'coeff');

neural_velocity_xcorr_s1 = xcorr(neural_pc1_s1, filtered_hinge_velocity_pc1_s1, 150, 'coeff');
neural_velocity_xcorr_s2 = xcorr(neural_pc1_s2, filtered_hinge_velocity_pc1_s2, 150, 'coeff');
neural_velocity_xcorr_s3 = xcorr(neural_pc1_s3, filtered_hinge_velocity_pc1_s3, 150, 'coeff');
neural_velocity_xcorr_s4 = xcorr(neural_pc1_s4, filtered_hinge_velocity_pc1_s4, 150, 'coeff');
neural_velocity_xcorr_s5 = xcorr(neural_pc1_s5, filtered_hinge_velocity_pc1_s5, 150, 'coeff');
neural_velocity_xcorr_s6 = xcorr(neural_pc1_s6, filtered_hinge_velocity_pc1_s6, 150, 'coeff');
neural_velocity_xcorr_s7 = xcorr(neural_pc1_s7, filtered_hinge_velocity_pc1_s7, 150, 'coeff');
neural_velocity_xcorr_s8 = xcorr(neural_pc1_s8, filtered_hinge_velocity_pc1_s8, 150, 'coeff');
neural_velocity_xcorr_s9 = xcorr(neural_pc1_s9, filtered_hinge_velocity_pc1_s9, 150, 'coeff');
neural_velocity_xcorr_s10 = xcorr(neural_pc1_s10, filtered_hinge_velocity_pc1_s10, 150, 'coeff');

%%
%%%%%%%%%%%%PLOT ALL ANGLE XCORRELATIONS ON ONE PLOT%%%%%%%%%%%%%%%

figure
hold on
plot(x3, neural_angle_xcorr_s1)
plot(x3, neural_angle_xcorr_s2)
plot(x3, neural_angle_xcorr_s3)
plot(x3, neural_angle_xcorr_s4)
plot(x3, neural_angle_xcorr_s5)
plot(x3, neural_angle_xcorr_s6)
plot(x3, neural_angle_xcorr_s7)
plot(x3, neural_angle_xcorr_s8)
plot(x3, neural_angle_xcorr_s9)
plot(x3, neural_angle_xcorr_s10)
xlabel('Time')
ylabel('Cross-Correlation')
title('Neural PC1-Hinge Angle PC1 XCorrelation (All Segments)')
legend('Segment 1','Segment 2','Segment 3','Segment 4','Segment 5','Segment 6','Segment 7','Segment 8','Segment 9','Segment 10')

%%
%%%%%%%%%%%%PLOT ANGLE XCORRELATIONS ON SEPARATE PLOT%%%%%%%%%%%%%%%

figure
plot(x3, neural_angle_xcorr_s1)
title('Neural PC1-Hinge Angle PC1 XCorrelation (Segment 1)')
xlabel('Time')
ylabel('Cross-Correlation')
figure
plot(x3, neural_angle_xcorr_s2)
title('Neural PC1-Hinge Angle PC1 XCorrelation (Segment 2)')
xlabel('Time')
ylabel('Cross-Correlation')
figure
plot(x3, neural_angle_xcorr_s3)
title('Neural PC1-Hinge Angle PC1 XCorrelation (Segment 3)')
xlabel('Time')
ylabel('Cross-Correlation')
figure
plot(x3, neural_angle_xcorr_s4)
title('Neural PC1-Hinge Angle PC1 XCorrelation (Segment 4)')
xlabel('Time')
ylabel('Cross-Correlation')
figure
plot(x3, neural_angle_xcorr_s5)
title('Neural PC1-Hinge Angle PC1 XCorrelation (Segment 5)')
xlabel('Time')
ylabel('Cross-Correlation')
figure
plot(x3, neural_angle_xcorr_s6)
title('Neural PC1-Hinge Angle PC1 XCorrelation (Segment 6)')
xlabel('Time')
ylabel('Cross-Correlation')
figure
plot(x3, neural_angle_xcorr_s7)
title('Neural PC1-Hinge Angle PC1 XCorrelation (Segment 7)')
xlabel('Time')
ylabel('Cross-Correlation')
figure
plot(x3, neural_angle_xcorr_s8)
title('Neural PC1-Hinge Angle PC1 XCorrelation (Segment 8)')
xlabel('Time')
ylabel('Cross-Correlation')
figure
plot(x3, neural_angle_xcorr_s9)
title('Neural PC1-Hinge Angle PC1 XCorrelation (Segment 9)')
xlabel('Time')
ylabel('Cross-Correlation')
figure
plot(x3, neural_angle_xcorr_s10)
title('Neural PC1-Hinge Angle PC1 XCorrelation (Segment 10)')
xlabel('Time')
ylabel('Cross-Correlation')
%%
%%%%%%%%%%%%PLOT ALL VELOCITY XCORRELATIONS ON ONE PLOT%%%%%%%%%%%%%%%

figure
plot(x3, neural_velocity_xcorr_s1)
title('Neural PC1-Hinge Velocity PC1 XCorrelation (Segment 1)')
xlabel('Time')
ylabel('Cross-Correlation')
figure
plot(x3, neural_velocity_xcorr_s2)
title('Neural PC1-Hinge Velocity PC1 XCorrelation (Segment 2)')
xlabel('Time')
ylabel('Cross-Correlation')
figure
plot(x3, neural_velocity_xcorr_s3)
title('Neural PC1-Hinge Velocity PC1 XCorrelation (Segment 3)')
xlabel('Time')
ylabel('Cross-Correlation')
figure
plot(x3, neural_velocity_xcorr_s4)
title('Neural PC1-Hinge Velocity PC1 XCorrelation (Segment 4)')
xlabel('Time')
ylabel('Cross-Correlation')
figure
plot(x3, neural_velocity_xcorr_s5)
title('Neural PC1-Hinge Velocity PC1 XCorrelation (Segment 5)')
xlabel('Time')
ylabel('Cross-Correlation')
figure
plot(x3, neural_velocity_xcorr_s6)
title('Neural PC1-Hinge Velocity PC1 XCorrelation (Segment 6)')
xlabel('Time')
ylabel('Cross-Correlation')
figure
plot(x3, neural_velocity_xcorr_s7)
title('Neural PC1-Hinge Velocity PC1 XCorrelation (Segment 7)')
xlabel('Time')
ylabel('Cross-Correlation')
figure
plot(x3, neural_velocity_xcorr_s8)
title('Neural PC1-Hinge Velocity PC1 XCorrelation (Segment 8)')
xlabel('Time')
ylabel('Cross-Correlation')
figure
plot(x3, neural_velocity_xcorr_s9)
title('Neural PC1-Hinge Velocity PC1 XCorrelation (Segment 9)')
xlabel('Time')
ylabel('Cross-Correlation')
figure
plot(x3, neural_velocity_xcorr_s10)
title('Neural PC1-Hinge Velocity PC1 XCorrelation (Segment 10)')
xlabel('Time')
ylabel('Cross-Correlation')

%%
%%%%%%%%%%%%PLOT AVERAGE XCORRELATIONS ON ONE PLOT%%%%%%%%%%%%%%%

neural_angle_xcorr_avg = (neural_angle_xcorr_s1+neural_angle_xcorr_s2+neural_angle_xcorr_s3+neural_angle_xcorr_s4+neural_angle_xcorr_s5+neural_angle_xcorr_s6+neural_angle_xcorr_s7+neural_angle_xcorr_s8+neural_angle_xcorr_s9+neural_angle_xcorr_s10)/10;
neural_velocity_xcorr_avg = (neural_velocity_xcorr_s1+neural_velocity_xcorr_s2+neural_velocity_xcorr_s3+neural_velocity_xcorr_s4+neural_velocity_xcorr_s5+neural_velocity_xcorr_s6+neural_velocity_xcorr_s7+neural_velocity_xcorr_s8+neural_velocity_xcorr_s9+neural_velocity_xcorr_s10)/10;

figure
plot(x3, neural_angle_xcorr_avg)
title('Neural PC1-Hinge Angle PC1 XCorrelation (Average Across Segments)')
xlabel('Time')
ylabel('Cross-Correlation')
figure
plot(x3, neural_velocity_xcorr_avg)
title('Neural PC1-Hinge Velocity PC1 XCorrelation (Average Across Segments)')
xlabel('Time')
ylabel('Cross-Correlation')

%%