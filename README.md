# sensor-based-classifierTuning


  ### How to use the scripts

- Tuning_10k : Script to build and train the classifier with 10 fold cross validation

- Run_HoldOut_10k : is the Script to Run 10 times the script Tuning_10k; after that the result will be 10 model trained with ten fold cross validation 

```bash
nohup ./run_HoldOut_10k.sh <input.csv> models/models.txt <output_folder> <label> &> log.txt &
```
where, \<input> is the input dataset,  <output_folder> is the name of the folder where saving the output, \<label> is the class to classify (valence for example). 

For example: 

```bash
nohup bash run_HoldOut_10k.sh Train_Empatica_10sec_valence_noicse.csv models/models.txt results_10sec_valence_noicse valence &>10sec_noicse.txt &
```

- Results parsing.ipynb The script essentially parses and summarizes the performance metrics from multiple text files, calculates mean values, and exports the summarized data to a CSV file.  This is useful to uderstand which is the best model!

- TestModel : is the script to Run the trained model on the test Dataset

```bash
Rscript testModel.R <input_test.csv> <best_model.rds> <prediction.csv> <result.csv>
```
  where, <input_test.csv> is the input  testing dataset,  <best_model.rds> is the best model trained with the command before, <result.csv> is the name of the file where saving the output metrics. 
