library(tidyverse)
library(cowplot)
library(svglite)
library(lubridate)

df <- tibble(timestamp = readLines("dates.txt"), unbottled = readLines("unbottled_count.txt"), total = readLines("file_count.txt")) %>% mutate_all(as.numeric) %>% mutate(bottled = total - unbottled, date = as.Date(as.POSIXct(timestamp, origin = "1970-01-01")), week = week(date), year = year(date)) %>% filter(bottled > 0)

summed <- df %>% group_by(week, year) %>% summarise(unbottled = mean(unbottled), bottled = mean(bottled), total = mean(total), date = date[1])

df2 <- gather(summed, "key", "value", bottled, total)

df3 <- summed %>% mutate(pct = bottled / total)

p1 <- ggplot(df2, aes(date, value, lty = key)) + geom_line() + labs(x = "Date", y = "Count") + scale_y_continuous(limits = c(0, 5100), expand = c(0, 0)) + theme_cowplot() + theme(legend.position = "none")

p2 <- ggplot(df3, aes(date, pct)) + geom_area(fill = "black") + labs(x = "Date", y = "Bottled") + scale_y_continuous(labels = scales::percent, limits = c(0, 0.75), expand = c(0, 0)) + theme_cowplot()

svglite()
plot_grid(p1, p2, ncol = 1)
dev.off()

write_csv(summed, "stats.csv")
