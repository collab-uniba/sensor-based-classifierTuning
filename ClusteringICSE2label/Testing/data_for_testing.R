library(tidyr)

rows <- function(x) lapply(seq_len(nrow(x)), function(i) lapply(x, "[", i))

# Features taken into consideration
datas_to_csv_line <- function(task) {
  return(gsub(" ", ",", paste(task$id, task$alpha_bin, task$beta_bin, task$gamma_bin, task$delta_bin,
                              task$theta_bin, task$alpha_beta, task$alpha_gamma, task$alpha_delta,
                              task$alpha_theta, task$beta_alpha, task$beta_gamma, task$beta_delta,
                              task$beta_theta, task$gamma_alpha, task$gamma_beta, task$gamma_delta,
                              task$gamma_theta, task$delta_alpha, task$delta_beta, task$delta_gamma,
                              task$delta_theta, task$theta_alpha, task$theta_beta, task$theta_gamma,
                              task$theta_delta, task$min_att, task$max_att, task$mean_att_difference, 
                              task$sd_att_difference, task$min_med, task$max_med, task$mean_med_difference,
                              task$sd_med_difference,
                              task$mean_SCL, task$AUC_Phasic,
                              task$min_peak_amplitude, task$max_peak_amplitude,
                              task$mean_phasic_peak,
                              task$sum_phasic_peak_amplitude,
                              task$difference_BVPpeaks_amp,
                              task$mean_BVPpeaks_ampl,
                              task$min_BVPpeaks_ampl, task$max_BVPpeaks_ampl,
                              task$sum_peak_ampl, task$HR_mean,
                              task$HR_variance, task$valence)))
}

# Read SAM_valence(22sub).csv or SAM_arousal(22sub).csv
task_features <- data.frame(read.csv("C:/Users/Utente/Desktop/ClusteringICSE2label/Feature/SAM_valence(22sub).csv", header = TRUE, sep = ","))
data_tf <- rows(task_features)

# IDs for testing files
ids <- c(1.1, 2.1, 3.1, 4.1, 5.1, 6.1, 7.1, 8.1, 9.1, 10.1, 11.1, 12.1, 13.1, 14.1, 15.1, 16.1, 17.1, 18.1, 19.1, 20.1, 21.1, 22.1)

out_dir <- "Testing_data/"
if (dir.exists(out_dir))
  unlink(out_dir, recursive = TRUE)
dir.create(out_dir)

sub <- 0
header <- "id,alpha_bin,beta_bin,gamma_bin,delta_bin,theta_bin,alpha_beta,alpha_gamma,alpha_delta,alpha_theta,beta_alpha,beta_gamma,beta_delta,beta_theta,gamma_alpha,gamma_beta,gamma_delta,gamma_theta,delta_alpha,delta_beta,delta_gamma,delta_theta,theta_alpha,theta_beta,theta_gamma,theta_delta,min_att,max_att,mean_att_difference,sd_att_difference,min_med,max_med,mean_med_difference,sd_med_difference,mean_SCL,AUC_Phasic,min_peak_amplitude,max_peak_amplitude,mean_phasic_peak,sum_phasic_peak_amplitude,difference_BVPpeaks_ampl,mean_BVPpeaks_ampl,min_BVPpeaks_ampl,max_BVPpeaks_ampl,sum_peak_ampl,HR_mean_difference,HR_variance_difference,valence"

# For each id in ids find all instances 
for (line in ids) {

  id_list <- strsplit(as.character(line), ",")
  to_write <- c()
  for (id in id_list[[1]]) {
    id_i <- as.integer(as.double(id))
    print(id_i)
    for(i in 1:6) {
      to_write <- append(to_write,
                         datas_to_csv_line(data_tf[[(id_i - 1) * 6 + i]]))
    }
  }

  sub <- sub + 1

  # Write csv
  file_name <- gsub(" ", "", paste(sub , ".csv"))
  write(header,paste(out_dir, file_name, sep = "/"), append = FALSE)
  write(to_write, paste(out_dir, file_name, sep = "/"), append = TRUE)
}
