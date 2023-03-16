% OFDM project
% ECE132A Winter 2023
%% Probability of error vs. SNR
clear
clc
L = 16;                         % Number of subcarriers in each OFDM symbol
Nh = 4;                          % Channel order
CP_length = 4;                  % Cyclic prefix length
B = 10;                         % Number of OFDM symbols per transmitted frame
mc_N = 5000;                    % Number of iterations to achieve sufficient errors
SNR_db = 0:2:20;                % SNR in dB
SNR = 10.^(SNR_db/10);          % SNR values
Pe = zeros(size(SNR_db));       % Initializing the error vector
Total_length = (CP_length+L)*B; % Total length of each frame
constl = [-1,1];                % For BPSK
M = 2;                          % For BPSK
% constl = [1,1i,-1,-1i];         % For QPSK
% M = 4;                          % For QPSK
for SNR_loop = 1:length(SNR_db)
    rho = SNR(SNR_loop);
    err = 0;
    
    for mc_loop = 1:mc_N
        dat_ind = ceil(M*rand(B,L));                % generate 1-4 at random
        data = constl(dat_ind);                     % generate random constellation points
        % Reshaping the data into a BxN matrix,...
        % ... used later for error detection
        data_reshape = reshape(data, 1, B*L);       % flatten data stream for iter (mc_loop)
        tx_data = data;
        for b = 1:B
            % Taking the IFFT
            data_t(b,:) = ifft(tx_data(b,:))*sqrt(L); % data_t records ifft results
        end
        % Adding cyclic prefix
        data_cp = [data_t(:,end-CP_length+1:end), data_t];
        % Reshape the BxN matrix to obtain the frame (1xTotal_length)
        data_tx = reshape(data_cp.',1,Total_length);
        h = [3;-1*exp(0.13i);1*exp(-.35i);0;4*exp(1.03i)]; % deterministic frequency-selective channel
        h = h/sqrt(sum(abs(h).^2));
%         h = complex(randn(Nh+1,1), randn(Nh+1,1))*sqrt(0.5/(Nh+1)); % Rayleigh fading
        
        % Noise
        noise = complex(randn(1,Total_length), ...
            randn(1,Total_length))  * sqrt(0.5/L);
        rec = sqrt(rho)*(filter(h,1,data_tx))+noise;
        % Reshape the rec'd signal into CP_length+N x B array
        rec_reshaped = (reshape(rec, CP_length+L, B)).';
        % Remove CP
        rec_sans_cp = rec_reshaped(:,CP_length+1:end);
        rec_f = zeros(size(rec_sans_cp));
        for bb = 1:B
            % Taking the FFT
            rec_f(bb,:) = fft(rec_sans_cp(bb,:))/sqrt(L);
        end
        % Calculating the equivalent channel on each subcarrier
        h_f = sqrt(rho)*fft(h,L)/sqrt(L);
        dec = zeros(B,L);
        decsym = zeros(B,L);
        for b2 = 1:B
            % Extracting the OFDM symbol from the rec_f matrix
            rec_symbol = transpose(rec_f(b2,:));
            % Calc. Euclidean dist assuming -1
            det1 = abs(rec_symbol./h_f-constl(1)).^2;
            % Calc. Euclidean dist assuming +1
            det2 = abs(rec_symbol./h_f-constl(2)).^2;
            % Concatenate the two vectors
            det = [det1, det2];
            % Find symbol the rec'd signal is closest to
            [min_val, ind] = min(det, [], 2);
            % Generate the demodulated symbols
%             dec(b2,:) = 2*((ind-1)>0.5)-1;
            dec(b2,:) = constl(ind);
            decsym(b2,:) = ind;
        end
        % Reshape the demodulated symbols to calc. error
        dec_reshape = reshape(dec, 1, B*L);
        decsym_reshape = reshape(decsym, 1, B*L);
        % Comparing dec_reshape against...
        % ...data_reshape to calculate errors
%         err = err + sum(dec_reshape ~= data_reshape);
        err = err + sum(sum(decsym ~= dat_ind));
    end
    % Calculate the probability of error
    Pe(SNR_loop) = err/(mc_N*B*L);
end
% Semilog plot of Pe vs. SNR_db
semilogy(SNR_db,Pe)
xlabel('SNR (dB)')
ylabel('P(e)')
grid on
%% CFO: Probability of error vs. frequency offset

% comparison of deterministic channel and random channel


clear all
clc
L = 16;                         % Number of subcarriers in each OFDM symbol
Nh = 4;                         % Channel order
CP_length = 4;                  % Cyclic prefix length
B = 1;                          % Number of OFDM symbols per transmitted frame
mc_N = 5000;                    % Number of iterations to achieve sufficient errors
SNR_db = 5;                     % SNR in dB
SNR = 10.^(SNR_db/10);          % SNR
Pe = zeros(size(SNR_db));
Total_length = (CP_length+L)*B; % Total length of each frame
constl = [-1,1];                    % For BPSK
M = 2;                          % For BPSK
freq_offset = (-0.5:0.01:0.5);
for off_loop = 1:length(freq_offset)
    rho = SNR;
    err = 0;
    for mc_loop = 1:mc_N
        dat_ind = ceil(M*rand(B,L));
        data = constl(dat_ind);
        % Reshaping the data into a BxN matrix,...
        %...used later for error detection
        data_reshape = reshape(data, 1, B*L);
        tx_data = data;
        for b = 1:B
            % Taking the IFFT
            data_t(b,:) = ifft(tx_data(b,:));
        end
        % Adding cyclic prefix
        data_cp = [data_t(:,end-CP_length+1:end), data_t];
        % Reshape the BxN matrix to...
        % ...obtain the frame (1xTotal_length)
        data_tx =reshape(data_cp.',1,Total_length);
        h = [3;-1*exp(0.13i);1*exp(-.35i);0;4*exp(1.03i)]; % deterministic frequency-selective channel
        h = h/sqrt(sum(abs(h).^2));
        % h = complex(randn(Nh+1,1), randn(Nh+1,1))*sqrt(0.5/(Nh+1)); % Rayleigh fading
        noise = complex(randn(1,Total_length), ...
            randn(1,Total_length)) *sqrt(0.5/L); % Noise
        rec = sqrt(rho)*(filter(h,1,data_tx))...
            * exp(-1i*2*pi*freq_offset(off_loop))+noise;
        % Reshape the rec'd signal...
        % ...into CP_length+L x B array
        rec_reshaped = (reshape(rec, CP_length+L, B)).';
        % Remove CP
        rec_sans_cp = rec_reshaped(:,CP_length+1:end);
        rec_f = zeros(size(rec_sans_cp));
        for bb = 1:B
            % Taking the FFT
            rec_f(bb,:) = fft(rec_sans_cp(bb,:));
        end
        % Calculating the equivalent channel on each subcarrier
        h_f = sqrt(rho)*fft(h,L);
        dec = zeros(B,L);
        decsym = zeros(B,L);
        for b2 = 1:B
            % Extracting the OFDM symbol from...
            %...the rec_f matrix
            rec_symbol = transpose(rec_f(b2,:));
            % Calc. Euclidean dist assuming -1
            det1 = abs(rec_symbol./h_f-constl(1)).^2;
            % Calc. Euclidean dist assuming +1
            det2 = abs(rec_symbol./h_f-constl(2)).^2;
            % Concatenate the two vectors
            det = [det1, det2];
            % Find symbol the recd signal is closest to
            [min_val, ind] = min(det, [], 2);
            % Generate the decoded symbols
            % dec(b2,:) = 2*((ind-1)>0.5)-1;
            decsym(b2,:) = ind;
        end
        % Reshape the decoded symbols to calc error
        dec_reshape = reshape(dec, 1, B*L);
        decsym_reshape = reshape(decsym, 1, B*L);
        % Compare dec_reshape against...
        % ...data_reshape to calc. errors
        % err = err + sum(dec_reshape ~= data_reshape);
        err = err + sum(sum(decsym ~= dat_ind));
    end
    % Calculating the probability of error
    Pe(off_loop) = err/(mc_N*B*L);
end
% Semilog plot of Pe vs. offset
semilogy(freq_offset,Pe)
xlabel('Frequency offset')
ylabel('P(e)')
grid on
%% PAPR
clear all
L = 16; % Length of data
SNR_db = 5;
SNR = 10.^(SNR_db/10);
noise_var = 1/SNR;
time_samples = 100;
avg_pow = zeros(1,time_samples);
mx_pow = zeros(1,time_samples);
papr = zeros(1,time_samples);
for time_loop = 1:time_samples
    data = 2*randi([0,1],[L,1])-1;
    data_t = ifft(fftshift(data));

    avg_pow(time_loop) = (norm(data_t))^2/L;
    mx_pow(time_loop) = max(data_t.*conj(data_t));
    papr(time_loop) = mx_pow(time_loop)/avg_pow(time_loop);
end
figure(1)
plot(10*log10(avg_pow))
hold all
plot(10*log10(mx_pow))
grid on
xlabel('Time samples')
ylabel('Power')
legend('avg','max','location','best')
figure(2)
plot(10*log10(papr))
xlabel('Time samples')
ylabel('PAPR')
grid on
%% PAPR (with clipping)

% add a channel


clear all
clc
L = 16;                         % Number of subcarriers in each OFDM symbol
Nh = 3;                         % Channel order
CP_length = 4;                  % Cyclic prefix length
B = 10;                         % Number of OFDM symbols per transmitted frame
mc_N = 50;                      % Number of iterations to achieve sufficient errors
th_var = 0:.1:1;                % Clipping thresholds
Pe = zeros(size(th_var));       % Initializing the error vector
Total_length = (CP_length+L)*B; % Total length of each frame
constl = [-1,1];                % For BPSK
M = 2;                          % For BPSK
for th_loop = 1:length(th_var)
    th = th_var(th_loop);
    err = 0;

    for mc_loop = 1:mc_N
        dat_ind = ceil(M*rand(B,L));
        data = constl(dat_ind);
        % Reshape the data into a BxN matrix,...
        % ...used later for error detection
        data_reshape = reshape(data, 1, B*L);
        tx_data = data;
        for b = 1:B
            % Taking the IFFT
            data_t(b,:) = ifft(tx_data(b,:));
        end
        % Adding Cyclic prefix
        data_cp = [data_t(:,end-CP_length+1:end), data_t];
        % Reshaping the BxN matrix to...
        % ...obtain the frame (1xTotal_length)
        data_tx =reshape(data_cp.',1,Total_length);
        thu = abs(th);
        thl = -abs(th);
        data_clip = data_tx;
        pt_high = find(data_clip>thu);
        data_clip(pt_high) = thu;
        pt_low = find(data_clip<thl);
        data_clip(pt_low) = thl;
        rec = data_clip;
        % Reshape the rec'd signal...
        % ...into CP_length+L x B array
        rec_reshaped = (reshape(rec, CP_length+L, B)).';
        % Remove CP
        rec_sans_cp = rec_reshaped(:,CP_length+1:end);
        rec_f = zeros(size(rec_sans_cp));
        for bb = 1:B
            %Taking the FFT
            rec_f(bb,:) = fft(rec_sans_cp(bb,:));
        end
        dec = zeros(B,L);
        decsym = zeros(B,L);
        for b2 = 1:B
            % Extracting the OFDM symbol...
            %...from the rec_f matrix
            rec_symbol = transpose(rec_f(b2,:));
            % Calc. the Euclidean dist assuming 1
            det1 = abs(rec_symbol-constl(1)).^2;
            % Calc. the Euclidean dist assuming +1i
            det2 = abs(rec_symbol-constl(2)).^2;
            % Concatenating the vectors
            det = [det1, det2];
            % Find symbol the recd signal is closest to
            [min_val, ind] = min(det, [], 2);
            % Generating the decoded symbols
            dec(b2,:) = constl(ind);
            decsym(b2,:) = ind;
        end
        % Reshape decoded symbols to calc error
        dec_reshape = reshape(dec, 1, B*L);
        decsym_reshape = reshape(decsym, 1, B*L);
        % Compare dec_reshape against data_reshape to calculate errors
        % err = err + sum(dec_reshape ~= data_reshape);
        err = err + sum(sum(decsym ~= dat_ind));
    end
    % Calculate the probability of error
    Pe(th_loop) = err/(mc_N*B*L);
end
% Semilog plot of Pe vs. clipping threshold
semilogy(th_var,Pe)
xlabel('Threshold')
ylabel('P(e)')
grid on