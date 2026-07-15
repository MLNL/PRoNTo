# Why PRoNTo Uses Linear Kernel Methods

## The challenge: neuroimaging data is high-dimensional

In a typical neuroimaging study, each brain scan contains far more measurements than there are subjects — often thousands to millions of voxels from only tens or hundreds of subjects. This means the dimensionality $p$ (number of measurements per scan/subject) far exceeds the sample size $N$ (number of scans/subjects), a situation written as $p \gg N$.

Standard machine learning methods that work directly on the data struggle in this setting — both because there are too few examples relative to the number of measurements, and because the data matrix itself is very large. Regularised kernel methods address both issues: 
- regularisation prevents overfitting when $p \gg N$, and
- the kernel representation replaces the large data matrix with a compact $N \times N$ summary of pairwise similarities between scans.

### Feature vectors and the data matrix

In machine learning, the measurements extracted from each data example (e.g. from each brain scan) are represented as a **feature vector** — a list of values, one per measurement. For a dataset of $N$ data examples, stacking all feature vectors produces the **data matrix $X$** of size $N \times p$. For example, in a dataset with sMRI of 100 subjects and 200,000 voxels per scan, **$X$** would be $100 \times 200,000$ — a matrix with 20 million entries. The kernel matrix **$K$**, by contrast, is only 100 $\times$ 100 (10,000 entries), regardless of the number of voxels.

---

## What is a kernel?

A **kernel** is a function that, for any two feature vectors (e.g. two brain scans), returns a single number representing their **pairwise similarity**. For example, instead of comparing scans voxel by voxel, a kernel summarises *how similar* two scans are in a compact form.

Formally, for two feature vectors **$x$** and **$x^*$**, the kernel function $K(x, x^*)$ returns a real number. For a dataset of $N$ scans, this produces an $N \times N$ kernel matrix **$K$**, where each entry $K(i, j) encodes the similarity between scan $i$ and scan $j$.

### The linear kernel

PRoNTo uses **linear kernels**, where the similarity between two scans $i$ and $j$ is computed as the **dot product** between their feature vectors **$x_i$** and **$x_j$**:

```
K(xᵢ, xⱼ) = xᵢ · xⱼ
```

For a dataset of $N$ scans with feature vectors $x_1$, $x_2$,$\ldots$, $x_N$ stacked into a data matrix **$X$** (of size $N \times p$), the full $N \times N$ linear kernel matrix **$K$** can be computed as:

```
K = X Xᵀ
```

As an illustrative example, if we have feature vectors with only two measures: feature vector 1 is $[4, 1]$ and feature vector 2 is $[−2, 3]$, their linear kernel value is:

```
K(x₁, x₂) = (4 × −2) + (1 × 3) = −5
```

This captures the overall similarity between the feature vectors.

---

## Why kernels are computationally efficient when $p \gg N$

This is the key insight behind using kernel methods in neuroimaging.

Machine learning models can be formulated in two ways:

- **Primal representation** — the model is expressed as a weight vector **$w$** in the $p$-dimensional feature space. The computational cost grows with the number of features $p$ (e.g. number of voxels).
- **Dual representation** — the model is expressed in terms of the $N \times N$ kernel matrix **$K$**. The computational cost depends only on the number of subjects $N$.

| | Primal | Dual (kernel) |
|---|---|---|
| Complexity depends on | number of features $p$ | number of subjects $N$ |
| Efficient when | $p \ll N$ | $p \gg N$ |
| Example | psychometric scores | voxel-level brain imaging |

When $p \gg N$ — which is almost always the case in voxel-level neuroimaging — **the dual (kernel) representation is far more efficient**. Rather than optimising over millions of voxel weights, the model optimises over $N$ dual coefficients, one per subject, using the $N \times N$ kernel matrix **$K$** as input.

---

## Why regularisation matters

With high-dimensional data and few samples, models risk **overfitting** — memorising the training data rather than learning generalisable patterns. Regularisation controls model complexity by penalising large weights.

In the kernel framework, **regularised kernel methods** such as Support Vector Machines (SVM) and Kernel Ridge Regression (KRR) incorporate regularisation naturally through the dual formulation. This means the model:

- Avoids overfitting even when $p \gg N$
- Produces solutions that generalise well to unseen subjects
- Remains computationally tractable regardless of the number of features

---

## Interpretability: recovering voxel weights

A practical advantage of linear kernels is that the **model weights in the original voxel space can be recovered** from the dual solution. This means that even though the model was trained in the kernel (similarity) space, the contribution of each voxel to the prediction can be mapped back — producing spatial weight maps that are interpretable in the context of the neuroimaging data. This distinguishes linear kernels from non-linear kernels, where recovering input-space weights is not straightforward.

---

## Multiple Kernel Learning (MKL)

When data come from **multiple modalities** (e.g. fMRI and sMRI) or **multiple feature groups** (e.g. different brain regions), PRoNTo can compute one kernel per modality or region and **combine them** using Multiple Kernel Learning (MKL).

MKL learns an optimal weighted combination of kernels jointly with the prediction model. The kernel weights β reveal the relative contribution of each kernel for prediction, aiding with interpretation.
