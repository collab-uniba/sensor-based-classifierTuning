
#return a vector containing the timestamps of the interruptions
getTimestamps <- function(intervals_file, pattern) {


  interruptions_timestamps <- c()
  conn <- file(intervals_file,open="r")
  lines <- readLines(conn)

  for (i in 1:length(lines)){

    if(grepl(pattern = pattern, lines[i]) == TRUE) {
      s <- strsplit(lines[i], ",")
      s <- unlist(s)
      interruptions_timestamps <- c(interruptions_timestamps, s[2])
    }
  }
  close(conn)
  print(interruptions_timestamps)
  return(interruptions_timestamps)

}



getIntervalEmotionElicitation <- function(times_file, pattern) {

  start_time <- getTimestamps(times_file, pattern)
  start_time <- as.numeric(start_time)

  videos <- c("V1", "V2", "V3", "V4","V5", "V6", "V7", "V8")
  start_timestamp_emotions <- c()
  end_timestamp_emotions <- c()
  labels_valence <- c("positive", "positive", "negative", "negative", "positive", "positive", "negative", "negative")
  labels_arousal <- c("low", "low", "low", "low", "high", "high", "high", "high")

  #the last 30 seconds before the video ends are considered as start time
  start_video1 <- as.numeric(start_time + minutes(1) + seconds(5))
  end_video1 <- as.numeric(start_time + minutes(1) + seconds(35))

  start_video2 <- as.numeric(start_time + minutes(2) + seconds(18))
  end_video2 <- as.numeric(start_time + minutes(2) + seconds(48)) 

  start_video3 <- as.numeric(start_time + minutes(4) + seconds(3))
  end_video3 <- as.numeric(start_time + minutes(4) + seconds(33))

  start_video4 <- as.numeric(start_time + minutes(5) + seconds(16))
  end_video4 <- as.numeric(start_time + minutes(5) + seconds(46))

  start_video5 <- as.numeric(start_time + minutes(7) + seconds(1))
  end_video5 <- as.numeric(start_time + minutes(7) + seconds(31))

  start_video6 <- as.numeric(start_time + minutes(8) + seconds(14)) 
  end_video6 <- as.numeric(start_time + minutes(8) + seconds(44))

  start_video7 <- as.numeric(start_time + minutes(9) + seconds(59)) 
  end_video7 <- as.numeric(start_time + minutes(10) + seconds(29)) 

  start_video8 <- as.numeric(start_time + minutes(11) + seconds(12))
  end_video8 <- as.numeric(start_time + minutes(11) + seconds(42))


  start_timestamp_emotions <- c(start_video1, start_video2, start_video3, start_video4, start_video5, start_video6, start_video7, start_video8 )
  end_timestamp_emotions <- c(end_video1, end_video2, end_video3, end_video4, end_video5, end_video6, end_video7, end_video8 )

  df_emotions <- data.frame(videos, start_timestamp_emotions, end_timestamp_emotions, labels_valence, labels_arousal)

  return(df_emotions)
}

  
#returns the the values between the timestamp and the previous seconds
getSignalValues <- function(signal, file, timestamp, seconds) {

  #check the format of the file: neurosky and E4 generate csv with different formats
  if (signal =="EEG"||signal =="EEG_ATT" || signal =="EEG_MED") {
  
    all_values <- read.csv(file, header = TRUE, sep = ",") #Neurosky application
    start_recording_timestamp <- as.numeric(all_values$Time[1])
  }
  
  else if (signal == "HRV") {

    all_values <- read.csv(file, header=FALSE, sep=",")
    start_recording_timestamp <- as.numeric(all_values[1,1]) 

  }
 
  else{
    all_values <- read.csv(file, header=FALSE, sep="")
    start_recording_timestamp <- as.numeric(all_values[1, 1])
  }
    
#convert in Date type the UNIX timestamp saved when the application started to record signals data
  start_recording_timestamp <- anytime(start_recording_timestamp)
  start_recording_timestamp <- strftime(start_recording_timestamp, format="%H:%M:%S")
  
  start_recording_timestamp <- hms(start_recording_timestamp)

  #convert in Date type the Unix timestamp of the interruption
  interruption <- as.numeric(timestamp)
  interruption <- anytime(interruption)
  interruption <- strftime(interruption, format="%H:%M:%S")

  end_interval <- hms(interruption)  
  start_interval <- end_interval - seconds(seconds) #determine the upper bound of interval based on how many seconds have to be analyzed


  #convert timestamps in number of seconds
  start_recording_timestamp_seconds <- as.numeric(start_recording_timestamp) 
  start_interval_seconds <- as.numeric(start_interval)
  end_interval_seconds <- as.numeric(end_interval)
  #print(paste("start_recording_second", start_recording_timestamp_seconds))
  #print(paste("start_interval_second", start_interval_seconds))
  #print(paste("end_interval_second", end_interval_seconds))


  #determine how many seconds have elapsed between the start of recording data and the interval
  elapsedSeconds_FromRecording_ToStartInterval <- start_interval_seconds - start_recording_timestamp_seconds
  elapsedSeconds_FromRecording_ToEndInterval <- end_interval_seconds - start_recording_timestamp_seconds
  #print(paste("number of seconds between start recording and start interval: ", elapsedSeconds_FromRecording_ToStartInterval ))
  #print(paste("number of seconds between start recording and end interval: ", elapsedSeconds_FromRecording_ToEndInterval ))


  if(signal== "EEG")
    sample_frequency <- 512
  else if (signal == "EEG_ATT" || signal == "EEG_MED" )
    sample_frequency <- 1
  else if (signal == "HRV")
    sample_frequency <- NA
  else
    sample_frequency <- all_values[2,1] #sample frequency is stored in the second row of the file
    
  #print(paste("signal:", signal) )
  #print(paste("sample_frequency:", sample_frequency))
  
  
  
  #get indexes of the lines of file where are stored the values of the interval to analyzed
  #https://www.epochconverter.com/ : to check the correspondance between line of file and time interval
  

  
  if (signal == "HRV") {

    j <- 2
    l <- length(all_values[,1])

    while(all_values[j,1] < elapsedSeconds_FromRecording_ToStartInterval && j < l)
      j <- j + 1
    start_index <- j

    while(all_values[j,1] < elapsedSeconds_FromRecording_ToEndInterval && j < l)
       j<-j+1
    end_index <- j
  }
  
  else{
    #start_index + 3: 
    #+2 because start_recording relies on the seconds line of the file
    #+1 because the first of the seconds to included relies on the next line of start interval calculated  #(otherwise we'll analyze n+1 seconds)
    #end_index + 2 because start_recording relies on the seconds line of the file
  
    start_index <- (elapsedSeconds_FromRecording_ToStartInterval*sample_frequency) + 3
    end_index <- (elapsedSeconds_FromRecording_ToEndInterval*sample_frequency) + 2
  }

  values <- c()

  #save in values only data related to the interval of interest

  if (signal=="EEG"||signal=="EEG_ATT" || signal == "EEG_MED")
      values <- all_values[start_index:end_index, 2] #Neuroview saves values in the second column of the file

  else if (signal == "HRV"){
    #values <- data.frame("seconds" = all_values[start_index:end_index,1], "values" = all_values[start_index:end_index,2]) #for IBI files E4 saves values in the second column of the file
  values <- all_values[start_index:end_index, 2]
  values <- as.numeric(as.character(values))

  }
  else
    values <- all_values[start_index:end_index,1] #E4 saves values in the first column of the file
  return(values)

}