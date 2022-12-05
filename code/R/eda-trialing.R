# data analysis
# setwd("trialing-assignment/")
# load the two datasets
library(dplyr)
library(ggplot2)

web <- read.csv2("data/hospital_web.csv", sep = ",", na.strings = c("", "NA"))
dim(web)
head(web)
summary(web)
colnames(web)

sum(duplicated(web$hospital_id))

temp <- web
cols <- c("name", "addr", "city", "region",
            "country")
temp[cols] <- lapply(temp[cols], factor)

summary(temp) # but this was to be expected


# we want to plot regions
# inspect regions
unique(web$region)
no_region <- which(is.na(web$region), arr.ind = TRUE)
city_no_region <- unique(web$city[no_region])

unique(web %>% select(city, region) %>% filter(!is.na(region))) -> lookup
out <- !(city_no_region %in% lookup$city)
inside <- !out
city_no_region[out]
fill_this <- city_no_region[inside]

# get rows with missing region

# some regions have empty string
# we replace it with NA
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

#undebug(fill_region)
web <- fill_region(web)

web$notfillable
# we see that for 4 cities we have to look up the
# region by hand
# osuna is andalucia
# hercual overa almería
# cabra andalusia
# el puerto de santa maria  is andlucia
levels(web$data$region) <-  c(levels(web$dataset$region), "Almería")

id1 <- which(web$dataset$city == web$notfillable[1], arr.ind = TRUE)
web$dataset[id1, "region"] <- "Andalucía"

id2 <- which(web$dataset$city == web$notfillable[2], arr.ind = TRUE)
web$dataset[id2, "region"] <- "Almería"

id3 <- which(web$dataset$city == web$notfillable[3], arr.ind = TRUE)
web$dataset[id3, "region"] <- "Andalucía"

id4 <- which(web$dataset$city == web$notfillable[4], arr.ind = TRUE)
web$dataset[id4, "region"] <- "Andalucía"

write.csv(web$dataset,  "./data/hospital_filled.csv")

# fill with hand Almeria

web <- read.csv2("./data/hospital_filled.csv", sep = ",", na.strings = c(" ", "NA"))
any(is.na(web$region))

trials <- read.csv2("./data/hospital_trials.csv", sep = ";")
dim(trials)
head(trials)



# multiple lines for each ID means one trial is in multiple hospitals?
# multiple lines for each hospital means one hospital had multiple hospitals?
# why are there duplicated lines? 16
sum(duplicated(trials))

web %>% left_join(trials, by = "hospital_id") -> df


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
