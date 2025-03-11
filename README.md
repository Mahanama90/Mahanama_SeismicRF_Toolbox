Mahanama SeismicRF Toolbox
Automated MATLAB Scripts for Streamlined Receiver Function (RF) Data Selection

![Seismic Data Analysis](Result_Figures.png)


Overview:
This repository provides a set of MATLAB scripts designed to automate the data selection process for Receiver Function (RF) analysis. The scripts enable researchers to efficiently filter and organize station metadata, ensuring consistency in sensor types, channels, and data durations before initiating an RF study.

One of the critical steps in RF analysis is selecting seismic stations with long-duration, high-quality waveform arrivals to enhance the reliability of results. These automation scripts were developed to streamline this process, eliminating inconsistencies and ensuring optimal data selection.

Why Use This Toolbox?

Efficient Data Filtering – Quickly process large station metadata files and extract only the most relevant records.

Ensures Data Consistency – Selects seismic stations with uniform sensors, channels, and durations, preventing mix-ups in RF processing.

Optimized for RF Studies – Helps in identifying clean, long-duration waveforms essential for accurate receiver function computation.

User-Friendly & Automated – Simply download station and channel metadata (.txt files) for your study duration, and let the scripts filter out the best data for extraction.
Please make sure to customize it according to the desired need. 

How It Works
Download station and channel metadata (.txt files) covering your desired study duration.
(https://service.iris.edu/fdsnws/station/docs/1/builder/) * Change Level to choose channels/stations.
Run the MATLAB scripts to filter stations based on key parameters:
Same sensors.
Same channel types.
Consistent location codes.
Longest available durations.
Obtain a refined dataset with optimal station selections, reducing preprocessing errors and improving RF analysis accuracy.

Each script in the repository is accompanied by a description file (.txt) explaining its function and expected output.

Use Example Station.txt and Channel.txt to run the script and also to familiarize yourself with the input data format.
