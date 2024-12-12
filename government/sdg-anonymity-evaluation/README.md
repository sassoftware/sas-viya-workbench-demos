# Synthetic Data Privacy Risk Evaluation with Anonymeter

## Introduction to Synthetic Data

Synthetic data is artificially generated data that replicate the statistical properties of real-world datasets while protecting sensitive information. In the era of data-driven decision-making, synthetic data has emerged as a powerful tool to address privacy concerns while maintaining the utility of data for analysis and innovation.

### Why Synthetic Data Matters?
Synthetic data solves the challenge of sharing and analyzing sensitive data in a secure, privacy-preserving manner. By substituting real data with synthetic counterparts, organizations can:

* Enable innovation while adhering to stringent data protection regulations (e.g., GDPR, HIPAA).
* Reduce risks of data breaches and re-identification of individuals.
* Facilitate cross-organization collaborations and open-data initiatives.

## Privacy Risks in Synthetic Data
While synthetic data minimizes privacy risks, it is essential to evaluate and quantify these risks to ensure robust data protection. Three primary types of privacy risks are associated with synthetic data:

### **1. Singling Out**
The ability to isolate an individual record within the synthetic dataset corresponding to a real-world individual in the original dataset. 

*"There is only one person with attributes X, Y, and Z"*

### **2. Linkability**
There is a risk that an attacker can link records between the synthetic dataset and other datasets (e.g., external data sources) to re-identify individuals.

*"Records A and B belong to the same person"*

### **3. Inference**
Definition: The risk that sensitive attributes of an individual can be inferred from synthetic data.

*"A person with attributes X and Y also have Z" (inference)*

## Privacy Risks Evaluation
This workbench demo demonstrates how to utilize the open-source Python library [Anonymeter](https://github.com/statice/anonymeter) to evaluate the different possible privacy risks. It  includes in-depth explanations of the different risks, how the library evaluates the risk, and how to interpret the results.

## Data
We shall be using data from the Adult Census Bureau database, made available here and released under license CC-0. This data was extracted from the 1994 Census Bureau database by Ronny Kohavi and Barry Becker (Data Mining and Visualization, Silicon Graphics).

The notebook contains steps to pull the data.

## Pre-requisites
An Active SAS Viya Workbench license and environment.

Python packages required:

pmlb - used for fetching datasets from the Penn Machine Learning Benchmark.
anonymeter  - Open Source package to evaluate privacy risks of synthetic datasets

Package versions can be found in the requirements.txt file.

Install packages using the following command line command:

```
pip install -r config/requirements.txt
```

## Parameters

### Synthetic Data

This notebook does not generate the synthetic data from the dataset mentioned. It can be generated, using other methods such as this [SDM Notebook](https://github.com/sassoftware/sas-viya-workbench-demos/tree/main/government/census-synthetic-data-generation), or services like SAS DataMaker.

The notebook will contain comments on where to enter the file path to the synthetic data.

## Output
Various Evaluation Metrics and Plots to illustrate the privacy risk of the synthetic data set.

## Contact
Josiah Chua (josiah.chuag@sas.com)

## Change Log
Version 1.0.0 (12DEC2024)
Initial release on GitHub