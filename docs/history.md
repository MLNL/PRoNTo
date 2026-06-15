# PRoNTo History

## Origins (2011)

The first version of PRoNTo was developed in 2011 by an international team led by [Prof. Janaina Mourao-Miranda](http://www0.cs.ucl.ac.uk/people/J.Mourao-Miranda.html) and supported by the European Union through the [PASCAL Harvest programme (PASCAL2)](https://cordis.europa.eu/project/id/216886).

The founding development team comprised: Janaina Mourao-Miranda, Christophe Phillips, Jessica Schrouff, John Ashburner, Maria Joao Rosa, Jonas Richiardi, Andre Marquand, Jane Rondina, and Carlton Chu.

The motivation was an unmet need for a flexible pattern recognition framework that could accommodate different types of neuroimaging data, address varied research questions, and be safely used by neuroscientists who are not machine learning experts. Because the team included [SPM](https://www.fil.ion.ucl.ac.uk/spm/) developers (John Ashburner and Christophe Phillips), PRoNTo was built on SPM's existing functions for file handling, image display, and the batch system ([Glauch V.](https://sourceforge.net/projects/matlabbatch/)).

## Growth (v1.1, v2.0, v2.1)

Over the years new contributors joined the team — Joao Matos Monteiro, Anil Rao, Tong Wu, and Konstantinos Tsirlis — and PRoNTo gained new capabilities including:

- Flexible cross-validation frameworks
- Option to remove the effect of confounds
- Atlas-based multiple kernel learning

Jessica Schrouff was a major contributor from PRoNTo's inception through version 3.0.

## PRoNTo v3.0 (2021)

Accepts multiple data formats (NIfTI, `.mat`, SPM `@meeg`) and enables building of **multimodal predictive models**. It was supported by the Wellcome Trust.

## PRoNTo v3.1 (2026)

The latest release includes the **Elastic-net Multiple Kernel Learning (ENMKL)** ([arXiv preprint](https://arxiv.org/abs/2512.11547)) to combine information from several kernels, where each kernel can correspond to different modalities (imaging and non-imaging) or different feature groupings (e.g. regions of interest).

## Current Leadership

PRoNTo v3.1 was led by **Prof. Janaina Mourao-Miranda** and co-supervised by **Prof. Christophe Phillips**. **Konstantinos Tsirlis** was responsible for the management and maintenance of the toolbox. At present, PRoNTo does not have a dedicated person managing developments or providing support. If you are interested in contributing, please contact **Prof. Janaina Mourao-Miranda** or **Prof. Christophe Phillips** directly — see the [Contributing guidelines](https://github.com/MLNL/PRoNTo_public/blob/main/CONTRIBUTING.md) for more details.

---

*Photos of the original PRoNTo development team (2011) are available on the [legacy website](http://www.mlnl.cs.ucl.ac.uk/pronto/prthistory.html).*
