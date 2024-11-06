source("libraries.R")
source("./IntervalExtraction.R")


# Get values function
get_signal_val <- function(subject_dir, signal) {
  signal_values <- c()
  file_path <- paste(subject_dir, paste(signal, "csv", sep = "."), sep = "/")
  values <- read.csv(file_path, header = FALSE, sep = ",")
  values <- values[3:nrow(values),] 
  signal_values <- c(signal_values, values)
  return(signal_values)
}

# Extract baseline features function
extractFeatures_baseline <- function(signal, baseline_values) {
  values <- c()
  if (signal == "EDA") {
    mean_values <- mean(as.numeric(baseline_values))
    sd_values <- sd(as.numeric(baseline_values))
    values <- c(mean_values, sd_values)
  }else if(signal == "HR"){
    mean_values <- mean(as.numeric(baseline_values))
    sd_values <- sd(as.numeric(baseline_values))
    values <- c(mean_values, sd_values)
  }
  return(values)
}


# Get files
getFiles_ICSE <- function(E4_path){

  EDA_file <- paste(E4_path, "EDA.csv", sep = "/")
  HR_file <- paste(E4_path, "HR.csv", sep = "/")


  files <- c(EDA_file, HR_file)

  return(files)
}

print(getwd())
data_path_ICSE <- paste(getwd(), "DataSubjects", sep = "/")
dirs_icse <- list.dirs(path = data_path_ICSE, full.names = TRUE, recursive = FALSE)
dirs_icse <- mixedsort(sort(dirs_icse))
dirs_icse <- as.character(dirs_icse)

signals <- c("EDA", "HR")
all_baseline_features <- c()
n_features_baseline <- 0
baseline_seconds <-30
emotions_rating <-read.csv(paste(data_path_ICSE, "emotions_rating.csv", sep= "/"), header=TRUE, sep=",")
interruptions_rating <-read.csv(paste(data_path_ICSE, "interruptions_rating.csv", sep= "/"), header=TRUE, sep=",")



# Baseline ICSE
for (s in 1:length(dirs_icse)){

  print(paste("Analyzing data: ", dirs_icse[s]))
  E4_path <- paste(dirs_icse[s], "E4", sep = "/") #E4 generates files from E4 Empatica (EDA, Temp, HR, BVP)

  files <- getFiles_ICSE(E4_path)
  print(files)

  intervals_file <- list.files(path = dirs_icse[s], pattern = "times*")
  intervals_file <- paste(dirs_icse[s], intervals_file, sep = "/")
  timestamp_baseline <- getTimestamps(intervals_file, "*end_baseline")

  for (i in 1: length(signals)){
    print(paste("Analyzing signal: ", signals[i]))
    baseline_values <- getSignalValues(signals[i], files[i], timestamp_baseline, baseline_seconds) #takes the last 30 seconds of baseline


  features_baseline <- extractFeatures_baseline(signals[i], baseline_values)
  n_features_baseline <- length(features_baseline) + 3
  features_baseline <- toString(features_baseline)
  id <- paste(paste(as.character(s), ".", sep = ""), 1, sep = "")
  instance <- paste(id, features_baseline, sep = ", ")
  all_baseline_features <- append(all_baseline_features, instance)
  }
}

# Data to write
all_features <- c()
i <- 1
while (i <= length(all_baseline_features)) {
  s1 <- all_baseline_features[i]
  splt <- strsplit(s1, split = ",")
  idx <- paste(splt[[1]][1], ",", sep = "")

  s2 <- all_baseline_features[i + 1]
  s2 <- sub(idx, "", s2)

  s3 <- all_baseline_features[i + 2]
  s3 <- sub(idx, "", s3)

  s <- paste(s1, s2, sep = ",")
  s <- gsub(" ", "", s)
  all_features <- append(all_features, s)
  i <- i + 2
}

baseline_header <- "id,mean_EDA,sd_EDA,mean_HR,sd_HR"
write(baseline_header, "baselineFeatures.csv", append = FALSE)
write(all_features, file = "baselineFeatures.csv", append = TRUE)