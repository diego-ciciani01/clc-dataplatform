/* select query */
SELECT * FROM "dev"."public"."album";
SELECT * FROM "dev"."public"."artist";
SELECT * FROM "dev"."public"."songplays";



/*** most popular songs over the time ***/
SELECT s.title, count(*) as count
FROM songplays sp
INNER JOIN songs s ON s.song_id = sp.song_id
GROUP BY s.title
ORDER BY count DESC, s.title ASC;


/***  most popular artists and their songs over the time ***/
SELECT ar.artist_name, s.title, count(*) as count
FROM songplays sp
INNER JOIN songs s ON s.song_id = sp.song_id
INNER JOIN artist ar ON ar.artist_id = sp.artist_id
GROUP BY ar.artist_name, s.title
ORDER BY count DESC, ar.artist_name, s.title ASC;