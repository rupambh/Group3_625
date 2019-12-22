### install packages/load libraries necessary for generating boxplot graphs and "Sankey Diagram"

library(tidyverse)
library(viridis)
library(patchwork)
library(hrbrthemes)
library(circlize)
library(networkD3)
library(ggplot2)
library(dplyr)

interaction_list = read.csv("~/Documents/BIOSTATS625/Group_Project/interactions_train.csv", stringsAsFactors = F)
pp_list = read.csv("~/Documents/BIOSTATS625/Group_Project/PP_recipes.csv", stringsAsFactors = F)
pp_users = read.csv("~/Documents/BIOSTATS625/Group_Project/PP_users.csv", stringsAsFactors = F)

### Look the content of each file

names(interaction_list)
names(pp_list)
names(pp_users)

### Merge interaction list, pp_list and pp_users (users, rating, and calorie levels)

merged_recipe_list = merge(interaction_list,pp_list, by.x = "recipe_id", by.y = "id" )
merged_user_list = merge(merged_recipe_list,pp_users, by = "u")
merged_list_table = table(merged_user_list[,c("rating", "calorie_level")])
write.table(merged_list_table, "~/Documents/BIOSTATS625/Group_Project/merged_list_table")

### Get percentages by row/by column to make better comparisons between the ratings/users

prop.table(merged_list_table, 1) #rows
prop.table(merged_list_table, 2) #columns

### Calculate p-values using fisher test and chisquare test to see if there is a pattern in the data
fisher.test(merged_list_table, simulate.p.value=TRUE)
chisq.test(merged_list_table)

### Convert merged list into a data frame 

merged_list_frame = data.frame(merged_list_table)

### Visualize merged data frame using ggplot 

mlf <-ggplot(data=merged_list_frame, aes(x=calorie_level, y=Freq, fill=rating)) +
  geom_bar(stat="identity")
mlf + labs(title="Plot of Calorie Level & User Rating", 
           x="Calorie Level", y = "Counts", fill = "Rating")

### Preparing Sankey Diagram 

nodes <- data.frame(name=c("cal0", "cal1", "cal2", "rat0", "rat1", "rat2", "rat3", "rat4", "rat5"))


merged_list_frame$IDsource= as.numeric(merged_list_frame$calorie_level)-1
merged_list_frame$IDtarget= as.numeric(merged_list_frame$rating)+2

ColourScal ='d3.scaleOrdinal() .range(["#FDE725FF","#B4DE2CFF","#6DCD59FF","#35B779FF","#1F9E89FF","#26828EFF","#31688EFF","#3E4A89FF","#482878FF","#440154FF"])'

sankeyNetwork(Links = merged_list_frame, Nodes = nodes,
              Source = "IDsource", Target = "IDtarget",
              Value = "Freq", NodeID = "name", 
              sinksRight=FALSE, colourScale=ColourScal, nodeWidth=40, fontSize=13, nodePadding=20)

### Packages used for the data analysis  

citation(package = "networkD3")
citation(package = "ggplot2")           
           
           
           