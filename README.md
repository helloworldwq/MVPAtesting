Quantifying spatial pattern similarity in multivariate analysis using functional anisotropy
==============
Overview 
--------------
This code will allow you to rerun the analysis described in the paper (HTML LINK). 

The basic structure is as follows: 
- Download data from open fMRI 
- Run preprocessing steps on the data 
- Run searchlight analysis 
- Run FuA analysis 

Below you will also see directions that will allows you run standalone versions of: 
- Tsd2008
- Tsd2013 
- The FuA calculation 

Getting the data set
--------------

Downloading the data and directory structure: 
- This code relies on the following data set from [Open-fMRI](https://openfmri.org/dataset/ds000158/ "Data Used For Project").
- Code should auto-download and create structure below (in case you want to adapt code for your own use case):
![Image of Dir Structure](/images/dirstruct.jpg?raw=true "Dir Structure For Project")
- Runing 'MAIN.m' should perform all the analysis that appear in the paper and generate the main Figures. 
- Visualizations for paper were made using Brain Voyager, but code also save results and .nii 
- Raw activation maps from the paper can be found on Neurovault. 

Toy Data Set
--------------
A toy data set is genearted on the fly so that you can see how the core functions (Multi-T and FuA) operate. 
- You can see code for this here [LINK]
- Here are the results of running that code [LINK] 

Multi-T and FuA in additional languages: 
--------------
The core functions we developed were also poreted to work with:
- Python
- R 
See here [LINK]. 



