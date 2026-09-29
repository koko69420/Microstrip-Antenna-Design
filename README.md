# 868 MHz Microstrip Patch & Beamforming Array Antenna Design

A high-frequency electromagnetic antenna design and simulation suite developed in **Dassault Systèmes CST Studio Suite**, featuring single-element inset-fed patch antennas and a 4-element broadside beamforming array with an integrated Wilkinson corporate power divider feed network operating in the 868 MHz ISM/CubeSat band.

---

## Features

- **Single-Element Inset-Fed Patch Antenna**:
  - Resonant frequency: 868 MHz with 50 $\Omega$ microstrip line feed and recessed inset notch for input impedance matching.
  - Substrate: Low-cost flame-retardant glass epoxy laminate (FR4, $\varepsilon_r = 4.45$, $\tan\delta = 0.02$, $h = 1.6\text{ mm}$).
- **4-Element Linear Beamforming Array ($1 \times 4$)**:
  - Uniform amplitude and linear phase excitation generating a directive broadside radiation beam.
  - Inter-element spacing: $d = 130\text{ mm}$ ($0.376\lambda_0$ / $0.78\lambda_g$) to maximize broadside directivity and suppress grating lobes.
  - Shared continuous substrate and common RF ground plane ($Z_{min} = 0$).
- **Integrated Corporate Wilkinson Feed Network**:
  - Multi-stage binary power splitting network ensuring equal power division and phase coherence.
  - Quarter-wave transformer matching arms ($Z_0 = 70.7\ \Omega$, width $w_{70} = 1.58\text{ mm}$, length $l_{70} = 48.3\text{ mm}$).
  - Surface-mount $100\ \Omega$ isolation resistors ($R_{iso}$) to guarantee port-to-port isolation and absorb reflected power.
- **Parametric 3D Full-Wave Electromagnetic Modeling**:
  - Fully parameterized models in CST Studio Suite enabling single-variable re-tuning and dimensional sweeps.
  - Time-Domain and Frequency-Domain finite integration technique (FIT) solvers.
  - Farfield radiation pattern extraction: 3D gain, directivity, beamwidth, side-lobe level (SLL), and axial ratio.
- **Manufacturing Outputs**:
  - Standard RS-274X Gerber file export (`Microstrip_antenna_array.gbr`) for PCB fabrication.

---

## Design Specifications

| Parameter | Symbol | Value | Unit | Description |
| :--- | :--- | :--- | :--- | :--- |
| **Operating Frequency** | $f_0$ | 868 | MHz | ISM telemetry band |
| **Input Impedance** | $Z_{in}$ | 50 | $\Omega$ | Standard RF connector impedance |
| **Substrate Material** | — | FR4 | — | Woven fiberglass epoxy |
| **Relative Permittivity** | $\varepsilon_r$ | 4.45 | — | Dielectric constant |
| **Loss Tangent** | $\tan\delta$ | 0.02 | — | Dielectric loss factor |
| **Substrate Height** | $h$ | 1.6 | mm | Core dielectric thickness |
| **Copper Cladding** | $t$ | 35 | $\mu$m | 1 oz finished copper |
| **Patch Width** | $W$ | 105.0 | mm | Single patch radiant width |
| **Patch Length** | $L$ | 87.0 | mm | Resonant patch length |
| **Inset Depth** | $y_0$ | 12.0 | mm | Inset feed distance for $50\ \Omega$ match |
| **Inset Gap** | $g$ | 1.0 | mm | Spacing between patch and feedline |
| **Feedline Width** | $w_f$ | 3.0 | mm | $50\ \Omega$ microstrip line width |
| **Element Spacing** | $d$ | 130.0 | mm | Center-to-center array pitch |
| **Array Count** | $N$ | 4 | — | Elements in linear array |
| **Wilkinson Transformer**| $Z_{70}$ | 70.7 | $\Omega$ | $w_{70} = 1.58\text{ mm}$, $l_{70} = 48.3\text{ mm}$ |
| **Isolation Resistor** | $R_{iso}$ | 100 | $\Omega$ | Wilkinson isolation resistor |

---

## Project Structure

```text
Microstrip-Antenna-Design/
├── Microstrip_antenna_emsim.cst      # Master CST project for single-element patch
├── Microstrip_antenna_emsim/         # CST results, meshes, and parameter definitions
│   └── Parameters.txt                # Single-element parametric dimensional list
├── Microstrip_antenna_array_emsim/   # Master array simulation project directory
│   ├── 1x4Microstrip_antenna_array_emsim.cst # 4-element linear array model
│   ├── 2x2array.cst                  # 2x2 planar array model
│   ├── txrxMicrostrip_antenna_array_emsim.cst# Transmit/Receive dual-array model
│   ├── CST_868MHz_Beamforming_Array_Walkthrough.md # Step-by-step CST modeling guide
│   ├── Microstrip_antenna_array.gbr  # RS-274X Gerber file for fabrication
│   ├── Parameters.txt                # Array geometry parameters
│   ├── Stage2L_ArmL.txt              # Feed network branch dimensions
│   ├── extrude_gndplane.txt          # Ground plane extrusion vertex script
│   └── extrude_Stage1_InputTrace .txt# Primary 50 Ohm input trace geometry
├── .gitignore                        # Git ignore patterns
└── README.md                         # Project documentation
```

---

## CST Modeling & Simulation Workflow

1. **Prerequisites**: [Dassault Systèmes CST Studio Suite](https://www.3ds.com/products-services/simulia/products/cst-studio-suite/) (2020 or later).
2. **Single Element Setup**:
   - Open `Microstrip_antenna_emsim.cst`.
   - Verify return loss ($S_{11} \le -15\text{ dB}$ at 868 MHz).
3. **Array Simulation**:
   - Open `Microstrip_antenna_array_emsim/1x4Microstrip_antenna_array_emsim.cst`.
   - Consult `CST_868MHz_Beamforming_Array_Walkthrough.md` for explicit profile extrusions, coordinate transformations ($X_1 \dots X_4$), and Wilkinson resistor placement.
   - Run the Time Domain Solver with an energy convergence criterion of $-40\text{ dB}$.

---

## License

Academic and research design. All rights reserved by the author.
