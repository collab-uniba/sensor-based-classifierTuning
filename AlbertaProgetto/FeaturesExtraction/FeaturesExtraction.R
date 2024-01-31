

extractFeatures <-function(signal, baseline_values, interval_values){
  
  switch(signal, 
        
         
         EDA={
           
           features <- getFeatures_EDA(baseline_values, interval_values); 
         },
         HR={
           features <- getFeatures_HR(baseline_values, interval_values);
         },
         BVP={
           features <- getFeatures_BVP(baseline_values, interval_values);
         }
  )
}

extractFeatures_baseline <- function(signal, baseline_values) {
  switch(signal,
    EDA = {
      features <- getFeatures_EDA_baseline(baseline_values)
    },
    HR = {
      features <- getFeatures_HR_baseline(baseline_values)
    },
    BVP = {
      features <- getFeatures_BVP_baseline(baseline_values)
    }

  )
}