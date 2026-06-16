# PRoNTo Frequently Asked Questions (FAQ)

---

## 1. Installation & Troubleshooting

### 1.1 How do I install PRoNTo?

Before installing, make sure your system meets the [software requirements](../README.md#requirements). In particular:
- Use MATLAB R2017b or later. R2024b recommended. A known file selector error and minor GUI display issues may appear in MATLAB R2025a (and probably later versions) — see section 1.3 below for details and workaround.
- Install [SPM](https://www.fil.ion.ucl.ac.uk/spm/) (SPM12 or SPM25) with its latest updates

Then:
1. Download the latest PRoNTo release from the [Releases page](https://github.com/MLNL/PRoNTo_public/releases).
2. Open MATLAB and add both PRoNTo and SPM to the MATLAB path:

  ```matlab
  addpath('path_to_pronto')
  addpath('path_to_spm')
  ```

You can also add paths via MATLAB's GUI using the *Add Folder* option. For more information see [MATLAB's documentation on search paths](http://uk.mathworks.com/help/matlab/matlab_env/what-is-the-matlab-searchpath.html).

To start PRoNTo, type `pronto` or `prt` in the MATLAB Command Window.

---

### 1.2 I cannot run SVM (or another machine) and it says `Matlab path issue`.

PRoNTo uses compiled C++ libraries (e.g. LIBSVM) via MATLAB MEX interfaces. These need to be compiled for your specific system. We provide pre-compiled binaries, but some platforms (certain Mac and Linux OS versions, older MATLAB versions) may require recompilation.

Detailed instructions for recompiling are in the [manual](manual.md).

For SVM specifically: ensure PRoNTo is at the **top** of your MATLAB path, as some MATLAB toolboxes can interfere with the MEX interfaces.

---

### 1.3 I am experiencing problems with the Graphical User Interface (GUI).

This typically occurs when running PRoNTo with an unsupported MATLAB version. Check the [system requirements](../README.md#requirements).

If you are on a supported version and still experiencing issues, try restarting MATLAB. If the problem persists, please open a [GitHub Issue](https://github.com/MLNL/PRoNTo_public/issues).

**Known issue — File selector error in MATLAB R2025a and later**

PRoNTo v3.1 is mostly functional in MATLAB R2025a but has two known issues:

**1. File selector error**

When selecting files in the Specify Modality window, the following error may appear in the MATLAB Command Window:

```
Error using matlab.ui.control.UIControl/updateListboxTopFromView
Invalid input for argument 2 (rhs2): Value must be a scalar.
```

This is a compatibility issue between MATLAB R2025a and SPM's file selector (`spm_select`). The exact cause is currently under investigation.

**Workaround:** Use MATLAB R2024b where the file selector works without errors.

**2. Minor GUI window display issues**

Minor display issues may appear in some PRoNTo windows. These do not affect functionality — data loading, model fitting, and results are not affected.

**Workaround:** Use MATLAB R2024b for a fully stable experience.

**Recommended configuration:** MATLAB R2024b with SPM25 or SPM26.

---

### 1.4 I am experiencing compiler issues.

Users on some MATLAB versions may encounter compiler errors on first use. A tutorial for resolving these issues is available [here (PDF)](Compiler_issues.pdf).

---

## 2. Inputs

### 2.1 What types of data can I input to PRoNTo?

From v3.0 PRoNTo accepts:
- **NIfTI format images** (structural MRI, functional MRI, PET, DTI, beta/contrast images)
- **Numerical arrays** in `.mat` files (e.g. connectivity matrices, psychometric data)
- **M/EEG data** in SPM's `@meeg` data format

---

### 2.2 What naming rules apply to modalities, feature sets, and models?

Names must consist only of **alphanumeric characters (a–z, 0–9) and underscores (_)**. Avoid spaces, dashes, and special characters — these may cause errors.

In batch mode, naming must be **consistent** across steps: a modality must always be referred to with exactly the same name (same capitalisation recommended for safety).

---

### 2.3 How should I name modalities in the Masks option in batch mode?

The name of each modality in the *Masks* option must **exactly match** the name used in *Groups*. For example, if you have three modalities called `Run1`, `Run2`, and `Run3`, there must be three masks with modality names `Run1`, `Run2`, and `Run3` respectively. The same mask file can be used for all three, as long as the names match.

---

### 2.4 What mask is required?

For NIfTI data, a **first-level mask** is required — a binary mask with a value of `1` at voxels that have intensity values in all subjects and conditions, and `0` elsewhere. This identifies "within-brain" voxels across all images and reduces memory use.

For `.mat` and MEEG data, masking is expected to have been performed before using PRoNTo — no additional mask is needed.

> **Important for beta/contrast images:** These often contain NaN values at different locations across images. Ensure your mask correctly excludes those NaN voxels. If you see `Warning: NaNs found in loaded data` in the workspace, revise your mask.

---

### 2.5 What pre-processing should I do before entering images?

PRoNTo assumes that voxel N in image 1 corresponds to voxel N in all other images. Input images must be **aligned and registered in the same space**.

PRoNTo can additionally perform:
- Detrending of time-series signals (for fMRI)
- Scaling of voxel intensities by a single value (commonly used for PET)

Any pre-processing that increases signal-to-noise ratio is recommended, **as long as it does not involve the model targets** (to avoid "double-dipping" / data leakage).

---

### 2.6 How do I specify the design for beta images?

There are two approaches:

**Within-subject design (many beta images per subject):** Enter subjects one by one and specify the design manually (not via SPM.mat). Example: 3 conditions, one beta per condition, selected as `beta_condA`, `beta_condB`, `beta_condC`. Set conditions with onsets `0, 1, 2` and duration `1` each, with units set to *Scans* and TR = 1. Leave HRF parameters at default (0), since the HRF is already accounted for in the betas.

**Across-subject design (a few betas, many subjects):** Use *Groups* — one group per condition (e.g. `condA`, `condB`). Enter subject images in the **same order in every group** to ensure correct cross-validation pairing. Mismatched ordering leads to data leakage.

---

## 3. Cross-Validation

### 3.1 Should I use 'Leave Subjects per Class Out' or 'Leave Subjects Out'?

- **Leave Subjects Out** works well when subjects have a within-subject design (e.g. conditions defined per subject via beta images or fMRI time series). Not ideal when classifying groups (e.g. healthy vs. diseased) since it can create class imbalance across folds.

- **Leave Subjects per Class Out** is appropriate when subjects are matched across groups and groups define the classes. It is the **only suitable choice** when beta images from the same subjects are entered as separate groups (see 2.6). Subjects must be entered in matching order across groups.

---

### 3.2 Should I use k-folds or Leave-One-Out cross-validation?

Leave-One-Out CV has been shown to produce **over-optimistic estimates** in neuroimaging ([Varoquaux et al., 2017](https://doi.org/10.1016/j.neuroimage.2016.10.038)). **k-folds with k = 5 or 10** (leaving 20% or 10% out per fold) is recommended.

Report performance across all CV schemes attempted, and include the **variance or standard deviation** across folds ([Varoquaux, 2018](https://doi.org/10.1016/j.neuroimage.2017.06.061)).

---

## 4. Interpreting Results

### 4.1 How should I interpret negative correlations in regression models?

A negative correlation suggests the model is not learning a meaningful relationship between the patterns and the targets — it is likely predicting near the mean of training targets for all test samples, with noise causing negative correlations.

**Mean-squared error (MSE)** is a more reliable metric than correlation for regression evaluation and should be used even when correlation is positive.

---

### 4.2 Why am I getting very low accuracy (e.g. 5%) for binary classification?

This occurs when the model cannot learn from the data. It does not imply the model is learning the "flipped" labels — it simply indicates the patterns are not informative for the given classification.

---

### 4.3 My classifier gives significant results for beta images but not contrast images. Why?

The choice between beta and contrast images can affect results. One possible explanation: if the variance of the signal differs between two conditions (e.g. between groups in the healthy cohort), that difference may be sufficient for discrimination using beta images. However, when computing a contrast (subtracting the means of conditions), this variance difference is lost, reducing discriminability. See [Hebart and Baker, 2018](https://doi.org/10.1016/j.neuroimage.2017.08.005) for more details.

---

### 4.4 How should I interpret the weight map from a model?

Weight maps represent the contribution of each voxel to the predictive function. Because all voxels with non-zero weights contribute to predictions, the map **cannot be thresholded**. Relating weight amplitude directly to brain activity can be misleading.

Recommended references:
- [Haufe et al., 2014](https://doi.org/10.1016/j.neuroimage.2013.10.067)
- [Kia et al., 2017](https://doi.org/10.3389/fnins.2016.00619)
- [Hebart and Baker, 2018](https://doi.org/10.1016/j.neuroimage.2017.08.005)
- [Schrouff and Mourão-Miranda, 2018](https://doi.org/10.1109/PRNI.2018.8423944)

---

### 4.5 How should I interpret positive/negative weights in a linear regression model?

For a single-voxel model `f = v1 * w1 + b`:
- `w1 = 3`: the predicted target increases by 3 for each unit increase in signal at `v1`
- `w1 = -2`: the predicted target decreases by 2 for each unit increase in signal at `v1`

In a multi-voxel model, the interpretation holds for each voxel while holding others constant. However, a non-zero weight does not necessarily indicate that the voxel is "more active" — noise structure and other factors can also produce non-null weights. See references in 4.4.

---

### 4.6 How should I interpret positive/negative weights in a binary classification model?

The interpretation is similar to regression (4.5), but the function value `f` is not a predicted target — it is either the **signed distance from the classification boundary** (SVM/MKL) or the **log-odds-ratio** (Gaussian Process Classification).

A negative weight does not mean the voxel is "activated" in the second class. See the references in 4.4 for a detailed discussion.
