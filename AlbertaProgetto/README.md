# progetto Alberta

 ## Costruzione Dataset
 - Emotions.R: script che crea i seguenti dataset:
    - taskFeatures.csv: contenente le features estratte dai 10 secondi che precedono ogni interruzione 
      Formato da:
        - la seguente intestazione:
           id,mean_SCL,AUC_Phasic,min_peak_amplitude,max_peak_amplitude,mean_phasic_peak,sum_phasic_peak_amplitude,difference_BVPpeaks_amp,mean_BVPpeaks_ampl,min_BVPpeaks_ampl,max_BVPpeaks_ampl,sum_peak_ampl,HR_mean,HR_variance,valence
        - 132 righe, corrispondenti a sei interruzioni per ogni soggetto (per 22 soggetti)

    - baselineFeatures.csv: contenente le features estratte dagli ultimi 30 secondi del segnale di baseline
      Formato da:
        -la seguente intestazione: 
          id,mean_SCL,AUC_Phasic,min_peak_amplitude,max_peak_amplitude,mean_phasic_peak,sum_phasic_peak_amplitude, mean_BVPpeaks_ampl,min_BVPpeaks_ampl,max_BVPpeaks_ampl,sum_peak_ampl,HR_mean,HR_variance
        - 22 righe, una per ogni soggetto
 
 ## Clustering e LOSO cross validation
 - Baseline_clustering.ipynb: notebook che esegue la LOSO corss validation sul dataset baselineFeatures.csv ed applica l'algoritmo di clustering k-means
    OUTPUT:
      -LOSO_Output_training: cartella contenente tutti i file degli n-1 soggetti su cui viene eseguito il k-means
      -LOSO_Output_testing: cartella contenente tutti i dati del soggetti che di volta in volta viene escluso dal training, sul quale viene usato predict
      -ids.csv: file contenente gli id di tutti i soggetti presenti nel cluster a cui, di volta in volta, appartiene il soggeto testato

Nella cartella TRAINING 
### Creazione dei dati per il training 
  
  - data_for_training.R: crea i dataset per il training a partire dagli id presenti sul file ids.csv. Confronta ogni id presente in ids.csv con gli id presenti nel file
                         taskFeatures.R ricostruendo così tutti i dati dei soggetti interessati
     OUTPUT:
      - Training_data: cartella contenente i dataset per il training -> Sono n file che contengono solamente le informazioni dei soggetti presenti mel cluster

### Training
  - tuning_cluster.R: Script per creare e addestrare un classificatore per ogni file presente nella cartella "Training_data"
   
```bash
Rscript tuning_cluster.R 1 models/models.txt <output_folder>&>log.txt &
```
dove, 1 è il numero di run, <output_folder> è il nome della cartella i cui verrà salvato l'output. 

Esempio:    
```bash
Rscript tuning_cluster.R 1 models/models.txt Result_training_valence &>training_valence.txt &
```

### Risultati
  - Results parsing.ipynb: notebook che legge i file di testo prodotti dal training, analizza le metriche e le riepiloga in un file csv      