# enable commandline arguments from script launched using Rscript
args<-commandArgs(TRUE)

print(args[1])
print(args[2])
print(args[3]) #signal
print(args[4]) #label

run <- args[1]

# set the random seed, held constant for the current run
seeds <- readLines("seeds.txt")
seed <- ifelse(length(seeds[run]) == 0, sample(1:1000, 1), seeds[as.integer(run)])
set.seed(seed)


models_file <- args[2]
signal <-args[3]

idx <- 1

# Train each file in Training_data
while(idx <= 22){
  file_name <- paste("Training_data", gsub(" ", "", paste(idx, ".csv")), sep = "/")
  csv_file <- file_name
  print(csv_file)

  # Create output dir for each Run
  output_dir <- paste(getwd(), gsub(" ", "", paste("results_SAM_arousal/Run",idx)), sep="/")
  if(!dir.exists(output_dir))
  dir.create(output_dir, showWarnings = FALSE, recursive = TRUE, mode = "0777")

  library(caret) # for param tuning
  library(e1071) # for normality adjustment

  # enables multicore parallel processing 
  if(!exists("enable_parallel", mode="function")) 
    source(paste(getwd(), "lib/enable_parallel.R", sep="/"))

  # comma delimiter
  dataset <- read.csv(csv_file, header = TRUE, sep=",")


  # name of outcome var to be predicted
  outcomeName <- args[4]
  print(outcomeName)


  # list of predictor vars by name
  excluded_predictors <- c("id")
  dataset <- dataset[ , !(names(dataset) %in% excluded_predictors)]
  l<-ncol(dataset)


  #consider a subset of features to train the dataset only on EEG features or only on skin and heart features
  if(signal == "EEG"){
      label <- dataset[,l]
      dataset <- dataset[ , 1:33]
      dataset <- cbind(dataset, label)
      colnames(dataset)[34] <- outcomeName
  }else if(signal == "E4"){
      dataset <- dataset[ , 34:l]
    
  }

  predictorsNames <- names(dataset[,!(names(dataset)  %in% c(outcomeName))]) # removes the var to be predicted from the test set

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
  classifiers <- readLines(models_file)

  #create the formula using as.formula and paste
  outcome <- as.formula(paste(outcomeName, ' ~ .' ))

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
    output_file <- gsub(" ", "", paste(output_dir, paste(classifier, "txt", sep="."), sep = "/"))
    
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
        
    
    if(!exists("scalar_metrics", mode="function")) 
      source(paste(getwd(), "lib/scalar_metrics.R", sep="/"))
    scalar_metrics(predictions=predictions, truth=testing[,outcomeName], outdir=".", outfile=output_file)
    

    # save the model to disk
    output_model_dir <- paste(output_dir, paste("models_rds", classifier, sep ="/"), sep = "/")
    if(!dir.exists(output_model_dir))
      dir.create(output_model_dir, showWarnings = FALSE, recursive = TRUE, mode = "0777")


    model_name <- paste(paste("best_model", run, sep = "_"), "rds", sep=".")
    print(paste(output_model_dir, model_name, sep = "/"))
    saveRDS(model, paste(output_model_dir, model_name, sep = "/"))

    rm(model)
    rm(predictions)
  
  }
  idx <- idx + 1
}