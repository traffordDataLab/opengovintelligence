# Number of individual browser connections #

# Source: https://docs.rstudio.com/shinyapps.io/metrics.html

# Usage metrics show that the app has been accessed 232 times 
# between November 2018 and January 2019.

library(rsconnect) ; library(tidyverse) ; library(lubridate)

metrics <- showMetrics(account = "trafforddatalab",
                  server = "shinyapps.io",
                  appName = "scan", 
                  metricSeries = "container_status",
                  metricNames = c("connect_count", "connect_procs"),
                  from = as.numeric(as.POSIXct("2018-11-01 0:00:00")),
                  until = as.numeric(as.POSIXct("2019-02-01 0:00:00")),
                  interval = "1m") 

connections <- metrics %>% 
  mutate(date = as_datetime(timestamp)) %>% 
  select(-timestamp) %>% 
  arrange(date) %>% 
  mutate(n_count = cumsum(connect_count),
         n_procs = cumsum(connect_procs),
         new_connect = 
           case_when(connect_count > lag(connect_count,1) ~ connect_count-lag(connect_count,1), TRUE ~ 0),
         n_connect = cumsum(new_connect)) %>% 
  filter(n_count > 0) %>%  
  select(n_connect, date)

max(connections$n_connect)

ggplot(connections) +
  geom_line(aes(x = date, y = n_connect), size = 1, colour = "#2c7fb8") +
  scale_y_continuous(limits = c(0, max(connections$n_connect)), expand = c(0,0)) +
  labs(title = "Cumulative browser connections to Scan app", 
       subtitle = "November 2018 - January 2019",
       x = NULL, y = NULL,
       caption = "Source: shinyapps.io") +
  theme_minimal() +
  theme(panel.grid.major.x = element_blank(),
        panel.grid.minor.x = element_blank(),
        axis.text.y = element_text(hjust = 0))
ggsave("connections.png", dpi = 300, scale = 1)
