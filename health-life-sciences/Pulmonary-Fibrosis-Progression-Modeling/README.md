# Modeling Pulmonary Fibrosis Progression

This repository contains coding examples in both SAS and Python for predicting pulmonary fibrosis progression using anonymized patient data.

The scenario for this demo is as follows: Imagine a patient is diagnosed with pulmonary fibrosis, a disorder with no known cause and no known cure, created by scarring of the lungs. This disease can be even more troubling as outcomes can range from long-term stability to rapid deterioration, but doctors aren’t easily able to tell where an individual may fall on that spectrum. By using machine learning we may be able to aid in this prediction, which could dramatically help both patients and clinicians.

These notebooks aim to predict a patient’s severity of lung function decline based on an initial baseline reading. Our target variable, lung function, is assessed based on output from a spirometer, which measures the forced vital capacity (FVC), i.e. the volume of air exhaled. The results consist of three predictions per patient accompanied by a confidence score for each.


## Prerequisites

- An active SAS Viya Workbench license and environment
- This demo makes use of certain open-source Python packages such as sklearn, all of which are expected to be made available out of the box with a SAS Viya Workbench environment.  In case of a requirement to install a package, install the same from the terminal:

```python
pip install <your_package>
```

## Data

This demo uses an adapted [Open Source Imaging Consortium](https://www.osicild.org/kaggle01.html) data set licensed under [CC BY-SA 4.0](https://creativecommons.org/licenses/by-sa/4.0/legalcode).

The original data set was taken from [this location](https://www.kaggle.com/competitions/osic-pulmonary-fibrosis-progression/data?select=train.csv), and the following changes were made:

- Drop DICOM data for size considerations

NOTE: when downloading the data you will only need [train.csv](https://www.kaggle.com/competitions/osic-pulmonary-fibrosis-progression/data?select=train.csv) (we partition training data as 'test.csv' doesn't include true values to score against). You can also directly download the dataset from the terminal: 

```python
kaggle competitions download osic-pulmonary-fibrosis-progression -f train.csv
```


## Parameters

The Python notebook can be run as-is.

The SAS notebook and SAS code may need minor modifications concerning the path of the input data or formats directory.  Look out for notes starting with **NOTE:**. These are usually for libname locations or input file locations.


## Output

1. Various inline reports showing preprocessing and summary statistics.
2. CSV of predictions and scoring. 

## Execution Order

There is no specified order; the SAS program, SAS notebook, and Python notebook carry out similar tasks independently.


## Contact

- Lleyton Seymour (lleyton.seymour@sas.com)


## Change Log

- Version 1.0.0 (XXJAN2025)
  - Initial release on GitHub
