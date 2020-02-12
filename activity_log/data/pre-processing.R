# Read all activity logs, total and bind

library(tidyverse)

files <- list.files(".", pattern = "*.csv", full.names = TRUE)
log <- map_df(files, read_csv)

summary <- log %>% 
  gather(source, n, -date, -participant) %>% 
  group_by(date, source) %>% 
  summarise(participant = "All participants",
            total = sum(n, na.rm = TRUE)) %>% 
  na_if(0) %>% 
  spread(source, total) %>% 
  select(date, participant, git, document, blog, wiki, meeting, telco, email, 
         slack, asana, twitter)

bind_rows(log, summary) %>%
  write_csv("../activity_log.csv")
