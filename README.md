# Human hippocampal codes shift under feedback control during rapid sequence learni

MATLAB code that reproduces every quantitative figure panel in the manuscript.

Corresponding: Seng Bum Michael Yoo and Sameer A. Sheth<br>Inquiry about code: Sangkyu Son (ss.sangkyu.son@gmail.com)

---

## 1. System requirements

### Software dependencies (tested on Linux Mint 20.2)

| Dependency                              | Required            | Version tested | Why it is needed                                                                                                                                                                                      |
| --------------------------------------- | ------------------- | -------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| MATLAB                                  | **R2018b or later** | 9.13 (R2022b)  | Newest functions used are `yline` and `sgtitle` (both R2018b); also `isfile` (R2017b), `fillmissing`/`xticks`/`xticklabels` (R2016b), `yyaxis`/`repelem` (R2015a). Nothing newer than R2018b is used. |
| Statistics and Machine Learning Toolbox | yes                 | 12.4           | `pca`, `glmfit`, `quantile`, `corr`                                                                                                                                                                   |
| Signal Processing Toolbox               | yes                 | 9.1            | `xcorr`, in `subspaceCrosscorrDirect.m`                                                                                                                                                               |

---

## 2. Installation guide

```matlab
cd /path/to/pubcode     % the folder that contains main.m
main                    % adds utils/ and compute/ to the path, then draws every panel
```

`main.m` sets `genDir = pwd`, so run it from the folder that holds it. To run from
elsewhere, edit that one line to the absolute path of the folder.

---

## 3. Demo

### Instructions to run on the packaged data

```matlab
cd /path/to/pubcode
main
```

| functions                   | includes                                                                         |
| --------------------------- | -------------------------------------------------------------------------------- |
| `draw_Figure1G`             | Behavior, learning across repeated trials                                        |
| `draw_Figure2D`             | Graded against sparse coding strength, cell by cell                              |
| `draw_Figure2E`             | Tuning of graded and sparse coding cells, before and after learning              |
| `draw_Figure3C`             | Population trajectory in the first two principal components                      |
| `draw_Figure3DG`            | Population trajectory in the graded coding x reward plane, correct and incorrect |
| `draw_Figure3EF`            | Reward and graded coding subspace around a press, correct and incorrect          |
| `draw_Figure3H`             | Reward against graded coding movement, cell by cell                              |
| `draw_Figure4AB`            | Population trajectory across learning stages, in two principal component bases   |
| `draw_Figure4C`             | Distribution along the graded and the sparse coding subspace                     |
| `draw_Figure4D`             | Subspace position across the four events of a sequence                           |
| `draw_Figure4E`             | Portion of subspace explained variance across learning stages                    |
| `draw_Figure4FG`            | Sensitivity of the two subspaces, and how the two co-vary                        |
| `draw_Figure5DEFG`          | Network behaviour, lesion cost, control cost and efficiency                      |
| `draw_Figure6AB`            | Benefit per control cost when transferring to a new sequence                     |
| `draw_SupplementaryFigure2` | Firing rate of each coding class against the rest of the cells                   |
| `draw_SupplementaryFigure3` | The two subspaces against the principal components, and against each other       |
| `draw_SupplementaryFigure4` | Subspace axes before and after the incorrect-ness regressor is separated out     |
| `draw_SupplementaryFigure5` | Where the population goes after the last event of a sequence                     |

---

## 4. Instructions for use

Every figure function takes a second argument that switches from the packaged
averages to a full recomputation from the raw recording:

```matlab
draw_Figure3C(dataDir)      % packaged example data (default)
draw_Figure3C(dataDir,1)    % recompute from the raw recording in data/raw/
```

The raw recording and the network simulation outputs are **distributed separately**
and are not part of this repository. Without them only the default path above runs.
Place them as follows:

```
data/
├── example/                      packaged averages, ships with this repository
│   ├── Figure1G.mat
│   └── ...                       (26 files, 686 KB)
├── raw/                          distributed separately
│   └── abcd_data_*.mat           the human recording
└── processed/                    created on the first raw-data run
    ├── networkLearning/          distributed separately: per-network simulation outputs
    ├── networkTransfer/          distributed separately: transfer-tier outputs
    ├── networkExtension/         distributed separately: extension-grid outputs
    └── *.mat                     generated caches
```

Each stage of the raw-data path caches its result under `data/processed/`, named after
the function that produces it. Delete a file, or pass the `recompute` flag
(`computeNeuralGLM(dataDir,1)`), to force that stage to recompute. The first raw-data
call builds `neuralData.mat` and the GLM caches, which dominates the total time.

---

## Repository layout

```
pubcode/
├── main.m            entry point: draws every panel in order
├── README.md
├── utils/            figure drawing (draw_*.m) and small shared helpers
├── compute/          recomputation from raw data (compute_*.m, process*.m, ...)
│   └── lib/          numerical helpers (PCA, smoothing, caching, ...)
└── data/
    └── example/      packaged averages, one .mat per panel
```

---
