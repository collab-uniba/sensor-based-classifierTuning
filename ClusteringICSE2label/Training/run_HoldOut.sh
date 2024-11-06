#!/bin/bash

# read and trim params

models_file=$(echo $1 | xargs)
signal=$(echo $2 | xargs)
label=$(echo $3| xargs)


if [[ -n "$models_file" ]]; then
    printf " === Starting the tuning of classifiers' params (this may take a while...)\n"
    start_time=$(date +"%Y-%m-%d_%H.%M")
    for i in `seq 1 10`;
    do
        now=$(date +"%Y-%m-%d %H.%M")
        echo " :: Run $i -- started at $now"
        time Rscript tuning.R $i $models_file $signal $label
    done   

    echo " Done"
else
    echo "Argument error: models and/or input file not given."
fi