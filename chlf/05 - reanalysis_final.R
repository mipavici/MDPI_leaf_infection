
# Load libraries ----------------------------------------------------------

#use library function to call the packages
library(tidyverse)
library(readxl)
library(mgcv)
library(broom)

# Import data -------------------------------------------------------------

#set wd
setwd("yourpath/qym_results")

#Import file names from working directory
temp=list.files(pattern = "*.csv")

#Using file names, import all csv files and save them as objects with names iqual to file names
datalist=lapply(setNames(temp,make.names(gsub("*.csv$","",temp))),read.csv)

#Now we have a list of 180 objects with data for one leaf per round.
#Bind all the objects in the list in one big data frame and filter all pixel values below 0.
#.id creates an extra column with the object name.
#In our case this create a column called "id" with file names.
#File names contain info about exp, round, tray and position.
df.qym = bind_rows(datalist, .id = "id")

#rename coluumns
names(df.qym)[names(df.qym)=="Value"] <- "qym"


# plot point to verify a correct import -----------------------------------

df.qym %>%
  filter(str_detect(id, 'X83.4.BC007.01')) %>%
  filter(qym > -100) %>%
  mutate(qym = ifelse(qym < 0,0,qym)) %>%
  ggplot(aes(x=X, y=-Y, color = qym)) +
  geom_point()


# Data wrangling ----------------------------------------------------------

#Separate file names into individual columns with a more tidy information and sae it as df2
df2 = separate(df.qym,id,c("exp","round", "trayid", "tray", "cam", "picname", "parameter", "pos"), sep = "\\.")%>%
  dplyr::select(-6,-7,-9,-10) #remove columns with useless data.

#take a look to df2
head(df2)

#the column round was imported as text coerce it to numeric
df2$round = as.numeric(df2$round)
df2$tray = as.numeric(df2$tray)

df2$pos = gsub("^tif_", "", df2$pos)

head(df2)

#Import file names from working directory
setwd("yourpath/chlf/")
lines_info = read_xlsx("line_names2.xlsx")

lines_info$tray_no = as.numeric(lines_info$tray_no)

#Bind genotype and plant id to df2
df4 = df2 %>%
  left_join(lines_info, by = c("tray" = "tray_no",  "pos" = "position", "trayid" = "exp_name"))

head(df4)

#Convert rounds to hpi
df5 = df4 %>%
  mutate(hpi = ifelse(round == 1, 0,
                      ifelse(round == 2, 24,
                             ifelse(round == 3, 48,
                                    ifelse(round == 4, 72, 96)))))
# remove background pixels
df6 = df5 %>%
  filter(qym != -100)

# set minimum quantum yield value to 0. 
df7 = df6 %>%
  mutate_at(.vars = vars(qym), .funs = list(~ifelse(. < 0, 0, .)))

head(df7)


# Density plot figure 4 ---------------------------------------------------

#Final density plot for figure 4
density = df7 %>%
  filter(hpi == 72) %>%
  ggplot(aes(x = qym, fill = genotype))+
  geom_density(alpha = .5)+
  geom_vline(xintercept = 0.75, linetype = 'dashed')+
  theme_bw()+
  theme(legend.position = c(0.15, 0.8),
        legend.background = element_rect(fill='transparent'))+
  labs(y = 'Density', x = expression('F'['v']/'F'['m']), fill = '')

#export plot
cairo_pdf('density.pdf', width = 3.5, height = 3)
density
dev.off()


# Create final dataframe --------------------------------------------------

#Using the arbitrary threshold of 0.75 we classified the pixels as symptomatic (1)
# or not symptomatic (0)

#add symptomatic (infected) column
df9 = df7 %>%
  mutate(infected = ifelse(qym <= 0.75, 1, 0))%>%
  filter(qym > -10)

tibble(df7)
tibble(df9)

# create a summarized data frame with two new columns size and severity
# size is the count of symptomatic pixels sum(infected)
# norm is the size normalized by the toal leaf size
# severity is the average of all qym pixel values per leaf
# save the results as ds for disease
ds1 = df9 %>%
  group_by(exp, hpi, tray, pos, genotype, leaf_id)%>%
  summarise(size = sum(infected), tot_size = n(), severity = mean(qym))%>%
  mutate(norm = size/tot_size)%>%
  ungroup()

#relevel genotypes
ds1$genotype = factor(ds1$genotype, levels = c("Col-0", "cyp", "lacs"))

# Check potential correlation with leaf total size ------------------------

ds1 %>%
  filter(hpi == 48)%>%
  ggplot(aes(x = tot_size, y = size))+
  geom_point()+
  geom_smooth(color = "red", method = "lm")+
  facet_wrap(~genotype)

ds1 %>%
  filter(hpi == 96)%>%
  ggplot(aes(x = tot_size, y = size))+
  geom_point()+
  geom_smooth(color = "red", method = "lm")+
  facet_wrap(~genotype)

###some have 


# disease progression plots figure 4 --------------------------------------
size = ds1 %>%
  ggplot(aes(x = hpi, y = size, color = genotype, fill = genotype, group = genotype))+
  scale_x_continuous(breaks = c(0, 24, 48, 72, 96))+
  geom_jitter(width = .5, alpha = .5)+
  stat_summary(fun.y = mean, geom = 'line')+
  stat_summary(fun.data = mean_se, geom = 'errorbar', color = 'black', width = .5)+
  stat_summary(fun.y = mean, geom = 'point', shape = 21, color = 'black', size = 2)+
  theme_bw()+
  theme(legend.position = c(0.15, 0.8),
        legend.background = element_rect(fill='transparent'),
        legend.key = element_rect(colour = NA, fill = NA))+
  labs(x = 'Hours post infection', y = 'Symptomatic pixel count', fill = '', color = '')

severity = ds1 %>%
  ggplot(aes(x = hpi, y = severity, color = genotype, fill = genotype, group = genotype))+
  scale_x_continuous(breaks = c(0, 24, 48, 72, 96))+
  geom_jitter(width = .5, alpha = .5)+
  stat_summary(fun.y = mean, geom = 'line')+
  stat_summary(fun.data = mean_se, geom = 'errorbar', color = 'black', width = .5)+
  stat_summary(fun.y = mean, geom = 'point', shape = 21, color = 'black', size = 2)+
  theme_bw()+
  theme(legend.position = c(0.15, 0.2),
        legend.background = element_rect(fill='transparent'),
        legend.key = element_rect(colour = NA, fill = NA))+
  labs(x = 'Hours post infection', y = expression('F'['v']/'F'['m']), fill = '', color = '')

#export plot
cairo_pdf('size.pdf', width = 3.5, height = 3)
size
dev.off()

cairo_pdf('severity.pdf', width = 3.5, height = 3)
severity
dev.off()


# Normality plots ---------------------------------------------------------

ds1 %>%
  ggplot(aes(sample = severity, color = exp))+
  stat_qq() + stat_qq_line()+
  facet_wrap(genotype~hpi, ncol = 5, scales = "free_y")

ds1 %>%
  ggplot(aes(sample = size))+
  stat_qq() + stat_qq_line()+
  facet_wrap(genotype~hpi, ncol = 5, scales = "free_y")


# Fit gam models to size ----------------------------------------------------------

#model symptomatic size with gams

#Convert to factor
ds1$leaf_id = factor(ds1$leaf_id)
ds1$exp = factor(ds1$exp)

#fit model
m0 = gam(size ~ s(hpi, k = 4) + s(hpi, leaf_id, bs = "re"), data = ds1, family = poisson(link = "log"))
m1 = gam(size ~ s(hpi, by = genotype, k = 4) + s(hpi, leaf_id, bs = "re") + genotype, data = ds1, family = poisson(link = "log"))

# extract predicted values ------------------------------------------------

# Create values to predict
newdata = ds1 %>% 
  select(hpi, genotype, leaf_id) %>%
  filter(hpi == 0) %>%
  select(-hpi) %>% 
  slice(rep(row_number(), 31)) %>%
  mutate(hpi = rep(seq(0,96,3.2), each = 36))

#Predict values
prd = predict.gam(m1, newdata = newdata, se.fit = T,  exclude = "s(hpi, leaf_id)", type = "response")

# add predicted and se values to dataframe
prd2 = newdata

prd2$size_prd = prd$fit
prd2$se = prd$se.fit

# add confidence intervals
prd2 = prd2 %>%
  mutate(up = size_prd + se*1.96, low = size_prd - se*1.96)

# average all leaves per genotype per hpi
prd3 = prd2 %>%
  group_by(hpi, genotype) %>%
  summarize(size = mean(size_prd), se = mean(se)) %>%
  mutate(up = size + se*1.96, low = size - se*1.96) %>%
  arrange(genotype)

# put Col-0 as first level
prd3$genotype = relevel(prd3$genotype, "Col-0")

# Final plot --------------------------------------------------------------

#final plot
ps1 = prd3 %>%
  ggplot(aes_string("hpi", "size", ymin = "low", ymax = "up", color = "genotype", fill = "genotype"))+
  scale_x_continuous(breaks = c(0,24,48,72,96))+
  geom_line(size = 2)+
  geom_ribbon(alpha = 0.3, color = NA)+
  theme_bw()+
  labs(y = "Symptomatic pixel count", x = "Hours post infection")+
  theme(legend.position=c(0.15, 0.75),legend.title=element_text(size=14),
        legend.background = element_blank(),
        legend.box.background = element_blank())

#export plot
cairo_pdf('size_model.pdf', width = 4, height = 3.5)
ps1
dev.off()


# Check residuals ---------------------------------------------------------

ds1.r = ds1
ds1.r$fit = fitted(m1)
ds1.r$res = resid(m1)

ds1.r %>%
  ggplot(aes(hpi, res))+
  geom_point()+
  stat_smooth(method = "gam", formula = y ~ s(x, k = 3)) +
  facet_wrap(~genotype)


# programming to calculate individual lines AIC ------------------

ds1$leaf_id = factor(ds1$leaf_id) #convert leaf_id as factor
output = as_tibble(setNames(data.frame(matrix(ncol = 4, nrow = 0)), c("geno", "aic1", "aic2", "aic_diff"))) #create an empty output file

#function for aic
modf = function(i) {
  z = ds1 %>%
    filter(genotype == "Col-0" | genotype == i) %>%
    droplevels()
  
  m1 = gam(size ~ s(hpi, k = 4) + s(hpi, leaf_id, bs = "re"), data = z, family = poisson(link = "log"))
  m2 = gam(size ~ s(hpi, by = genotype, k = 4) + s(hpi, leaf_id, bs = "re") + genotype, data = z, family = poisson(link = "log"))
  
  aic = c(AIC(m1), AIC(m2))
  
  output <<- bind_rows(output, tibble(geno = i, aic1 = AIC(m1), aic2 = AIC(m2), 
                                      aic_diff = min(aic) - max(aic)))
}

#create a genotype list
gen = as.character(unique(ds1$genotype)[-1])

#get p values
map(gen, modf)

setwd("yourpath/chlf")
write.csv(output, "size_stats_aic.csv")


# individual size predicted plots ------------------------------------------

#All plots
genelist = unique(ds1$genotype)[-1]

plotlist = 
  map(genelist, function(i) { 
    prd3 %>%
      filter(genotype == "Col-0" | genotype == i ) %>%
      ggplot(aes_string("hpi", "size", ymin = "low", ymax = "up", color = "genotype", fill = "genotype"))+
      scale_x_continuous(breaks = c(0,24,48,72,96))+
      scale_color_manual("Genotype", values = c("darkturquoise", "deeppink2"))+
      scale_fill_manual("Genotype", values = c("darkturquoise", "deeppink2"))+
      geom_line(size = 2)+
      geom_ribbon(alpha = 0.3, color = NA)+
      theme_bw()+
      labs(y = "Symptomatic pixel count", x = "Hours post infection")
  })

require(gridExtra)
do.call("grid.arrange", args = c(plotlist, ncol = 2))


# Fit gam models to severity ----------------------------------------------

# Add a very small values to allow beta models handle 0s.
ds1 = ds1 %>%
  mutate(sev = ifelse(severity < 0, 0.0001, severity))

#all lines
m0 = gam(sev ~ s(hpi, k = 4) + s(hpi, leaf_id, bs = "re"), data = ds1, family = "betar")
m1 = gam(sev ~ s(hpi, by = genotype, k = 4) + s(hpi, leaf_id, bs = "re") + genotype, data = ds1, family = "betar")


# Extract predicted values ------------------------------------------------

# Create values to be predicted
newdata = ds1 %>% 
  select(hpi, genotype, leaf_id) %>%
  filter(hpi == 0) %>%
  select(-hpi) %>% 
  slice(rep(row_number(), 31)) %>%
  mutate(hpi = rep(seq(0,96,3.2), each = 36))

# Predict values
prd = predict.gam(m1, newdata = newdata, se.fit = T,  exclude = "s(hpi, leaf_id)", type = "response")

# Add predicted and se values to dataframe
prd2 = newdata

prd2$sev_prd = prd$fit
prd2$se = prd$se.fit

# calculate confidence intervals
prd2 = prd2 %>%
  mutate(up = sev_prd + se*1.96, low = sev_prd - se*1.96)

# average all leaf severity values by genotype by hpi
prd3 = prd2 %>%
  group_by(hpi, genotype) %>%
  summarize(severity = mean(sev_prd), se = mean(se)) %>%
  mutate(up = severity + se*1.96, low = severity - se*1.96) %>%
  arrange(genotype)

# Put Col-0 as first level
prd3$genotype = relevel(prd3$genotype, "Col-0")


# Final plot --------------------------------------------------------------

ps2 = prd3 %>%
  ggplot(aes_string("hpi", "severity", ymin = "low", ymax = "up", color = "genotype", fill = "genotype"))+
  scale_x_continuous(breaks = c(0,24,48,72,96))+
  geom_line(size = 2)+
  geom_ribbon(alpha = 0.3, color = NA)+
  theme_bw()+
  labs(y = expression('F'['v']/'F'['m']), x = "Hours post infection")+
  theme(legend.position=c(0.15, 0.6),legend.title=element_text(size=14),
        legend.background = element_blank(),
        legend.box.background = element_blank())

cairo_pdf('severity_model.pdf', width = 4, height = 3.5)
ps2
dev.off()


# Check residuals ---------------------------------------------------------

### check residuals
ds1.r = ds1
ds1.r$fit = fitted(m1)
ds1.r$res = resid(m1)

ds1.r %>%
  ggplot(aes(hpi, res))+
  geom_point()+
  stat_smooth(method = "gam", formula = y ~ s(x, k = 3)) +
  facet_wrap(~genotype)


# programming to calculate individual lines AIC ---------------------------

ds1$leaf_id = factor(ds1$leaf_id) #convert leaf_id as factor
output = as_tibble(setNames(data.frame(matrix(ncol = 4, nrow = 0)), c("geno", "aic1", "aic2", "aic_diff"))) #create an empty output file

#function for aic
modf = function(i) {
  z = ds1 %>%
    filter(genotype == "Col-0" | genotype == i) %>%
    droplevels()
  
  m1 = gam(sev ~ s(hpi, k = 4) + s(hpi, leaf_id, bs = "re"), data = z, family = "betar")
  m2 = gam(sev ~ s(hpi, by = genotype, k = 4) + s(hpi, leaf_id, bs = "re") + genotype, data = z, family = "betar")
  
  aic = c(AIC(m1), AIC(m2))
  
  output <<- bind_rows(output, tibble(geno = i, aic1 = AIC(m1), aic2 = AIC(m2), 
                                      aic_diff = (min(aic) - max(aic))))
}

#create a genotype list
gen = as.character(unique(ds1$genotype)[-1])

#get p values
map(gen, modf)

setwd("yourpath")
write.csv(output, "severity_stats_aic.csv")


# plot individual lines ---------------------------------------------------

#All plots
require(gridExtra)
genelist = unique(ds1$genotype)[-1]

plotlist = 
  map(genelist, function(i) { 
    prd3 %>%
      filter(genotype == "Col-0" | genotype == i ) %>%
      ggplot(aes_string("hpi", "severity", ymin = "low", ymax = "up", color = "genotype", fill = "genotype"))+
      scale_x_continuous(breaks = c(0,24,48,72,96))+
      scale_color_manual("Genotype", values = c("darkturquoise", "deeppink2"))+
      scale_fill_manual("Genotype", values = c("darkturquoise", "deeppink2"))+
      geom_line(size = 2)+
      geom_ribbon(alpha = 0.3, color = NA)+
      theme_bw()+
      labs(y = "Severity (Fv/Fm)", x = "Hours post infection")
  })

do.call("grid.arrange", args = c(plotlist, ncol = 2))
