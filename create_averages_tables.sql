/* CSCI403: project 7 */

/* Generate tables of temperature averages (min and max) by location, season, and year.
 * The temperature averages are in a weighted format that is a positive integer, where
 * other temperature weights are comparable with each other. A min value of X is equal
 * to a max value of X.
 *
 * Tables are:
 *  wxdata_avg: the primary table giving the functionality explained above. 
 *  temperature_weights: a mapping of values found in the min & max columns for wxdata_avg
 *                       to actual temperature values (in tenths of a degree C)
 *  years: full years contained in wxdata_avg
 *  seasons: valid seasons along with their start and end months inclusive
 */

BEGIN;

   /* seasons */
   DROP TABLE IF EXISTS seasons CASCADE;
   CREATE TABLE seasons
   (
      season text PRIMARY KEY,
      begin_month_inclusive integer,
      end_month_inclusive integer
   );

   INSERT INTO seasons 
      (season, begin_month_inclusive, end_month_inclusive) 
   VALUES
      ('winter', 1, 2),
      ('spring', 4, 6),
      ('summer', 7, 9),
      ('fall', 10, 12)
   ;
   GRANT ALL ON seasons TO avanderm;
   GRANT ALL ON seasons TO gciluffo;


   /* match all temperature weights in wxdata_avg to actual temperature in tenths of a degree C */
   DROP TABLE IF EXISTS temperature_weights CASCADE;
   CREATE TABLE temperature_weights
   (
      weight integer,
      temperature integer
   );
   GRANT ALL ON temperature_weights TO avanderm;
   GRANT ALL ON temperature_weights TO gciluffo;


   /* by year and location seasonal averages */
   DROP TABLE IF EXISTS wxdata_avg CASCADE;
   CREATE TABLE wxdata_avg
   (
      latitude numeric(8,5),
      longitude numeric(8,5),
      year integer,
      season text REFERENCES seasons(season),
      min integer, /* min and max are positive weights that are proportional to temperatures */
      max integer
   );
   CREATE INDEX wxdata_avg_season_idx ON wxdata_avg (season);
   CREATE INDEX wxdata_avg_year_idx ON wxdata_avg (year);
   GRANT ALL ON wxdata_avg TO avanderm;
   GRANT ALL ON wxdata_avg TO gciluffo;

   INSERT INTO wxdata_avg
      (latitude, longitude, year, season, min, max)
      (
         SELECT DISTINCT
            x.latitude, 
            x.longitude, 
            extract(year from d.date) AS year, 
            s.season, 
            AVG(d.tmin) AS min,
            AVG(d.tmax) AS max
         FROM 
            wxdata d JOIN wxstations x ON d.station_id = x.id,
            seasons s
         WHERE 
            extract(month from d.date) BETWEEN s.begin_month_inclusive AND s.end_month_inclusive
            AND d.tmin <> -9999 AND d.tmax <> -9999 /* do not add bogus -9999 temp values */
         GROUP BY
            x.latitude,
            x.longitude,
            year,
            s.season
      )
   ;


   /* map weights to actual temperatures */

   /* find lowest actual temperature and make it weight 0 in temperature_weights */
   INSERT INTO temperature_weights (weight, temperature) 
   (
      SELECT 0 AS weight, min(min) AS temperature
      FROM wxdata_avg
   );

   /* populate the temperature_weights table with all temps in wxdata_avg */
   INSERT INTO temperature_weights (weight, temperature)
   (
      SELECT DISTINCT * FROM 
      (
         (
            SELECT 
               min + (
                  SELECT DISTINCT ABS(temperature) 
                  FROM temperature_weights 
                  WHERE weight = 0
               ) AS weight,
               min AS temperature
            FROM wxdata_avg
         ) 
         UNION
         (
            SELECT 
               max + (
                  SELECT DISTINCT ABS(temperature) 
                  FROM temperature_weights 
                  WHERE weight = 0
               ) AS weight,
               max AS temperature
            FROM wxdata_avg
         )
      ) AS t
      WHERE weight <> 0 /* 0 weight already added */
   );


   /* increase all temperatures in wxdata_avg by temperature matching weight 0.
    * this makes 0 the lowest value present in a min or max weight
    */
   UPDATE wxdata_avg SET min = min + (
      SELECT DISTINCT ABS(temperature)
      FROM temperature_weights 
      WHERE weight = 0
   );
   UPDATE wxdata_avg SET max = max + (
      SELECT DISTINCT ABS(temperature)
      FROM temperature_weights 
      WHERE weight = 0
   );


   /* years available in wxdata_avg */
   DROP TABLE IF EXISTS years CASCADE;
   CREATE TABLE years
   (
      year integer 
   );
   GRANT ALL ON years TO avanderm;
   GRANT ALL ON years TO gciluffo;

   INSERT INTO years (year)
      (
         SELECT DISTINCT year FROM wxdata_avg
      )
   ;
   

COMMIT;

