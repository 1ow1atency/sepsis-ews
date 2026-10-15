# CLAUDE.md

## Project
ICU sepsis early-warning system on the PhysioNet/CinC Challenge 2019 data. Train on one hospital (set A or B), test on the other.

## Hardware
- MacBook Air, Apple Silicon, 8 GB RAM.
- Use float32, load data in compact formats, avoid copying large DataFrames.
- GPU training, if ever needed, happens on Colab T4.

## Data splitting and leakage
- Split by PATIENT, never by row. No patient may appear in both train and test.
- Features must be causal: forward-fill only, no back-fill, rolling windows look backwards only.

## Evaluation protocol
- Lock the data split and final settings BEFORE touching test data, and run the test set once.
- Choose settings (including the alert threshold) on a validation split only, then freeze them for the other hospital.
- Do not tune after seeing test results. Anything changed after seeing them is labelled "post-hoc".
- Always compare against a simple baseline. Write predictions down before running an experiment.

## Reporting
- Report AUROC, AUPRC and the official challenge utility score. Never report accuracy.
- Report counts and bootstrap confidence intervals, not only percentages.
- Say plainly when a sample is small or a result is a tie or null.
- When summarizing results, report only what was measured. Do not overstate. If something failed or was skipped, say so.

## Engineering
- Every module gets a pytest test.
- Keep each stage in its own commit with a clear message.
- Never put secrets in git. Keys go in a gitignored .env.
