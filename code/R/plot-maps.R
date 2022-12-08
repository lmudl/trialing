# install.packages("mapSpain")
library(mapSpain)
library(ggplot2)

df <- read.csv2("data/hospital_and_trial.csv", sep = ",", na.strings = c("", "NA"))

country <- esp_get_country()
lines <- esp_get_can_box()

codelist <- mapSpain::esp_codelist

# we change the names in our region variable to match
# the ccaa.shortname.es variable
df$ccaa.shortname.es <- df$region
df %>% mutate(ccaa.shortname.es = case_when(
  ccaa.shortname.es == "Castilla - La Mancha" ~ "Castilla-La Mancha",
  ccaa.shortname.es == "Comunidad de Madrid" ~ "Madrid",
  ccaa.shortname.es == "Comunitat Valenciana" ~ "Comunidad Valenciana",
  TRUE ~ ccaa.shortname.es
)) -> df

# Are all ccca shortnames in our data also in the original ones?
# TRUE
all(df$ccaa.shortname.es %>% unique() %>% sort() == b %>% unique() %>% sort())

# we load plot data
CCAA_sf <- esp_get_ccaa()
Can <- esp_get_can_box()

# count trials per region, and save also percentages
df %>% count(ccaa.shortname.es) %>% mutate(prop = round(prop.table(n),3),
                                           perc = paste0(100*prop, "%")) -> count_df

# combine plot and trial data
plot_df <- left_join(CCAA_sf, count_df, by = "ccaa.shortname.es") 

# plot map with absolute values
abs_plot <- ggplot(plot_df) +
  geom_sf(aes(fill = n),
          color = "grey70",
          linewidth = .3) +
  geom_sf(data = Can, color = "grey70") +
  geom_sf_label(aes(label = n),
                fill = "white", alpha = 0.5,
                size = 3, label.size = 0) +
  geom_sf_label(aes(label = ccaa.shortname.es),
                fill = "white", alpha = 0.5,
                size = 3, label.size = 0,
                nudge_x = 0.0,
                nudge_y = 0.25) +
  scale_fill_gradientn(
    colors = hcl.colors(10, "Blues", rev = TRUE),
    n.breaks = 10,
    # labels = function(x) {
    #   sprintf("%1.1f%%", 100*x)
    # },
    guide = guide_legend(title = "N")
  ) +
  theme_void() +
  theme(legend.position = c(0.1, 0.6))

# save plot with absolute values
ggsave("results/mapplot_abs.pdf", width = 8, height = 8)

# plot map with percentages
perc_plot<- ggplot(plot_df) +
  geom_sf(aes(fill = prop),
          color = "grey70",
          linewidth = .3) +
  geom_sf(data = Can, color = "grey70") +
  geom_sf_label(aes(label = perc),
                fill = "white", alpha = 0.5,
                size = 3, label.size = 0) +
  geom_sf_label(aes(label = ccaa.shortname.es),
                fill = "white", alpha = 0.5,
                size = 3, label.size = 0,
                nudge_x = 0.0,
                nudge_y = 0.25) +
  scale_fill_gradientn(
    colors = hcl.colors(10, "Blues", rev = TRUE),
     n.breaks = 10,
    labels = function(x) {
      sprintf("%1.1f%%", 100*x)
    },
    guide = guide_legend(title = "Perc.")
  ) +
  theme_void() +
  theme(legend.position = c(0.1, 0.6))

perc_plot
# save plot with percentages
ggsave("results/mapplot_perc.pdf", width = 8, height = 8)


perc_nonames <- ggplot(plot_df) +
  geom_sf(aes(fill = prop),
          color = "grey70",
          linewidth = .3) +
  geom_sf(data = Can, color = "grey70") +
  geom_sf_label(aes(label = perc),
                fill = "white", alpha = 0.5,
                size = 3, label.size = 0) +
  scale_fill_gradientn(
    colors = hcl.colors(10, "Blues", rev = TRUE),
    n.breaks = 10,
    labels = function(x) {
      sprintf("%1.1f%%", 100*x)
    },
    guide = guide_legend(title = "Perc.")
  ) +
  theme_void() +
  theme(legend.position = c(0.1, 0.6))

ggsave("results/mapplot_perc_nonames.pdf", width = 8, height = 8)


