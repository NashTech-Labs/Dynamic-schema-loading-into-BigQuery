#!/bin/bash

usage() {
  logm Usage " Must set environment variables for PROJECT_ID, JSON_DATA_FILE, GCS_PATH, BIGQUERY_TABLE, DATASET, GCS_BUCKET_ID, GOOGLE_APPLICATION_CREDENTIALS"
  exit 1
}

logm () {
Color_Off='\033[0m'       # Text Reset
# Regular colors
RED='\033[0;31m'         
GREEN='\033[0;32m'       
YELLOW='\033[0;33m'      
BLUE='\033[0;34m'        
WHITE='\033[0;37m'
PURPLE='\033[0;35m'       
# Bold colors
BRED='\033[1;31m'
BGREEN='\033[1;32m'
BYELLOW='\033[1;33m'
BBLUE='\033[1;34m'
BPURPLE='\033[1;35m'      
local TYPE=$1
shift
local MESSAGE=$@

case "$TYPE" in
    Error | error | ERROR) echo -e "${BRED}[$TYPE] $MESSAGE ${Color_Off}" ;;
    info | INFO | Info) echo -e "${BBLUE}[$TYPE] $MESSAGE ${Color_Off}" ;;
    LOG | Log | log) echo -e "${BGREEN}[$TYPE] $MESSAGE ${Color_Off}" ;;
    *) echo -e "${BPURPLE}[$TYPE] $MESSAGE ${Color_Off}" ;;
esac

}


if [[ -z "$PROJECT_ID" ]];then
  logm error "PROJECT_ID is not set"
  usage
fi

if [[ -z "$GCS_BUCKET_ID" ]];then
  logm error "GCS_BUCKET_ID is not set"
  usage
fi

if [[ -z "$DATASET" ]];then
  logm error "DATASET is not set"
  usage
fi

if [[ -z "$BIGQUERY_TABLE" ]];then
  logm error "BIGQUERY_TABLE is not set"
  usage
fi

if [[ -z "$GCS_PATH" ]];then
  logm error "GCS_PATH is not set"
  usage
fi

if [[ -z "$JSON_DATA_FILE" ]];then
  logm error "JSON_DATA_FILE is not set"
  usage
fi

create_dataset(){
    echo ""
 echo "Creating dataset into bigquery"
 read -p "Enter name of your Dataset. [default: $DATASET] " dataset

 if [[ -z "$dataset" ]];then
  dataset=$DATASET
 fi
 bq --location=us mk --dataset $PROJECT_ID:$dataset
}


load_data(){
    echo ""
echo "Listing Datasets in $PROJECT_ID project..."   
bq ls --datasets
read -p "Enter name of your Dataset. [default: $DATASET] " dataset
if [[ -z "$dataset" ]];then
  dataset=$DATASET
 fi

read -p "Choose name of your BigQuery Table to be created in $dataset Dataset. [default: $BIGQUERY_TABLE] " table

if [[ -z "$table" ]];then
  table=$BIGQUERY_TABLE
 fi


bq --location=us load \
--noreplace \
--autodetect \
--schema_update_option=ALLOW_FIELD_ADDITION \
--source_format=NEWLINE_DELIMITED_JSON \
$PROJECT_ID:$dataset.$table \
gs://$GCS_BUCKET_ID/$GCS_BUCKET_PATH/$JSON_DATA_FILE
}

append_load(){
echo ""
echo "Listing Datasets in $PROJECT_ID project..."   
bq ls --datasets
read -p "Enter name of your Dataset. [default: $DATASET] " dataset
if [[ -z "$dataset" ]];then
  dataset=$DATASET
 fi
 echo "Listing Tables in $dataset dataset...."
bq ls $dataset
read -p "Choose name of your BigQuery Table in $dataset Dataset. [default: $BIGQUERY_TABLE] " table

if [[ -z "$table" ]];then
  table=$BIGQUERY_TABLE
 fi

bq --location=us load \
--noreplace \
--autodetect \
--schema_update_option=ALLOW_FIELD_ADDITION \
--source_format=NEWLINE_DELIMITED_JSON \
$PROJECT_ID:$dataset.$table \
gs://$GCS_BUCKET_ID/$GCS_BUCKET_PATH/$JSON_DATA_FILE 

}

overwrite_load(){
echo ""
echo "Listing Datasets in $PROJECT_ID project..."   
bq ls --datasets
read -p "Enter name of your Dataset. [default: $DATASET] " dataset
if [[ -z "$dataset" ]];then
  dataset=$DATASET
 fi
 echo "Listing Tables in $dataset dataset...."
bq ls $dataset
read -p "Choose name of your BigQuery Table in $dataset Dataset. [default: $BIGQUERY_TABLE] " table

if [[ -z "$table" ]];then
  table=$BIGQUERY_TABLE
 fi

bq --location=us load \
--autodetect \
--schema_update_option=ALLOW_FIELD_ADDITION \
--source_format=NEWLINE_DELIMITED_JSON \
$PROJECT_ID:$dataset.$table \
gs://$GCS_BUCKET_ID/$GCS_BUCKET_PATH/$JSON_DATA_FILE

}

upload_local_data(){
echo ""
echo -e "Listing all json file in $(pwd) directory ... \n"
ls |grep json
echo ""
read -p "Enter the json data file: (like: data.json) " json
echo -e "\nUploading...."

cat $json|jq -c > $JSON_DATA_FILE

gsutil cp $JSON_DATA_FILE gs://$GCS_BUCKET_ID/$GCS_BUCKET_PATH/$JSON_DATA_FILE

rm $JSON_DATA_FILE
}

while true; do
        echo -e "\nOptions..."
        echo -e "\n1) Create a dataset in $PROJECT_ID \n2) Create table with JSON data \n3) Dynamic Append data in table \n4) Overwrite JSON Data into table \n5) Upload local JSON data into GCS bucket.\n"
        read -n 1 -p "Make a choice [  1,2,3,4,5 or q to exit  ]" yn
        echo ""
        case $yn in
            1 ) create_dataset;;
            2 ) load_data;;
            3 ) append_load;;
            4 ) overwrite_load;;
            5 ) upload_local_data;;
            [Qq]* ) echo -e "\nExit";exit 0;;
            * ) echo "Please provide a yes or no answer."
        esac
    done