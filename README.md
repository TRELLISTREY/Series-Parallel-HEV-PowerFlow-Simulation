# Series-Parallel HEV Power-Flow Simulation

A MATLAB/Simulink model for studying power-flow management in a Series-Parallel Hybrid Electric Vehicle (HEV).

## 📌 Project Overview

This project implements a simplified supervisory control and power-flow model for a hybrid electric vehicle using MATLAB/Simulink.

The model demonstrates how power is distributed between the internal combustion engine, electric motor, generator, battery, and mechanical drivetrain under different vehicle operating conditions.

## ⚙️ Operating Modes

The simulation demonstrates three operating modes:

- 🔋 **Battery Only** – propulsion is primarily supplied by the battery and electric motor.
- ⚡ **Full Acceleration** – increased wheel-power demand results in combined power contribution from the available power sources.
- ♻️ **Regenerative Braking** – braking energy is recovered and directed toward the battery.

## 🧩 Model Features

- HEV supervisory controller
- Engine power-flow calculation
- Generator mechanical and electrical power paths
- Traction motor power-flow calculation
- DC motor input power
- Battery power monitoring
- Friction braking
- Regenerative braking
- Battery State of Charge (SOC) estimation
- Operating-mode indicators
- Real-time power displays
- Simulink Scope for observing power-flow behaviour

## 📊 Simulation Outputs

The model monitors:

- Engine power
- Direct mechanical power
- Generator mechanical power
- Generator DC power
- Traction motor mechanical power
- Motor DC input power
- Battery power
- Friction brake power
- Battery State of Charge (SOC)

The simulation was configured for a 15-second operating cycle to observe transitions between different operating conditions.

## 🛠️ Tools Used

- MATLAB
- Simulink
- Stateflow

## 📁 Repository Contents

| File | Description |
|---|---|
| `Series_Parallel_HEV_PowerFlow_Simulink.slx` | Main Simulink model |
| `Build_HEV_Model.m` | MATLAB script used to construct/configure the model |
| `HEV_Simulation.m` | Simulation setup and execution script |
| `README.md` | Project documentation |
| `LICENSE` | MIT License |

## 🎥 Project Demonstration

A screen-recorded demonstration of the simulation is available on my LinkedIn profile.

The video demonstrates the model running in Simulink and shows the changes in power flow and operating-mode indicators during the simulation.

## 📚 Learning Context

This project was developed as part of my ongoing learning in Electric and Hybrid Vehicle technologies through **ISIEINDIA**.

It provided an opportunity to apply concepts related to:

- Hybrid vehicle power management
- Electric vehicle systems
- Control systems
- Power electronics
- MATLAB/Simulink modelling

## 🤖 Use of AI as a Learning Aid

AI tools were used during the development process as a learning and troubleshooting aid, particularly for understanding Simulink implementation, debugging errors, and exploring modelling approaches.

The model was implemented, tested, modified, and validated through hands-on work in MATLAB/Simulink.

## 👨‍💻 Author

**Trellis Trey**

B.Tech Mechatronics Engineering  
Parul University, India

## 📄 License

This project is licensed under the MIT License. See the `LICENSE` file for details.
