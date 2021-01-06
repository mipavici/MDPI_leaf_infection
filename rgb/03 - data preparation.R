#use library function to call the packages
library(tidyverse)
library(readxl)
library(broom)

#set wd
setwd("your_path/rgb/results_rgb")

#Import file names from working directory
temp=list.files(pattern = "*.csv")

#Using file names, import all csv files and save them as objects with names equal to file names
datalist=lapply(setNames(temp,make.names(gsub("*.csv$","",temp))),read.csv)

#Now we have a list of xxx objects with data for one leaf per round each.
#Bind all the objects in the list in one big data frame and filter all pixel values below 0.
#.id creates an extra column with the object name.
#In our case this create a column called "id" with file names.
#File names contain info about exp, round, tray and position.
bc007 = bind_rows(datalist, .id = "id")


#Take a look to how the data frame looks like
head(bc007)

#Filter Background pixels (group 3)
bc007 = bc007 %>%
  filter(Value != 3)

#Separate file names into indivudual columns with a more tidy information and save it as df2
df2 = separate(bc007,id,c("exp","round", "trayid", "tray", "cam", "picname", "pos"), sep = "\\.")

#Take a look to the tidied data frame df2
head(df2)

df2 = dplyr::select(df2, -5,-6,-8,-9) #remove columns with useless data.

#Give better column names to df2 and save it as df3
df3 = rename(df2, cluster = Value)

#Take a look to df3
head(df3)

#Fix experiment, round and tray columns
df3 = df3 %>%
    mutate(exp = str_replace(exp, 'WithMask_',''), pos = str_replace(pos, 'tif_','')) %>%
    mutate_at(.vars = vars(exp, round, tray), .funs = list(as.numeric))

head(df3)

#Import file names from working directory
lines_info = read_xlsx("../line_names.xlsx") %>% mutate(tray_no = as.numeric(tray_no))

#Bind genotype and plant id to df3
df4 = df3 %>%
  inner_join(lines_info, by = c("tray" = "tray_no",  "pos" = "position"))

#add hpi
df6 = df4 %>%
  mutate(hpi = ifelse(round == 1, 0,
                      ifelse(round == 2, 24,
                             ifelse(round == 3, 48,
                                    ifelse(round == 4, 72, 96)))))
#calculate symptomatic area (size).
#This is done by counting the number of pixels in each cluster/class
#In this case each row correspond to a pixel, before counting we have to group 
#them by tray, pos, hpi, genotype and cluster values.
df7 = df6 %>%
  group_by(tray, pos, hpi, genotype, cluster) %>%
  summarise(size = n())

#Create a full grid for missing values

# Pixels clusters not present in a given hpi won't appear in this count
# e.g. Some Col-0 leaves do not have chlorotic pixels (cluster == 1) at 24 hpi
# To overcome this we will create a dataframa containing all values
df8 = as_tibble(expand.grid(tray = unique(df7$tray), pos = unique(df7$pos), hpi = unique(df7$hpi), cluster = c(0,1,2)))

#convert position to a character vector
df8$pos = as.character(df8$pos)

#create sorted genotype vector to bind to the new grid
geno_info = rep(lines_info$genotype, 5)
geno_info2 = rep(geno_info, each = 3)
geno = tibble(genotype = geno_info2)

print(geno)

#sort data in the same way to new dataframe
df8 = df8 %>%
  arrange(hpi, tray, pos, cluster)

print(df8)

# add genotype information to the new dataframe
df8a = bind_cols(df8, geno)

#join new dataframe with previous data to add missing rows
df9 = df8a %>%
  left_join(df7) %>%
  as_tibble()

# Take a look to the results
print(df9)

#It looks good, but we need to convert NA values to 0.
#create a corrected size column (NA = 0)
df10 = df9 %>%
  mutate(size2= ifelse(is.na(size), 0, size)) %>%
  select(-size)

# Convert size to proportion of the total leaf size.
df10 = df10 %>%
  spread(key = cluster, value = size2) %>% # spread size by cluster column
  mutate(tot_size = `0` + `1` + `2`) %>% # calculating total size by adding cluster 1, 2 and 3
  mutate_at(.vars = vars(`0`, `1`, `2`), .funs = list(~./tot_size)) %>% # divide each cluster by total size
  mutate(check = `0` + `1` + `2`) %>% # verify if the sum of proportions is equal to 1.
  select(-tot_size, -check) %>% # remove useless columns
  gather(key = "cluster", value = "size", `0`, `1`, `2`) # gather back all clusters

#relevel genotypes
df10$genotype = factor(df10$genotype, levels = c("Col-0", "cyp", "lacs"))

#Rename clusters
df10$cluster = factor(df10$cluster, levels = c(0, 1, 2), labels = c("Healthy", "Chlorotic", "Necrotic"))

df11 = df10 %>% filter(str_detect(genotype, 'Col-0|lacs|cyp')) #%>% distinct(genotype)

#export data
write_csv(df10, "../bc007_rgb_curated.csv")
