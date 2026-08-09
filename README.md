# Road Crack Detection System

An integrated MATLAB platform for road crack detection, method comparison, quantitative evaluation, visualization, and automatic result export.


<p align="center">
  <img src="data/images/hero.png" width="85%">
</p>

<p align="center">
<b>Figure 1.</b> MATLAB App Designer interface.
</p>

---

## Overview

Problem
Road surface cracks are important indicators of pavement deterioration and can affect safety, maintenance planning, and infrastructure costs when they are not identified early. Manual inspection is time-consuming, subjective, and difficult to scale across large road networks, motivating the development of automated methods that can locate crack regions consistently from road images.

Solution
This academic project combines classical image processing with deep learning in a unified road crack detection workflow. The classical pipeline provides three complementary approaches—Otsu global thresholding, Sauvola adaptive thresholding, and Canny edge detection—followed by configurable rule-based post-processing. A U-Net segmentation model provides a learning-based alternative for detecting more complex crack patterns. Bringing these methods together makes it possible to inspect individual predictions, compare algorithm behaviour, process image collections, and evaluate outputs against available ground-truth masks.

Implementation
The system is implemented as a modular MATLAB project with an interactive MATLAB App Designer interface. The application connects data handling, pre-processing, inference, post-processing, quantitative evaluation, visualization, and organized export in a single platform suitable for academic experimentation and software engineering development.

---

## Project Highlights

Unified MATLAB App integrating classical image processing and deep learning.
Three working modes: Single, Compare, and Batch Processing.
Built-in quantitative evaluation and automatic export.
Modular software architecture for easy extension.

---

## Features

<p align="center">
  <img src="data/images/features.png" width="35%">
</p>

<p align="center">
<b>Figure 2.</b> Major functional modules of the Road Crack Detection System.
</p>

---

## Workflow

<p align="center">
  <img src="data/images/work flow.png" width="105%">
</p>

<p align="center">
<b>Figure 3.</b> Overall processing pipeline.
</p>

The pipeline begins by loading and validating a road image, then applies the pre-processing operations required by the selected detector. Detection is performed using one of the three classical methods or the U-Net model. Optional post-processing refines the initial binary mask by suppressing noise and retaining crack-like structures. When a matching ground-truth mask is available, the system evaluates the prediction and generates supporting visualizations such as overlays and error maps. Images, masks, figures, and tabular metrics can then be exported in an organized form for later analysis or reporting.

---

## Project Architecture

<p align="center">
  <img src="data/images/Software Architecture .png" width="75%">
</p>

<p align="center">
<b>Figure 4.</b> Overall Software Architecture.
</p>

| Module | Responsibility |
|---|---|
| `cfg` | Stores project configuration, paths, parameters, and shared settings. |
| `m0_data` | Handles image discovery, loading, validation, and dataset organization. |
| `m1_pre` | Provides reusable image pre-processing operations. |
| `m2_cls` | Implements the Otsu, Sauvola, and Canny classical detectors. |
| `m3_post` | Refines masks using rule-based morphological and component-level processing. |
| `m4_dl` | Manages U-Net loading, inference, probability fusion, and mask generation. |
| `m5_eval` | Computes evaluation outputs and produces overlays, error maps, and exportable metrics. |
| `m6_app` | Connects the processing modules to the MATLAB App Designer interface. |

---

## Folder Structure

```text
Main crack project/
├── cfg/                 # Configuration, paths, and shared parameters
├── data/                # Test set and train set
├── images/              # Screenshots of App and reults
├── src/
│   ├── m0_data/         # Data loading and dataset utilities
│   ├── m1_pre/          # Image pre-processing
│   ├── m2_cls/          # Classical detection methods
│   ├── m3_post/         # Rule-based post-processing
│   ├── m4_dl/           # U-Net inference pipeline
│   ├── m5_eval/         # Evaluation and visualization
│   └── m6_app/          # MATLAB App Designer integration
├── scripts/             # Setup, training, testing, and utility scripts
├── results/             # Exported masks, figures, metrics, and reports
├── test/                # Scripts for testing if the src file is valid
├── Update Log.txt/
├── 更新日志.txt/
└── README.md            # Project documentation
```

The structure separates configuration, data management, algorithm development, evaluation, and user-interface code. This organization allows individual modules to be tested or extended without tightly coupling them to the application layer.

---

## Classical Pipeline

<p align="center">
  <img src="data/images/Classical Detection Pipeline.png" width="75%">
</p>

<p align="center">
<b>Figure 5.</b> Classical Detection Pipeline.
</p>

The classical pipeline first normalizes the input into a suitable grayscale representation and applies any required contrast enhancement or noise reduction. It then uses one of three detection strategies:

- **Otsu:** Calculates a global intensity threshold and separates likely crack pixels from the road background.
- **Sauvola:** Uses locally adaptive thresholds to accommodate uneven illumination and surface variation.
- **Canny:** Detects intensity transitions that may correspond to crack boundaries.

The initial detector output can contain isolated noise, texture responses, or fragmented regions. Rule-based post-processing therefore applies suitable morphological operations and connected-component filtering to improve spatial consistency and retain structures that are more likely to represent road cracks.

---

## Deep Learning Pipeline

<p align="center">
  <img src="data/images/Deep Learning Pipeline.png" width="75%">
</p>

<p align="center">
<b>Figure 6.</b> Deep Learning Pipeline.
</p>

The deep learning pipeline accepts a road image and prepares it for U-Net inference. Large images are divided into manageable, potentially overlapping windows. The network predicts a crack probability map for each window, and the local predictions are fused to reconstruct a probability map at the original image scale. Thresholding converts the fused probabilities into a binary segmentation mask. Connected-component filtering then removes unsuitable isolated regions and produces the final crack mask for visualization, evaluation, and export.


---

## MATLAB GUI

### Single Detection Mode

<p align="center">
  <img src="data/images/Single.png" width="85%">
</p>

<p align="center">
<b>Figure 7.</b> Single Detection Mode.
</p>

### Compare Mode

<p align="center">
  <img src="data/images/Compare.png" width="85%">
</p>

<p align="center">
<b>Figure 8.</b> Compare Detection Mode.
</p>

### Batch Processing Mode

<p align="center">
  <img src="data/images/Batch.png" width="85%">
</p>

<p align="center">
<b>Figure 9.</b> Batch Processing Mode.
</p>

---

## Installation

### Prerequisites

- **Deep Learning Toolbox**
- **Image Processing Toolbox**
- **Statistics and Machine Learning Toolbox**
- **Parallel Computing Toolbox(optional if you need use gpu)**

### Setup

Open the App Designer `.mlapp` file from the application module(src/m6_app) and select **Run**.

If the program can't start normally due to the Matlab version or other issues, please open and run it through the APP Designer in Matlab.

---

## Usage

1. Load a road image.
2. Select **Otsu**, **Sauvola**, **Canny**, or **U-Net**.
3. Enable or disable post-processing as required.
4. Run the selected detection method.
5. Review the predicted mask, overlay, error map, and available metrics.
6. Export results and evaluation data.

Use **Compare Mode** when inspecting the behaviour of multiple detectors on the same input.For multi-image analysis, switch to **Batch Processing**, select the relevant input and output locations, configure the desired method, and start the batch run. 

---

## Future Work

- Investigate transformer-based segmentation architectures.
- Improve inference speed and memory efficiency.
- Support real-time road inspection and deployment.
- Develop a mobile or edge-device platform.
- Train and evaluate on additional road-surface datasets.
- Extend the system to multi-class road damage detection.
- Improve robustness to shadows, road markings, and changing illumination.
- Add reproducible experiment configuration and automated testing.
- Expand into other areas, like detecting damage on solar panels.

---

## Author

| Field | Details |
|---|---|
| **University** | UNSW |
| **Project** | 26T2 ELEC9773 |
| **Team** | Group 3 |
| **Name** | Zitong Feng |
| **Contact Info** | vozitong@gmail.com |


