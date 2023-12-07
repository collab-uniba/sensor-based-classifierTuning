# enable commandline arguments from script launched using Rscript
args<-commandArgs(TRUE)

print(args[1])
print(args[2])
print(args[3])
#print(args[6]) #label

run <- args[1]
#run <- ifelse(is.na(run), 1, run)

# set the random seed, held constant for the current run
print(getwd())
#setwd("/Users/Daniela/OneDrive - Università degli Studi di Bari/biometrics-main/biometrics-main/Field Study/RQ/RQ3-biometrics/Analysis")
seeds <- readLines("seeds.txt", warn= FALSE)
seed <- ifelse(length(seeds[run]) == 0, sample(1:1000, 1), seeds[as.integer(run)])
set.seed(seed)
print(seed)

output_folder <- args[4] 
#output_folder<- "results_10seconds_prova"


# creates current output directory for current execution
output_dir <- paste(getwd(),output_folder , sep="/")
if(!dir.exists(output_dir))
  dir.create(output_dir, showWarnings = FALSE, recursive = TRUE, mode = "0777")


csv_file <- args[2]
models_file <- args[3]

#csv_file <- "Empatica_10sec_valence_ALL.csv"
#models_file <- "models/models.txt"
#signal <- "valence"  



# library setup, depedencies are handled by R
#library(pROC) # for AUC
library(rlang)
library(caret) # for param tuning
library(e1071) # for normality adjustment

# enables multicore parallel processing 
if(!exists("enable_parallel", mode="function")) 
  source(paste(getwd(), "lib/enable_parallel.R", sep="/"))

# comma delimiter
# comma delimiter
dataset <- read.csv(csv_file, header = TRUE, sep=",")

#print(dataset)

# name of outcome var to be predicted
outcomeName <- "valence"
#print(outcomeName)


# list of predictor vars by name
excluded_predictors <- c("id")

dataset <- dataset[ , !(names(dataset) %in% excluded_predictors)]
l<-ncol(dataset)


#print(dataset)


predictorsNames <- names(dataset[,!(names(dataset)  %in% c(outcomeName))]) # removes the var to be predicted from the test set
#print(predictorsNames)
x=dataset[,predictorsNames]
y=factor(dataset[,outcomeName])

# create stratified training and test sets from SO dataset
splitIndex <- createDataPartition(dataset[,outcomeName], p = .90, list = FALSE)
training <- dataset[splitIndex, ]
testing <- dataset[-splitIndex, ]



# LOOCV CV repetitions
fitControl <- trainControl(
  method = "LOOCV",
  #number = 10,
  ## repeated ten times, works only with method="repeatedcv", otherwise 1
  #repeats = 10,
  #verboseIter = TRUE,
  savePredictions = "final",
  # binary problem
  #summaryFunction=defaultSummary,
  classProbs = TRUE,
  # enable parallel computing if avail
  allowParallel = TRUE,
  #returnData = FALSE
  #sampling = "smote"
)


# load all the classifiers to tune
classifiers <- readLines(models_file, warn = FALSE)

#create the formula using as.formula and paste
outcome <- as.formula(paste(outcomeName, ' ~ .' ))

bestAccuracy <- 0
bestModel <- ""
bestTune <- ""

for(i in 1:length(classifiers)){
  nline <- strsplit(classifiers[i], ":")[[1]]
  classifier <- nline[1]
  cpackage <- nline[2]
  # RWeka packages do need parallel computing to be off
  fitControl$allowParallel <- ifelse(!is.na(cpackage) && cpackage == "RWeka", FALSE, TRUE)
  print(paste("Building model for classifier", classifier))
  
  
  time.start <- Sys.time()
  model <- caret::train(outcome, 
                        data = training,
                        method = classifier,
                        trControl = fitControl,
                        metric = "ROC",
                        preProcess = c("center", "scale"),
                        tuneLength = 5 # five values per param
  )
  time.end <- Sys.time()
  
  
  # output file for the classifier at nad
  output_file <- paste(output_dir, paste(classifier, "txt", sep="."), sep = "/")
  
  cat("", "===============================\n", file=output_file, sep="\n", append=TRUE)
  #cat("Seed:", seed, file=output_file, sep="\n", append=TRUE)
  out <- capture.output(model)
  title = paste(classifier, run, sep = "_run# ")
  cat(title, out, file=output_file, sep="\n", append=TRUE)
  
  
  # elapsed time
  time.elapsed <- time.end - time.start
  out <- capture.output(time.elapsed)
  cat("\nElapsed time", out, file=output_file, sep="\n", append=TRUE)
  
  # the highest roc val from train to save
  out <- capture.output(getTrainPerf(model))
  cat("\nHighest ROC value:", out, file=output_file, sep="\n", append=TRUE)
  
  
  
  # computes the scalar metrics
  predictions <- predict(object=model, testing[,predictorsNames], type='raw')
  
  
  #preds <- c()
  #for (i in 0:length(testing[,"valence"])){
  #  preds <- c(preds, paste(ids[i],predictions[i], sep=","))
  #}
  # save errors to text file
  #cat("Row,Predicted\n",file= output_file)
  #write.table(preds, file= paste(output_dir, paste(classifier, "_predictions.txt", sep=""), sep = "/"), quote = FALSE, row.names = FALSE, col.names = FALSE, append=TRUE)
  
  
  
  if(!exists("scalar_metrics", mode="function")) 
    source(paste(getwd(), "lib/scalar_metrics.R", sep="/"))
  scalar_metrics(predictions=predictions, truth=testing[,outcomeName], outdir=".", output_file)
  
  # save the model to disk
  output_model_dir <- paste(output_dir, paste("models_rds", classifier, sep ="/"), sep = "/")
  if(!dir.exists(output_model_dir))
    dir.create(output_model_dir, showWarnings = FALSE, recursive = TRUE, mode = "0777")
  
  model_name <- paste(paste("best_model", run, sep = "_"), "rds", sep=".")
  #print(paste(output_model_dir, model_name, sep = "/"))
  saveRDS(model, paste(output_model_dir, model_name, sep = "/"))
  ## === cleanup ===
  # deallocate large objects
  #rm(model)
  #rm(predictions)
  # unload the package:
  # if(!is.na(cpackage))
  #    detach(name=paste("package", cpackage, sep=":"), unload = TRUE, character.only = TRUE)
  # garbage collection
  #gc()
}
