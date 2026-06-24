import sys
import json
import pyspark
from pyspark.sql.functions import col, collect_list, struct, array_join

from awsglue.transforms import *
from awsglue.utils import getResolvedOptions
from pyspark.context import SparkContext
from awsglue.context import GlueContext
from awsglue.job import Job

###### READ PARAMETERS
args = getResolvedOptions(sys.argv, [
        'JOB_NAME',
        'FINAL_LIST_PATH',
        'DETAILS_PATH',
        'RELATED_VIDEOS_PATH',
        'TAGS_PATH'
    ])

##### START JOB CONTEXT AND JOB
sc = SparkContext()
glueContext = GlueContext(sc)
spark = glueContext.spark_session

job = Job(glueContext)
job.init(args['JOB_NAME'], args)

#### FROM FILES
tedx_dataset_path = args['FINAL_LIST_PATH']
details_dataset_path = args['DETAILS_PATH']
tags_dataset_path = args['TAGS_PATH']
related_dataset_path = args['RELATED_VIDEOS_PATH']

#### READ INPUT FILES TO CREATE AN INPUT DATASET
tedx_dataset = spark.read \
    .option("header","true") \
    .option("quote", "\"") \
    .option("escape", "\"") \
    .csv(tedx_dataset_path)

## READ THE DETAILS
details_dataset = spark.read \
    .option("header","true") \
    .option("quote", "\"") \
    .option("escape", "\"") \
    .csv(details_dataset_path)

details_dataset = details_dataset.select(col("id").alias("id_ref"),
                                         col("description"),
                                         col("duration"),
                                         col("publishedAt"))

# JOIN WITH THE MAIN TABLE
tedx_dataset_main = tedx_dataset.join(details_dataset, tedx_dataset.id == details_dataset.id_ref, "left") \
    .drop("id_ref")

## READ TAGS DATASET
tags_dataset = spark.read.option("header","true").csv(tags_dataset_path)

# CREATE THE AGGREGATE MODEL FOR TAGS
tags_dataset_agg = tags_dataset.groupBy(col("id").alias("id_ref")).agg(collect_list("tag").alias("tags"))

tedx_dataset_agg = tedx_dataset_main.join(tags_dataset_agg, tedx_dataset.id == tags_dataset_agg.id_ref, "left") \
    .drop("id_ref")

# RELATED VIDEOS (WATCH NEXT)
related_dataset = spark.read.option("header","true").csv(related_dataset_path)

related_dataset_agg = related_dataset.groupBy(col("id").alias("id_related_ref")).agg(
    collect_list(
        struct(
            col("related_id"),
            col("title").alias("related_title"),
            col("slug").alias("related_slug"),
            col("duration").alias("related_duration")
        )
    ).alias("related_videos")
)

tedx_dataset_final = tedx_dataset_agg.join(related_dataset_agg, tedx_dataset_agg.id == related_dataset_agg.id_related_ref, "left") \
    .drop("id_related_ref") \
    .select(col("id").alias("_id"), col("*")) \
    .drop("id")


write_mongo_options = {
    "connectionName": "TEDX",
    "database": "unibg_tedx_2026",
    "collection": "tedx_data",
    "ssl": "true",
    "ssl.domain_match": "false"}

from awsglue.dynamicframe import DynamicFrame
tedx_dataset_dynamic_frame = DynamicFrame.fromDF(tedx_dataset_final, glueContext, "nested")

glueContext.write_dynamic_frame.from_options(tedx_dataset_dynamic_frame, connection_type="mongodb", connection_options=write_mongo_options)

job.commit()