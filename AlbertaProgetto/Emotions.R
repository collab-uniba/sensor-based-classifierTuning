
source("libraries.R")
source("./Preprocessing/IntervalExtraction.R")
source("./Preprocessing/SignalsPreprocessing.R")
source("./FeaturesExtraction/FeaturesExtraction.R")
source("./FeaturesExtraction/Fe_BVP.R")
source("./FeaturesExtraction/Fe_EDA.R")
source("./FeaturesExtraction/Fe_HR.R")

utils <-import_from_path("utils", path = "./inst/", convert = TRUE)
tools <-import_from_path("tools", path = "./inst/", convert = TRUE)

source_python("./inst/cvxEDA.py")
source_python("./inst/kbk_scr.py")


# enable commandline arguments from script launched using Rscript
args<-commandArgs(TRUE)


getFiles <-function(E4_path ){

  EDA_file <- paste(E4_path, "EDA.csv", sep = "/")
  HR_file <- paste(E4_path, "HR.csv", sep = "/")
  BVP_file <- paste(E4_path, "BVP.csv", sep = "/")

  files <- c(EDA_file, HR_file, BVP_file)

  return(files)

}


getLabel <-function(n, emotions_rating, k, interruptions_rating){
  
labels <-c()
# n: number of participant analyzed
#k: number of interruption  


#emotions_rating: dataframe with the rating of all participants during emotions elicitation: 
#columns from 2 to 9 contain valence ratings, columns from 10 to 17 contain arousal ratings
  
#interrut_rating: dataframe with the rating of all participants during development tasks
#columns from 2 to 7 contain valence ratings, columns from 8 to 13 contain arousal ratings
  
  
mean_rating_valence <- mean(as.numeric(emotions_rating[n,2:9]))
#mean_rating_arousal <- mean(as.numeric(emotions_rating[n,10:17]))

k<-k + 1

int_rating_valence <- interruptions_rating[n,k]
#int_rating_arousal <- interruptions_rating[n,k+6]

if(int_rating_valence > mean_rating_valence + 0.5 )
    labels <- c(labels,"positive")
else if (int_rating_valence < mean_rating_valence - 0.5 )
    labels <- c(labels,"negative")
 else 
     labels <- c(labels,"neutral")

  
#if(int_rating_arousal > mean_rating_arousal + 0.5)
#  labels <- c(labels, "high")
#else if (int_rating_arousal < mean_rating_arousal - 0.5)
#    labels <- c(labels, "low")
# else 
#    labels <- c(labels, "neutral")

return(labels)
  
}

#START MAIN

data_path <- paste(getwd(), "DataSubjects", sep = "/" )
dirs <-list.dirs(path = data_path, full.names = TRUE, recursive = FALSE)
dirs <- mixedsort(sort(dirs))
dirs<-as.character(dirs)
print(dirs)

baseline_seconds <-30
emotions_rating <-read.csv(paste(data_path, "emotions_rating.csv", sep= "/"), header=TRUE, sep=",")
interruptions_rating <-read.csv(paste(data_path, "interruptions_rating.csv", sep= "/"), header=TRUE, sep=",")


signals <- c( "EDA", "HR", "BVP")


all_signal_features_baseline <- c()
n_features_baseline <- 0

all_signal_features <- c()


#cycle on each subject
for(n in 1: length(dirs) ){
  
  print(paste("Analyzing data: ", dirs[n]))
  
  E4_path <- paste(dirs[n], "E4", sep = "/") #E4 generates files from E4 Empatica (EDA, Temp, HR, BVP)
  
  files <-getFiles(E4_path)
  
  intervals_file <- list.files(path = dirs[n], pattern = "times*")
  intervals_file <- paste(dirs[n], intervals_file, sep = "/")
  timestamp_baseline <- getTimestamps(intervals_file, "*end_baseline")
  
  
  #For each signal
  #Extract the baseline
  
  #For each interruption
    #Extract the data of the interval that have to be processed
    #Extract features
    
  #Save all the features of the signal on file (one instance per task)
  
  
   for(i in 1: length(signals)){
     print(paste("Analyzing signal: ", signals[i]))
     baseline_values <- getSignalValues(signals[i], files[i], timestamp_baseline, baseline_seconds) #takes the last 30 seconds of baseline

     features_baseline <- extractFeatures_baseline(signals[i], baseline_values)
     n_features_baseline <- length(features_baseline) + 3
     features_baseline <- toString(features_baseline)
     id <- paste(paste(as.character(n), ".", sep = ""), 1, sep = "")
     instance <- paste(id, features_baseline, sep = ", ")
     all_signal_features_baseline <- append(all_signal_features_baseline, instance)


     n_features <- 0
     #get all timestamps of interruption and extract the features related to signals during working task
     interruptions <- getTimestamps(intervals_file, "*interruption")
     for(k in 1:length(interruptions)){
        print(paste("interruption: ",k))
        interval_values <- getSignalValues(signals[i], files[i], interruptions[k], 10)
        features <- extractFeatures(signals[i], baseline_values, interval_values)
        n_features <-length(features) + 3
        features <-toString(features)
        labels <- getLabel( n,emotions_rating, k, interruptions_rating)
        labels <-toString(labels)
        id <- paste(paste(as.character(n),".", sep=""), k, sep="")
        instance <- paste(id, features,labels, sep = ", ")
        all_signal_features <- append(all_signal_features,instance)
        
    }
    
    gc()
    rm()
  }
  
  print(paste("DONE:", dirs[n]))
  
  
}
#baseline
all_features <- c()
i <- 1
while (i <= length(all_signal_features_baseline)) {
  s1 <- all_signal_features_baseline[i]
  splt <- strsplit(s1, split = ",")
  idx <- paste(splt[[1]][1], ",", sep = "")

  s2 <- all_signal_features_baseline[i + 1]
  s2 <- sub(idx, "", s2)

  s3 <- all_signal_features_baseline[i + 2]
  s3 <- sub(idx, "", s3)

  s <- paste(s1, s2, s3, sep = ",")
  s <- gsub(" ", "", s)
  all_features <- append(all_features, s)
  i <- i + 3
}
baseline_header <- "id,mean_SCL,AUC_Phasic,min_peak_amplitude,max_peak_amplitude,mean_phasic_peak,sum_phasic_peak_amplitude, mean_BVPpeaks_ampl,min_BVPpeaks_ampl,max_BVPpeaks_ampl,sum_peak_ampl,HR_mean,HR_variance"
write(baseline_header, "baselineFeatures.csv", append = FALSE)
write(all_features, file = "baselineFeatures.csv", append = TRUE)

#task
all_features_task <- c()
i <- 1
pat <- "[ positive negative neutral]"
while (i <= length(all_signal_features)-12) {
  s1 <- all_signal_features[i]
  s1 <- gsub(pat, '', s1)
  splt <- strsplit(s1, split = ',')
  idx <- paste(splt[[1]][1], ",", sep = "")

  s2 <- all_signal_features[i + 6]
  s2 <- gsub(pat, '', s2)
  s2 <- sub(idx, '', s2)

  s3 <- all_signal_features[i + 12]
  s3 <- sub(idx, '', s3)

  s <- paste(s1, s2, s3, sep = "")
  s <- gsub(' ', '', s)
  print(s)
  all_features_task <- append(all_features_task, s)

  if (i %% 6 == 0) {
    i <- i + 13
  } else {
    i <- i + 1
  }
}
header <- "id,mean_SCL,AUC_Phasic,min_peak_amplitude,max_peak_amplitude,mean_phasic_peak,sum_phasic_peak_amplitude,difference_BVPpeaks_amp,mean_BVPpeaks_ampl,min_BVPpeaks_ampl,max_BVPpeaks_ampl,sum_peak_ampl,HR_mean,HR_variance,valence"
write(header, "taskFeatures.csv", append = FALSE)
write(all_features_task, "taskFeatures.csv", append = TRUE)

rm(list=ls()) #remove all variables in the workspace



