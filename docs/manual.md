# PRoNTo Manual

The PRoNTo manual is a comprehensive document covering all aspects of the toolbox — from installation and data input to model specification, results display, and developer documentation. **If you have not used PRoNTo before, we recommend starting with the manual and reproducing the examples in the tutorials before trying it on your own data.** Video tutorials showing step-by-step how to implement the tutorials are also available as part of the PRoNTo course material — see [`docs/courses.md`](courses.md) for details on how to access them.

**Download the manual:** [prt_manual.pdf](../manual/prt_manual.pdf)

> The manual is also distributed with the software at `PRoNTo/manual/prt_manual.pdf`.

---

## Table of Contents

### Chapter 1 — Introduction
- Background and motivation
- Methods: inputs, preprocessing, and machine learning algorithms
- Installing and launching the toolbox
- Troubleshooting
- What's new in each version (v1.0 – v3.1)
- How to cite PRoNTo
- PRoNTo history and main contributors

---

### Part I — Description of PRoNTo Tools

**Chapter 2 — Data & Design**
- Setting up the PRT directory
- Groups, subjects/samples, and modalities
- Masks and HRF correction
- Batch interface and PRT structure

**Chapter 3 — Prepare Feature Set**
- Feature extraction and pre-processing
- NIfTI, `.mat`, and `@meeg` data formats
- Batch interface

**Chapter 4 — Model Specification and Estimation**
- Model specification and feature sets
- Classification and regression algorithms
- Hyper-parameter optimisation
- Cross-validation schemes
- Model estimation and batch interface

**Chapter 5 — Display Model Performance**
- Launching results display
- Measuring model performance (classification and regression)
- Permutation testing
- Visualising model performance

**Chapter 6 — Computing Feature and Region Contributions**
- Feature weights
- Atlas-based weights
- Batch interface

**Chapter 7 — Display Weights**
- Displaying weight maps
- Anatomical images and additional plots

**Chapter 8 — List of Input Files**

---

### Part II — Batch Interfaces

- **Chapter 9** — Data & Design
- **Chapter 10** — Feature Set / Kernel (NIfTI, MEEG, `.mat`)
- **Chapter 11** — Model: Specify New (classification, regression, cross-validation)
- **Chapter 12** — Model: Run (with optional permutation testing)

---

### Part III — Practical Tutorials

Each tutorial provides step-by-step instructions for both GUI and batch analysis. Download the datasets from [`docs/datasets.md`](datasets.md).

| Chapter | Dataset | Task |
|---|---|---|
| 13 | Haxby block-design fMRI | Classification |
| 14 | OASIS structural MRI | Regression |
| 15 | Multimodal Face Recognition | Multiple Kernel Learning |
| 16 | OASIS structural MRI | Classification with confound removal |
| 17 | Multimodal Face Recognition | Multi-modal analysis |
| 18 | Simulated ECoG | Classification of semi-simulated ECoG data |
| 19 | OASIS structural MRI | Non-kernel machine example |
| 20 | Within-subject fMRI | Within-subject regression |
| 21 | — | New machine tutorial (for developers) |

---

### Part IV — Advanced Topics

**Chapter 22 — Developer's Manual**
- PRoNTo folder structure
- Data & Design, Feature Set, Model Specify/Run, Compute Weights — internal behaviour, PRT fields, files created, functions called

**Chapter 23 — PRoNTo Functions and the PRT Structure**
- Full list of PRoNTo functions
- The PRT structure

---

### Part V — Appendix

**Chapter 24 — Appendix**
- One data file per subject
- Computing atlas for connectivity matrix
- Connectivity matrix from MEEG
- Connectivity ROI weights

---

## Related Documentation

| Document | Description |
|---|---|
| [FAQ](faq.md) | Frequently asked questions on installation, inputs, cross-validation, and interpretation |
| [Datasets](datasets.md) | Example datasets for the tutorials |
| [Mac Instructions](instructions-for-mac.md) | Mac-specific installation instructions |
| [Citation](citation.md) | How to cite PRoNTo |
