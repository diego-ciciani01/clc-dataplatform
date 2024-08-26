import sys
from awsglue.transforms import *
from awsglue.utils import getResolvedOptions
from pyspark.context import SparkContext
from awsglue.context import GlueContext
from awsglue.job import Job
import logging
from pyspark.sql import SparkSession
import os
# Recupera i parametri passati al job
args = getResolvedOptions(sys.argv, ['JOB_NAME'])

# Inizializza GlueContext e Spark
glueContext = GlueContext(SparkContext.getOrCreate())
spark = glueContext.spark_session

# Inizializza il job di Glue
job = Job(glueContext)
job.init(args['JOB_NAME'], args)

# Specifica il database e la tabella dal Glue Data Catalog
database_name = "clc-dataplatform-database-catalogs-dev"
table_name = "clc-dataplatform-table-catalogs-dev"
output_data = "s3://clc-dataplatform-datalake-silver-dev/"




"""
Questo metodo legge i dati delle canzoni da una tabella in Glue Data Catalog, esegue le trasformazioni con Spark e scrive i risultati in formato Parquet su un bucket S3.

:param spark: sessione Spark per trasformazione e warehousing dei dati.
:param glueContext: contesto Glue per interagire con Glue Data Catalog.
:param database_name: nome del database su Glue Data Catalog.
:param table_name: nome della tabella su Glue Data Catalog.
:param output_data: percorso S3 per salvare i dati trasformati.
:return: None
"""

logging.info("Reading song data from Glue Data Catalog...")
dynamic_frame = glueContext.create_dynamic_frame.from_catalog(database=database_name, table_name=table_name)
song_df = dynamic_frame.toDF()
logging.info("Reading song data completed.")

songs_table = song_df.select("songid", "title", "artistid", "year", "duration").dropDuplicates()

# Scrivi la tabella delle canzoni su S3 in formato Parquet, partizionata per anno e artista
logging.info("Writing songs table ...")
songs_table.write.mode('overwrite').partitionBy("year", "artistid").parquet(os.path.join(output_data, 'songs'))
logging.info("Writing songs table completed.")

# Estrai le colonne per creare la tabella degli artisti
artists_table = song_df.selectExpr("artistid", "artistname as name", 
                                   "artistlocation as location", 
                                   "artistlatitude as latitude", 
                                   "artistlongitude as longitude").dropDuplicates()

# Scrivi la tabella degli artisti su S3 in formato Parquet
logging.info("Writing artists table ...")
artists_table.write.mode('overwrite').parquet(os.path.join(output_data, 'artists'))
logging.info("Writing artists table completed.")


# extract columns to create album table
album_table = song_df.selectExpr("albumid","albumname", "artistid").dropDuplicates()

# write album table to parquet files
logging.info("Writing album table ... ")
album_table.write.mode('overwrite').parquet(os.path.join(output_data, 'album'))
logging.info("Writing album table completed.")

#fact table 


song_df = spark.read.parquet(os.path.join(output_data, "songs")).alias("songs")
artists_df = spark.read.parquet(os.path.join(output_data, "artists")).alias("artists")
album_df = spark.read.parquet(os.path.join(output_data, "album")).alias("album")

songplays_table = song_df \
    .join(artists_df, song_df["artistid"] == artists_df["artistid"], "leftouter") \
    .join(album_df, song_df['artistid'] == album_df["artistid"], "leftouter") \
    .selectExpr(
        "monotonically_increasing_id() as songplay_id",
        "songs.year as year",
        "songs.songid as song_id",
        "artists.artistid as artist_id",
        "songs.title as song_title",
        "songs.duration as duration",
        "artists.name as artist_name",
        "artists.location as artist_location",
        "album.albumid as album_id",
        "album.albumname as album_name"
    ).dropDuplicates()

# write songplays table to parquet files partitioned by year and month
songplays_table.write.parquet(os.path.join(output_data, "songplays"), mode='overwrite', partitionBy=["year"])

job.commit()