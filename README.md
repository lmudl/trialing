# Trialing - Data Science Challenge

This is the repository for my trialing assignment solution

## Overview and Summary
In this assignment the challenge is to web scrape the data from the trialing website.  
http://trialing-df.s3-website-eu-west-1.amazonaws.com/  
and for each hospital obtain the following information:   
**id**, **name**, **address**, **lat**, **long**, **country**, **region**, **city**, **contact data**.  
We scraped the data using *Beautifulsoup* and saved it to data/hospital_web.csv.
Rows wih duplicated hospital_id were merged and their combined information was stored (for the phone
variable).
Some hospitals were missing the region information but for other hospitals in the same city,
the region was giving. We therefore matched the regions with the cities when region was missing
(see code/R/eda-trialing.csv).    
After completing the data this way, in the next step we match the hospitals with a dataset that 
contains clinical trials and the hospital_id where the trial was done (hospital_trial.csv). 
Before we do so, we remove duplicated rows (hospital_id and trial_id).
We combine the general hospital information with the trial data and create a plot to show the number of trials done in each region.  
The barplot can be found at results/barplot.pdf.

## Folder Structure

### code

This folder contains all the code to replicate the results.

*python/web-scrape.py*:  
Code for scraping the hospital data from the trialing website  

*jupyter-notebooks/web-scrape-trialing.py*  
Contains the same code as web-scrape.py but in a jupyter notebook  

*R/eda-trialing.r*  
With this code we fill in the missing region information, merge
hospital_web and hospital_trials and create the barplot.

## data

Contains the original data and filled data set.  

*hospital_web*: Data scraped from trialing

*hospital_trials*: Clinical trials and their hospital id  

*hospital_filled:* Data from hospital_web with region filled in  

## results

Contains the final bar plot  

## Replicate

Download the repository with all the data.  
If you want to check the data is created correctly you can  
delete hospital_web and hospital_filled and run the code.  

0. Set trialing as wd
1. Run web-scrape.py
2. Check if hospital_web was created successfully  
3. Run eda-trialing.r to fill in the region information, create hospital_filled and the barplot  
4. Check if the barplot was created in the results folder  

## Outlook

We can imagine other plots to visualize the region-trial distribution, for example
a Spain map with each region coloured according to their trial count.
