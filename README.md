Here’s a simplified breakdown of your end-to-end data pipeline:  

### **1. Data Ingestion (Batch Processing)**  
- **Google Cloud Storage (GCS)** → Stores raw data.  
- **Terraform** → Provisions infrastructure (GCS, BigQuery, Airflow).  
- **Docker** → Containerizes the pipeline.  
- **Apache Airflow** → Orchestrates batch processing.  

### **2. Data Processing**  
- **PySpark** → Cleans and processes raw data.  
- **Airflow DAG** → Moves processed data to BigQuery.  

### **3. Data Warehousing**  
- **Google BigQuery** → Stores structured, partitioned, and clustered data.  

### **4. Data Transformation**  
- **dbt (Data Build Tool)** → Applies SQL-based transformations on BigQuery.  

### **5. Data Visualization**  
- **Power BI** → Connects to BigQuery and creates dashboards.  

### **6. Infrastructure as Code**  
- **Terraform** → Deploys and manages the infrastructure.  

Here’s a **detailed explanation** of each step in your **end-to-end data pipeline** using GCP and modern data tools:

---

## **1. Data Ingestion (Batch Processing)**
This is the first step where raw data is collected and stored before processing.

- **Google Cloud Storage (GCS)**:  
  - Acts as a **data lake** where raw files (CSV, JSON, Parquet, etc.) are stored.  
  - You can upload data manually or automate it via scripts/API.  

- **Terraform (Infrastructure as Code - IaC)**:  
  - Automates the provisioning of GCP resources like **GCS, BigQuery, and Airflow**.  
  - Ensures infrastructure is reproducible and version-controlled.  

- **Docker (Containerization)**:  
  - Packages applications and dependencies into **containers** for consistency across environments.  
  - Helps deploy Airflow, PySpark jobs, and dbt in an isolated environment.  

- **Apache Airflow (Workflow Orchestration)**:  
  - Manages and schedules batch jobs using **DAGs (Directed Acyclic Graphs)**.  
  - Defines steps like:  
    1. Extract data from **GCS**.  
    2. Process it using **PySpark**.  
    3. Load it into **BigQuery**.  

---

## **2. Data Processing**
After ingestion, data needs cleaning and transformation before storage.

- **PySpark (Batch Processing Framework)**:  
  - Runs distributed processing for large datasets.  
  - Performs data cleaning, filtering, aggregation, and transformations.  
  - Converts raw data into structured format before loading into BigQuery.  

- **Airflow DAGs (Task Automation)**:  
  - Automates PySpark processing.  
  - Moves processed data from GCS to BigQuery in an **ETL pipeline**.  

---

## **3. Data Warehousing**
Once processed, data is stored in a structured format for easy querying.

- **Google BigQuery (Cloud Data Warehouse)**:  
  - Stores **processed, structured data**.  
  - Supports **partitioning (by date)** and **clustering (by category)** to improve performance.  
  - Handles **large-scale analytics** with SQL queries.  

---

## **4. Data Transformation**
After storing the data, transformations are applied to prepare it for analytics.

- **dbt (Data Build Tool)**:  
  - Defines transformations using **SQL models**.  
  - Creates **views and tables** in BigQuery for analysis.  
  - Automates **incremental updates** to optimize queries.  

Example:  
- Raw table: **user_clicks_raw**  
- Transformed table: **daily_user_activity_summary**  

---

## **5. Data Visualization**
Now that the data is structured and transformed, it’s ready for reporting.

- **Power BI (Business Intelligence Tool)**:  
  - Connects to **BigQuery** for real-time dashboards.  
  - Creates **two types of visualizations**:  
    1. **Categorical Distribution Graph** (e.g., Top 10 products by sales).  
    2. **Time Series Graph** (e.g., Sales growth over time).  
  - Ensures interactive and easy-to-read dashboards.  

---

## **6. Infrastructure as Code (Automation & Deployment)**
To keep the pipeline scalable and reproducible, infrastructure is automated.

- **Terraform**:  
  - Deploys **GCS, BigQuery, Airflow, dbt, and other resources** with a single script.  
  - Ensures everything is **version-controlled and repeatable**.  

---

## **Final Workflow Summary**
1. **Raw Data** → Stored in **GCS**.  
2. **Airflow DAG** → Triggers **PySpark** processing.  
3. **PySpark** → Cleans and loads data into **BigQuery**.  
4. **dbt** → Transforms data for analytics.  
5. **Power BI** → Visualizes insights for decision-making.  

---

This **end-to-end pipeline** ensures **automated, scalable, and efficient data processing** using GCP tools.


### **Step 1: Data Ingestion (Batch Processing) - Detailed Breakdown**  
The first step is to **ingest raw data** and store it in a **data lake** for further processing. This step ensures that data is collected, stored securely, and is available for processing in a structured way.

---

## **📌 Objective of This Step**  
We need to collect raw data from a source, store it in **Google Cloud Storage (GCS)**, and automate infrastructure deployment using **Terraform**.

---

## **📂 Example Use Case: E-commerce Sales Data**  
Let's assume we are working with an **e-commerce dataset** that contains **customer transactions**. The data is generated by the online store daily in CSV format.  
   
**Example raw data file (`sales_data_2025-03-25.csv`)**:  
| Order_ID | Customer_ID | Product | Category | Price | Quantity | Timestamp           |  
|----------|------------|---------|----------|-------|----------|---------------------|  
| 1001     | 500        | Laptop  | Electronics | 1200  | 1        | 2025-03-25 08:30:00 |  
| 1002     | 501        | Phone   | Electronics | 800   | 2        | 2025-03-25 09:00:00 |  

---

## **🛠️ Technologies Used & Why?**  

| Technology  | Purpose  | How We Use It?  |  
|-------------|----------|----------------|  
| **Google Cloud Storage (GCS)** | Stores raw data | Upload CSV files to a **dedicated bucket** for processing |  
| **Terraform (IaC)** | Automates cloud resource creation | Creates the GCS bucket and IAM roles programmatically |  
| **Docker** | Ensures consistent environment | Runs Airflow in a **containerized setup** |  
| **Apache Airflow** | Orchestrates the pipeline | Automates file ingestion from a local system to GCS |  
| **Bash (Shell Scripting)** | Uploads files programmatically | Automates file transfers to GCS |  

---

## **🛠️ Step-by-Step Implementation**

### **1️⃣ Create Google Cloud Storage (GCS) Bucket**  
Before uploading files, we need a **GCS bucket** to store raw data.

- **Terraform Script to Create GCS Bucket (`gcs.tf`)**:
```hcl
resource "google_storage_bucket" "raw_data_bucket" {
  name     = "ecommerce-raw-data"
  location = "US"
  storage_class = "STANDARD"
}
```
✅ **What this does?**  
- Creates a **GCS bucket** named `"ecommerce-raw-data"`.  
- Sets the **storage class** to `"STANDARD"` for cost efficiency.  

---

### **2️⃣ Upload Data to GCS (Using Bash Script & Airflow)**  
Once the bucket is created, we need to **upload raw CSV files**.

- **Bash Script to Upload Data (`upload_data.sh`)**:
```bash
#!/bin/bash
BUCKET_NAME="ecommerce-raw-data"
FILE_PATH="data/sales_data_2025-03-25.csv"

# Upload file to GCS
gsutil cp $FILE_PATH gs://$BUCKET_NAME/raw/
echo "File uploaded successfully to GCS: $BUCKET_NAME"
```
✅ **What this does?**  
- Uses **`gsutil cp`** to copy a local file (`sales_data_2025-03-25.csv`) to GCS.  
- Stores the file inside a `"raw/"` directory in GCS.  

---

### **3️⃣ Automate File Upload with Apache Airflow**  
We don’t want to manually run the script daily. Instead, we use **Airflow** to automate the process.

- **Airflow DAG to Upload Data (`upload_to_gcs.py`)**:
```python
from airflow import DAG
from airflow.operators.bash import BashOperator
from datetime import datetime

# Define default arguments
default_args = {
    'owner': 'airflow',
    'start_date': datetime(2025, 3, 25),
    'retries': 1
}

# Define the DAG
dag = DAG(
    dag_id='upload_sales_data_to_gcs',
    default_args=default_args,
    schedule_interval='@daily',
    catchup=False
)

# Define the task
upload_task = BashOperator(
    task_id='upload_csv_to_gcs',
    bash_command='bash /opt/airflow/scripts/upload_data.sh',
    dag=dag
)

upload_task
```
✅ **What this does?**  
- **Schedules** the upload task to run **daily**.  
- **Triggers the Bash script** (`upload_data.sh`) to copy files to GCS.  

---

### **4️⃣ Verify Data in GCS**  
After execution, check if the file is uploaded:  
```bash
gsutil ls gs://ecommerce-raw-data/raw/
```
🔹 Expected Output:  
```
gs://ecommerce-raw-data/raw/sales_data_2025-03-25.csv
```
---

## **🎯 Summary of Step 1**
✔️ **Created a GCS bucket** for raw data storage using **Terraform**.  
✔️ **Wrote a Bash script** to upload CSV files to **GCS**.  
✔️ **Automated the upload process** using **Apache Airflow DAGs**.  
✔️ **Ensured repeatability** using **Docker** and **Terraform**.  

---

## **Next Steps**
✅ Now that the raw data is in GCS, the next step is **processing it using PySpark** before loading it into **BigQuery**. Let me know if you want a similar detailed breakdown for the next step!

If we want to **fully automate Step 1**, including **Terraform deployment, data upload, and orchestration**, we need to containerize the entire process using **Docker**. Here’s how we can achieve that:

---

# **📌 High-Level Overview**
We will create a **Dockerized environment** that automates:
1. **Infrastructure deployment** using Terraform.  
2. **File upload to GCS** using a Bash script.  
3. **Orchestration** using Apache Airflow to trigger the upload task daily.  

---

## **📂 Folder Structure**
```
data-pipeline/
│── airflow/                      # Airflow-related files
│   ├── dags/                     # DAGs for automation
│   │   ├── upload_to_gcs.py      # DAG to automate file upload
│   ├── Dockerfile                 # Airflow Docker setup
│── terraform/                     # Terraform files
│   ├── main.tf                    # Terraform script to create resources
│   ├── variables.tf                # Terraform variables
│   ├── terraform.sh                # Shell script to apply Terraform
│── scripts/                        # Helper scripts
│   ├── upload_data.sh              # Script to upload data to GCS
│── docker-compose.yml               # Docker Compose to run everything
│── .env                             # Environment variables
```

---

# **🛠️ Step-by-Step Implementation**

### **1️⃣ Write the Terraform Configuration**
Create the **Terraform script** (`terraform/main.tf`) to set up GCS:

```hcl
provider "google" {
  project = var.project_id
  region  = var.region
}

resource "google_storage_bucket" "raw_data_bucket" {
  name     = "ecommerce-raw-data"
  location = var.region
  storage_class = "STANDARD"
}
```
✅ **This creates a GCS bucket in GCP.**  

---

### **2️⃣ Automate Terraform Deployment**
Create a **shell script** (`terraform/terraform.sh`) to automate Terraform execution:

```bash
#!/bin/bash
echo "Initializing Terraform..."
terraform init

echo "Applying Terraform..."
terraform apply -auto-approve

echo "Terraform deployment completed."
```
✅ **This script automatically initializes and applies Terraform.**  

---

### **3️⃣ Automate Data Upload to GCS**
Create a **Bash script** (`scripts/upload_data.sh`) to upload files:

```bash
#!/bin/bash
BUCKET_NAME="ecommerce-raw-data"
FILE_PATH="/opt/airflow/data/sales_data_$(date +%Y-%m-%d).csv"

echo "Uploading data to GCS..."
gsutil cp $FILE_PATH gs://$BUCKET_NAME/raw/

echo "File successfully uploaded!"
```
✅ **This uploads a CSV file with the current date to GCS.**  

---

### **4️⃣ Create Airflow DAG for Automation**
Create an **Airflow DAG** (`airflow/dags/upload_to_gcs.py`):

```python
from airflow import DAG
from airflow.operators.bash import BashOperator
from datetime import datetime

default_args = {
    'owner': 'airflow',
    'start_date': datetime(2025, 3, 25),
    'retries': 1
}

dag = DAG(
    dag_id='upload_sales_data_to_gcs',
    default_args=default_args,
    schedule_interval='@daily',
    catchup=False
)

upload_task = BashOperator(
    task_id='upload_csv_to_gcs',
    bash_command='bash /opt/airflow/scripts/upload_data.sh',
    dag=dag
)

upload_task
```
✅ **This DAG schedules the upload task daily.**  

---

### **5️⃣ Create Dockerfile for Airflow**
Create an **Airflow Dockerfile** (`airflow/Dockerfile`):

```dockerfile
FROM apache/airflow:2.5.1

USER root

# Install Google Cloud CLI for GCS operations
RUN apt-get update && apt-get install -y google-cloud-sdk

# Set working directory
WORKDIR /opt/airflow

# Copy scripts and DAGs
COPY dags /opt/airflow/dags
COPY scripts /opt/airflow/scripts
COPY terraform /opt/airflow/terraform

# Change permissions
RUN chmod +x /opt/airflow/scripts/upload_data.sh
RUN chmod +x /opt/airflow/terraform/terraform.sh

# Install dependencies
RUN pip install apache-airflow-providers-google

# Start Airflow
CMD ["airflow", "scheduler"]
```
✅ **This image sets up Airflow with Google Cloud SDK and required scripts.**  

---

### **6️⃣ Define Docker Compose to Run Everything**
Create a **Docker Compose file** (`docker-compose.yml`) to run all components:

```yaml
version: '3.8'
services:
  terraform:
    image: hashicorp/terraform:latest
    container_name: terraform
    working_dir: /opt/airflow/terraform
    volumes:
      - ./terraform:/opt/airflow/terraform
    entrypoint: ["/bin/sh", "-c", "./terraform.sh"]

  airflow:
    build: ./airflow
    container_name: airflow
    restart: always
    environment:
      - AIRFLOW__CORE__EXECUTOR=SequentialExecutor
      - GOOGLE_APPLICATION_CREDENTIALS=/opt/airflow/keys/gcp-credentials.json
    volumes:
      - ./airflow/dags:/opt/airflow/dags
      - ./scripts:/opt/airflow/scripts
      - ./terraform:/opt/airflow/terraform
    ports:
      - "8080:8080"
    depends_on:
      - terraform
```
✅ **This setup ensures:**  
- **Terraform runs first** to create infrastructure.  
- **Airflow starts automatically** and schedules the upload task.  

---

### **7️⃣ Run Everything**
Now, simply run the following commands:

```bash
# Start the whole pipeline
docker-compose up --build
```
---

## **✅ Final Workflow**
1️⃣ **Terraform runs inside Docker** → Creates GCS bucket.  
2️⃣ **Airflow container starts** and schedules data upload.  
3️⃣ **Airflow executes the DAG** → Calls `upload_data.sh`.  
4️⃣ **Bash script uploads CSV files to GCS** automatically.  

---

## **🚀 Advantages of This Setup**
✔ **Fully automated** → No manual steps needed.  
✔ **Containerized** → Works consistently across machines.  
✔ **Infrastructure as Code (IaC)** → Easily reproducible.  
✔ **Orchestrated** → Airflow ensures proper scheduling.  

---

This **Dockerized data ingestion process** ensures a **scalable, repeatable, and automated pipeline** for storing raw data in GCS. 

# **📌 Step 2: Data Processing (Batch Processing with PySpark & dbt)**  

Now that raw data is stored in **Google Cloud Storage (GCS)**, we need to **process and clean** it before loading it into **Google BigQuery (BQ)**. This ensures that data is structured, optimized, and ready for analytics.

---

## **🎯 Objective of Step 2**  
1. **Extract** raw data from GCS.  
2. **Clean & transform** it using **PySpark**.  
3. **Load the processed data** into **Google BigQuery (BQ)**.  
4. **Use dbt (Data Build Tool)** for further transformations inside BigQuery.  

---

## **📂 Example Use Case: E-commerce Sales Data**  
The raw data (`sales_data_YYYY-MM-DD.csv`) from Step 1 has the following issues:  
✅ **Missing values** (e.g., some customers don't have a Customer_ID).  
✅ **Duplicate records** (e.g., repeated transactions).  
✅ **Inconsistent formatting** (e.g., date columns have mixed formats).  
✅ **Unnecessary columns** that won’t be used in analytics.  

**Example Raw Data (Before Processing)**:
| Order_ID | Customer_ID | Product  | Category    | Price | Quantity | Timestamp           |  
|----------|------------|----------|------------|-------|----------|---------------------|  
| 1001     | 500        | Laptop   | Electronics | 1200  | 1        | 2025-03-25 08:30:00 |  
| 1002     | NULL       | Phone    | Electronics | 800   | 2        | 2025-03-25 09:00:00 |  
| 1003     | 500        | Laptop   | Electronics | 1200  | 1        | 2025-03-25 08:30:00 |  

**Example Processed Data (After PySpark Cleaning & Transformation)**:
| Order_ID | Customer_ID | Product  | Category    | Total_Price | Order_Date  |  
|----------|------------|----------|------------|------------|------------|  
| 1001     | 500        | Laptop   | Electronics | 1200       | 2025-03-25 |  
| 1002     | Unknown    | Phone    | Electronics | 1600       | 2025-03-25 |  

---

## **🛠️ Technologies Used & Why?**

| Technology  | Purpose  | How We Use It?  |  
|-------------|----------|----------------|  
| **PySpark** | Big data processing | Reads raw data from GCS, cleans it, and transforms it |  
| **Google BigQuery (BQ)** | Cloud data warehouse | Stores the processed data for analytics |  
| **dbt (Data Build Tool)** | Data transformation inside BQ | Performs final modeling and aggregations |  
| **Apache Airflow** | Orchestration | Automates the PySpark job and dbt execution |  

---

# **🛠️ Step-by-Step Implementation**

### **1️⃣ Read Raw Data from GCS Using PySpark**  
We'll create a PySpark job to read data from GCS.

📌 **PySpark Script (`scripts/process_sales_data.py`)**:
```python
from pyspark.sql import SparkSession
from pyspark.sql.functions import col, when, sum, to_date

# Initialize Spark Session
spark = SparkSession.builder \
    .appName("SalesDataProcessing") \
    .getOrCreate()

# Define GCS source and BQ destination
gcs_path = "gs://ecommerce-raw-data/raw/sales_data_2025-03-25.csv"
bq_table = "ecommerce_dataset.processed_sales"

# Read raw CSV file from GCS
df = spark.read.option("header", "true").csv(gcs_path)

# Clean the data
df_cleaned = df.dropDuplicates(["Order_ID"]).fillna({"Customer_ID": "Unknown"})

# Transformations
df_transformed = df_cleaned.withColumn("Total_Price", col("Price") * col("Quantity")) \
    .withColumn("Order_Date", to_date(col("Timestamp")))

# Save to BigQuery
df_transformed.write \
    .format("bigquery") \
    .option("temporaryGcsBucket", "ecommerce-temp-bucket") \
    .mode("overwrite") \
    .save(bq_table)

print("✅ Data processing completed and saved to BigQuery!")
```

✅ **This script does the following:**  
- **Reads raw data from GCS** (`sales_data_YYYY-MM-DD.csv`).  
- **Removes duplicates** based on `Order_ID`.  
- **Fills missing values** (`Customer_ID` → `"Unknown"`).  
- **Calculates total price** (`Price * Quantity`).  
- **Converts timestamp into a clean date format** (`Order_Date`).  
- **Writes the transformed data to BigQuery**.

---

### **2️⃣ Automate Processing with Airflow DAG**
We don’t want to run this script manually. Instead, we automate it with **Airflow**.

📌 **Airflow DAG (`airflow/dags/process_data.py`)**:
```python
from airflow import DAG
from airflow.operators.bash import BashOperator
from datetime import datetime

default_args = {
    'owner': 'airflow',
    'start_date': datetime(2025, 3, 26),
    'retries': 1
}

dag = DAG(
    dag_id='process_sales_data',
    default_args=default_args,
    schedule_interval='@daily',
    catchup=False
)

process_task = BashOperator(
    task_id='run_pyspark_processing',
    bash_command='python /opt/airflow/scripts/process_sales_data.py',
    dag=dag
)

process_task
```

✅ **This Airflow DAG does the following:**  
- Runs the PySpark script **daily**.  
- Ensures that data is cleaned and **loaded into BigQuery** automatically.  

---

### **3️⃣ Further Transform Data in BigQuery Using dbt**
Once data is in **BigQuery**, we can perform additional transformations using **dbt**.

📌 **dbt Model (`dbt/models/clean_sales_data.sql`)**:
```sql
WITH transformed AS (
    SELECT
        Order_ID,
        Customer_ID,
        Product,
        Category,
        Total_Price,
        Order_Date
    FROM `ecommerce_dataset.processed_sales`
)
SELECT * FROM transformed
WHERE Total_Price > 0
```

✅ **This dbt model does the following:**  
- Removes any **invalid transactions** (where `Total_Price <= 0`).  
- Ensures that only **clean data** is available for the dashboard.  

---

### **4️⃣ Automate dbt Execution with Airflow**
📌 **Airflow DAG (`airflow/dags/dbt_transformation.py`)**:
```python
from airflow import DAG
from airflow.operators.bash import BashOperator
from datetime import datetime

default_args = {
    'owner': 'airflow',
    'start_date': datetime(2025, 3, 26),
    'retries': 1
}

dag = DAG(
    dag_id='run_dbt_transformation',
    default_args=default_args,
    schedule_interval='@daily',
    catchup=False
)

dbt_task = BashOperator(
    task_id='run_dbt',
    bash_command='dbt run --profiles-dir /opt/airflow/dbt',
    dag=dag
)

dbt_task
```
✅ **This DAG runs the dbt transformation daily after PySpark processing.**  

---

# **🎯 Summary of Step 2**
✔ **PySpark reads raw data from GCS** → Cleans and processes it.  
✔ **Writes transformed data into BigQuery**.  
✔ **dbt performs final transformations inside BigQuery**.  
✔ **Airflow automates the entire pipeline**.  

---

# **🚀 Next Steps**
✅ Now that we have **cleaned and structured data in BigQuery**, we can move to **Step 3: Dashboard Creation using Power BI**. 

# **📦 Containerizing & Automating Step 2 with Dataproc & Docker**  

Since we want **full automation**, we will:  
✅ **Containerize the entire data processing pipeline** using **Docker**.  
✅ **Use Terraform** to provision **Google Dataproc** (a managed Spark service on GCP).  
✅ **Use Airflow** to trigger Dataproc jobs automatically.  

---

## **🛠️ Tech Stack for Automation**
| Technology  | Purpose  |
|-------------|----------|
| **Docker**  | Containerizes the PySpark job |
| **Google Dataproc** | Runs PySpark in a managed environment |
| **Terraform** | Creates Dataproc clusters automatically |
| **Apache Airflow** | Orchestrates Dataproc jobs |
| **Google Cloud Storage (GCS)** | Stores raw & intermediate data |
| **Google BigQuery (BQ)** | Stores final structured data |

---

## **📂 Step-by-Step Implementation**

### **1️⃣ Containerizing the PySpark Job**
We will run our **PySpark job inside a Docker container** so it can be deployed consistently.

📌 **Project Structure**:
```
├── docker/
│   ├── Dockerfile
│   ├── process_sales_data.py
├── terraform/
│   ├── main.tf
│   ├── dataproc.tf
│   ├── variables.tf
├── airflow/
│   ├── dags/
│   │   ├── process_data.py
├── dbt/
│   ├── models/
│   │   ├── clean_sales_data.sql
```

---

📌 **Dockerfile for PySpark Job** (`docker/Dockerfile`):
```dockerfile
FROM gcr.io/dataproc-oss/pyspark:latest

WORKDIR /app

COPY process_sales_data.py .

CMD ["spark-submit", "process_sales_data.py"]
```
✅ **This builds a container that runs PySpark on Dataproc.**

---

📌 **PySpark Job for Data Processing** (`docker/process_sales_data.py`):
```python
from pyspark.sql import SparkSession
from pyspark.sql.functions import col, when, to_date

# Initialize SparkSession
spark = SparkSession.builder.appName("SalesDataProcessing").getOrCreate()

# Define paths
gcs_input = "gs://ecommerce-raw-data/raw/sales_data.csv"
gcs_temp_bucket = "ecommerce-temp-bucket"
bq_table = "ecommerce_dataset.processed_sales"

# Read raw data from GCS
df = spark.read.option("header", "true").csv(gcs_input)

# Clean and transform data
df_cleaned = df.dropDuplicates(["Order_ID"]).fillna({"Customer_ID": "Unknown"})
df_transformed = df_cleaned.withColumn("Total_Price", col("Price") * col("Quantity")) \
    .withColumn("Order_Date", to_date(col("Timestamp")))

# Save to BigQuery
df_transformed.write \
    .format("bigquery") \
    .option("temporaryGcsBucket", gcs_temp_bucket) \
    .mode("overwrite") \
    .save(bq_table)

print("✅ Data processing completed and saved to BigQuery!")
```
✅ **This script reads data from GCS, processes it, and loads it into BigQuery.**

---

### **2️⃣ Automating Dataproc Cluster Creation with Terraform**
We use **Terraform** to automatically create a **Dataproc cluster**.

📌 **Terraform Configuration (`terraform/dataproc.tf`)**:
```hcl
provider "google" {
  project = "your-gcp-project-id"
  region  = "us-central1"
}

resource "google_dataproc_cluster" "dataproc-cluster" {
  name   = "dataproc-cluster"
  region = "us-central1"

  cluster_config {
    master_config {
      num_instances = 1
      machine_type  = "n1-standard-4"
    }

    worker_config {
      num_instances = 2
      machine_type  = "n1-standard-4"
    }

    software_config {
      image_version = "2.0-debian10"
      optional_components = ["JUPYTER"]
    }
  }
}
```
✅ **This creates a Dataproc cluster with 1 master node and 2 worker nodes.**

📌 **Apply Terraform**:
```bash
cd terraform
terraform init
terraform apply -auto-approve
```
✅ **This provisions the Dataproc cluster automatically.**

---

### **3️⃣ Running the PySpark Job on Dataproc**
Once the cluster is up, we **submit our PySpark job**.

📌 **Submit PySpark Job to Dataproc**:
```bash
gcloud dataproc jobs submit pyspark gs://ecommerce-raw-data/scripts/process_sales_data.py \
    --cluster=dataproc-cluster \
    --region=us-central1 \
    --async
```
✅ **This runs our PySpark script on Dataproc.**

---

### **4️⃣ Automating the Entire Process with Airflow**
Instead of manually running the job, we use **Apache Airflow**.

📌 **Airflow DAG (`airflow/dags/process_data.py`)**:
```python
from airflow import DAG
from airflow.providers.google.cloud.operators.dataproc import DataprocSubmitJobOperator
from datetime import datetime

default_args = {
    'owner': 'airflow',
    'start_date': datetime(2025, 3, 26),
    'retries': 1
}

dag = DAG(
    dag_id='process_sales_data',
    default_args=default_args,
    schedule_interval='@daily',
    catchup=False
)

dataproc_job = {
    "reference": {"project_id": "your-gcp-project-id"},
    "placement": {"cluster_name": "dataproc-cluster"},
    "pyspark_job": {"main_python_file_uri": "gs://ecommerce-raw-data/scripts/process_sales_data.py"},
}

submit_job = DataprocSubmitJobOperator(
    task_id="submit_dataproc_job",
    job=dataproc_job,
    region="us-central1",
    project_id="your-gcp-project-id",
    dag=dag
)

submit_job
```
✅ **This DAG triggers our Dataproc job every day.**

---

### **5️⃣ Automating dbt Transformations**
Once PySpark processing is done, we trigger **dbt** to run transformations inside BigQuery.

📌 **Airflow DAG for dbt (`airflow/dags/dbt_transformation.py`)**:
```python
from airflow import DAG
from airflow.operators.bash import BashOperator
from datetime import datetime

default_args = {
    'owner': 'airflow',
    'start_date': datetime(2025, 3, 26),
    'retries': 1
}

dag = DAG(
    dag_id='run_dbt_transformation',
    default_args=default_args,
    schedule_interval='@daily',
    catchup=False
)

dbt_task = BashOperator(
    task_id='run_dbt',
    bash_command='dbt run --profiles-dir /opt/airflow/dbt',
    dag=dag
)

dbt_task
```
✅ **This DAG runs dbt models automatically after PySpark processing.**

---

## **🎯 Summary of Full Automation**
✔ **Step 1: Terraform provisions the Dataproc cluster.**  
✔ **Step 2: PySpark job is containerized with Docker & runs on Dataproc.**  
✔ **Step 3: Airflow schedules & submits PySpark jobs to Dataproc.**  
✔ **Step 4: Processed data is stored in BigQuery.**  
✔ **Step 5: dbt runs additional transformations inside BigQuery.**  

---

# **🚀 Next Steps**
✅ Now that we have **fully automated data processing**, we can move to **Step 3: Dashboard Creation using Power BI**. 


# **📊 Step 3: Dashboard Creation with Power BI**  

Now that the **processed and transformed data** is stored in **Google BigQuery**, we will build a **Power BI dashboard** to visualize it.

---

## **📂 Overview of the Process**
✅ **Connect Power BI to Google BigQuery**  
✅ **Create Data Model & Transform Data if Needed**  
✅ **Build Visualizations (Two Required Tiles)**  
✅ **Publish & Share the Dashboard**  

---

## **1️⃣ Connecting Power BI to Google BigQuery**
Power BI **natively supports** Google BigQuery, but we need to configure it properly.

📌 **Steps to Connect**:  
1️⃣ Open Power BI and go to **"Home" → "Get Data"**  
2️⃣ Search for **Google BigQuery** and select it  
3️⃣ Sign in with your **Google Cloud account**  
4️⃣ Select the **BigQuery dataset** where your transformed data is stored  
5️⃣ Load the data **directly** or use **Power Query to transform it further**  

✅ **Example Query to Import Data**:  
```sql
SELECT 
    Order_ID, 
    Customer_ID, 
    Order_Date, 
    Total_Price, 
    Product_Category
FROM `ecommerce_dataset.processed_sales`
```
📌 **Tip:** Use **DirectQuery Mode** if you want real-time updates from BigQuery.

---

## **2️⃣ Data Modeling & Transformation in Power BI**
After importing data, we may need to clean and model it.

📌 **Key Tasks in Power BI's Power Query Editor**:
- **Rename columns** for better readability  
- **Convert data types** (e.g., ensure "Order_Date" is a Date type)  
- **Create calculated columns** (e.g., profit margins, customer segments)  
- **Add measures using DAX**  

✅ **Example DAX Measure: Total Sales per Month**
```DAX
Total_Sales = SUM('processed_sales'[Total_Price])
```
✅ **Example DAX Measure: Sales Growth Rate**
```DAX
Sales_Growth = 
    DIVIDE(
        [Total_Sales] - CALCULATE([Total_Sales], PREVIOUSMONTH('processed_sales'[Order_Date])),
        CALCULATE([Total_Sales], PREVIOUSMONTH('processed_sales'[Order_Date])),
        0
    )
```
---

## **3️⃣ Building the Dashboard**
We need **at least two tiles**, so let’s create **two key visualizations**.

### **📌 Tile 1: Sales Distribution by Product Category**
✅ **Chart Type:** Bar Chart  
✅ **Purpose:** Shows which product categories generate the most sales.  
📌 **Steps**:  
1️⃣ Drag **Product_Category** to the X-axis  
2️⃣ Drag **Total_Sales** to the Y-axis  
3️⃣ Apply sorting by **descending order**  
4️⃣ Format with a title and labels  

🔍 **Example Insight:**  
*“Electronics contribute to 40% of total sales, making it the highest-selling category.”*

---

### **📌 Tile 2: Monthly Sales Trend Over Time**
✅ **Chart Type:** Line Chart  
✅ **Purpose:** Tracks sales growth over time.  
📌 **Steps**:  
1️⃣ Drag **Order_Date** to the X-axis  
2️⃣ Drag **Total_Sales** to the Y-axis  
3️⃣ Format the X-axis to **"Month-Year"**  
4️⃣ Add a **trendline** for better insights  

🔍 **Example Insight:**  
*“Sales peak in November and December due to Black Friday and holiday shopping.”*

---

## **4️⃣ Publishing & Sharing the Dashboard**
After creating the dashboard, we need to **share it** with stakeholders.

📌 **Steps to Publish**:  
1️⃣ Click **"Publish"** in Power BI  
2️⃣ Choose **Power BI Service (Online)**  
3️⃣ Create a **workspace** and upload your report  
4️⃣ Set up **data refresh schedule** (if using DirectQuery)  
5️⃣ Share access with **team members or stakeholders**  

✅ **Automating Refresh (Optional)**:  
- If using **Import Mode**, schedule daily/weekly refresh  
- If using **DirectQuery**, the data updates automatically  

---

## **🎯 Summary of Step 3**
✔ **Connected Power BI to BigQuery**  
✔ **Transformed data & created measures in Power BI**  
✔ **Built two visualizations (Sales by Category & Monthly Sales Trend)**  
✔ **Published and shared the dashboard**  

---

# **🚀 Next Steps**
✅ Now that the **dashboard is ready**, do you want to explore **automating Power BI refreshes** or **optimizing the data model further**? Let me know how you’d like to proceed!

# **🚀 Automating Power BI Refresh & Optimizing Data Model**  

Now that the **dashboard is built**, we’ll focus on:  
✅ **Automating Data Refresh** – Ensuring the Power BI report always has the latest data.  
✅ **Optimizing Data Model** – Improving performance and reducing query costs.

---

## **🛠️ 1️⃣ Automating Power BI Data Refresh**  

### **Option 1: Scheduled Refresh in Power BI Service (for Import Mode)**
If we **imported data** from BigQuery, we need to schedule periodic refreshes.

📌 **Steps to Enable Scheduled Refresh:**  
1️⃣ Go to **Power BI Service** → Select your **Published Report**  
2️⃣ Click on **Dataset Settings**  
3️⃣ Under **Gateway & Cloud Connection**, ensure the Google BigQuery connection is set up  
4️⃣ Enable **"Scheduled Refresh"**  
5️⃣ Set the refresh frequency (**Hourly, Daily, Weekly**)  

✅ **Best Practice:** Set refresh to **every 6-12 hours** to balance performance & cost.

---

### **Option 2: Using DirectQuery (for Real-time Updates)**
If we **used DirectQuery**, data updates automatically without needing scheduled refreshes.

✅ **Pros:**  
✔ No need for periodic refreshes.  
✔ Always fetches live data from BigQuery.  

✅ **Cons:**  
❌ Slower performance since queries run in real-time.  
❌ BigQuery costs may increase due to frequent queries.  

📌 **When to Use DirectQuery?**  
Use DirectQuery if **data needs to be updated in real-time** (e.g., stock market dashboards, live sales reports).

---

### **Option 3: Automating Refresh with Power Automate**  
For **more control over refresh timing**, we can use **Power Automate**.

📌 **Steps to Set Up Power Automate for Refresh**  
1️⃣ Go to **Power Automate** → Click **New Flow**  
2️⃣ Choose **Scheduled Cloud Flow**  
3️⃣ Select **Power BI → Refresh Dataset** action  
4️⃣ Choose the **Power BI workspace & dataset**  
5️⃣ Set **trigger schedule** (e.g., every 4 hours)  
6️⃣ Click **Save & Activate**  

✅ **Benefit**: More flexibility in scheduling refreshes (e.g., trigger refresh **only when new data is added**).

---

## **📊 2️⃣ Optimizing Power BI Data Model**  
To **improve performance and reduce costs**, we’ll optimize **data structure & queries**.

### **📌 Best Practices for Data Modeling**
✔ **Use Aggregations** – Instead of detailed raw data, pre-aggregate totals in BigQuery.  
✔ **Reduce Column Count** – Only import the **necessary fields**.  
✔ **Optimize Relationships** – Use **star schema** instead of direct table joins.  
✔ **Partition & Cluster BigQuery Tables** – Improves query speed.  

✅ **Example: Optimize a Query in BigQuery**  
Before (Inefficient Query 🛑 – Scans Entire Table):
```sql
SELECT * FROM `ecommerce_dataset.sales_data`
WHERE Order_Date BETWEEN '2024-01-01' AND '2024-03-31'
```
After (Optimized Query ✅ – Uses Partitioning & Clustering):
```sql
SELECT Order_ID, Customer_ID, Total_Price
FROM `ecommerce_dataset.sales_data`
WHERE Order_Date >= DATE_SUB(CURRENT_DATE(), INTERVAL 3 MONTH)
```
📌 **Why?**  
- Uses **partitioning** → Queries only **recent data**, reducing scan cost.  
- Limits columns → Only retrieves what Power BI needs.  

---

### **📌 Reducing Query Load on BigQuery**
Since Power BI can query BigQuery **frequently**, we need to **optimize performance**.

✅ **Strategies**:
✔ **Use Import Mode for Large Datasets** (Avoids running queries every time a user loads the dashboard).  
✔ **Cache Data in Power BI** – Reduces calls to BigQuery.  
✔ **Create Materialized Views in BigQuery** – Precompute reports for faster performance.  

---

## **🎯 Summary & Next Steps**
✔ **Enabled Automated Data Refresh** (Scheduled Refresh, DirectQuery, Power Automate).  
✔ **Optimized Power BI Data Model** (Better queries, fewer columns, aggregations).  
✔ **Reduced BigQuery Costs** (Partitioning, Materialized Views, Import Mode).  

🚀 **Next Step:**  
Would you like to set up **CI/CD automation for deploying Power BI reports** or optimize **BigQuery cost further**? Let me know how you want to proceed! 😊








