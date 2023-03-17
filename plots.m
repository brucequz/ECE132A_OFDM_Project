

%% Section 1

load rayleigh_1.mat;
figure;
semilogy(SNR_db,Pe_no_equalize, "-o"); hold on;
semilogy(SNR_db,Pe_phase_equalize, "-x"); hold on;
semilogy(SNR_db,Pe_all_equalize, "-*"); hold off;
grid on;
title("Rayleigh channel", 'FontSize', 20)
xlabel('SNR (dB)', 'FontSize', 15);
ylabel('Symbol Error Rate, P(e)', 'FontSize', 15);
lgd = legend("No Equalization", "Phase Equalization", "Phase and Magnitude Equalization");
lgd.FontSize = 12;

%% Section 2

load mag_pha_2.mat;
figure;
ylabel("Magnitude"); xlabel("Channel");
stem(abs(fft(h,16)));   % plot magnitude response of the channel
title("Magnitude Response of the Channel", 'FontSize', 20);
figure;
stem(angle(fft(h,16)));   % plot phase response of the channel
ylabel("Angle"); xlabel("Channel");
title("Phase response of the Channel", 'FontSize', 20);


%% Section 3

load SER_vs_SNR_3.mat;
semilogy(SNR_db,Pe_BPSK, "-o", 'MarkerSize',8); hold on;
semilogy(SNR_db,Pe_QPSK, "-x", 'MarkerSize',8); hold on;
semilogy(SNR_db,Pe_8PSK, "-*", 'MarkerSize',8); hold off;
title("SER vs. SNR", 'FontSize', 20);
xlabel('SNR (dB)', 'FontSize',15);
ylabel('Symbol Error Rate: P(e)', 'FontSize', 15);
grid on;
lgd = legend("BPSK", "QPSK", "8PSK");
lgd.FontSize = 12;

%% Section 4

load BER_vs_SNR_4.mat;
semilogy(SNR_db,Pe_bit_BPSK, "-o"); hold on;
semilogy(SNR_db,Pe_bit_QPSK, "-x"); hold on;
semilogy(SNR_db,Pe_bit_8PSK, "-*"); hold off;
title("BER vs. SNR (dB)", 'FontSize', 20);
xlabel('SNR (dB)', 'FontSize',15);
ylabel('Bit Error Rate: P(e)', 'Fontsize', 15);
grid on;
lgd = legend("Bit Error Rate - BPSK", "Bit Error Rate - QPSK", "Bit Error Rate - 8PSK");  
lgd.FontSize = 12;

%% Section 5

load BER_vs_EbN0_5.mat;
f = figure;
f.Position = [100 100 750 600];
semilogy(SNR_db,Pe_bit_BPSK, '-o'); hold on;
semilogy(SNR_db-3,Pe_bit_QPSK, '-*'); hold on;
semilogy(SNR_db-4.77,Pe_bit_8PSK, '-^'); hold on;
semilogy(SNR_db-1.57,Pe_bit_mixed, '-d', 'Color', 'm'); hold on; %%%%%% !!!!!
load mixed_reverse.mat;
semilogy(SNR_db-1.57,Pe_bit_mixed, '--d', 'Color','m'); hold off;
grid on;
xlabel('Eb/N0 (dB)', 'FontSize',20);
xlim([0,16]);
ylabel('Bit Error Rate: P(e)', 'Fontsize', 20);
title('BER vs. Eb/N0', 'FontSize', 25);
lgd = legend("Bit Error Rate - BPSK", "Bit Error Rate - QPSK",...
                "Bit Error Rate - 8PSK", "Bit Error Rate - Mixed",...
                "Bit Error Rate - Mixed (reverse channels)");  
lgd.FontSize = 15;


%% Section 6

close all;
load BER_vs_EbN0_5.mat;
f = figure;
f.Position = [100 100 750 600];
semilogy(SNR_db,Pe_bit_BPSK, '-o', 'Color', 'r'); hold on;
semilogy(SNR_db-3,Pe_bit_QPSK, '-*', 'Color', 'g'); hold on;
semilogy(SNR_db-4.77,Pe_bit_8PSK, '-^', 'Color', 'b'); hold on;
semilogy(SNR_db-1.57,Pe_bit_mixed, '-d', 'Color', 'm'); hold on; %%%%%% !!!!!
load mixed_reverse.mat;
semilogy(SNR_db-1.57,Pe_bit_mixed, ':d', 'Color','m'); hold on;
load BER_vs_EbN0_6.mat;
semilogy(SNR_db-1.57,Pe_bit_mixed_under, '-s', 'Color', 'k'); hold on;
semilogy(SNR_db-1.57,Pe_bit_mixed_exact, '--s', 'Color', 'k'); hold on;
semilogy(SNR_db-1.57,Pe_bit_mixed_over, '-.s', 'Color', 'k'); hold on;
grid on;
xlabel('Eb/N0 (dB)', 'FontSize',20);
xlim([0,16]);
ylabel('Bit Error Rate: P(e)', 'Fontsize', 20);
title('BER vs. Eb/N0', 'FontSize', 25);
lgd = legend("Bit Error Rate - BPSK", "Bit Error Rate - QPSK",...
                "Bit Error Rate - 8PSK", "Bit Error Rate - Mixed",...
                "Bit Error Rate - Mixed (reverse channels)", ...
                "Bit Error Rate - Excess CP", "Bit Error Rate - Exact CP", ...
                "Bit Error Rate - ISI");  
lgd.FontSize = 15;