#!/usr/bin/env python
# coding: utf-8

# In[92]:

# code for web scraping trialing
# name, address, latitude, longitude, country, region, city, contact data
import requests
from bs4 import BeautifulSoup
import pandas as pd
import numpy as np
import re

import os
print(os.getcwd())
# In[93]:


URL = "http://trialing-ds.s3-website-eu-west-1.amazonaws.com/"
page = requests.get(URL)
soup = BeautifulSoup(page.content, "html.parser")


# In[94]:


# print(soup.prettify())


# In[101]:


cards = soup.find_all("div", class_ = "card-body shadow p-3")


# In[150]:


# name, address, latitude, longitude, country, region, city, contact data
# we assume here that the first "p" is awlays address and if there is a second one
# we use it as phone info. If length is one we set phone NA

def extract_info(cards):
    hospital_id = []
    name = []
    address = []
    city = []
    region = []
    country = []
    phone = []
    long = []
    lat = []
    
    for card in cards:
        hospital_id.append(card.parent.get("id"))
        name.append(card.find("h5").text)
        all_p = card.find_all("p")
        add_info = all_p[0].text
        add_info = re.split(pattern = 'Address: ', string = add_info)[1]
        add_info = re.split(pattern = "\|", string = add_info)
        address.append(add_info[0].strip())
        city.append(add_info[1].strip())
        city_region_info = re.split(pattern = ",", string = add_info[2])
        region.append(city_region_info[0].strip())
        country.append(city_region_info[1].strip())
        if len(all_p) > 1:
            ph_info = all_p[1].text
            ph_info = re.split(pattern = "Phone: ", string = ph_info)[1]
            phone.append(ph_info)
        else:
            phone.append(np.nan)
        link = card.find("a")
        link_url = link["href"]
        lat_info = re.search('\@(-?[\d\.]*)', link_url).group(1)
        long_info = re.search('\@[-?\d\.]*\,([-?\d\.]*)', link_url).group(1)
        lat.append(lat_info)
        long.append(long_info)
        
    df = pd.DataFrame({'hospital_id': hospital_id,
                  'name': name,
                  'addr': address,
                  'city': city,
                  'region': region,
                  'country': country,
                  'phone': phone,
                  'long': long,
                  'lat': lat})
        
    return(df)
    


# In[151]:


df = extract_info(cards)


# In[152]:


# df.head()


# In[153]:


# df.tail()


# In[154]:


df.to_csv('./data/hospital_web.csv', index=False, encoding='utf-8')

print("success")
# In[155]:


# len(cards)


# In[ ]:




