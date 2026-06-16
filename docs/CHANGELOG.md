# Changelog

All notable changes to PRoNTo are documented here.

---

## [3.1.0] — 2026

### Added
- Elastic-net Multiple Kernel Learning (ENMKL) to combine information from several kernels, where each kernel can correspond to a different modalities (imaging and non-imaging) or to a different feature grouping (e.g. regions of interest). See [arXiv preprint](https://arxiv.org/abs/2512.11547).

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
- Atlas-based multiple kernel learning ([Schrouff et al., 2018, Neuroinformatics](https://doi.org/10.1007/s12021-017-9347-8))

---

## [2.0.0] — 2015

### Added
- Localising and comparing weight maps ([Schrouff et al., 2013, PRNI](https://doi.org/10.1109/PRNI.2013.40))
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
