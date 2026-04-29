clc;
clear;
close all;

%% ====================================
% BPSK
%======================================
%% Parameters 
N = 1e5;
bits = randi([0 1], N, 1);

% MAPPER
symbols = 2*bits - 1;

% Channel
EbNo_dB = -4:1:14;
BER = zeros(1, length(EbNo_dB));

Eb = 1;

for i = 1:length(EbNo_dB)
    
    EbNo_linear = 10^(EbNo_dB(i)/10);
    N0 = Eb / EbNo_linear;
    
    noise = sqrt(N0/2) * randn(size(symbols));
    rx_symbols = symbols + noise;
    
    % DEMAPPER
    rx_bits = rx_symbols > 0;
    
    % BER
    BER(i) = sum(bits ~= rx_bits) / N;
    
end

% Theoretical BER
EbNo_linear = 10.^(EbNo_dB/10);
theoritical_BER_BPSK = 0.5 * erfc(sqrt(EbNo_linear));

% Plot
figure;
semilogy(EbNo_dB, BER, 'o-','LineWidth',2);
hold on;
semilogy(EbNo_dB, theoritical_BER_BPSK, 'r--','LineWidth',2);

grid on;
xlabel('Eb/No (dB)');
ylabel('BER');
title('Simulation Vs Theoretical (BPSK)');

legend('Simulation','Theoretical');

%% ====================================
% QPSK 
%%=====================================
%% Parameters 
N = 1e5; % Number of bits
bits = randi([0 1], N, 1);

% Group bits into pairs [b1, b2]
bit_pairs = reshape(bits, 2, [])';

% MAPPER 
% Convert binary pairs to decimal (0, 1, 2, 3)
dec_values = bi2de(bit_pairs, 'left-msb');

% Define Constellations (Decimal indices: 0, 1, 2, 3)
gray_constellation    = [-1-1j; -1+1j;  1-1j;  1+1j]; 
nongray_constellation = [-1-1j; -1+1j;  1+1j;  1-1j]; 

% Map the symbols
symbols_gray    = gray_constellation(dec_values + 1);
symbols_nongray = nongray_constellation(dec_values + 1);

% AWGN CHANNEL
EbNo_dB = -4:1:14; % Range of Eb/No in decibels
BER_gray = zeros(1, length(EbNo_dB));
BER_nongray = zeros(1, length(EbNo_dB));

Es = 2; % Energy per symbol (1^2 + 1^2 = 2)
Eb = Es / 2; % Energy per bit 

for i = 1:length(EbNo_dB)
    
    % Calculate Noise Variance based on Eb/No
    EbNo_linear = 10^(EbNo_dB(i)/10);
    N0 = Eb / EbNo_linear;
    
    % Generation of Complex AWGN using randn 
    noise_gray = sqrt(N0 / 2) * (randn(size(symbols_gray)) + 1j*randn(size(symbols_gray)));
    noise_nongray = sqrt(N0 / 2) * (randn(size(symbols_nongray)) + 1j*randn(size(symbols_nongray)));
    
    % received symbols with noise
    rx_symbols_gray = symbols_gray + noise_gray;
    rx_symbols_nongray = symbols_nongray + noise_nongray;
    
    % DEMAPPER 
    rx_bits_gray = zeros(size(bits));
    rx_bits_nongray = zeros(size(bits));
    
    for k = 1:length(rx_symbols_gray)
        % Gray Demapping
        distances_gray = abs(rx_symbols_gray(k) - gray_constellation);
        [value1 , min_index_gray] = min(distances_gray);
        dec_val_gray = min_index_gray - 1;
        rx_bits_gray(2*k-1:2*k) = de2bi(dec_val_gray, 2, 'left-msb')';
        
        % Non-Gray Demapping
        distances_nongray = abs(rx_symbols_nongray(k) - nongray_constellation);
        [value2 , min_index_nongray] = min(distances_nongray);
        dec_val_nongray = min_index_nongray - 1;
        rx_bits_nongray(2*k-1:2*k) = de2bi(dec_val_nongray, 2, 'left-msb')';
    end
    
    % BER CALCULATOR
    num_errors_gray    = sum(bits ~= rx_bits_gray);
    num_errors_nongray = sum(bits ~= rx_bits_nongray);
    
    % Store the Bit Error Rate for Eb/No value
    BER_gray(i) = num_errors_gray / N;
    BER_nongray(i) = num_errors_nongray / N;
    
    fprintf('Eb/No = %2d dB | Gray Errors: %4d | Non-Gray Errors: %4d\n', EbNo_dB(i), num_errors_gray, num_errors_nongray);
end

% PLOTTING RESULTS
% Calculate Theoretical bounds
EbNo_lin_plot = 10.^(EbNo_dB/10);
theo_BER_gray_QPSK = 0.5 * erfc(sqrt(EbNo_lin_plot));
theo_BER_nongray_QPSK = 0.75 * erfc(sqrt(EbNo_lin_plot)); 

% Graph 1: Gray Simulation vs Theoretical
figure(1);
semilogy(EbNo_dB, BER_gray, 'bo-', EbNo_dB, theo_BER_gray_QPSK, 'k--', 'LineWidth', 1.5);
grid on; title('Gray: Simulation vs Theoretical'); ylabel('BER'); xlabel('Eb/No (dB)');
legend('Simulation', 'Theoretical');

% Graph 2: Non-Gray Simulation vs Theoretical
figure(2);
semilogy(EbNo_dB, BER_nongray, 'rs-', EbNo_dB, theo_BER_nongray_QPSK, 'm--', 'LineWidth', 1.5);
grid on; title('Non-Gray: Simulation vs Theoretical'); ylabel('BER'); xlabel('Eb/No (dB)');
legend('Simulation', 'Theoretical');

% Graph 3: Simulation Comparison (Gray vs Non-Gray)
figure(3);
semilogy(EbNo_dB, BER_gray, 'bo-', EbNo_dB, BER_nongray, 'rs-', 'LineWidth', 1.5);
grid on; title('Simulated: Gray vs Non-Gray'); ylabel('BER'); xlabel('Eb/No (dB)');
legend('Gray', 'Non-Gray');

% Graph 4: Theoretical Comparison (Gray vs Non-Gray)
figure(4);
semilogy(EbNo_dB, theo_BER_gray_QPSK, 'k--', EbNo_dB, theo_BER_nongray_QPSK, 'm--', 'LineWidth', 1.5);
grid on; title('Theoretical: Gray vs Non-Gray'); ylabel('BER'); xlabel('Eb/No (dB)');
legend('Gray', 'Non-Gray');

%% ====================================
% 8PSK 
%%=====================================
%% Parameters 
order = 8;                   % 8-PSK 
no_of_bits = log2(order);    % 3 bits per symbol 
symorder = 'gray';           % Gray mapping

% Constellation Generation
symbols = 0:order-1;         % create symbol indices [0 1 2 3 4 5 6 7]
psk_symbols = pskmod(symbols, order, 0, symorder);      % generate 8-PSK constellation points, and apply gray mapping
n_symbols = length(psk_symbols);
gray_bits = de2bi(symbols, no_of_bits, 'left-msb');     % convert each symbol index into binary

% Constellation Plot
axlim = 1.2;
color = 'red';

figure;
hold on;
theta = linspace(0, 2*pi, 1000);
plot(cos(theta), sin(theta), '--', 'Color', color, 'LineWidth', 1.5);   % draw unit circle
plot(real(psk_symbols), imag(psk_symbols), 'o', ...
    'MarkerSize', 10, 'LineWidth', 2, 'Color', color);  %  plot constellation points

% Bit labels
for i = 1:n_symbols
    txt = num2str(gray_bits(i,:));   % convert binary vector to string
    text(real(psk_symbols(i)) + 0.08, ...
         imag(psk_symbols(i)) + 0.08, ...
         txt);                       % place bit labels near each symbol
end

axis equal;     % x and y scale are equal
grid on;
% set plot boundaries
xlim([-axlim axlim]);
ylim([-axlim axlim]);
ax = gca;
ax.XAxisLocation = 'origin';
ax.YAxisLocation = 'origin';
ax.LineWidth = 1.5;
title('8PSK Gray Constellation');
hold off;

% BER Parameters
EbNo_dB = -4:1:14;      % SNR range in dB
BER = zeros(size(EbNo_dB));

Es = 1;     % Symbol energy normalized to 1
Eb = Es / no_of_bits;

% Channel Simulation
for i = 1:length(EbNo_dB)

    EbNo_linear = 10^(EbNo_dB(i)/10);      % convert dB to linear scale
    N0 = Eb / EbNo_linear;                 % Noise power spectral density

    % Generate random transmitted symbols
    Nsym = 1e5;
    tx_index = randi([0 7], Nsym, 1);

    % Map indices to PSK symbols
    tx_symbols = psk_symbols(tx_index + 1);

    % Convert symbols to bit stream vector
    tx_bits = de2bi(tx_index, no_of_bits, 'left-msb');
    tx_bits = reshape(tx_bits.', [], 1);

    % Generates complex Gaussian noise
    noise = sqrt(N0/2) * (randn(size(tx_symbols)) + 1j*randn(size(tx_symbols)));
    rx_symbols = tx_symbols + noise;    % Received signal is equal to transmitted + noise

    % Demapper 
    rx_index = zeros(Nsym,1);       

    for n = 1:Nsym  
        [~, idx] = min(abs(rx_symbols(n) - psk_symbols));   % Find nearest constellation point
        rx_index(n) = idx - 1;
    end
    % Convert detected symbols to bit stream
    rx_bits = de2bi(rx_index, no_of_bits, 'left-msb');
    rx_bits = reshape(rx_bits.', [], 1);

    % BER
    BER(i) = sum(tx_bits ~= rx_bits) / length(tx_bits);
end

% Theoretical BER
EbNo_lin = 10.^(EbNo_dB/10);       % Convert full SNR vector to linear scale
theo_BER_8PSK = (1/no_of_bits) * erfc( sqrt(no_of_bits * EbNo_lin) .* sin(pi/order) );
%theo_BER_8PSK = (2/no_of_bits) * qfunc( sqrt(2*no_of_bits*EbNo_lin) * sin(pi/order) );

% BER Plot
figure;
semilogy(EbNo_dB, BER, 'o-', 'LineWidth', 2);
hold on;
semilogy(EbNo_dB, theo_BER_8PSK, '-', 'LineWidth', 2);

grid on;
xlabel('E_b/N_0 (dB)');
ylabel('BER');
title('8PSK Gray Coding BER Comparision');
legend('Simulation', 'Theory');
%% ====================================
% BFSK 
%%=====================================
%% Parameters
N = 1e5;              % Number of bits 
Tb = 1;               % Bit duration
fs = 100;             % Sampling frequency
t = 0:1/fs:Tb-1/fs;   % Time vector

f1 = 1/Tb;            % Frequency for bit 0
f2 = 2/Tb;            % Frequency for bit 1

EbNo_dB = -4:1:14;    % Eb/No range in dB
BER = zeros(1, length(EbNo_dB));

Eb = 1;               % Energy per bit

% Basis Functions (Orthonormal)
phi1 = sqrt(2/Tb) * cos(2*pi*f1*t);  % Basis function for bit 0
phi2 = sqrt(2/Tb) * cos(2*pi*f2*t);  % Basis function for bit 1

% Generate Random Bits
bits = randi([0 1], N, 1);

% MAPPER
% Map bits into BFSK waveforms
s = zeros(N, length(t));

for k = 1:N
    if bits(k) == 0
        s(k,:) = sqrt(Eb) * phi1;   % Bit 0 → frequency f1
    else
        s(k,:) = sqrt(Eb) * phi2;   % Bit 1 → frequency f2
    end
end

% Simulation over Eb/No
for i = 1:length(EbNo_dB)
    
    EbNo = 10^(EbNo_dB(i)/10);   % Convert dB to linear
    N0 = Eb / EbNo;              % Noise spectral density
   
    % CHANNEL
    % Add white Gaussian noise to the transmitted signal
    noise = sqrt(N0 * fs / 2) * randn(size(s));
    r = s + noise;   % Received signal
    

    % DEMAPPER

    % Correlator: project received signal onto basis functions
    r1 = trapz(t, r .* phi1, 2);   % Projection on phi1
    r2 = trapz(t, r .* phi2, 2);   % Projection on phi2
    
    % Decision rule:
    % Choose the basis with the higher correlation
    rx_bits = r2 > r1;
    
    % Bit Error Rate calculation
    BER(i) = sum(bits ~= rx_bits) / N;
end

% Theoretical BER 
EbNo_linear = 10.^(EbNo_dB/10);
theoritical_BER_BFSK = 0.5 * erfc(sqrt(EbNo_linear/2));

% Plot Results
figure;
semilogy(EbNo_dB, BER, 'o-','LineWidth',2);
hold on;
semilogy(EbNo_dB, theoritical_BER_BFSK, 'r--','LineWidth',2);

grid on;
xlabel('Eb/No (dB)');
ylabel('Bit Error Rate (BER)');
title('BFSK: Simulation vs Theoretical Performance');

legend('Simulation','Theoretical');

% Baseband Equivalent (PSD calculations)

Delta_f = f2 - f1;

s_bb = zeros(N, length(t));

for k = 1:N
    if bits(k) == 0
        % s1_BB(t)
        s_bb(k,:) = sqrt(2*Eb/Tb) * ones(size(t));
    else
        % s2_BB(t) EXACT from expansion
        s_bb(k,:) = sqrt(2*Eb/Tb) * ...
            (cos(2*pi*Delta_f*t) - sin(2*pi*Delta_f*t));
    end
end

% Serialize signal
s_bb_serial = reshape(s_bb.', 1, []);

% PSD using Welch
[PSD, f] = pwelch(s_bb_serial, [], [], [], fs, 'centered');

% Plot
figure;
plot(f, 10*log10(PSD), 'LineWidth',2);
grid on;
xlabel('Frequency (Hz)');
ylabel('PSD (dB/Hz)');
title('Simulated PSD');

%% ====================================
% 16QAM
%%=====================================
%% generate and mapping the data to send (MAPPER)
number_of_symbols=10000*16;
number_of_bits=4;

%each row represent a symbol 4 bits 
data_bits =randi([0 1],number_of_symbols,number_of_bits); 

data_decimal= bi2de(data_bits,'left-msb');
%each symbole is consist of I and Q component 
QAM16_table =[-3-3j;-3-j;-3+3j;-3+j;
              -1-3j;-1-j;-1+3j;-1+j;
               3-3j;3-j;3+3j;3+j;
               1-3j;1-j;1+3j;1+j];

%mapping 
%add one because matlab indexing start from 1 not zero
symboles=QAM16_table(data_decimal+1);

% channel
SNR=-4:14; %in db Eb/NO
demapped_bits=zeros(size(data_bits));
theoritical_BER_16QAM = zeros(length(SNR),1);

%calculate the Esavrage to get the noise poer for symbol not bit
Esav=sum((abs(symboles)).^2)/number_of_symbols ;

Eb=Esav/4;

for i=1:length (SNR)
    SNR_linear=10^(SNR(i)/10);

    No=Eb/SNR_linear;

    noise = sqrt(No/2)*(randn(size(symboles))+1j*randn(size(symboles)));

    noisy_signal=noise+symboles;

% demapper using desicion regions of 16QAM
recieved_signal=noisy_signal;

XI=real(recieved_signal);

XQ=imag(recieved_signal);

for j=1:number_of_symbols
         if (XI(j)<-2)
        XI_bit=[0 0];
         elseif (XI(j)<0) 
        XI_bit=[0 1];
         elseif (XI(j)<2) 
        XI_bit=[1 1];
         else  
        XI_bit=[1 0];
         end
        if (XQ(j)<-2)
        XQ_bit=[0 0];
        elseif (XQ(j)<0) 
        XQ_bit=[0 1];
        elseif (XQ(j)<2) 
        XQ_bit=[1 1];
        else  
        XQ_bit=[1 0];
        end
demapped_bits(j,:) = [XI_bit XQ_bit] ;
end
% BER 
number_of_errors=sum(data_bits ~=demapped_bits);
BER_simulated (i,:) =number_of_errors/(number_of_symbols) ;
BER_avg =(BER_simulated (:,1)+BER_simulated (:,2)+BER_simulated (:,3)+BER_simulated (:,4))*0.25;
theoritical_BER_16QAM(i,:)=(3/8)*erfc(sqrt(Eb/(2.5*No)));
end

% Plotting
semilogy(SNR, theoritical_BER_16QAM, '-.o', 'LineWidth', 2, 'Color', 'r'); hold on;
semilogy(SNR, BER_avg, '-s', 'LineWidth', 2, 'Color', 'b');
grid on;
legend('Theoretical','Simulated','Location','northwest');
axis([-4 14 1e-6 1]);
xlabel('SNR');
ylabel('BER');
title('the BER for 16 QAM theoritical vs simulated');

%% BER vs. Eb/No Comparison
figure;
semilogy(EbNo_dB, theoritical_BER_BPSK, 'k-','LineWidth',2);
hold on;
semilogy(EbNo_dB, theo_BER_gray_QPSK, 'r--','LineWidth',2);
hold on;
semilogy(EbNo_dB, theo_BER_8PSK, 'b--','LineWidth',2);
hold on;
semilogy(EbNo_dB, theoritical_BER_BFSK, 'g--','LineWidth',2);
hold on;
semilogy(EbNo_dB, theoritical_BER_16QAM, 'y--','LineWidth',2);
grid on;
xlabel('Eb/No (dB)');
ylabel('Bit Error Rate (BER)');
title('BER vs. Eb/No Comparison');

legend('BPSK','QPSK','8PSK','BFSK','16QAM');

