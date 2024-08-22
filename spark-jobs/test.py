from pyspark.sql import SparkSession

spark = SparkSession.builder.appName("SparkJobTesting").getOrCreate()

df = spark.read.csv("s3a://data/new_retail_data.csv", header=True, inferSchema=True)

df.show(5)