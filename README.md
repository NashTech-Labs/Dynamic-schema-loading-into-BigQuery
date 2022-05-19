# DYNAMIC SCHEMA & DATA LOADING INTO BIGQUERY

## Usage 

Set these values in the `env_vars.sh` file

```bash
export PROJECT_ID=
export GCS_BUCKET_ID=
export DATASET=
export BIGQUERY_TABLE=
export GCS_BUCKET_PATH=json/data
export JSON_DATA_FILE=
```

Source the variables

```bash
source env_vars.sh
```


Run the main script

```bash
./loadTables.sh
```