# data analysis
# setwd("trialing-assignment/")
# load the two datasets
library(dplyr)
library(ggplot2)

# Load the web scraped data
web <- read.csv2("data/hospital_web.csv", sep = ",", na.strings = c("", "NA"))
dim(web)
head(web)
summary(web)
colnames(web)

# get number of duplicates for hospital_id
n_dupl <- sum(duplicated(web$hospital_id))
# get number of rows in web scraped data
n_og <- nrow(web)

# merge rows with same hospital_id combining information on phone for example
web %>%  group_by(hospital_id) %>%
  summarise_all(list(~toString(unique(na.omit(.))))) -> web
# give empty strings NA again
web %>% mutate_all(list(~na_if(., ""))) -> web

# check if there are any duplicates of hospital_id left
any(duplicated(web$hospital_id)) # FALSE
# validate that we have less rows, the number is equal to the number of duplicates
n_post <- nrow(web)
n_og - n_post == n_dupl

# create factor variables and show a summary of the dataset
temp <- web
cols <- c("hospital_id", "name", "addr", "city", "region",
            "country")
temp[cols] <- lapply(temp[cols], factor)

# there are missing values for region
summary(temp)


# we want to plot regions
# inspect regions
unique(web$region)
# in which rows is region missing
no_region <- which(is.na(web$region), arr.ind = TRUE)
# get all cities that have missing regions
city_no_region <- unique(web$city[no_region])
# create a lookup table for all city and region combinations
unique(web %>% select(city, region) %>% filter(!is.na(region))) -> lookup
# which cities that have missing regions are NOT in the lookup table
# these cities have to be checked by hand
out <- !(city_no_region %in% lookup$city)
# all other cities have their region in the lookup table and can be matched
inside <- !out
# display the cities that have to check by hand
city_no_region[out]
# create a vector of cities that can be looked up by a function
fill_this <- city_no_region[inside]

# get rows with missing region
# some regions had empty string
# we replaced it with NA
# now we match the cities without region with cities with regions
# loop over each city, get region for that city
# get all rows that have that city and fill with that region

fill_region <- function(dataset) {
  # create lookup
  unique(dataset %>% select(city, region) %>% filter(!is.na(region))) -> lookup
  # get rows with missing region
  no_region <- which(is.na(dataset$region), arr.ind = TRUE)
  city_no_region <- dataset$city[no_region]
  city_no_region <- unique(city_no_region)
  found <- city_no_region %in% lookup$city
  fillable <- city_no_region[found]
  not_fillable <- city_no_region[!found]
  for(i in fillable) {
    print(i)
    # get correct region
    reg <- lookup$city == i
    reg <- lookup$region[reg]
    # which rows match cit and have NA for region
    this_city <- which(dataset$city == i, arr.ind = TRUE) 
    id <- intersect(this_city, no_region)
    dataset$region[id] <- reg
  }
  return(list(dataset = dataset, notfillable = not_fillable))
}


# undebug(fill_region)
web <- fill_region(web)

web$notfillable
# we see that for 4 cities we have to look up the
# region by hand
# osuna is andalucia
# hercual overa almería
# cabra andalusia
# el puerto de santa maria  is andlucia
levels(web$data$region) <-  c(levels(web$dataset$region), "Andalucía")

id1 <- which(web$dataset$city == web$notfillable[1], arr.ind = TRUE)
web$dataset[id1, "region"] <- "Andalucía"

id2 <- which(web$dataset$city == web$notfillable[2], arr.ind = TRUE)
web$dataset[id2, "region"] <- "Andalucía"

id3 <- which(web$dataset$city == web$notfillable[3], arr.ind = TRUE)
web$dataset[id3, "region"] <- "Andalucía"

id4 <- which(web$dataset$city == web$notfillable[4], arr.ind = TRUE)
web$dataset[id4, "region"] <- "Andalucía"

write.csv(web$dataset,  "./data/hospital_filled.csv")

web <- read.csv2("./data/hospital_filled.csv", sep = ",", na.strings = c(" ", "NA"))
# no row with missing region left
any(is.na(web$region))


trials <- read.csv2("./data/hospital_trials.csv", sep = ";")
dim(trials)
head(trials)



# multiple lines for each ID means one trial is in multiple hospitals?
# multiple lines for each hospital means one hospital had multiple hospitals?
# why are there duplicated lines? 16
sum(duplicated(trials))

# we drop duplicated rows
trials %>% distinct() -> trials

# we combine the two datasets
web %>% inner_join(trials, by = "hospital_id") -> df

# its important to inner join because not all web hospital_ids are in trials
# and not all trials hopspital_ids are in web.
# We only want to see those trial hospital_ids that we have information on
# in web hospital_id.
# Therfore: web inner_join trials on hospital_id
# all(trials$hospital_id %in% web$hospital_id) FALSE
# all(web$hospital_id %in% trials$hospital_id) FALSE
# but
sum(trials$hospital_id %in% web$hospital_id) == nrow(df) # TRUE


barplot <- ggplot(data = df, aes(x=reorder(region,
                                           region,
                                           function(x)-length(x)))) +
  geom_bar(stat = "count", fill = "steelblue") + theme_minimal() +
  ggtitle("Barplot of Clinical Trials per Region") +
  theme(axis.text.x = element_text(angle = 60, hjust =1)) +
  geom_text(stat="count", aes(label =..count..), vjust = -0.5) +
  xlab("Region") + ylab ("Number of trials")
barplot
saveRDS(barplot, "results/barplot.rds")
ggsave("results/barplot.pdf", width = 6, height = 6)

write.csv(df,  "./data/hospital_and_trial.csv")


