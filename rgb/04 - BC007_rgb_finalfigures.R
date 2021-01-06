#use library function to call the packages
library(tidyverse)
library(readxl)
library(broom)

#set wd
setwd("your_path/rgb") # use your own path

#import data
df10 = read_csv("bc007_rgb_curated.csv")

#relevel genotypes
df10$genotype = factor(df10$genotype, levels = c("Col-0", "cyp", "lacs"))

#Rename clusters
df10$cluster = factor(df10$cluster, levels = c("Healthy", "Chlorotic", "Necrotic"))

#explore data
pal = c("#228b22", "#e6e600", "#808080") #color palette

pstack =
  df10 %>%
  ggplot(aes(x = hpi, y = size, fill = cluster)) +
  scale_fill_manual(values = pal)+
  scale_x_continuous(breaks = c(0, 24, 48, 72, 96))+
  stat_summary(fun.y = mean, geom = "area", position = "fill")+
  facet_wrap(~genotype)+
  theme_bw()+
  theme(panel.grid.major = element_blank(),
        panel.grid.minor = element_blank())+
  labs(x='Hours post infection', y='Symptom proportion')

pcourse =
  df10 %>%
  ggplot(aes(x = hpi, y = size, fill = genotype, color = genotype)) +
  scale_x_continuous(breaks = c(0, 24, 48, 72, 96))+
  geom_jitter(width = 0.1, alpha = .5)+
  stat_summary(fun.y = mean, geom = "line")+
  stat_summary(fun.data = mean_se, geom = "pointrange", shape = 21, color = "black")+
  facet_wrap(~cluster)+
  theme_bw()+
  theme(panel.grid.major = element_blank(),
        panel.grid.minor = element_blank())+
  labs(x='Hours post infection', y='Symptom proportion')

#Export plots
cairo_pdf('rgb_stack.pdf', width = 6.5, height = 2.5)
pstack
dev.off()

cairo_pdf('rgb_course.pdf', width = 6.5, height = 2.5)
pcourse
dev.off()

