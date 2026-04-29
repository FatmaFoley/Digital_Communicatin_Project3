# Digital_Communicatin_Project3
MATLAB simulation of digital modulation schemes (BPSK, QPSK, 8PSK, BFSK, and 16-QAM) over an AWGN channel, with BER vs. Eb/No analysis and comparison between simulated and theoretical performance.

## Project Overview

This project implements and analyzes multiple digital modulation schemes by simulating their transmission over an Additive White Gaussian Noise (AWGN) channel.

The main objective is to evaluate and compare the Bit Error Rate (BER) versus Eb/N0
for each modulation technique and validate the simulation results against theoretical expressions.

## Implemented Modulation Schemes
🔹 BPSK (Binary Phase Shift Keying)
🔹 QPSK
Gray Coding
Non-Gray Coding
🔹 8-PSK (Gray coded)
🔹 BFSK (Coherent Detection)
🔹 16-QAM

## Key Features
✔️ End-to-end communication system simulation
✔️ AWGN channel modeling
✔️ BER computation (Simulated & Theoretical)
✔️ Constellation visualization (8PSK)
✔️ Power Spectral Density (PSD) analysis for BFSK
✔️ Comparative performance analysis across modulation schemes

## Results & Visualizations
The project generates:
📈 BER vs Eb/N0 curves
📉 Simulation vs Theoretical comparisons
🔁 Gray vs Non-Gray QPSK comparison
🔵 8PSK constellation diagram
📡 BFSK Power Spectral Density (PSD)
📊 Combined BER comparison for all schemes

## Theoretical Insights
BPSK & QPSK → Best BER performance (high noise immunity)
Gray Coding → Minimizes bit errors in QPSK
8PSK → Higher spectral efficiency, lower noise tolerance
BFSK → Moderate performance with orthogonal signaling
16-QAM → Highest data rate, but most sensitive to noise

## Trade-off:
Higher spectral efficiency ⇢ Higher BER

## Technologies Used MATLAB
Built-in functions:
randn
pskmod
bi2de, de2bi
pwelch

## How to Run
1. Open MATLAB
2. Copy the code into a .m file (e.g., main.m)
3. Run the script
4. Figures will be generated automatically
   Project Structure
   Digital-Modulation-Project
│── 📄 main_code.m
│── 📄 Com3_Report.pdf
│── 📄 README.md

## Notes
Minor deviations at high
Eb/N0	​are expected due to finite simulation length
Simulated BER may reach zero, while theoretical BER asymptotically approaches zero
Log-scale plots cannot display BER = 0
