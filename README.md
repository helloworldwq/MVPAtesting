Quantifying spatial pattern similarity in multivariate analysis using functional anisotropy
==============
Overview 
--------------
This code will allow you to rerun the analysis described in the [paper] (https://arxiv.org/abs/1605.03482)

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
- Visualizations for paper were made using Brain Voyager, but code can also save results in .nii format
- Raw activation maps from the paper can be found on [Neurovault](http://neurovault.org/collections/978/) . 

Working Example
--------------
A a simple example is genearted on the fly so that you can see how the core functions (Multi-T and FuA)
operate and understand the difference between directional and non-directional analysis. 
- The .m function is called `simple_example.m`
- You can see a published version of the code [here] (https://rawgit.com/roeegilron/Multi-TandFuA/master/html/simple_example.html "sample example"). 

Multi-T and FuA in additional languages: 
--------------
The core functions we developed were also poreted to work with:
- Python
- R 
See [here] (https://github.com/roeegilron/Multi-TandFuA/tree/master/python_and_R). 



