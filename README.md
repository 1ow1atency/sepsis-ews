# Sepsis EWS

An ICU sepsis early-warning system built on the PhysioNet/Computing in Cardiology Challenge 2019 data, trained on one hospital and tested on the other.

> **Research and education only. Not a medical device. Retrospective results do not demonstrate clinical benefit.**

## Data

- **Source:** PhysioNet, *Early Prediction of Sepsis from Clinical Data: the PhysioNet/Computing in Cardiology Challenge 2019*, version 1.0.0: https://physionet.org/content/challenge-2019/1.0.0/
- **Access:** open access, no login or credentialing required.
- **License:** [Creative Commons Attribution 4.0 International](https://creativecommons.org/licenses/by/4.0/).
- **Not stored in this repo.** `data/` is gitignored. Download it locally with the command below.

Only the two training sets are used: `training_setA` (hospital A) and `training_setB` (hospital B). Each `.psv` file is one patient, one row per ICU hour, 41 pipe-separated columns.

Download command (run from the repo root):

```bash
./scripts/download_data.sh
```

This downloads into `data/training_setA/` and `data/training_setB/`. It is resumable: if interrupted, run it again and finished files are skipped. The file list is read from physionet.org; the files are fetched from PhysioNet's official open S3 mirror (`s3://physionet-open/challenge-2019/1.0.0/`, listed on the dataset page), which is much faster per file. On a laptop, prefix it with `caffeinate -is` to stop the Mac sleeping mid-download.

Downloaded on 2026-10-16: 20,336 files in set A (161 MB) and 20,000 in set B (152 MB), matching the server listings.

The dataset page's own command, which fetches the whole dataset from physionet.org instead, is:

```bash
wget -r -N -c -np https://physionet.org/files/challenge-2019/1.0.0/
```
