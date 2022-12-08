# Trialing - Data Science Challenge

This is the repository for my trialing assignment solution

## Overview and Summary
In this assignment the challenge is to web scrape the data from the trialing website: http://trialing-df.s3-website-eu-west-1.amazonaws.com/.  
For each hospital on the website we scrape the following information: **id**, **name**, **address**, **lat**, **long**, **country**, **region**, **city**, **contact data**.  
1. We scraped the data using *Beautifulsoup* and saved it to data/hospital_web.csv.   
2. Rows with duplicated hospital_id were merged and their combined information was stored (for the phone variable).
3. Some hospitals were missing the region information but for other hospitals in the same city,
the region was given. We therefore matched the regions with the cities when region was missing
(see code/R/eda-trialing.R).
4. The second dataset contains a hospital id and a clinical trial id. We remove duplicated rows in this dataset (see code/R/eda-trialing.R)
5. After preprocessing the datasets this way, we merge the hospital and trial information into one dataset (data/hospital_and_trials.csv) and create a plot to show the number of trials done in each region. The bar plot can be found at results/barplot.pdf.
6. Also we plot the number of trials and percentages according to our dataset on a map of Spain and the respective autonomous regions.

<p align="center">
<img src="/results/mapplot_perc.jpg" alt="Employee data" title="Employee Data title" width="50%" height="50%">
<p>


## Folder Structure

### code

This folder contains all the code to replicate the results.

*python/web-scrape.py*:  
Code for scraping the hospital data from the trialing website  

*jupyter-notebooks/web-scrape-trialing.py*  
Contains the same code as web-scrape.py but in a jupyter notebook  

*R/eda-trialing.r*  
With this code we fill in the missing region information, merge
hospital_web and hospital_trials to a final data frame (hospital_and_trials) and create a bar plot.

*R/plot-maps.r*
From the final data frame we plot the absolute values and percentages of clinical trials
in each autonomous region on a map.

## data

Contains the original data and filled data set.  

*hospital_web*: Data scraped from trialing

*hospital_trials*: Clinical trials and their hospital id  

*hospital_filled:* Data from hospital_web with region filled in  

## results

Contains the final bar plot and map plots.

## Replicate

Download the repository with all the data.  
If you want to check the data is created correctly you can  
delete hospital_web and hospital_filled and run the code.  

0. Set trialing as working directory
1. Run web-scrape.py
2. Check if hospital_web was created successfully  
3. Run eda-trialing.r to fill in the region information, create hospital_filled and the bar plot  
4. Check if the bar plot was created in the results folder  

## Outlook

We can imagine other plots to visualize the region-trial distribution, for example
a Spain map with each region colored according to their trial count.

