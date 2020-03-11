library(tidyverse)
library(cowplot)

df <- tibble(timestamp = readLines("dates.txt"), unbottled = readLines("unbottled_count.txt"), total = readLines("file_count.txt")) %>% mutate_all(as.numeric) %>% mutate(bottled = total - unbottled, date = as.Date(as.POSIXct(timestamp, origin = "1970-01-01"))) %>% filter(bottled > 0)

df2 <- gather(df, "key", "value", bottled, total)

df3 <- df %>% mutate(pct = bottled / total)

ggplot(df2, aes(date, value, lty = key)) + geom_line() + ylab("Count") + theme_cowplot() + theme(legend.position = "none")

ggplot(df3, aes(date, pct)) + geom_area() + scale_y_continuous("Bottled", labels = scales::percent, limits = c(0, 0.75), expand = c(0, 0)) + theme_cowplot() + theme(axis.title.y = element_text(angle = 0, vjust = 0.5))
