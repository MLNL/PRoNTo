# Changelog

All notable changes to PRoNTo are documented here.

---

## [3.1.0] — 2026

### Added
- Elastic-net Multiple Kernel Learning for classification (Elastic-net MKL Support Vector Machine, ENMKL-SVM) and regression (Elastic-net MKL Kernel Ridge Regression, ENMKL-KRR)
- Weights display: box-and-jitter plot of per-modality kernel weights, with additional modality-table columns (median kernel weight, number of kernels)
- Weights display: "Full kernel weight list" window listing each kernel's weight (%), modality and ROI/grouping name, with CSV export


### Changed
- 'Normalise samples' renamed to 'Normalise samples/kernels' in the GUI
- MATLAB compatibility updated to R2017b–R2024b

### Fixed
- Cross-validation now reports the underlying machine error on a fold failure, instead of a misleading "Unrecognized field name func_val" error
- Weights display: modality names containing underscores no longer render as subscripts; table cells no longer show raw HTML on recent MATLAB versions

---

## [3.0.0-beta] — 2021-09-28

### Added
- Support for numerical arrays in `.mat` format (e.g. connectivity, psychometric data)
- Support for M/EEG data in SPM's MEEG format
- Multimodal predictive model building
- Extended multiple kernel learning capabilities
- New tutorial datasets and manual chapters

---

## [2.1.1] — 2018-11-30

### Changed
- Updates to credits and introduction sections of the manual

---

## [2.1.0] — 2018

### Added
- Atlas-based multiple kernel learning (Schrouff et al., 2018, Neuroinformatics)

---

## [2.0.0] — 2015

### Added
- Localising and comparing weight maps (Schrouff et al., 2013, PRNI)
- Flexible cross-validation frameworks
- Option to remove the effect of confounds

---

## [1.1.0] — 2011

### Added
- Initial public release
- Support for NIfTI format images (sMRI, fMRI, PET, DTI, betas/contrasts)
- Classification and regression models (SVM, GPC, KRR, MKL)
- GUI and batch system interface
- Supported on Windows, Mac OS, Linux (32 and 64 bit)
