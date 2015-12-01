/* CSCI403
 * project 7
 */

BEGIN;

/* the raw data table.
 * data from the csv file will 
 * be imported to this table, after the select columns
 * have been extracted from the actual raw csv file with this 
 * command to strip out many unwanted columns:
 * cat 635787.csv  | cut -d ',' -f 1,2,3,4,5,6,7,17,22,27 > 635787-select_columns.csv
 */
DROP TABLE IF EXISTS wxdata_raw;
CREATE TABLE wxdata_raw 
  (
    STATION text,
    STATION_NAME text,
    ELEVATION numeric(20,10),
    LATITUDE numeric(13,10),
    LONGITUDE numeric(13,10),
    DATE date,
    PRCP numeric(20,10),
    SNOW numeric(20,10),
    TMAX numeric(20,10),
    TMIN numeric(20,10)
);

GRANT ALL ON wxdata_raw TO avanderm;
GRANT ALL ON wxdata_raw TO gciluffo;


/* this will bring in the data: */
\copy wxdata_raw FROM '635787-select_columns.csv' WITH (FORMAT 'csv', HEADER, NULL 'unknown');
\copy wxdata_raw FROM '636970.csv' WITH (FORMAT 'csv', HEADER, NULL 'unknown');
\copy wxdata_raw FROM '636973.csv' WITH (FORMAT 'csv', HEADER, NULL 'unknown');

\copy wxdata_raw FROM '643353.csv' WITH (FORMAT 'csv', HEADER, NULL 'unknown');
\copy wxdata_raw FROM '643355.csv' WITH (FORMAT 'csv', HEADER, NULL 'unknown');
\copy wxdata_raw FROM '643357.csv' WITH (FORMAT 'csv', HEADER, NULL 'unknown');
\copy wxdata_raw FROM '643358.csv' WITH (FORMAT 'csv', HEADER, NULL 'unknown');
\copy wxdata_raw FROM '643360.csv' WITH (FORMAT 'csv', HEADER, NULL 'unknown');
\copy wxdata_raw FROM '643362.csv' WITH (FORMAT 'csv', HEADER, NULL 'unknown');

/* wxstations */
DROP TABLE IF EXISTS wxstations CASCADE;
CREATE TABLE wxstations
  (
    /* stations can move location over time, they keep the same name though
     * so a serial id is used as a primary key that can then be used as
     * a foreign key */
    id serial PRIMARY KEY,

    station text,
    station_name text,
    elevation numeric(8,3), /* to thousandths of meters */
    latitude numeric(8,5),
    longitude numeric(8,5)
  );

GRANT ALL ON wxstations TO avanderm;
GRANT ALL ON wxstations TO gciluffo;

INSERT INTO wxstations 
  (station, station_name, elevation, latitude, longitude)
  (
    SELECT DISTINCT STATION, STATION_NAME, ELEVATION, LATITUDE, LONGITUDE 
    FROM wxdata_raw
  );


/* wxdata */
DROP TABLE IF EXISTS wxdata CASCADE;
CREATE TABLE wxdata 
  (
    date date,
    precipitation integer, /* tenths of mm */
    snow integer, /* mm */
    tmax integer, /* celcius in tenths */
    tmin integer, /* celcius in tenths */
    station_id integer REFERENCES wxstations(id)
  );

GRANT ALL ON wxdata TO avanderm;
GRANT ALL ON wxdata TO gciluffo;

INSERT INTO wxdata (date, precipitation, snow, tmax, tmin, station_id)
  SELECT 
    r.DATE date, r.PRCP precipitation, r.SNOW snow, r.TMAX tmax, r.TMIN tmin, w.id station_id
    FROM wxdata_raw r
    JOIN wxstations w ON
    (w.station = r.STATION)
    AND (w.elevation = r.ELEVATION)
    AND (w.latitude = r.LATITUDE)
    AND (w.longitude = r.LONGITUDE)
    ;


COMMIT;


