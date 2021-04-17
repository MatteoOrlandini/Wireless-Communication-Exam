# Wireless-Communication-Exam

## Introduction

The purpose of this project is to estimate and correct the IQ imbalance in a QPSK modulation using Simulink and Matlab. Both amplitude and phase imbalance can occur as shown in the figure below.

![](https://github.com/MatteoOrlandini/Wireless-Communication-Exam/blob/main/Images/QPSK_constellation_with_amplitude_and_phase_imbalance.png)

The Simulink model to view the saved signals was taken from the example [QPSK Transmitter and Receiver in Simulink](https://www.mathworks.com/help/comm/ug/qpsk-transmitter-and-receiver-in-simulink.html) and is illustrated in figure below. The files are previously saved as 801 frames consisting of 12500 samples. 

![](https://github.com/MatteoOrlandini/Wireless-Communication-Exam/blob/main/Images/simulink_receiver.png)

## The code

* Simulink model [NO_USRP.slx](https://github.com/MatteoOrlandini/Wireless-Communication-Exam/blob/main/No_USRP.slxc) allows to view the saved signals with imbalance
  * signal_1: unbalanced signal
  * signal_2: unbalanced signal with higher power than signal_1
  * signal_IQ10: signal with 10% imbalance in transmission
  * signal_IQ20: signal with 20% imbalance in transmission
  * signal_IQ30: signal with 30% imbalance in transmission.

* The function [delete_first_zeroes.m]() deletes the first zeroes from a signal 
* The function [apply_IQ_imbal.m](https://github.com/MatteoOrlandini/Wireless-Communication-Exam/blob/main/apply_IQ_imbal.m) applies an IQ imbalance to a signal
* The function [imbalance_algorithm_estimation.m](https://github.com/MatteoOrlandini/Wireless-Communication-Exam/blob/main/imbalance_algorithm_estimation.m) estimates the imbalance from a signal
* The function [imbalance_correction.m](https://github.com/MatteoOrlandini/Wireless-Communication-Exam/blob/main/imbalance_correction.m) corrects the imbalance of a signal 
* The function [imbalance_estimation.m](https://github.com/MatteoOrlandini/Wireless-Communication-Exam/blob/main/imbalance_estimation.m) estimates the amplitude and phase imbalance from a signal using comm.IQImbalanceCompensator

For more information type in Matlab:
* `help delete_first_zeroes`
* `help apply_IQ_imbal`
* `help imbalance_algorithm_estimation`
* `help imbalance_correction`  
* `help imbalance_estimation`

## How to run
Open Matlab and run [main.m](https://github.com/MatteoOrlandini/Wireless-Communication-Exam/blob/main/main.m).

The input signals are not available due to the large dimensions. The input signals signal_1, signal_2, signal_IQ10, signal_IQ20, signal_IQ30 are 801x12500 matrices (801 frames x 12500 samples). 

## Results
### Simulink

signal_IQ30 after raised cosine

![](https://github.com/MatteoOrlandini/Wireless-Communication-Exam/blob/main/Images/signal_IQ30_after_raised_cosine_simulink.png)

signal_IQ30 after symbol synchronizer

![](https://github.com/MatteoOrlandini/Wireless-Communication-Exam/blob/main/Images/signal_IQ30_after_symbol_synchronizer_simulink.png)

signal_IQ30 after carrier synchronizer

![](https://github.com/MatteoOrlandini/Wireless-Communication-Exam/blob/main/Images/signal_IQ30_after_carrier_synchronizer_simulink.png)

### Matlab

Comparison of the real part of the signal with imbalance and the
original signal

![](https://github.com/MatteoOrlandini/Wireless-Communication-Exam/blob/main/Images/real_part_imbalanced_signal_comparison.png)

Comparison of the imaginary part of the signal with imbalance and the
original signal

![](https://github.com/MatteoOrlandini/Wireless-Communication-Exam/blob/main/Images/imaginary_part_imbalanced_signal_comparison.png)

Comparison of the real part of the corrected signal and the original signal

![](https://github.com/MatteoOrlandini/Wireless-Communication-Exam/blob/main/Images/real_part_corrected_signal_comparison.png)

Comparison of the imaginary part of the corrected signal and the original signal

![](https://github.com/MatteoOrlandini/Wireless-Communication-Exam/blob/main/Images/imaginary_part_corrected_signal_comparison.png)

The output of [imbalance_estimation.m](https://github.com/MatteoOrlandini/Wireless-Communication-Exam/blob/main/imbalance_estimation.m) is very similar to the expected values, in fact for the signal modified by [apply_IQ_imbal.m](https://github.com/MatteoOrlandini/Wireless-Communication-Exam/blob/main/apply_IQ_imbal.m), an amplitude imbalance of 2.4623 dB is estimated, while the expected one is 20 log_10 (1.3) = 2.2789 dB.

The results of [imbalance_algorithm_estimation.m](https://github.com/MatteoOrlandini/Wireless-Communication-Exam/blob/main/imbalance_algorithm_estimation.m) are listed in the following table.

|    Signal   | Imbalance [dB] | Estimated imbalance [dB] |
|:-----------:|----------------|--------------------------|
| Signal_IQ10 | 0.82785        | 0.81093                  |
| Signal_IQ20 | 1.5836         | 1.2474                   |
| Signal_IQ30 | 2.2789         | 1.6251                   |

## Conclusions

This project showed, through the Matlab script, how it is possible to apply
and correct the IQ imbalance and how to estimate the imbalance from a signal
unknown. This estimate is best for a software unbalanced signal
compared to an imbalanced signal acquired by a transmitter.
This error is due to the recovery of the receiving carrier and ambiguity
phase.

The errors that arise due to
a phase and frequency error are shown respectively in the figures below.

Example of QPSK carrier recovery frequency error causing rotation of the received symbol constellation. [Wikipedia](https://en.wikipedia.org/wiki/Carrier_recovery)

![](https://github.com/MatteoOrlandini/Wireless-Communication-Exam/blob/main/Images/QPSK_Freq_Error.png)

Example of QPSK carrier recovery phase error causing a fixed rotational offset of the received symbol constellation. [Wikipedia](https://en.wikipedia.org/wiki/Carrier_recovery)

![](https://github.com/MatteoOrlandini/Wireless-Communication-Exam/blob/main/Images/QPSK_Phase_Error.png)

For more information please see [Relazione.pdf](https://github.com/MatteoOrlandini/Wireless-Communication-Exam/blob/main/Relazione.pdf) in Italian language.
