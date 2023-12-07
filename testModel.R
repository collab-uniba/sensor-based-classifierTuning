# enable commandline arguments from script launched using Rscript
args<-commandArgs(TRUE)

# load libraries
library(caret)
library(mlbench)
library(randomForest)
library(doMC)
library(class)
# load dataset
input_file <- args[1]
print(input_file)
testing <- read.csv(input_file, header = TRUE, sep=",")

l<-ncol(testing)
label <- testing[,l]


excluded_predictors <- c("id", "difference_BVPpeaks_ampl", "valence") #"Neu_vs_NonNeu_predictions"
testing <- testing[ , !(names(testing) %in% excluded_predictors)]

print(testing[1:5,])

# load the model

model <- args[2]

super_model <- readRDS(model)

# make a predictions on "new data" using the final model
final_predictions <- predict(super_model, testing)


output_file <- args[4]


if(!exists("scalar_metrics", mode="function")) 
  source(paste(getwd(), "lib/scalar_metrics.R", sep="/"))
scalar_metrics(predictions=final_predictions, truth=label, outdir= "ModelResults", output_file)

final_predictions <- data.frame(final_predictions)
print(final_predictions)
#final_predictions <- unlist(final_predictions)

print(length(label))
#write.table(final_predictions, "predictions.csv", row.names = FALSE)

print(label)

output_file_predictions <- args[3]
write.csv(final_predictions,output_file_predictions, row.names = FALSE, quote = FALSE)

rm(model)
rm(final_predictions)
# unload the package:
lapply(names(sessionInfo()$loadedOnly), require, character.only = TRUE)
invisible(lapply(paste0('package:', names(sessionInfo()$otherPkgs)), detach, character.only=TRUE, unload=TRUE, force=TRUE))# garbage collection
#gc()