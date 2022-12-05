# code for web scraping trialing
# name, address, latitude, longitude, country, region, city, contact data
import requests
from bs4 import BeautifulSoup
import pandas as pd
import numpy as np
import re


URL = "http://trialing-ds.s3-website-eu-west-1.amazonaws.com/"
page = requests.get(URL)
soup = BeautifulSoup(page.content, "html.parser")


print(soup.prettify())

cards = soup.find_all("div", class_ = "card-body shadow p-3")

# name, address, latitude, longitude, country, region, city, contact data

# name, address, latitude, longitude, country, region, city, contact data

def extract_info(cards):
    name = []
    address = []
    city = []
    region = []
    country = []
    phone = []
    long = []
    lat = []
    for card in cards:
        name.append(card.find("h5").text)
        all_p = card.find_all("p")
        add_info = all_p[0].text
        add_info = re.split(pattern = 'Address: ', string = add_info)[1]
        add_info = re.split(pattern = "\|", string = add_info)
        address.append(add_info[0])
        city.append(add_info[1])
        city_region_info = re.split(pattern = ",", string = add_info[2])
        region.append(city_region_info[0])
        country.append(city_region_info[1])
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
        
    df = pd.DataFrame({'name': name,
                  'addr': address,
                  'city': city,
                  'region': region,
                  'country': country,
                  'phone': phone,
                  'long': long,
                  'lat': lat})
    return(df)
    


df = extract_info(cards)

df

df.to_csv('trialing-hospitals.csv', index=False, encoding='utf-8')

len(cards)
