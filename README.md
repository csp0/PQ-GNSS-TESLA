# PQ-GNSS-TESLA 

This repository contains the official simulation source codes and hardware benchmark implementations for the paper:  
> **"PQ-GNSS-TESLA: Post-Quantum GNSS Authentication Scheme Based on Seamless TESLA Key Chains (by Chang-Seop Park)"** 

The proposed architecture resolves the critical Signal-in-Space (SIS) bandwidth bottleneck inherent in post-quantum (PQ) GNSS environments. This repository provides both an end-to-end MATLAB simulation framework for GPS L1C CNAV-2 and a C/C++ embedded benchmark to evaluate cross-layer authentication performance (NMA and SCA) and hardware feasibility.
                                        

## Repository Structure

The repository is organized into two newly categorized folders and core root files to facilitate easy replication of the paper's results.

### 1. `Hardware_Evaluation/`
This directory contains the C/C++ (Arduino) benchmark source codes used to evaluate the computational latency and memory overhead on embedded hardware.
* **Target Hardware:** Raspberry Pi Pico 2 (ARM Cortex-M33).
* **Contents:** The benchmark sketch (`PQ_GNSS_Benchmark.ino`) and associated cryptographic libraries required to evaluate the CPU execution time and static memory footprint (Flash ROM and SRAM) for the proposed Falcon-based PQ-GNSS-TESLA scheme compared to the legacy ECDSA-based Chimera protocol.

### 2. `MATLAB codes for Figures/`
This folder contains the standalone MATLAB scripts specifically designed to reproduce the analytical graphs and statistical results presented in the paper.
* **Contents:** Scripts for generating figures such as the minimum required key/MAC lengths, pre/post-quantum absolute attack time bounds, and the statistical distribution of Time-To-First-Authenticated-Fix (TTFAF).

### 3. Root Directory (Core MATLAB Simulation)
The root directory houses the core MATLAB end-to-end simulation framework for the physical and logical layer signal processing.
* **`PQ_GNSS_TESLA_Main.m`**: The main execution script. It establishes the fundamental GPS L1C/CNAV-2 signal generation and receiver processing pipeline, atop which the proposed PQ-GNSS-TESLA architecture and related protocols are fully integrated to support both NMA and SCA. It runs the Monte Carlo simulation to evaluate the end-to-end authentication success probabilities over a range of $C/N_0$ values, generating the deep fading waterfall curves.
* **`L1CLDPCParityCheckMatrices.mat`**: Standardized LDPC parity-check matrices for GPS L1C CNAV-2.
* **`gpsNAVDataEncode.m` & `gpsNavigationConfig.m`**: Functions for baseband navigation data encoding, interleaving, and framing.
* **`get_sector_pattern.mlx` & `marker_overlay_symbol.mlx`**: Live scripts containing the core logic for physical-layer Chimera marker generation, puncturing, and overlay mapping onto the primary spreading code.
* **`hexToBits.mlx`**: Utility live script for cryptographic hexadecimal-to-binary conversions.

##  How to Run

### Software Simulation (MATLAB)
1. Require MATLAB R2022b or later with the Communications Toolbox.
2. Open MATLAB and navigate to the repository root.
3. Run `PQ_GNSS_TESLA_Main.m` to simulate the cross-layer authentication performance and generate the deep fading robustness graph.
4. To reproduce specific analytical graphs from the paper, navigate to the `MATLAB codes for Figures/` folder and execute the respective scripts.

### Hardware Benchmark (Raspberry Pi Pico 2)
1. Open the `.ino` project file located inside the `Hardware_Evaluation/` folder using the Arduino IDE.
2. Ensure the appropriate Raspberry Pi Pico board manager and included cryptographic libraries are installed.
3. Compile and upload the code to the Pico 2 board to observe the per-epoch CPU execution time and memory footprint via the Serial Monitor.
