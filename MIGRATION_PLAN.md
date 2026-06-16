# PRoNTo Website → GitHub Migration Plan

Repository: **https://github.com/MLNL/PRoNTo_public**

This document tracks what has been migrated from the UCL website and what still needs to be done before the repository goes public.

---

## ✅ Completed (this scaffold)

| Website Page | GitHub File | Status |
|---|---|---|
| Introduction / Homepage | `README.md` | ✅ Done |
| How to Cite | `docs/citation.md` | ✅ Done |
| FAQ | `docs/faq.md` | ✅ Done |
| Credits | `docs/credits.md` | ✅ Done |
| History | `docs/history.md` | ✅ Done |
| Datasets | `docs/datasets.md` | ✅ Done |
| Courses & Slides | `docs/courses.md` | ✅ Done |
| Documentation index | `docs/manual.md` | ✅ Done |
| Mailing list / Support | `docs/mailing-list.md` | ✅ Done |
| Release history | `CHANGELOG.md` | ✅ Done |
| Contribution guide | `CONTRIBUTING.md` | ✅ Done |
| MATLAB `.gitignore` | `.gitignore` | ✅ Done |
| Bug report template | `.github/ISSUE_TEMPLATE_bug.md` | ✅ Done |
| Feature request template | `.github/ISSUE_TEMPLATE_feature.md` | ✅ Done |

---

## 🔲 Still To Do — Manual Action Required

### 1. Add the MATLAB source code
Copy the PRoNTo MATLAB source code from your existing repository into the root of this repository. Recommended top-level layout:

```
PRoNTo_public/
├── prt.m                  # Entry point
├── prt_*.m                # Core toolbox functions
├── machines/              # ML model implementations
├── utils/                 # Utility functions
├── batch/                 # Batch processing scripts
├── manual/
│   └── prt_manual.pdf     # Manual distributed alongside code
└── demo_data/             # Optional: small demo data
```

### 2. Add the manual PDF
Place `prt_manual.pdf` in `manual/prt_manual.pdf` (it is already distributed with the software).
The documentation index at `docs/manual.md` links to the PDF — update that link once placed.

### 3. Add a LICENSE file
The toolbox is distributed under GNU GPL v2. Create a `LICENSE` file in the repo root:

```bash
curl https://www.gnu.org/licenses/old-licenses/gpl-2.0.txt -o LICENSE
```

### 4. Migrate dataset files (optional)
The benchmark datasets are currently hosted on the UCL server. Options:
- **Keep UCL links** — simpler, but fragile if the UCL server goes offline.
- **Upload to Zenodo or OSF** — recommended for long-term stability; update links in `docs/datasets.md`.
- **Git LFS** — use [Git LFS](https://git-lfs.github.com/) if hosting binary files directly on GitHub.

### 5. Migrate course slides (optional)
The 2017 and 2018 PDF slides are currently linked from the UCL server. To make the repo self-contained, download the PDFs and commit them to `docs/course_slides/2017/` and `docs/course_slides/2018/`, then update links in `docs/courses.md`.

### 6. Set up GitHub Releases
For each version of the toolbox, create a tagged release so users can download the software directly from GitHub (replacing the old form-based download):

```bash
git tag -a v3.0.0 -m "PRoNTo v3.0.0 beta"
git push origin v3.0.0
```

Then go to **https://github.com/MLNL/PRoNTo_public/releases**, click *Draft a new release*, select the tag, and attach the `.zip` archive of the source.

### 7. Enable GitHub Discussions (optional)
To replace the old mailing list with a modern community forum:
1. Go to **Settings → Features** in the repository.
2. Enable **Discussions**.
3. Update `docs/mailing-list.md` and `README.md` to point users to the Discussions tab.

### 8. Set up GitHub Pages (optional)
To serve a public-facing website directly from this repository:
1. Go to **Settings → Pages**.
2. Set the source to the `main` branch, `/docs` folder.
3. The Markdown files in `docs/` will render automatically; optionally add a Jekyll theme for styling.

### 9. Update the UCL website
Once the GitHub repository is live and public, add a prominent link on the old UCL PRoNTo page (http://www.mlnl.cs.ucl.ac.uk/pronto/) pointing users to:
**https://github.com/MLNL/PRoNTo_public**

---

## ✅ Checklist Before Going Public

- [ ] MATLAB source code added
- [ ] `LICENSE` file present (GPL v2)
- [ ] `manual/prt_manual.pdf` present
- [ ] All internal links verified
- [ ] At least one tagged Release created (v3.0.0)
- [ ] GitHub Discussions enabled (optional)
- [ ] GitHub Pages configured (optional)
- [ ] UCL website updated with link to https://github.com/MLNL/PRoNTo_public
