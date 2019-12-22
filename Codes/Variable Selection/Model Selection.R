# Read the  data files

interactions_train <- read.csv("interactions_train.csv", stringsAsFactors=FALSE)
PP_recipes <- read.csv("PP_recipes.csv", stringsAsFactors=FALSE)
PP_users <- read.csv("PP_users.csv", stringsAsFactors=FALSE)

# Select the important variables

interactions_work=interactions_train[,4:6]
recipes_work=PP_recipes[,c(2,7)]
users_work=PP_users[,c(1,5:6)]

rm(interactions_train,PP_recipes,PP_users)

# Modifying some variables

library(tidyverse)

users_work$ratingavg=sapply(strsplit(gsub("[\\[\\]]","",users_work$ratings,perl=T),", "),function(x) mean(as.numeric(x)))
users_work=users_work[,-2]

recipes_rating=interactions_work%>%group_by(i)%>%summarise(avgrating=mean(rating),nreviews=n())

# Join recipe dataframes

recipes_work=recipes_work[order(recipes_work$i),]
recipes_work=recipes_work[recipes_work$i%in%recipes_rating$i,]
recipes_rating$clevel=recipes_work$calorie_level

rm(interactions_work,recipes_work,users_work)

# Analyze recipe data

library(lme4)

recipes_rating$avgrating=recipes_rating$avgrating/5
Model.1=glm(avgrating~nreviews+clevel,family=binomial(link="logit"),data=recipes_rating)
Model.2=glm(avgrating~clevel,family=binomial(link="logit"),data=recipes_rating,weights=nreviews)
Model.3=glmer(avgrating~(1|nreviews)+clevel,family=binomial(link="logit"),data=recipes_rating)

# Save all

save.image("Results.rda")