#!/bin/bash
BUCKET_NAME="dtc_data_lake_de_zoomcamp_nytaxi_abd"
FILE_PATH="/root/myrole/data-engineering-zoomcamp-main/05-batch/code/taxi_zone_lookup.csv"

echo "Uploading data to GCS..."
gsutil -m cp -r $FILE_PATH gs://project-data-eng-2025/raw/taxi_zone_lookup.csv

echo "File successfully uploaded!"
