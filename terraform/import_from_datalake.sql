/*
this part of sql is runned on redshfit cluster using spectrum service 
that lets a data analyst conduct fast, complex analysis on objects stored on the AWS cloud 
With Redshift Spectrum, an analyst can perform SQL queries on data stored in Amazon S3 buckets.
*/
USE mydbdev;
/*create schema for album table*/
CREATE TABLE album (
    album_id BIGINT,
    album_name VARCHAR(255),
    artist_id VARCHAR(18)
);

/* import parquet table on redshift */
COPY album
FROM 's3://clc-dataplatform-datalake-silver-prod/album/part-00000-377ecfbb-1b06-4fc0-9afe-8c2ac46ce8f7-c000.snappy.parquet'
IAM_ROLE 'arn:aws:iam::359090434390:role/myRedshiftRole'
FORMAT AS PARQUET;


/*create schema for album table*/
CREATE TABLE artist (
    artist_id VARCHAR(255),
    artist_name VARCHAR(255),
    city VARCHAR(255),
    latitude VARCHAR(255),-- Aggiornato a FLOAT per corrispondere ai dati numerici
    longitude FLOAT8
);

/* import parquet table on redshift */

COPY artist
FROM 's3://clc-dataplatform-datalake-silver-prod/artists/part-00000-0e35f27a-7654-4974-87ea-1e45f23bc30c-c000.snappy.parquet'
IAM_ROLE 'arn:aws:iam::359090434390:role/myRedshiftRole'
FORMAT AS PARQUET;

/* create schema for songs */

CREATE TABLE songs (
    song_id VARCHAR(255),
    title VARCHAR(255),
    duration FLOAT8,
    year INT8,
    artist_id VARCHAR(255)
);

/* copy command to get data from parquet table */
COPY songs
FROM 's3://clc-dataplatform-datalake-silver-prod/songs/'
IAM_ROLE 'arn:aws:iam::359090434390:role/myRedshiftRole'
FORMAT AS PARQUET;

/* create schema for songplays */

CREATE TABLE songplays (
    songplays_id INT8,
    song_id VARCHAR(255),
    artist_id VARCHAR(255),
    title VARCHAR(255),
    duration FLOAT8,
    artist_name VARCHAR(255),
    artist_location VARCHAR(255),
    album_id INT8,
    album_name VARCHAR(255),
    year INTEGER
);

/* copy command to get data from parquet table */
    COPY songplays
    FROM 's3://clc-dataplatform-datalake-silver-prod/songplays/'
    IAM_ROLE 'arn:aws:iam::359090434390:role/myRedshiftRole'
    FORMAT AS PARQUET;