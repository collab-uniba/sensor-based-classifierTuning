# SETUP
*Version of Python used*: 3.11.1 
*Version of R used*: 4.3.2 



## INSTALL
To install all the libraries needed to run the scripts use the command: 
   ```bash
   Rscript install.R
   ```



### HOW TO USE THE SCRIPTS
Below is a description of the folders contained in the replication package, as well as instructions for running the scripts and replicating the results reported in the study.



- **FEATURE FOLDER**  
This is the folder where you need to place the "SAM_valence(22sub)" and "SAM_arousal(22sub)" datasets in order to be able to create the training files later.



- **BASELINE FOLDER**  
Contains all the necessary scripts to extract baseline features. You need to put the raw data in the "DataSubjects" folder and use the following command:

    ```bash
    Rscript Baseline.R
    ```

The output of this script will be the "baselineFeatures.csv" file.# SETUP
*Version of Python used*: 3.11.1 

*Version of R used*: 4.3.2 



# INSTALL
To install all the libraries needed to run the scripts use the command: 
   ```bash
   Rscript install.R
   ```



# HOW TO USE THE SCRIPTS
Below is a description of the folders contained in the replication package, as well as instructions for running the scripts and replicating the results reported in the study.



## **FEATURE FOLDER**  
This is the folder where you need to place the "SAM_valence(22sub)" and "SAM_arousal(22sub)" datasets in order to be able to create the training files later.



- **BASELINE FOLDER**  
Contains all the necessary scripts to extract baseline features. You need to put the raw data in the "DataSubjects" folder and use the following command:

    ```bash
    Rscript Baseline.R
    ```

The output of this script will be the "baselineFeatures.csv" file.



## **CLUSTERING FOLDER**  
This folder contains all the necessary scripts to:

   - **Find the optimal number of clusters using the "Number_of_clusters.ipynb" notebook**, which will plot the optimal number of clusters using the Elbow Method and the Silhouette coefficient 
     based on the given "baselineFeatures.csv" file, as described in the study.
   
   - **Perform clustering on the baseline data using the "Baseline_clustering.ipynb" notebook.** This will plot the data distribution with two clusters for each run, each including n-1 subjects, 
     and will give the result of the "predict" method for the remaining subject. The subject IDs present in each cluster are stored in the output folder "ids_in_cluster."


 ### **IMPORTANT NOTE**: 
 The datasets provided in this replication package, containing only one instance, are insufficient on their own to determine the optimal number of clusters or to perform clustering effectively, as this will result in an error. A minimum of 6 subjects in "baselineFeatures.csv" is required to perform clustering with the included notebook.
**However, for full functionality of all scripts in this package, baseline data from all 22 subjects is recommended.**



## **TRAINING FOLDER**  
In this folder, there are:


 - *data_for_training_SAM.R*: 
 To run this script, use the following command:

    ```bash
    Rscript data_for_training_SAM.R
    ```

      This script creates the training files based on the results reported in "ids_in_cluster." 
      To create training files for valence or for arousal, you must specify the label you are interested in the script, in the "datas_to_csv_line" function, as follows:

      ```R
      task$valence
      ```
      or
      ```R
      task$arousal
      ```

      You must also specify the dataset from which to take the features. For valence features, it will be:

      ```R
      task_features <- data.frame(read.csv("<your_path>/Feature/SAM_valence(22sub).csv", header = TRUE, sep = ","))
      ```

      And for arousal features, it will be:

      ```R
      task_features <- data.frame(read.csv("<your_path>/Feature/SAM_arousal(22sub).csv", header = TRUE, sep = ","))
      ```

   The output files will be created in a folder named "Training_data."


 - *run_HoldOut.sh* runs the *tuning.R* script 10 times.


 - *Tuning.R* is a HoldOut classifier that trains each file contained in the "Training_data" folder using the model specified in the "models/model.rxt" path.
 The command used to run the training is:

      ```bash
      nohup ./run_HoldOut.sh models/models.txt <signal> <label> &> log.txt &
      ```
      where `<signal>` is used to select the features that have to be used for creating the model (it can be: EEG, E4, or ALL), and `<label>` is the class to classify (it can be valence or arousal). 


      For example, the command to replicate the results of our study, which is based on the E4 signal, for the valence label is:

      ```bash
      nohup ./run_HoldOut.sh models/models.txt E4 valence &> log.txt &
      ```

      For arousal is:

      ```bash
      nohup ./run_HoldOut.sh models/models.txt E4 arousal &> log.txt &
      ```

   As a result, a "Results" folder will be created, which will contain 22 runs, each corresponding to one subject. 
   Each of these runs will contain all 10 models trained for each algorithm present in the "models.txt" file.


 - *Results parsing.ipynb* 
 Is a jupyter notebook that reads all the eight files, corresponding to the eight models trained, and produce an unique .csv files containing, for each algorithm, the results of the single run. 



## **TESTING FOLDER**  
This folder contains:


 - *data_for_testing.R script*: it allows the creation of the testing files.  
 As with the "data_for_training_SAM.R" script, you need to specify the label considered and the input dataset from which the features are taken, 
 either "SAM_valence(22sub).csv" or "SAM_arousal(22sub).csv". In the "datas_to_csv_line" function, specify: `task$valence` or `task$arousal`.  
 The "Testing_data" folder will be created.



 - *testModel.R* 
 Is the script to run the trained model on the test dataset using the following command:

    ```bash
    Rscript testModel.R <input_test.csv> <best_model.rds> <prediction.csv> <result.csv>
    ```
     where `<input_test.csv>` is the input testing dataset, for example "Testing_data/1.csv", `<best_model.rds>` is the best model trained with "tuning.R," 
     and `<result.csv>` is the name of the file where the output metrics will be saved.

     > **Note**: In testModel.R, set the desired label by updating the excluded_predictors variable as follows:  
       ```R
       excluded_predictors <- c("id", <label>)
       ```
      where label is "valence" or "arousal".




- **CLUSTERING FOLDER**  
This folder contains all the necessary scripts to:

   - Find the optimal number of clusters using the "Number_of_clusters.ipynb" notebook, which will plot the optimal number of clusters using the Elbow Method and the Silhouette coefficient 
     based on the given "baselineFeatures.csv" file, as described in the study.
   
   - Perform clustering on the baseline data using the "Baseline_clustering.ipynb" notebook. This will plot the data distribution with two clusters for each run, each including n-1 subjects, 
     and will give the result of the "predict" method for the remaining subject. The subject IDs present in each cluster are stored in the output folder "ids_in_cluster."


  <IMPORTANT_NOTE: The datasets provided in this replication package, containing only one instance, are insufficient on their own to determine the optimal number of clusters
                    or to perform clustering effectively, as this will result in an error. A minimum of 6 subjects in "baselineFeatures.csv" is required to perform clustering with the included notebook. 
                    However, for full functionality of all scripts in this package, baseline data from all 22 subjects is recommended.>



- **TRAINING FOLDER**  
In this folder, there are:


 - *data_for_training_SAM.R* 
 To run this script, use the following command:

    ```bash
    Rscript data_for_training_SAM.R
    ```

      This script creates the training files based on the results reported in "ids_in_cluster." 
      To create training files for valence or for arousal, you must specify the label you are interested in the script, in the "datas_to_csv_line" function, as follows:

      ```R
      task$valence
      ```
      or
      ```R
      task$arousal
      ```

      You must also specify the dataset from which to take the features. For valence features, it will be:

      ```R
      task_features <- data.frame(read.csv("<your_path>/Feature/SAM_valence(22sub).csv", header = TRUE, sep = ","))
      ```

      And for arousal features, it will be:

      ```R
      task_features <- data.frame(read.csv("<your_path>/Feature/SAM_arousal(22sub).csv", header = TRUE, sep = ","))
      ```

   The output files will be created in a folder named "Training_data."


 - *run_HoldOut.sh* runs the *tuning.R* script 10 times.


 - *Tuning.R* is a HoldOut classifier that trains each file contained in the "Training_data" folder using the model specified in the "models/model.rxt" path.
 The command used to run the training is:

      ```bash
      nohup ./run_HoldOut.sh models/models.txt <signal> <label> &> log.txt &
      ```
      where `<signal>` is used to select the features that have to be used for creating the model (it can be: EEG, E4, or ALL), and `<label>` is the class to classify (it can be valence or arousal). 


      For example, the command to replicate the results of our study, which is based on the E4 signal, for the valence label is:

      ```bash
      nohup ./run_HoldOut.sh models/models.txt E4 valence &> log.txt &
      ```

      For arousal, it will be:

      ```bash
      nohup ./run_HoldOut.sh models/models.txt E4 arousal &> log.txt &
      ```

   As a result, a "Results" folder will be created, which will contain 22 runs, each corresponding to one subject. 
   Each of these runs will contain all 10 models trained for each algorithm present in the "models.txt" file.


 - *Results parsing.ipynb* 
 Is a jupyter notebook that reads all the eight files, corresponding to the eight models trained, and produce an unique .csv files containing, for each algorithm, the results of the single run. 



- **TESTING FOLDER**  
This folder contains:


 - *data_for_testing.R script*: it allows the creation of the testing files.  
 As with the "data_for_training_SAM.R" script, you need to specify the label considered and the input dataset from which the features are taken, 
 either "SAM_valence(22sub).csv" or "SAM_arousal(22sub).csv". In the "datas_to_csv_line" function, specify: `task$valence` or `task$arousal`.  
 The "Testing_data" folder will be created.



 - *testModel.R* 
 Is the script to run the trained model on the test dataset using the following command:

    ```bash
    Rscript testModel.R <input_test.csv> <best_model.rds> <prediction.csv> <result.csv>
    ```
 where `<input_test.csv>` is the input testing dataset, for example "Testing_data/1.csv", `<best_model.rds>` is the best model trained with "tuning.R," 
 and `<result.csv>` is the name of the file where the output metrics will be saved.

 > Reminder: In testModel.R, set the desired label by updating the excluded_predictors variable as follows:  
   ```R
   excluded_predictors <- c("id", <label>)
   ```
 > replace <label> with either "valence" or "arousal".
