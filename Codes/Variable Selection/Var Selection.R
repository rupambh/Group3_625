# Read the  data files

load("Results.rda")

PP_recipes <- read.csv("PP_recipes.csv", stringsAsFactors=FALSE)
review_wc <- read.csv("review_wc.csv", header=FALSE, stringsAsFactors=FALSE)
RAW_recipes <- read.csv("RAW_recipes.csv", stringsAsFactors=FALSE)

PP_recipes=PP_recipes[order(PP_recipes$id),]
review_wc=review_wc[order(review_wc$V1),]

PP_recipes=PP_recipes[PP_recipes$id%in%review_wc$V1,]
review_wc=review_wc[review_wc$V1%in%PP_recipes$id,]
review_wc$V1=PP_recipes$i

rr_smaller=recipes_rating[recipes_rating$i%in%review_wc$V1,]
review_wc=review_wc[review_wc$V1%in%recipes_rating$i,]

rr_smaller=data.frame(rr_smaller,review_wc[,-1])
colnames(rr_smaller)[-(1:4)]=paste0("Word",1:100)

RAW_recipes=RAW_recipes[order(RAW_recipes$id),]
RAW_recipes=RAW_recipes[RAW_recipes$id%in%PP_recipes$id,]
RAW_recipes$i=PP_recipes$i

RAW_recipes=RAW_recipes[,c(3,8,12,13)]
RAW_recipes=RAW_recipes[order(RAW_recipes$i),]
RAW_recipes=RAW_recipes[RAW_recipes$i%in%rr_smaller$i,]

rr_smaller=as.data.frame(append(rr_smaller,list(RAW_recipes[,1:3]),after=4))

rm(RAW_recipes,PP_recipes,review_wc)
rownames(rr_smaller)=rr_smaller$i
rr_smaller=rr_smaller[,-1]

# Re-fit GLMM model without words

library(lme4)

Model.4=glmer(avgrating~(1|nreviews)+clevel+minutes+n_steps+n_ingredients,family=binomial(link="logit"),data=rr_smaller)

# Fit LASSO with words

rr_fit=as.matrix.data.frame(rr_smaller)

Variables=NULL

# Iteration based on for loop - not run

#for(i in 1:100)
#{
#  CV.Fit=glmnet::cv.glmnet(rr_fit[,-1],rr_fit[,1],type.measure='mse',nfolds=5)
#  Coeffs=coef(CV.Fit,s='lambda.min',exact=TRUE)
#  Indices=Coeffs@i[-1]+1
#  
#  print(i)
#  
#  Variables.temp=row.names(Coeffs)[Indices]
#  `%ni%`=Negate(`%in%`)
#  
#  Variables=c(Variables,Variables.temp[Variables.temp%ni%'(Intercept)'])
#}

# iteration based on mclapply

Fit.LASSO=function(x)
{
  CV.Fit=glmnet::cv.glmnet(rr_fit[,-1],rr_fit[,1],type.measure='mse',nfolds=5)
  Coeffs=coef(CV.Fit,s='lambda.min',exact=TRUE)
  Indices=Coeffs@i[-1]+1
  
  Variables.temp=row.names(Coeffs)[Indices]
  `%ni%`=Negate(`%in%`)
  
  Variables.temp=Variables.temp[Variables.temp%ni%'(Intercept)']
  
  return(Variables.temp)
}

ncores=parallel::detectCores()
mc=getOption("mc.cores",ncores)

Variables=unlist(parallel::mclapply(1:100,Fit.LASSO))
Variables=sort(table(Variables),decreasing=TRUE)/100