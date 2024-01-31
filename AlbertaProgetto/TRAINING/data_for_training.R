library(tidyr)

rows <- function(x) lapply(seq_len(nrow(x)), function(i) lapply(x, "[", i))
datas_to_csv_line <- function(task) {
  return(gsub(" ", ",", paste(task$id, task$mean_SCL, task$AUC_Phasic,
                              task$min_peak_amplitude, task$max_peak_amplitude,
                              task$mean_phasic_peak,
                              task$sum_phasic_peak_amplitude,
                              task$difference_BVPpeaks_amp,
                              task$mean_BVPpeaks_ampl,
                              task$min_BVPpeaks_ampl, task$max_BVPpeaks_ampl,
                              task$sum_peak_ampl, task$HR_mean,
                              task$HR_variance, task$valence)))
}


#leggi taskFeatures
task_features <- data.frame(read.csv("C:/Users/Utente/Desktop/sensor-based-classifierTuning/AlbertaProgetto/taskFeatures.csv", header = TRUE, sep = ","))
data_tf <- rows(task_features)

#leggi ids
ids <- readLines("C:/Users/Utente/Desktop/sensor-based-classifierTuning/AlbertaProgetto/ids.csv")

out_dir <- "Training_data/"
if (dir.exists(out_dir))
  unlink(out_dir, recursive = TRUE)
dir.create(out_dir)


sub <- 0
header <- "id,mean_SCL,AUC_Phasic,min_peak_amplitude,max_peak_amplitude,mean_phasic_peak,sum_phasic_peak_amplitude, mean_BVPpeaks_ampl,min_BVPpeaks_ampl,max_BVPpeaks_ampl,sum_peak_ampl,HR_mean,HR_variance,valence"

#per ogni riga di ids
for (line in ids) {
  #prendi gli id
  id_list <- strsplit(line, ",")
  to_write <- c()
  for (id in id_list[[1]]) {
    id_i <- as.integer(as.double(id))
    for(i in 1:6) {
      to_write <- append(to_write,
                         datas_to_csv_line(data_tf[[(id_i - 1) * 6 + i]]))
    }
  }
  sub <- sub + 1
  file_name <- gsub(" ", "", paste(sub , ".csv"))
  write(header,paste(out_dir, file_name, sep = "/"), append = FALSE)
  write(to_write, paste(out_dir, file_name, sep = "/"), append = TRUE)
}
